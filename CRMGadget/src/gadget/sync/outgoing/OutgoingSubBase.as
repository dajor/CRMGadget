package gadget.sync.outgoing
{
	
	
	
	
	import com.adobe.utils.StringUtil;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import gadget.dao.ActivityContactDAO;
	import gadget.dao.ActivityUserDAO;
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.i18n.i18n;
	import gadget.service.SupportService;
	import gadget.sync.WSProps;
	import gadget.sync.task.ReferenceUpdater;
	import gadget.util.FieldUtils;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	import org.purepdf.pdf.forms.PushbuttonField;

	public class OutgoingSubBase extends OutgoingObject
	{
		protected var subIDour:String;
		protected var subIDsod:String;
		protected var subIDns:String;
		protected var subList:String;
		protected var subIDId:String;
		protected var subDao:SupportDAO;
		
		protected var deleted:Boolean=true;
		protected var oper:String = "";
		protected var subFields:ArrayCollection;
		public function OutgoingSubBase(ID:String, subId:String)
		{
			super(ID);
			subIDour	= subId;
			var objSod:SodUtilsTAO = SodUtils.transactionProperty(subId);
			if(objSod!=null){
				subIDsod	= objSod.sod_name;
			}else{
				subIDsod = subId;
			}
			if(ID == Database.opportunityDao.entity && subId == Database.productDao.entity){
				subIDsod = subIDsod + "Revenue";
				
			}else if((ID == Database.contactDao.entity||ID==Database.accountDao.entity)  && subId == "Related"){
				subIDsod = subIDsod + ID;
			}else if(ID == Database.contactDao.entity && "Custom Object 2" == subIDsod){
				subIDsod = "CustomObject2";
			}
			if(subIDsod==null){
				subIDsod = subId;
			}
			
			subIDns		= subIDsod.replace(/ /g,"");
			
			subList		= "ListOf"+subIDns;
			
			subDao= SupportRegistry.getSupportDao(entity, subId);
			
			if(subDao==null){
				subDao = Database[SodUtils.transactionProperty(subId).dao];
			}
		
			subIDId		=  DAOUtils.getOracleId(subDao.entity);;
			NameCols = DAOUtils.getNameColumns(subDao.entity);	
			
			
		}
		
		override protected function getDao():BaseDAO{
			return this.subDao;
		}
		
		override protected function doRequest():void{
			if(deleted){
				records = subDao.findDeleted(faulted,PAGE_SIZE);
			}else{
				if (updated) {
					records = subDao.findUpdated(faulted, PAGE_SIZE);
				} else {
					records = subDao.findCreated(faulted, PAGE_SIZE);
				}
			}
			
			if(deleted){				
				oper = "delete";
				
			}else{
				oper = updated ? 'update' : 'insert';
			}
			
			
			
			if (records.length == 0) {
				
				if(deleted){
					deleted = false;
					faulted = 0;
				}else{	
					if (updated) {
						successHandler(null);
						return;
					}
						updated = true;				
				}	
				faulted = 0;
				doRequest();
				return;
			}
			
			
			if(oper=='insert'){
				var parentId:String=''
				//right now we send only one record per request
				if(subIDour=='Team' && entity==Database.businessPlanDao.entity){
					parentId = records[0]['ParentId'];
				}else{
					parentId = records[0][SodID];
				}
				
				//ignore sub if the parent recode cannot sync.
				if(parentId==null || parentId.indexOf('#')!=-1){
					faulted++;
					doRequest();
					return;
				}
				
				if(getDao() is ActivityContactDAO){
					var contactId:String = records[0]['Id'];
					if(StringUtils.isEmpty(contactId)){					
						faulted++;
						doRequest();
						return;
					}
				}
				
			}
			
			var WSTag:String = WSTagExe;
			var request:XML =
				<{WSTag} xmlns={ns1}>
					<{ListOfTag}/>
				</{WSTag}>;
			
			var xml:XML = <{EntityTag} xmlns={ns1} operation='skipnode'/>;
			var subXML:XML = <{subList} xmlns={ns1}/>;
			
			for(var i:int = 0; i < records.length; i++){
				var tmp:XML = <{subIDsod} operation={oper}/>;
				if(oper == "delete"){
					
					var pf:String = WSProps.ws10to20(entity,SodID);
					if(subIDour=='Team' && entity==Database.businessPlanDao.entity){
						xml.appendChild(
							<{pf}>{StringUtils.unNull(records[i]['ParentId'])}</{pf}>
						);
					}else{
						xml.appendChild(
							<{pf}>{StringUtils.unNull(records[i][SodID])}</{pf}>
						);
					}
					
					if("DummySiebelRowId" == subIDId){
						subIDId = "Id";
					}
					tmp.appendChild(<{subIDId}>{StringUtils.unNull(records[i][subIDId])}</{subIDId}>);
					
				}else{
					var ingnoreFields:Dictionary = subDao.outgoingIgnoreFields;
					var addParentField:Boolean = false;
					for each (var field:Object in allFields) {
						var name:String = field.element_name;
						if (name=="DummySiebelRowId")
							continue;
						//if (obj[name] == null) continue;
						var val:String = StringUtils.unNull(records[i][name]);
						
						if (oper=='insert') {
							if (name==subIDId || val=='')
								continue;
							//warningHandler(_("trying to fix NULL value in {1} subrecord {2}", entity, sub), null);
						}
						
						if(subIDour=='Team' && entity==Database.businessPlanDao.entity){
							if('ParentId'==name){
								addParentField = true;
								var ws20field:String = WSProps.ws10to20(entity,SodID);
								xml.appendChild(
									<{ws20field}>{val}</{ws20field}>
								);
							}
						}else{
							if(SodID==name){
								addParentField = true;
								var ws20field:String = WSProps.ws10to20(entity,SodID);
								xml.appendChild(
									<{ws20field}>{val}</{ws20field}>
								);
							}
						}
						
						if(ingnoreFields.hasOwnProperty(name)) continue;
						
						tmp.appendChild(<{name}>{ensureData(val)}</{name}>);
					}
					if(!addParentField){
						var ws20field:String = WSProps.ws10to20(entity,SodID);
						xml.appendChild(
							<{ws20field}>{StringUtils.unNull(records[i][SodID])}</{ws20field}>
						);
					}
				}
				
				subXML.appendChild(tmp);
				
				xml.appendChild(subXML);
				request.child(Q1ListOf)[0].appendChild(xml);
			}
			
			
 			sendRequest(URNexe,request);

		}
		
		protected function get allFields():ArrayCollection{
			if(subFields==null || subFields.length<1){
				if(subDao is ActivityUserDAO){
					subFields = SupportService.getFields(subDao.entity);
				}else{			
					subFields = FieldUtils.allFields(subDao.entity);
				}
			}
			return subFields;
		}
		
		override protected function getOperation():String{
			return oper=="insert"?"Created":oper=="update"?"Updated":"deleted";
		}
		
		override protected function getOracleIdField():String{
			return subIDId;
		}
		
		override protected function handleResponse(request:XML, result:XML):int{
			var i:int = 0;
			if(oper=="delete"){
				subDao.delete_(records[0]);
				i++;
			}else{
				for each (var data:XML in result.child(Q2ListOf)[0].child(Q2Entity)) {
					var xmllist:XMLList = data.child(new QName(ns2.uri,subList));
					if (xmllist.length()==0)
						return 0;
					
					for each (var subrec:XML in xmllist[0].child(new QName(ns2.uri,subIDns))) {
						
						var changed:Boolean = false;										
						
						var rec:Object = records[i];
						
						changed = subDao.fix_sync_outgoing(rec);
						
						for each (var fieldObj:Object in FieldUtils.allFields(subDao.entity)) {
							var col:String = fieldObj.element_name;
							var field:XMLList = subrec.child(new QName(ns2.uri,col));
							if (field.length()>0) {
								
								var upd:String = field[0].toString();
								var old:String = rec[col];
								
								//if (upd==old) continue;
								
								changed = true;
								if (col==subIDId) {
									ReferenceUpdater.updateReferences(subDao.entity, old, upd);
								}
								rec[col] = upd;
							}
						}
						i++;
						if (changed) {
							rec.deleted = false;
							rec.local_update = null;
							rec.error = false;
							subDao.update(rec);
						}
						
					}
				}
			}
			
			_nbItems += i;
			countHandler(_nbItems);
			doRequest();
			return i;
	}
		
		override public function getEntityName():String {
			return subDao.entity;
		}
		
		override public function getName():String {
			return i18n._("Sending {1} data to server...", subDao.entity); 
		}
		
		override public function getMyClassName():String {
			return getQualifiedClassName(this) + subDao.entity;
		}			
		
		
		
	}
}