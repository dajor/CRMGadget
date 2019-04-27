package gadget.sync.outgoing
{
	
	import com.adobe.rtc.pods.WebCamera;
	
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.sync.incoming.DuplicateAttachmentService;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;
	import gadget.util.SodUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;

	public class OutgoingAttachment extends OutgoingObject
	{
		
		protected var subIDour:String;
		protected var subIDsod:String;
		protected var subIDns:String;
		protected var subList:String;		
		protected var deleted:Boolean = true;
		public function OutgoingAttachment(ID:String)
		{
			super(ID);
			subIDour	= "Attachment";
			subIDsod	= SodUtils.transactionProperty("Attachment").sod_name;
			subIDns		= subIDsod.replace(/ /g,"");
			subList		= "ListOf"+subIDns;
			deleted = true;
			updated = false;
		}
		
		override protected function doRequest():void{
			
			if (deleted) {
				records = Database.attachmentDao.findDeleted(entity,faulted,PAGE_SIZE);
			} else {
				if(updated){
					records = Database.attachmentDao.findUpdate(entity,faulted,PAGE_SIZE);
				}else{
					records = Database.attachmentDao.findCreate(entity,faulted,PAGE_SIZE);
				}
					
				
				
				
			}
			if (records.length == 0) {
				
				if(deleted){
					deleted = false;
					updated = false;
				}else{
					if (updated) {
						successHandler(null);
						return;
					}else{
						updated=true;
					}
					
				}
				faulted = 0;
				doRequest();
				return;
			}
			
			var WSTag:String = WSTagExe;
			var request:XML =
				<{WSTag} xmlns={ns1}>
					<{ListOfTag}/>
				</{WSTag}>;
			
			var xml:XML = <{EntityTag} xmlns={ns1} operation='skipnode'/>;
			var subXML:XML = <{subList} xmlns={ns1}/>;
			
			
			//records= Database.attachmentDao.findAllAttachments(entity, parentRec.gadget_id);
			
			
			var isSend:Boolean = false;
			for(var i:int = 0; i < records.length; i++){
				var gadgetId:String = records[i].gadget_id;
				gadgetId = gadgetId.replace("#","");
				var parentRec:Object = null;
				try{
					parentRec = Database.getDao(entity).findByGadgetId(gadgetId);
				}catch(e:SQLError){
					//maybe set gadget id invalid
					//try to find with oracle id
					parentRec = Database.getDao(entity).findByOracleId(gadgetId);
				}
				if(parentRec==null){
					Database.attachmentDao.deleteAttachment(records[i]);
					continue;
				}else{
					var att:Object = records[i];
					if(att.filename == 'temp.tmp'){
						Database.attachmentDao.deleteAttachment(records[i]);
						continue;
					}
					
				}
				
				var operation:String = StringUtils.isEmpty(records[i].AttachmentId)?'insert':'update';
				if(records[i].deleted){							
					operation = 'delete'						
						
				}
				
				
				isSend = true;
				var attXml:XML = Utils.instanceAttachmentXML(records[i], operation);
				if(records[i].deleted){
					attXml.appendChild(<Id>{records[i].AttachmentId}</Id>);
				} 
				
				subXML.appendChild(attXml);
			}
		
			var sodid:String  = DAOUtils.getOracleId(entity);
			var parentId:String = parentRec[sodid];
			if(parentId.indexOf("#")!=-1){//parent object hasbeen error
				records[0].error = true;
				faulted++;
				isSend = false;
			}
			var ws20field:String = WSProps.ws10to20(entity,sodid);
			xml.appendChild(
				<{ws20field}>{parentRec[sodid]}</{ws20field}>
			);
			
			xml.appendChild(subXML);
			request.child(Q1ListOf)[0].appendChild(xml);
			
			
			if(isSend){
				sendRequest(URNexe,request);
			}else{
				doRequest();
			}
			
			
		}
		
		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean{
			if (faultString.indexOf("(SBL-DAT-00382)")>=0 ||
				faultString.indexOf("SBL-DAT-00381")>=0) {
				var gadgetId:String = records[0].gadget_id;
				gadgetId = gadgetId.replace("#","");
				var parentRec:Object = null;
				try{
					parentRec = Database.getDao(entity).findByGadgetId(gadgetId);
				}catch(e:SQLError){
					//maybe set gadget id invalid
					//try to find with oracle id
					parentRec = Database.getDao(entity).findByOracleId(gadgetId);
				}
				var sodid:String  = DAOUtils.getOracleId(entity);
				
				new DuplicateAttachmentService(entity,parentRec[sodid],doRequest).start();
				faulted++;
				return true;
			}
			
			return super.handleRequestFault(soapAction,request,response,faultString,xml_list,event);
			
			
		}
		
		
		override protected function handleResponse(request:XML, result:XML):int{
			
			var i:int = 0;
			for each (var data:XML in result.child(Q2ListOf)[0].child(Q2Entity)) {
				var xmllist:XMLList = data.child(new QName(ns2.uri,subList));
				if (xmllist.length()==0)
					return 0;
				for each(var attachment:XML in xmllist[0].child(new QName(ns2.uri,subIDns))){
					
					if(records[i].deleted){
						Database.attachmentDao.deleteAttachment(records[i]);
					}else{
						var object:Object = new Object();
						object.entity = entity;
						object.gadget_id = records[i].gadget_id;
						object.filename = records[i].filename;	
						object.updated = false;
						object.deleted = false;
						var attachId:String = attachment.ns2::Id[0].toString();
						object.AttachmentId = attachId;
						Database.attachmentDao.updateAttachmentID(object);
					}					
					i += 1;
				
				}
				
				
			}
			_nbItems += i;
			countHandler(_nbItems);
			doRequest();
			return i;
		}
		
		override public function getEntityName():String { return entity+subIDsod; }
		
		
	}
}