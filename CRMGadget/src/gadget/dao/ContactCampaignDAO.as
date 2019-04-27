package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class ContactCampaignDAO extends SupportDAO
	{
		
		private var stmtDeleteByRelatedContactId:SQLStatement = null;
		public function ContactCampaignDAO(sqlConnection:SQLConnection, work:Function) {
			
			super(work, sqlConnection, {
				entity: [ 'Contact','CampaignRecipient'   ],
				id:     [ 'Id' ],
				columns: TEXTCOLUMNS
			},{				
				name_column:["CampaignName"],
				oracle_id:"Id",
				unique:['Id','CampaignId,ContactId'],
				search_columns:["CampaignName"],
				record_type:"ContactCampaign",
				index:['ContactId','CampaignId'],
				clean_table:false,
				columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
			
			
			});
			stmtDeleteByRelatedContactId = new SQLStatement();
			stmtDeleteByRelatedContactId.text = "DELETE FROM  contact_campaignrecipient WHERE ContactId = :ContactId";
			stmtDeleteByRelatedContactId.sqlConnection = sqlConnection;
			_isSyncWithParent = false;
			_isSelectAll = true;
			_isGetField = true;
		}
		
		
		public function deleteByRelatedContactId(relatedContactId:String):void{
			stmtDeleteByRelatedContactId.parameters[":ContactId"] = relatedContactId;
			exec(stmtDeleteByRelatedContactId);
		}
		
		override protected function getIncomingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["ContactId","ContactFullName"]);
		}
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["ContactId",
				"CampaignType",
				"CampaignName",
				"UpdatedByFirstName",
				"UpdatedByLastName",
				"ContactFullName"
			]);
		}
		
		override public function findRelatedData(parentEntity:String , oracleId:String):ArrayCollection {
			return findDataByRelation({keySrc:'ContactId'},oracleId);//the parent is contact
		}
		
		private const TEXTCOLUMNS:Array = [
			"ModifiedDate",
			"CreatedDate",
			"ModifiedById",
			"CreatedById",
			"ModId",
			"Id",
			"ResponseStatus",
			"Description",
			"DeliveryStatus",
			"CampaignType",
			"CampaignName",
			"CampaignExternalSystemId",
			"CreatedBy",
			"CampaignId",
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
			"ModifiedBy",
			"ContactId",
			"ContactFullName"
		];
	}
}
