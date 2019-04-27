package gadget.sync.incoming
{
	import flash.events.IOErrorEvent;
	
	import gadget.dao.Database;
	import gadget.dao.IncomingSyncDAO;
	import gadget.dao.SubobjectTable;
	import gadget.i18n.i18n;
	import gadget.sync.WSProps;
	import gadget.sync.task.TaskParameterObject;
	import gadget.util.SodUtils;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class IncomingAttachment extends IncomingSubBase
	{
		private var fixId:String = null;

		public function IncomingAttachment(ID:String) {
			noPreSplit = true;
			super(ID, "Attachment");
		}

		override protected function tweak_vars():void {
			entityIDId = SodUtils.transactionProperty(entityIDour).ws20att_id;
			
			super.tweak_vars();

			if (stdXML == null) {
				stdXML =
					<{wsID} xmlns={ns1.uri}>
						<ViewMode>{viewMode}</ViewMode>
						<{listID} pagesize={pageSize} startrownum={ROW_PLACEHOLDER}>
							<{entityIDns} searchspec={PARENT_SEARCH_SPEC} >
								<ListOfAttachment pagesize={SUB_PAGE_SIZE} startrownum={SUBROW_PLACEHOLDER}>
									<Attachment searchspec={SEARCHSPEC_PLACEHOLDER}>
										<Id/>
										<{entityIDId}/>
										<DisplayFileName/>
										<FileNameOrURL/>
										<FileExtension/>
										<Attachment/>
										<ModifiedDate/>
									</Attachment>
								</ListOfAttachment>
							</{entityIDns}>
						</{listID}>
					</{wsID}>
				;
				}
		}
		
		// VAHI: This is a copy from gadget.incoming.IncomingInterface, which was a changed version of Utils.incomingAttachment.
		override protected function importRecord(entity:String, data:XML, googleListUpdate:ArrayCollection=null):int {
			var pid:String = data.child(new QName(ns2.uri,entityIDId))[0].toString();
			var parent:Object = Database.getDao(entityIDour).findByOracleId(pid);
			if (parent==null) {
				// The parental record is missing.
				// This is due a wrong reference design,
				// the attachment must be referenced by Siebel RowId,
				// instead of gadget_id
//				failErrorHandler(i18n._('{1} with Id {2} missing, cannot continue', entityIDour, pid));
				return 0;
			}
			var gadget_id:String = parent.gadget_id;
			
			var attachId:String = data.ns2::Id[0].toString();
			//VAHI is this right only to check for the RowID?  I hope so.
			// (traditionally Siebel attachments cannot be updated, only delete+create with a new RowID)
//			if (Database.attachmentDao.findByOracleId(attachId,entityIDour)==null){
				var xmllist:XMLList = data.ns2::Attachment;
				if (xmllist.length() > 0) {
					var obj:Object = new Object();
					obj.data = StringUtils.decodeStringToByteArray(xmllist[0].toString());
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
					obj.filename = data.ns2::DisplayFileName[0].toString();
					//Bug 5792 CRO
					//remove checking extension  if filename has dot, it is not working ex: Test_12.2013
					//if( StringUtils.getExtension(String(obj.filename)) == "" ) {
						obj.filename = obj.filename + "." + data.ns2::FileExtension[0].toString();
					//}
					if(obj.filename == 'temp.tmp'){
						return 0;
					}
					// GET Attacment Id do it later
					obj.AttachmentId = attachId;
					obj.updated = false;
					obj.deleted = false;
					trace('ATT',entityIDour, attachId, obj.filename);
					//Database.attachmentDao.insert(obj);
					Database.attachmentDao.replaceAttachment(obj,false);
					_nbItems++;
				}
//			}
			return 1;
		}

		override public function getTransactionName():String { return getParentTransactionName(); }
	}
}