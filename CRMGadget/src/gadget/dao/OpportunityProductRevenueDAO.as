package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	
	import gadget.i18n.i18n;
	
	import mx.collections.ArrayCollection;
	
	public class OpportunityProductRevenueDAO extends SupportDAO
	{
		public function OpportunityProductRevenueDAO(work:Function, sqlConnection:SQLConnection)
		{
			super(work, sqlConnection, {
				
				entity: ['Opportunity',   'Product'],
				id:     ['Id' ],
				columns: TEXTCOLUMNS
			}
				,{
					record_type:"Revenue",
					unique:['Id'],
					clean_table:false,
					must_drop :false,
					name_column:["ProductName"],
					search_columns:["ProductName"],
					oracle_id:"Id",		//VAHI's not so evil kludge
					columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
				});
			_isSyncWithParent = false;
			_isGetField = true;
			_isSelectAll = true;
			
		}
		
		override public function get metaDataEntity():String{
			return "Revenue";
		}
		
		
		override public function getPluralName():String{
			return i18n._("Product Revenues");
		}
		override public function findRelatedData(parentEntity:String , oracleId:String):ArrayCollection {
			var arr:ArrayCollection;
			stmtFindRelatedSub.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE OpportunityId = '" + oracleId + "'";
			exec(stmtFindRelatedSub);
			var result:SQLResult = stmtFindRelatedSub.getResult();
			if (result.data == null || result.data.length == 0) {
				return new ArrayCollection();
			}
			return new ArrayCollection(result.data);
		}
		
		override public function getLayoutFields():Array{
			var fields:ArrayCollection =Database.fieldDao.listFields(entity);
//			var layoutFields:Array = [
//				{data_type:"Picklist",display_name:"Product Name",element_name:"ProductName",entity:this.entity,required:true},
//				{data_type:"Text (Short)",display_name:"Product Category",element_name:"ProductCategory",entity:this.entity,readonly:true,required:false},				
//				{data_type:"Text (Short)",display_name:"Part #",element_name:"ProductPartNumber",entity:this.entity,readonly:true,required:false},				
//				{data_type:"Text (Short)",display_name:"Product Type",element_name:"ProductType",entity:this.entity,readonly:true,required:false,readonly:true},
//				{data_type:"Text (Short)",display_name:"Product Status",element_name:"ProductStatus",entity:this.entity,required:false,readonly:true},
//				{data_type:"Text (Short)",display_name:"Revenue",element_name:"Revenue",entity:this.entity,required:false,readonly:true},
//				{data_type:"Text (Short)",display_name:"Currency",element_name:"CurrencyCode",entity:this.entity,required:false,readonly:true},
//				{data_type:"Number",display_name:"Purchase Price",element_name:"PurchasePrice",entity:this.entity,required:false},
//				{data_type:"Number",display_name:"Quantity",element_name:"Quantity",entity:this.entity,required:false},
////				{data_type:"Text (Short)",display_name:"Created",element_name:"CreatedBy",entity:this.entity,required:false,readonly=true},
////				{data_type:"Text (Short)",display_name:"Modified",element_name:"ModifiedBy",entity:this.entity,required:false,readonly=true},
//				{data_type:"Date",display_name:"Start/Close Date",element_name:"StartCloseDate",entity:this.entity,required:false},
//				{data_type:"Number",display_name:"# of Periods",element_name:"NumberOfPeriods",entity:this.entity,required:false},
//				{data_type:"Picklist",display_name:"Frequency",isCustom:true,element_name:"Frequency",entity:this.entity,required:false},
//				{data_type:"Text (Short)",display_name:"Sales Stage",element_name:"OpportunitySalesStage",entity:'Opportunity',required:false,readonly:true},
//				{data_type:"Picklist",display_name:"Account",element_name:"AccountName",entity:this.entity,required:false},
//				{data_type:"Picklist",display_name:"Probability %",isCustom:true,element_name:"Probability",entity:this.entity,required:false},
//				{data_type:"Picklist",display_name:"Owner",element_name:"Owner",entity:this.entity,required:false},
//				{data_type:"Number",display_name:"Expected Revenue",element_name:"ExpectedRevenue",entity:this.entity,required:false,readonly:true},
//				{data_type:"Checkbox",display_name:"Forecast",element_name:"Forecast",entity:this.entity,required:false},
//				{data_type:"Text (Long)",display_name:"Description",element_name:"Description",entity:this.entity,required:false}
//			];
			return fields.source;
		}
		
		
		protected override function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection([
			"ProductCategoryId",
			"ProductCategory",
			"AccountLocation",
			"ContactLastName",
			"ContactFirstName",
			"OpportunityName",
			"AccountName",
			"ProductName",
			"OpportunityExternalSystemId",
			"ContactExternalSystemId",
			"AccountExternalSystemId",
			"ProductCategoryExternalSystemId",
			"ProductExternalSystemId",
			"ProductType",
			"ProductStatus",
			"ProductPartNumber",
			"Owner"
			]);
		}
		private var  TEXTCOLUMNS:Array = [
			"ModifiedDate",
			"CreatedDate",
			"ModifiedById",
			"CreatedById",
			"ModId",
			"Id",
			"CurrencyCode",
			"ProductCategoryId",
			"ProductCategory",
			"AccountLocation",
			"ContactLastName",
			"ContactId",
			"ContactFirstName",
			"CustomInteger18",
			"CustomCurrency5",			
			"CustomText30",			
			"CustomText0",
			"CustomCurrency8",
			"CustomCurrency4",
			"CustomCurrency0",
			"CustomInteger0",
			"CustomCurrency7",
			"CustomCurrency6",
			"CustomPickList0",
			"CustomCurrency1",
			"CustomCurrency3",
			"CustomBoolean0",			
			"ProductId",
			"AccountId",
			"Forecast",
			"ExpectedRevenue",
			"Status",
			"StartCloseDate",
			"Type",
			"Quantity",
			"Probability",
			"PurchasePrice",
			"Revenue",
			"Description",
			"OpportunityId",
			"OpportunityName",
			"AccountName",
			"ProductName",
			"ContactExternalSystemId",
			"AccountExternalSystemId",
			"ProductCategoryExternalSystemId",
			"IndexedBoolean0",
			"IndexedCurrency0",
			"IndexedDate0",
			"IndexedNumber0",
			"IndexedPick0",
			"IndexedPick1",
			"IndexedPick2",
			"IndexedPick3",
			"IndexedPick4",
			"IndexedPick5",
			"IndexedLongText0",
			"IndexedShortText0",
			"IndexedShortText1",
			"AssetValue",
			"Premium",
			"ExternalSystemId",
			"OpportunityExternalSystemId",
			"ProductExternalSystemId",
			"Frequency",
			"Contract",
			"ModifiedByandDate",
			"IntegrationId",
			"PurchaseDate",
			"ProductType",
			"ProductStatus",
			"ProductPartNumber",
			"OwnerId",
			"Owner",
			"OpportunitySalesStage",
			"SerialNumber",
			"NumberOfPeriods",
			"Warranty",
			"ShipDate",
			"ContactFullName",
			"CustomObject4Id",
			"CustomObject5Id",
			"CustomObject6Id",
			"CustomObject7Id",
			"CustomObject8Id",
			"CustomObject9Id",
			"CustomObject10Id",
			"CustomObject11Id",
			"CustomObject12Id",
			"CustomObject13Id",
			"CustomObject14Id",
			"CustomObject15Id",
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
			"CustomObject4Name",
			"CustomObject4Type",
			"CustomObject4ExternalSystemId",
			"CustomObject4IntegrationId",
			"CustomObject5Name",
			"CustomObject5Type",
			"CustomObject5ExternalSystemId",
			"CustomObject5IntegrationId",
			"CustomObject6Name",
			"CustomObject6Type",
			"CustomObject6ExternalSystemId",
			"CustomObject6IntegrationId",
			"CustomObject7Name",
			"CustomObject7Type",
			"CustomObject7ExternalSystemId",		
			"CustomObject7IntegrationId",
			"CustomObject8Name",
			"CustomObject8Type",
			"CustomObject8ExternalSystemId",
			"CustomObject8IntegrationId",
			"CustomObject9Name",
			"CustomObject9Type",
			"CustomObject9ExternalSystemId",			
			"CustomObject9IntegrationId",
			"CustomObject10Name",
			"CustomObject10Type",
			"CustomObject10ExternalSystemId",
			"CustomObject10IntegrationId",
			"CustomObject11Name",
			"CustomObject11Type",
			"CustomObject11ExternalSystemId",
			"CustomObject11IntegrationId",
			"CustomObject12Name",
			"CustomObject12Type",			
			"CustomObject12ExternalSystemId",
			"CustomObject12IntegrationId",
			"CustomObject13Name",
			"CustomObject13Type",
			"CustomObject13ExternalSystemId",
			"CustomObject13IntegrationId",
			"CustomObject14Name",
			"CustomObject14Type",
			"CustomObject14ExternalSystemId",
			"CustomObject14IntegrationId",
			"CustomObject15Name",
			"CustomObject15Type",			
			"CustomObject15ExternalSystemId",
			"CustomObject15IntegrationId",
			"CreatedBy",
			"ModifiedBy"
			];
	}
}