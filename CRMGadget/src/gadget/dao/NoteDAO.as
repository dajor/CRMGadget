// semi-automatically generated from Note.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	public class NoteDAO extends BaseDAO {

		
//		private var stmtFind:SQLStatement;
//		private var stmtFindAll:SQLStatement;
//		private var stmtFindCreate:SQLStatement;
//		private var stmtFindDeleted:SQLStatement;
		public function NoteDAO(sqlConnection:SQLConnection, work:Function) {
			var structure:Object ={
				table: 'note',
				oracle_id: 'Id',
				must_drop :true,
				name_column: [ 'Subject' ],	//___EDIT__THIS___
				search_columns: [ 'Subject' ],
				display_name : "Note",	//___EDIT__THIS___
				index: [ 'Id','ParentNoteId','Subject' ],
				unique : ["ParentNoteId,Id"],
				columns: { 'TEXT' : textColumns }
			};
			super(work,sqlConnection, structure);
			
			
//			DAOUtils.register(this.entity, structure);
//			stmtFindAll = new SQLStatement();
//			stmtFindAll.sqlConnection = sqlConnection;
//			stmtFindAll.text = "SELECT '" + entity + "' gadget_type, * FROM note WHERE entity = :entity AND gadget_id = :gadget_id ORDER BY filename";
//			
//			stmtFind = new SQLStatement();
//			stmtFind.sqlConnection = sqlConnection;
//			stmtFind.text = "SELECT '" + entity + "' gadget_type, * FROM note WHERE entity = :entity AND (deleted=false OR deleted is null) AND gadget_id = :gadget_id AND Id is null ORDER BY filename";
//			
//			stmtFindCreate = new SQLStatement();
//			stmtFindCreate.sqlConnection = sqlConnection;
//			stmtFindCreate.text = "SELECT '" + entity + "' gadget_type, * FROM note WHERE entity = :entity AND (deleted=false OR deleted is null)  AND Id is null LIMIT :limit OFFSET :offset";
//			
//			stmtFindDeleted = new SQLStatement();
//			stmtFindDeleted.sqlConnection = sqlConnection;
//			stmtFindDeleted.text = "SELECT '" + entity + "' gadget_type, * FROM note WHERE entity = :entity AND deleted=true   AND Id is not null LIMIT :limit OFFSET :offset";
			
		}
/*
		override protected function get sortColumn():String {
			return "Subject";	//___EDIT__THIS___
		}
*/		
		override public function get entity():String {
			return "Note";
		}
		
		
//		public function findCreate(entity:String, offset:int, limit:int):ArrayCollection{
//			stmtFindCreate.parameters[":entity"] = entity;
//			stmtFindCreate.parameters[":offset"] = offset;
//			stmtFindCreate.parameters[":limit"] = limit;
//			exec(stmtFindCreate);
//			return new ArrayCollection(stmtFindCreate.getResult().data);
//		}
//		public function findDeleted(entity:String,offset:int, limit:int):ArrayCollection{
//			stmtFindDeleted.parameters[":entity"] = entity;
//			stmtFindDeleted.parameters[":offset"] = offset;
//			stmtFindDeleted.parameters[":limit"] = limit;
//			exec(stmtFindDeleted);
//			return new ArrayCollection(stmtFindDeleted.getResult().data);
//		}
//		
//		
//		
//		public function updateNoteByID(note:Object):void {
//			update(note, {entity:note.entity,gadget_id:note.gadget_id,Id:note.Id} );
//		}
//		
//		public function findByOracleId(oracleId:String,entity:String):Object {
//			var result:Array = fetch({Id:oracleId,'entity':entity});
//			return result.length == 0?null:result[0]; 
//		}
//		
//		public function findNotes(entity:String, gadget_id:String):ArrayCollection {			
//			stmtFind.parameters[":entity"] = entity;
//			stmtFind.parameters[":gadget_id"] = gadget_id;
//			exec(stmtFind);
//			return new ArrayCollection(stmtFind.getResult().data);
//		}
//		
//		
//		
//		
//		public function replaceAttachment(attachment:Object):void {
//			replace(attachment);
//		}
//		public function findAllNotes(entity:String, gadget_id:String):ArrayCollection{
//			stmtFindAll.parameters[":entity"] = entity;
//			stmtFindAll.parameters[":gadget_id"] = gadget_id;
//			exec(stmtFindAll);
//			return new ArrayCollection(stmtFindAll.getResult().data);
//		}
//		
//		public function deleteTemp(note:Object):void{
//			if(note.Id==null || note.Id==''){
//				deleteNote(note);
//			}else{
//				note.deleted=true;
//				updateNoteByID(note);	
//			}
//			
//		}
//		public function deleteNote(note:Object):void{
//			delete_({"entity":note.entity,"gadget_id":note.gadget_id,"Id":note.Id});
//		}
//		public function deleteNoteByNoteId(id:String,entity:String):void{
//			delete_({"entity":entity,"Id":id});
//		}
//		public function deleteByGadgetId(parentId:String):void{
//			delete_({"gadget_id":parentId});
//		}
		
		
		private var textColumns:Array = [			
			"CreatedBy",
			"CreatedByAlias",
			"CreatedByEMailAddr",
			"CreatedByExternalSystemId",
			"CreatedById",
			"CreatedByIntegrationId",
			"CreatedByUserSignInId",
			"CreatedDate",
			"Id",
			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"Note",
			"OwnerAlias",
			"OwnerId",
			"ParentNoteId",
			"Private",
			"ReadFlag",
			"SourceId",
			"SourceName",
			"SourceType",
			"Subject",
			"UpdatedByAlias",
			"UpdatedByEMailAddr",
			"UpdatedByExternalSystemId",
			"UpdatedByFirstName",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			];
	}
}
