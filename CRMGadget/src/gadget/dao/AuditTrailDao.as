package gadget.dao
{
	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;
	
	public class AuditTrailDao extends SupportDAO
	{
		public function AuditTrailDao(sqlConnection:SQLConnection, work:Function) {
			
			super(work, sqlConnection, {
				
				entity: ['AuditTrail'],
				id:     ['Id' ],
				columns: textColumns
			}
				,{
					record_type:"AuditTrail",
					unique:['Id,RecordName'],
					clean_table:false,
					must_drop :false,
					name_column:["RecordName"],
					search_columns:["RecordName"],
					oracle_id:"Id",	
					columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
				});
			_isSyncWithParent = false;
			_isGetField = true;			
			this._isSelectAll = false;
			
			
		}
		
		private const textColumns:Array = [
			"ModId",
			"Id",
			"RecordType",
			"ModifiedDate",
			"RecordName",
			"Operation",
			"FieldName",
			"OldFieldValue",
			"NewFieldValue",
			"RecordUpdatedDate",
			"SourceIPAddress",
			"SourceType",
			"UserId",
			"UserFirstName",
			"UserLastName",
			"UserFullName",
			"UserSignInId",
			"CreatedById",
			"CreatedBy",
			"CreatedDate",
			"CreatedByAlias",
			"CreatedByFirstName",
			"CreatedByLastName",
			"CreatedByFullName",
			"CreatedByEMailAddr",
			"CreatedByExternalSystemId",
			"CreatedByUserSignInId",
			"CreatedByIntegrationId",
			"ModifiedBy",
			"ModifiedById",
			"UpdatedByAlias",
			"UpdatedByFirstName",
			"UpdatedByLastName",
			"UpdatedByFullName",
			"UpdatedByEMailAddr",
			"UpdatedByExternalSystemId",
			"UpdatedByUserSignInId",
			"UpdatedByIntegrationId"];
	}
}