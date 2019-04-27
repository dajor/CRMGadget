package gadget.dao
{
	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;
	
	public class ContactTeamDAO extends SupportDAO implements ITeam
	{
		public function ContactTeamDAO(sqlConnection:SQLConnection, work:Function)
		{
			super(work, sqlConnection, {
				
				entity: ['Contact',   'Team'],
				id:     ['ContactId', 'UserId' ],
				columns: TEXTCOLUMNS
			}
				,{
					record_type:"Contact Team",
					unique:['ContactId,UserId','Id'],
					clean_table:false,
					name_column:["UserLastName"],
					search_columns:["UserLastName"],
					oracle_id:"Id",		//VAHI's not so evil kludge
					columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
				});
			_isSyncWithParent = false;
			_isGetField = true;
			_isSelectAll = true;
		}
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["UserExternalSystemId",
				"UserLastName",
				"UserFirstName",
				"UserEmail",
				"UserAlias"	,
				"UserIntegrationId",
				"UserRole"
				
			]);
		}
		
		private var TEXTCOLUMNS:Array = [
										'ModifiedDate',								
										'CreatedDate',
										'ModifiedById',										
										'CreatedById',
										'ModId',
										'Id',
										'UserLastName',
										'UserFirstName',
										'UserRole',
										'ContactId',
										'UserEmail',
										'CreatedBy',
										'UserAlias',
										'TeamRole',
										'UserId',
										'UserExternalSystemId',
										'UserIntegrationId',
										'ContactAccessId',
										'ContactAccess',
										'UpdatedByFirstName',
										'UpdatedByLastName',
										'UpdatedByUserSignInId',
										'UpdatedByAlias',
										'UpdatedByFullName',
										'UpdatedByIntegrationId',
										'UpdatedByExternalSystemId',
										'UpdatedByEMailAddr',
										'CreatedByFirstName',
										'CreatedByLastName',
										'CreatedByUserSignInId',
										'CreatedByAlias',
										'CreatedByFullName',
										'CreatedByIntegrationId',
										'CreatedByExternalSystemId',
										'CreatedByEMailAddr',
										'ModifiedBy'
										]	;	
			
			
	
			
	}
}