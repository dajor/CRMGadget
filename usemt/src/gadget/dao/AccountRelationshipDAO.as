package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class AccountRelationshipDAO extends SupportDAO
	{
		private var stmtDeleteByRelatedAccountId:SQLStatement = null;
		public function AccountRelationshipDAO(sqlConnection:SQLConnection, work:Function)
		{
			super(work, sqlConnection, {
				entity: [ 'Account','Related'   ],
				id:     [ 'Id' ],
				columns: TEXTCOLUMNS
			},{				
				name_column:["RelatedAccountName"],
				oracle_id:"Id",
				unique:['Id'],
				search_columns:["RelatedAccountName"],
				record_type:"AccountRelationship",
				clean_table:true,
				columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
				
				
			});
			stmtDeleteByRelatedAccountId = new SQLStatement();
			stmtDeleteByRelatedAccountId.text = "DELETE FROM  account_related WHERE RelatedAccountId = :RelatedAccountId";
			stmtDeleteByRelatedAccountId.sqlConnection = sqlConnection;
			_isSyncWithParent = false;
			_isSelectAll = false;
			_isGetField = true;
		}
		override protected function getIncomingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["AccountId"]);
		}
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
		 	return new ArrayCollection(["AccountId"]);
		}
		
		override public function getLayoutFields():Array{
			var layoutFields:Array = [
				{data_type:"Picklist",display_name:"Account Name",element_name:"RelatedAccountName",entity:this.entity,required:true},				
				{data_type:"Picklist",display_name:"Role",isCustom:true,element_name:"Role",entity:this.entity,required:false},
				{data_type:"Picklist",display_name:"Reverse Role",isCustom:true,element_name:"ReverseRole",entity:this.entity,required:false},
				{data_type:"Date",display_name:"Start Date",element_name:"StartTime",entity:this.entity,required:false},
				{data_type:"Date",display_name:"End Date",element_name:"EndTime",entity:this.entity,required:false},
				{data_type:"Picklist",display_name:"Status",isCustom:true,element_name:"RelationshipStatus",entity:this.entity,required:false}
				
			];
			return layoutFields;
		}
		private const TEXTCOLUMNS:Array = [
			"Comment",
			"ContactFullName",
			"ContactId",
			"ContactPhone",
			"CreatedBy",
			"CreatedByAlias",
			"CreatedByEMailAddr",
			"CreatedByExternalSystemId",
			"CreatedByFirstName",
			"CreatedByFullName",
			"CreatedByIntegrationId",
			"CreatedByLastName",
			"CreatedByUserSignInId",
			"CreatedDate",
			"DefaultRelatedPartyType",
			"EndTime",
			"Id",
			"ModifiedBy",
			"ModifiedDate",
			"RelatedAccountId",
			"RelatedAccountName",
			"RelationshipStatus",
			"ReverseRole",
			"Role",
			"StartTime",
			"Strength",
			"UpdatedByAlias",
			"UpdatedByEMailAddr",
			"UpdatedByExternalSystemId",
			"UpdatedByFirstName",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			"Weakness",
			"AccountId"

		];
	}
}