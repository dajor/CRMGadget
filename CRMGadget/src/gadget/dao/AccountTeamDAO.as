//Not used (Account Team cannot be fetched as it is missing.)
package gadget.dao
{
	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;

	public class AccountTeamDAO extends SupportDAO implements ITeam	{

		public function AccountTeamDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super( workerFunction,sqlConnection,
				{
					
					entity: ['Account',   'Team'],
					id:     ['AccountId', 'UserId' ],
					columns: TEXTCOLUMNS
				}
					,{
						record_type:"Account Team",
						unique:['AccountId,UserId','Id'],
						clean_table:false,
						must_drop:false,
						name_column:["FirstName","LastName"],
						search_columns:["FirstName","LastName"],
						oracle_id:"Id",		//VAHI's not so evil kludge
						columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
					});
			_isSyncWithParent = false;
			_isGetField = true;
			_isSelectAll = true;
		
			
		}
		
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["UserExternalSystemId",
				"FirstName",
				"UserFirstName",
				"LastName",
				"UserAlias"	,
				"AccountName",
				"RoleName"
				
			]);
		}
		
		private var TEXTCOLUMNS:Array = [
			'ModifiedDate',
			'CreatedDate',
			'ModifiedById',
			'CreatedById',
			'ModId',
			'Id',
			'UserId',
			'AccountId',
			'AccountName',
			'LastName',
			'TeamRole',
			'FirstName',			
			'RoleName',
			'UserEmail',
			'AccountAccessId',
			'AccountAccess',
			'OpportunityAccessId',
			'OpportunityAccess',
			'ContactAccessId',
			'ContactAccess',
			'UserAlias',
			'UserExternalSystemId',
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
		];
	}
}