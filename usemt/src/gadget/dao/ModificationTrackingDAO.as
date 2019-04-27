// semi-automatically generated from CRMODLS_ModificationLog.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class ModificationTrackingDAO extends BaseDAO {

		
		private var stmtProcess:SQLStatement;
		private var stmtFindRemoveChild:SQLStatement;
		private var stmtFindChildUpdate:SQLStatement;
		public function ModificationTrackingDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'sod_modificationtracking',
				oracle_id: 'Id',
				name_column: [ 'Id' ],	//___EDIT__THIS___
				search_columns: [ 'Id' ],
				display_name : "ModificationTracking",	//___EDIT__THIS___
				index: [ 'Id' ],
				columns: { 'TEXT' : textColumns }
			});
			
			// statement for setting the processed field
			stmtProcess = new SQLStatement();
			stmtProcess.sqlConnection = sqlConnection;
			stmtProcess.text = "UPDATE sod_modificationtracking SET processed = 1 WHERE processed IS NULL AND ObjectName = :ObjectName AND ObjectId = :ObjectId";	
			stmtFindRemoveChild = new SQLStatement();
			stmtFindRemoveChild.sqlConnection = sqlConnection;
			stmtFindRemoveChild.text = "SELECT ObjectId from sod_modificationtracking where ObjectName = :ObjectName AND ( EventName ='RestoreRecord' OR (EventName IN('PreDeleteRecord','WriteRecordNew') AND ChildId IS NOT NULL AND ChildId !=''))";
			
			stmtFindChildUpdate = new SQLStatement();
			stmtFindChildUpdate.sqlConnection = sqlConnection;
			stmtFindChildUpdate.text = "SELECT ObjectId,ChildId from sod_modificationtracking where ObjectName = :ObjectName AND ChildName = :ChildName AND ( EventName IN('Associate','WriteRecordUpdated','RestoreRecord','WriteRecordNew') AND ChildId IS NOT NULL AND ChildId !='')";
		}

		override public function get entity():String {
			return "ModificationTracking";
		}
		protected override function getIndexColumns():Array{
			return ["deleted", "local_update"];			
			
		}
		private var textColumns:Array = [
			"ChildId",
			"ChildName",
			"CreatedBy",
			"CreatedByAlias",
			"CreatedByEMailAddr",
			"CreatedByExternalSystemId",
			"CreatedByFirstName",
			"CreatedByFullName",
			"CreatedById",
			"CreatedByIntegrationId",
			"CreatedByLastName",
			"CreatedByUserSignInId",
			"CreatedDate",
			"EventName",
			"ExternalSystemId",
			"Id",
			"ModId",
			"ModificationNumber",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"ObjectId",
			"ObjectName",
			"UpdatedByAlias",
			"UpdatedByEMailAddr",
			"UpdatedByExternalSystemId",
			"UpdatedByFirstName",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			];
		public function getTestIdsByEntity(entity:String):Dictionary{
			stmtFindRemoveChild.parameters[':ObjectName']=entity;
			exec(stmtFindRemoveChild);
			
			var result:Dictionary = new Dictionary();			
			var items:ArrayCollection = new ArrayCollection(stmtFindRemoveChild.getResult().data);
			if(items.length>0){
				for each(var o:Object in items){
					var id:String = o['ObjectId'];					
					result[id]=id;
				}
				
			}
			return result;
			
		}
		
		
		public function getSubIdByEntity(parentEntity:String, sub:String):ArrayCollection{
			stmtFindChildUpdate.parameters[':ObjectName']=parentEntity;
			stmtFindChildUpdate.parameters[':ChildName']=sub;
			exec(stmtFindChildUpdate);				
			return new ArrayCollection(stmtFindChildUpdate.getResult().data);			
			
		}
		
		public function process(objectName:String, objectId:String):void {
			stmtProcess.parameters[':ObjectName'] = objectName;
			stmtProcess.parameters[':ObjectId'] = objectId;
			exec(stmtProcess);
		}
	}
}
