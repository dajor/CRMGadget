package gadget.sync.incoming
{
	import flash.events.Event;
	
	import gadget.dao.Database;
	import gadget.sync.outgoing.DeleteAttachment;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class DuplicateAttachmentService extends IncomingAttachment
	{
		private var _end:Function;
		
		public function DuplicateAttachmentService(ID:String,pid:String,end:Function)
		{
			super(ID);
			this.pid = pid;
			this._end = end;
			stdXML =
				<{wsID} xmlns={ns1.uri}>
					<ViewMode>{viewMode}</ViewMode>
					<{listID} pagesize={pageSize} startrownum={ROW_PLACEHOLDER}>
						<{entityIDns} searchspec={SEARCHSPEC_PLACEHOLDER} >
							<ListOfAttachment pagesize={SUB_PAGE_SIZE} startrownum={SUBROW_PLACEHOLDER}>
								<Attachment>
									<Id/>
									<{entityIDId}/>
									<DisplayFileName/>
									<FileNameOrURL/>
									<FileExtension/>									
									<ModifiedDate/>
								</Attachment>
							</ListOfAttachment>
						</{entityIDns}>
					</{listID}>
				</{wsID}>
			;
			
			
			
		}
		
		
		override protected function doRequest():void {
			var dateSpec:String = "[Id] = \'"+pid+"\'";
			var pagenow:int = _page;
			var subpagenow:int = _subpage;
			
			isLastPage = false;
			var tmpXML:String = getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, pagenow*pageSize)
				.replace(SUBROW_PLACEHOLDER, subpagenow*SUB_PAGE_SIZE)
				.replace(SEARCHSPEC_PLACEHOLDER,dateSpec);			
			
			sendRequest("\""+getURN()+"\"", new XML(tmpXML));
		}
		
		
		protected function doCountHandler(task:WebServiceBase, nbItems:int):void {
			//todolater
		}
		protected function doTaskEventHandler(task:WebServiceBase, remote:Boolean, type:String, name:String, action:String):void {
			//todo later
		}
		
		protected function doTaskSuccess(task:WebServiceBase, result:String):void {
			trace(result);
			
		}
		protected function errorHandler(task:WebServiceBase, error:String, event:Event,recode_err:Object=null):void {
			trace(error);
		}
		
		protected function warningHandler(warning:String, event:Event,recorde_error:Object=null):void{
			trace(warning);
		}
		
		public function start():void{
			
			var p:TaskParameterObject = new TaskParameterObject(this);
			
			
			p.preferences		= Database.preferencesDao.read();
			p.setErrorHandler =errorHandler;	
			p.setCountHandler=doCountHandler;
			p.setSuccessHandler=doTaskSuccess;
			p.setEventHandler=doTaskEventHandler;	
			p.setWarningHandler = warningHandler; 
			p.waiting			= true;
			p.finished			= true;
			p.running			= false;
			this.param			= p;
			initOnce();
			doRequest();
		}
		
		
		override protected function nextSubPage(lastPage:Boolean, lastSubPage:Boolean):void {
			
			if (!lastSubPage) {
//				showCount();
				_subpage++;		//VAHI yes, this might overcount
				doRequest();
				return;
			}
			_end();
		}
		
		// VAHI: This is a copy from gadget.incoming.IncomingInterface, which was a changed version of Utils.incomingAttachment.
		override protected function importRecord(entity:String, data:XML, googleListUpdate:ArrayCollection=null):int {
//			var pid:String = data.child(new QName(ns2.uri,entityIDId))[0].toString();
			var parent:Object = Database.getDao(entityIDour).findByOracleId(pid);			
			var gadget_id:String = parent.gadget_id;
			var attachId:String = data.ns2::Id[0].toString();
			var attachName:String =  data.ns2::DisplayFileName[0].toString();
			var ext:String = data.ns2::FileExtension[0].toString();
			if(attachName == 'temp' && ext =='tmp'){
				new DeleteAttachment(entityIDour,pid,attachId).start();
				return 0;
			}
			//VAHI is this right only to check for the RowID?  I hope so.
			// (traditionally Siebel attachments cannot be updated, only delete+create with a new RowID)
			if (Database.attachmentDao.findByOracleId(attachId,entityIDour)==null){
//				var xmllist:XMLList = data.ns2::Attachment;
//				if (xmllist.length() > 0) {
					var obj:Object = new Object();
					//obj.data = StringUtils.decodeStringToByteArray(xmllist[0].toString());
					obj.entity = entityIDour;
					obj.gadget_id = gadget_id;
					
					/*
					0/
					the attachment table should be change its primary key. we will use (entity,gadget_id and filename with extension) as the primary key.
					
					1/Incoming attachment file
					Check if displayfilename has an extension, then we remove it. (to handle the files that have been uploaded since the old version)
					In order to open file, we need both filename and fileextension
					We compare 3 fields (entity, gadget_id and filename) if it exists, we do update, otherwise, we do insert.
					
					2/Outgoing attachment file
					we have to split the filename and the extension before sending to siebel
					
					*/
					obj.filename = attachName;
					if( StringUtils.getExtension(String(obj.filename)) == "" ) {
						obj.filename = obj.filename + "." + ext;
					}
					// GET Attacment Id do it later
					obj.AttachmentId = attachId;					
					trace('ATT',entityIDour, attachId, obj.filename);
					//Database.attachmentDao.insert(obj);
					Database.attachmentDao.replaceAttachment(obj);
					dicCount.count(attachId);
//				}
			}
			return 1;
		}
		
		
	}
}