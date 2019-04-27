package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class AccountPartnerDAO extends SupportDAO
	{
		private var stmtDeleteByPartnerId:SQLStatement = null;
		public function AccountPartnerDAO(work:Function, sqlConnection:SQLConnection)
		{
			super(work, sqlConnection, {
				
				entity: ['Account',   'Partner'],
				id:     ['Id' ],
				columns: TEXTCOLUMNS
			}
				,{
					record_type:"AccountPartner",
					unique:['Id'],
					clean_table:true,
					must_drop :false,
					name_column:["PartnerName"],
					search_columns:["PartnerName"],
					oracle_id:"Id",		//VAHI's not so evil kludge
					columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
				});
			_isSyncWithParent = false;
			_isGetField = true;
			stmtDeleteByPartnerId = new SQLStatement();
			stmtDeleteByPartnerId.text = "DELETE FROM  account_partner WHERE PartnerId = :PartnerId";
			stmtDeleteByPartnerId.sqlConnection = sqlConnection;
			this._isSelectAll = false;
			
		}
		
		public function deleteByPartnerId(partnerId:String):void{
			stmtDeleteByPartnerId.parameters[":PartnerId"] = partnerId;
			exec(stmtDeleteByPartnerId);
		}
		override protected function getIncomingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["AccountId"]);
		}
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["AccountId",
				"PartnerName",
				"PrimaryContactName",
				"PartnerExternalSystemId",
				"PartnerIntegrationId"
			]);
		}
		override public function getLayoutFields():Array{
			var layoutFields:Array = [
				{data_type:"Picklist",display_name:"Account Partner",element_name:"PartnerName",entity:this.entity,required:true},
				{data_type:"Picklist",display_name:"Primary Contact",element_name:"PrimaryContactName",entity:this.entity,required:false},
				{data_type:"Picklist",display_name:"Role",isCustom:true,element_name:"RelationshipRole",entity:this.entity,required:true},
				{data_type:"Picklist",display_name:"Reverse Role",isCustom:true,element_name:"ReverseRelationshipRole",entity:this.entity,required:true},
				{data_type:"Date",display_name:"Start Date",element_name:"StartDate",entity:this.entity,required:true},
				{data_type:"Date",display_name:"End Date",element_name:"EndDate",entity:this.entity,required:false},
				{data_type:"Text (Long)",display_name:"Strengths",element_name:"Strengths",entity:this.entity,required:false},
				{data_type:"Text (Long)",display_name:"Weaknesses",element_name:"Weaknesses",entity:this.entity,required:false},
				{data_type:"Text (Long)",display_name:"Comments",element_name:"Comments",entity:this.entity,required:false}
			];
			return layoutFields;
		}
		
		
		
		private var  TEXTCOLUMNS:Array = [
			"AccountId",
			"ModifiedDate",
			"CreatedDate",
			"ModifiedById",
			"CreatedById",
			"ModId",
			"Id",
			"ReverseRelationshipRole",
			"RelationshipRole",
			"PartnerId",
			"StartDate",
			"CreatedBy",
			"PartnerIntegrationId",
			"PartnerExternalSystemId",
			"ParentPrimaryContactId",
			"PrimaryContactId",
			"PrimaryContactName",
			"EndDate",
			"PartnerName",
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
			"Comments",
			"Weaknesses",
			"Strengths"];
	}
}