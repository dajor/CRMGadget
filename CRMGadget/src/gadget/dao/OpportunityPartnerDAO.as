package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class OpportunityPartnerDAO extends SupportDAO
	{
		private var stmtDeleteByPartnerId:SQLStatement = null;
		public function OpportunityPartnerDAO(work:Function, sqlConnection:SQLConnection)
		{
			super(work, sqlConnection, {
				
				entity: ['Opportunity',   'Partner'],
				id:     ['Id' ],
				columns: TEXTCOLUMNS
			}
				,{
					record_type:"OpportunityPartner",
					unique:['Id'],
					clean_table:false,
					must_drop :false,
					name_column:["PartnerName"],
					search_columns:["PartnerName"],
					oracle_id:"Id",		//VAHI's not so evil kludge
					columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
				});
			_isSyncWithParent = false;
			_isGetField = true;
			stmtDeleteByPartnerId = new SQLStatement();
			stmtDeleteByPartnerId.text = "DELETE FROM  opportunity_partner WHERE PartnerId = :PartnerId";
			stmtDeleteByPartnerId.sqlConnection = sqlConnection;
			this._isSelectAll = true;
			
		}
		
		public function deleteByPartnerId(partnerId:String):void{
			stmtDeleteByPartnerId.parameters[":PartnerId"] = partnerId;
			exec(stmtDeleteByPartnerId);
		}
		
		override public function getLayoutFields():Array{
			var layoutFields:Array = [
				{data_type:"Picklist",display_name:"Opportunity Partner",element_name:"PartnerName",entity:this.entity,required:true},
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
		
		override protected function getIncomingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["OpportunityId"]);
		}
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["OpportunityId",
				"PrimaryContactName",
				"PartnerIntegrationId",
				"PartnerName",
				"PartnerExternalSystemId"				
				
			]);
		}
		
		private var  TEXTCOLUMNS:Array = [
			"OpportunityId",
			"ModifiedDate",
			"CreatedDate",
			"ModifiedById",
			"CreatedById",
			"ModId",
			"Id",
			"PartnerExternalSystemId",
			"CreatedByFullName",
			"PartnerName",
			"PrimaryContactId",
			"PrimaryContactName",
			"PartnerIntegrationId",
			"EndDate",
			"PartnerId",
			"ReverseRelationshipRole",
			"RelationshipRole",
			"StartDate",			
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
			"CreatedByIntegrationId",
			"CreatedByExternalSystemId",
			"CreatedByEMailAddr",
			"ModifiedBy",
			"Comments",
			"Weaknesses",
			"Strengths"];
	
	}
}