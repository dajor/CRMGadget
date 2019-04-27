package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class AccountCompetitorDAO extends SupportDAO
	{
		
		private var stmtDeleteByCompetitorId:SQLStatement = null;
		public function AccountCompetitorDAO(work:Function, sqlConnection:SQLConnection)
		{
			super(work, sqlConnection, {
				
				entity: ['Account',   'Competitor'],
				id:     ['Id' ],
				columns: TEXTCOLUMNS
			}
				,{
					record_type:"AccountCompetitor",
					unique:['Id'],
					clean_table:false,
					must_drop :false,
					name_column:["CompetitorName"],
					search_columns:["CompetitorName"],
					oracle_id:"Id",		//VAHI's not so evil kludge
					columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
				});
			stmtDeleteByCompetitorId = new SQLStatement();
			stmtDeleteByCompetitorId.text = "DELETE FROM  account_competitor WHERE CompetitorId = :CompetitorId";
			stmtDeleteByCompetitorId.sqlConnection = sqlConnection;
			_isSyncWithParent = false;
			_isGetField = true;
			_isSelectAll = false;
		}
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["AccountId",
				"PrimaryContactName",
				"CompetitorName",
				"CompetitorExternalSystemId",
				"CompetitorIntegrationId"]);
		}
		
		public function deleteByCompetitorId(competitorId:String):void{
			stmtDeleteByCompetitorId.parameters[":CompetitorId"] = competitorId;
			exec(stmtDeleteByCompetitorId);
		}
		
		override protected function getIncomingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["AccountId"]);
		}
		
		override public function getLayoutFields():Array{
			var layoutFields:Array = [
					{data_type:"Picklist",display_name:"Account Competitor",element_name:"CompetitorName",entity:this.entity,required:true},
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
		
		private var TEXTCOLUMNS:Array=[
		"AccountId",
		"ModifiedDate",
		"CreatedDate",
		"ModifiedById",
		"CreatedById",
		"ModId",
		"Id",
		"CreatedBy",
		"CompetitorIntegrationId",
		"CompetitorExternalSystemId",
		"RelationshipRole",
		"ReverseRelationshipRole",
		"EndDate",
		"CompetitorId",
		"PrimaryContactId",
		"PrimaryContactName",
		"StartDate",
		"CompetitorName",
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
		"Strengths"
		];
		
	}
}