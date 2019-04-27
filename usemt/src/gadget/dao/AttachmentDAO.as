package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class AttachmentDAO extends SimpleTable {
		
		private var stmtFind:SQLStatement;
		private var stmtFindAll:SQLStatement;
		private var stmtFindCreate:SQLStatement;
		private var stmtFindDeleted:SQLStatement;
		private var stmtFindUpdate:SQLStatement;
		private var stmtDeleteByFileName:SQLStatement;
		
		private  const structure:Object = {
			table:"attachment",
			name_column: [ 'filename' ],
			unique : ["entity, gadget_id, filename"],
			columns: {
				'TEXT' : [ 'entity','gadget_id', 'filename', 'AttachmentId' ],
				'BLOB':['data'],
				'BOOLEAN':['include_in_report','deleted','updated'] //CRO bug fixing 59 02.02.2011
				
			}
		};
		
		
		
		
		public function AttachmentDAO(sqlConnection:SQLConnection, work:Function) {	
			
			super(sqlConnection, work, structure);
			DAOUtils.register(this.entity, structure);
			
			stmtDeleteByFileName  = new SQLStatement();
			stmtDeleteByFileName.sqlConnection = sqlConnection;
			stmtDeleteByFileName.text = "delete FROM attachment WHERE gadget_id = :gadget_id  AND filename like :filename";
			
			stmtFindAll = new SQLStatement();
			stmtFindAll.sqlConnection = sqlConnection;
			stmtFindAll.text = "SELECT '" + entity + "' gadget_type, * FROM attachment WHERE entity = :entity AND gadget_id = :gadget_id ORDER BY filename";
			
			
			
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT '" + entity + "' gadget_type, * FROM attachment WHERE entity = :entity AND (deleted=false OR deleted is null) AND gadget_id = :gadget_id AND AttachmentId is null ORDER BY filename";
			
			stmtFindCreate = new SQLStatement();
			stmtFindCreate.sqlConnection = sqlConnection;
			stmtFindCreate.text = "SELECT '" + entity + "' gadget_type, * FROM attachment WHERE entity = :entity AND (deleted=false OR deleted is null)  AND AttachmentId is null LIMIT :limit OFFSET :offset";
			
			stmtFindDeleted = new SQLStatement();
			stmtFindDeleted.sqlConnection = sqlConnection;
			stmtFindDeleted.text = "SELECT '" + entity + "' gadget_type, * FROM attachment WHERE entity = :entity AND deleted=true   AND AttachmentId is not null LIMIT :limit OFFSET :offset";
			
			
			stmtFindUpdate = new SQLStatement();
			stmtFindUpdate.sqlConnection = sqlConnection;
			stmtFindUpdate.text = "SELECT '" + entity + "' gadget_type, * FROM attachment WHERE entity = :entity AND deleted=false  AND updated = true   AND AttachmentId is not null LIMIT :limit OFFSET :offset";
			
			
			
		}
		
		 
//		public function updateOrInsertAttachmentByNameEntityAndGadgetId(obj:Object):void{
//			var exist:Array = fetch({'entity':obj.entity,'gadget_id':obj.gadget_id,'filename':obj.filename});
//			if(exist!=null && exist.length>0){
//				obj['AttachmentId'] = exist[0]['AttachmentId'];
//				updateAttachmentID(obj);
//				
//			}else{
//				insert(obj);
//			}
//			
//		}
		public function deleteByFileName(fileName:String,gadget_id:String):void{
			
			stmtDeleteByFileName.parameters[":filename"] = fileName+"%";
			stmtDeleteByFileName.parameters[":gadget_id"] = gadget_id;
			exec(stmtDeleteByFileName);
			
		}
		
		public function findUpdate(entity:String,offset:int,limit:int):ArrayCollection{
			stmtFindUpdate.parameters[":entity"] = entity;
			stmtFindUpdate.parameters[":offset"] = offset;
			stmtFindUpdate.parameters[":limit"] = limit;
			exec(stmtFindUpdate);
			return new ArrayCollection(stmtFindUpdate.getResult().data);
			
		}
		
		public function selectAttachment(entity:String, gadget_id:String):ArrayCollection {
			var tmpResult:Array = fetch({'entity':entity,'gadget_id':gadget_id});
			var result:ArrayCollection = new ArrayCollection();
			for each( var o:Object in tmpResult){
				if(o.deleted){
					continue;
				}
				result.addItem(o);
			}
			
			//return new ArrayCollection(fetch({'entity':entity,'gadget_id':gadget_id,'deleted':false}));
			return result;
			
		}
		
		public function get entity():String{
			return "Attachment";
		}
		public function findCreate(entity:String, offset:int, limit:int):ArrayCollection{
			stmtFindCreate.parameters[":entity"] = entity;
			stmtFindCreate.parameters[":offset"] = offset;
			stmtFindCreate.parameters[":limit"] = limit;
			exec(stmtFindCreate);
			return new ArrayCollection(stmtFindCreate.getResult().data);
		}
		public function findDeleted(entity:String,offset:int, limit:int):ArrayCollection{
			stmtFindDeleted.parameters[":entity"] = entity;
			stmtFindDeleted.parameters[":offset"] = offset;
			stmtFindDeleted.parameters[":limit"] = limit;
			exec(stmtFindDeleted);
			return new ArrayCollection(stmtFindDeleted.getResult().data);
		}
		
		
		
		public function updateAttachmentID(attachment:Object):void {
			update(attachment, {entity:attachment.entity,gadget_id:attachment.gadget_id,filename:attachment.filename} );
		}
		
		public function findByOracleId(oracleId:String,entity:String):Object {
			var result:Array = fetch({AttachmentId:oracleId,'entity':entity});
			return result.length == 0?null:result[0]; 
		}
		
		public function findAttachments(entity:String, gadget_id:String):ArrayCollection {			
			stmtFind.parameters[":entity"] = entity;
			stmtFind.parameters[":gadget_id"] = gadget_id;
			exec(stmtFind);
			return new ArrayCollection(stmtFind.getResult().data);
		}
		
		
		
		
		public function replaceAttachment(obj:Object,updated:Boolean=true):void {
			var exist:Array = fetch({'entity':obj.entity,'gadget_id':obj.gadget_id,'filename':obj.filename});
			if(exist!=null && exist.length>0){
				obj['AttachmentId'] = obj.AttachmentId==null?exist[0]['AttachmentId']:obj.AttachmentId;
				if(obj.data==null){
					obj.data = exist[0].data;
				}
				obj['updated'] = updated;
				obj['deleted']=false;
				updateAttachmentID(obj);
				
			}else{
				obj['updated'] = false;
				insert(obj);
			}
		}
		public function findAllAttachments(entity:String, gadget_id:String):ArrayCollection{
			stmtFindAll.parameters[":entity"] = entity;
			stmtFindAll.parameters[":gadget_id"] = gadget_id;
			exec(stmtFindAll);
			return new ArrayCollection(stmtFindAll.getResult().data);
		}
		
		public function deleteTemp(attachment:Object):void{
			if(attachment.AttachmentId==null || attachment.AttachmentId==''){
				deleteAttachment(attachment);
			}else{
				attachment.deleted=true;
				updateAttachmentID(attachment);	
			}
		
		}
		public function deleteAttachment(attachment:Object):void{
			delete_({"entity":attachment.entity,"gadget_id":attachment.gadget_id,"filename":attachment.filename});
		}
		public function deleteAttachmentByAttId(id:String,entity:String):void{
			delete_({"entity":entity,"AttachmentId":id});
		}
		public function deleteByGadgetId(parentId:String):void{
			delete_({"gadget_id":parentId});
		}
		
	}
	
}