package gadget.dao
{
	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;
	
	public class OpportunityTeamDAO extends SupportDAO implements ITeam
	{
		public function OpportunityTeamDAO(work:Function, sqlConnection:SQLConnection)
		{
			super(work, sqlConnection, {
				
				entity: ['Opportunity',   'Team'],
				id:     ['OpportunityId', 'UserId','Id' ],
				columns: TEXTCOLUMNS
			}
				,{
					record_type:"Opportunity Team",
					unique:['OpportunityId,UserId','Id'],
					clean_table:true,
					must_drop :false,
					name_column:["UserFirstName","UserLastName"],
					search_columns:["UserFirstName","UserLastName"],
					oracle_id:"Id",		//VAHI's not so evil kludge
					columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
				});
			_isSyncWithParent = false;
			_isGetField = true;
		}
		
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["UserExternalSystemId",
				"UserLastName",
				"UserFirstName",
				"UserEmail",
				"UserAlias"				
				
			]);
		}
		
		private var TEXTCOLUMNS:Array = [
			"ModifiedDate",
			"CreatedDate",
			"ModifiedById",
			"CreatedById",
			"Id",                    
			"CreatedBy",
			"UserEmail",
			"UserAlias",
			"OpportunityId",
			"UserId",
			"UserExternalSystemId",
			"UserLastName",
			"UserFirstName",
			"TeamRole",
			"OpportunityAccess",
			"OpportunityAccessId",
			"UpdatedByFirstName",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			"UpdatedByAlias",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByExternalSystemId",
			"UpdatedByEMailAddr",
			"CreatedByFirstName",
			"CreatedByLastName",
			"CreatedByUserSignInId",
			"CreatedByAlias",
			"CreatedByFullName",
			"CreatedByIntegrationId",
			"CreatedByExternalSystemId",
			"CreatedByEMailAddr",
			"ModifiedBy"
			
		]	;	
	}
}