package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	
	public class FieldDAO extends BaseSQL {
		
		private var stmtInsert:SQLStatement;
		//private var stmtUpdate:SQLStatement;
		private var stmtDeleteFields:SQLStatement;
		private var stmtFindFieldByPrimaryKey:SQLStatement;
		private var stmtAllEntitiesList:SQLStatement;
		private var stmtSelectOnlyElement:SQLStatement;
		private var stmtAllPicklists:SQLStatement;
		private var stmtFindByNameIgnoreCase:SQLStatement;
		
		private var stmtFindField:SQLStatement;
		
		
		public function FieldDAO(sqlConnection:SQLConnection) {
			//super(sqlConnection);
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO field (entity, element_name, display_name, data_type) VALUES (:entity, :element_name, :display_name, :data_type)";

			stmtDeleteFields = new SQLStatement();
			stmtDeleteFields.sqlConnection = sqlConnection;
			stmtDeleteFields.text = "DELETE FROM field WHERE entity = :entity";
/*
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE field SET display_name = :display_name, data_type = :data_type WHERE entity = :entity AND element_name = :element_name";
*/			
			stmtFindFieldByPrimaryKey = new SQLStatement();	
			stmtFindFieldByPrimaryKey.sqlConnection = sqlConnection;
			stmtFindFieldByPrimaryKey.text = "SELECT * FROM field WHERE entity = :entity AND element_name = :element_name";
			
			stmtAllEntitiesList = new SQLStatement();
			stmtAllEntitiesList.sqlConnection = sqlConnection;
		  //stmtAllEntitiesList.text = "SELECT * FROM field WHERE entity = :entity AND element_name not like 'CI_%' ORDER BY display_name";
			stmtAllEntitiesList.text = "SELECT * FROM field WHERE entity = :entity AND element_name not like 'CI/_%' ESCAPE '/' ORDER BY display_name";
			
			stmtSelectOnlyElement = new SQLStatement();
			stmtSelectOnlyElement.sqlConnection = sqlConnection;
			stmtSelectOnlyElement.text = "SELECT element_name FROM field WHERE entity = :entity AND element_name not like 'CI/_%' ESCAPE '/' ORDER BY display_name";
			
			//Bug #4997 'CI/_%' ESCAPE '/'
			stmtAllPicklists = new SQLStatement();
			stmtAllPicklists.sqlConnection = sqlConnection;
			// Change Request #460
			stmtAllPicklists.text = 
				"SELECT entity, element_name FROM field WHERE data_type in ('Picklist','Multi-Select Picklist') " +
				" AND element_name NOT LIKE '%ExternalSystemId' AND element_name NOT LIKE '%IntegrationId' AND element_name NOT LIKE '%ExternalId'" + 
				" AND element_name NOT LIKE '%Name' AND element_name NOT LIKE 'AssessmentFilter%' AND element_name NOT LIKE 'Parent%'" +
				" AND element_name NOT IN ('Owner', 'CurrencyCode', 'Industry', 'Territory', 'AccountLocation', 'Manager', 'OwnerEmailAddress', " +
					"'SalesProcess', 'OccamTerritory', 'SalesStage', 'Dealer', 'ApproverAlias', 'SourceCampaign', 'PrimaryContact', 'Lead', 'FundRequest', " +
					"'ServiceRequestNumber', 'PortfolioNumber','Address', 'Alias', 'SmartCall', 'DelegatedBy', 'ProductCurrency', 'ProductCategory', 'Class', 'Product', 'PortfolioAccountNumber', 'SolutionTitle', 'Currency', 'VIN', 'LeadOwner', 'Campaign', 'SalesPerson'"
					+", 'Language', 'Locale'" //VAHI added for SoD Users object (currently stored in AllUsersDAO)
					+" )";
			
			
			stmtFindField = new SQLStatement();
			stmtFindField.sqlConnection = sqlConnection;
			
			
			stmtFindByNameIgnoreCase = new SQLStatement();
			stmtFindByNameIgnoreCase.text = "SELECT * FROM field WHERE entity = :entity AND element_name LIKE :element_name";
			stmtFindByNameIgnoreCase.sqlConnection = sqlConnection;
			
		}
				
		public function delete_fields(entity:Object):void {
			stmtDeleteFields.parameters[":entity"] = entity; 
			exec(stmtDeleteFields);
		}

		public function insert(field:Object):void {
			stmtInsert.parameters[":entity"] = field.entity; 
			stmtInsert.parameters[":element_name"] = field.element_name; 
			stmtInsert.parameters[":display_name"] = field.display_name; 
			stmtInsert.parameters[":data_type"] = field.data_type; 
			
			exec(stmtInsert);
		}
/*
		public function update(field:Object):void {
			stmtUpdate.parameters[":entity"] = field.entity; 
			stmtUpdate.parameters[":element_name"] = field.element_name;
			stmtUpdate.parameters[":display_name"] = field.display_name; 
			stmtUpdate.parameters[":data_type"] = field.data_type; 
		    exec(stmtUpdate);
		}
*/
		
		public function findFieldByNameIgnoreCase(entity:String,element_name:String):Object {	
			if(StringUtils.unNull(entity).indexOf(Database.businessPlanDao.entity)!=-1){
				entity = Database.businessPlanDao.entity;
			}			
			stmtFindByNameIgnoreCase.parameters[":entity"] = entity;
			stmtFindByNameIgnoreCase.parameters[":element_name"] = element_name;
			exec(stmtFindByNameIgnoreCase);
			var result:SQLResult = stmtFindByNameIgnoreCase.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		public function findFieldByPrimaryKey(entity:String,element_name:String):Object {	
			if(StringUtils.unNull(entity).indexOf(Database.businessPlanDao.entity)!=-1){
				entity = Database.businessPlanDao.entity;
			}
			stmtFindFieldByPrimaryKey.parameters[":entity"] = entity;
			stmtFindFieldByPrimaryKey.parameters[":element_name"] = element_name;
			exec(stmtFindFieldByPrimaryKey);
			var result:SQLResult = stmtFindFieldByPrimaryKey.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		/** 
		 * That function return a list with all the fields by param
		 * @param: entity:string
		 * */
		public function listFields(entity:String):ArrayCollection{
		
			stmtAllEntitiesList.parameters[":entity"] = entity;			
			exec(stmtAllEntitiesList);
			return new ArrayCollection(stmtAllEntitiesList.getResult().data);
		}
		
		public function getAllElementName(entity:String):ArrayCollection{
			stmtSelectOnlyElement.parameters[":entity"] = entity;			
			exec(stmtSelectOnlyElement);
			
			var result:Array = stmtSelectOnlyElement.getResult().data;
			var elements:ArrayCollection = new ArrayCollection();
			if(result!=null){
				for each(var field:Object in result){
					elements.addItem(field.element_name);
				}
			}
			
			
			
			return elements;
			
		}

		
		/**
		 * Lists all required picklists.
		 * @return Required picklists.
		 */
		public function listPicklists():ArrayCollection{				
			exec(stmtAllPicklists);
			return new ArrayCollection(stmtAllPicklists.getResult().data);			
		}
		
		public function findFieldsByDisplayName(entity:String, display_name:String):ArrayCollection{
			stmtFindField.text = "SELECT * FROM field WHERE entity = '" + entity + "' AND element_name not like 'CI/_%' ESCAPE '/' AND (display_name LIKE '" + display_name + "%' OR display_name LIKE '% " + display_name + "%')"; 
			exec(stmtFindField);
			return new ArrayCollection(stmtFindField.getResult().data);
		}
		
		public function getFieldByDisplayName(entity:String, display_name:String):Object{
			var display_name1:String = entity + " " + display_name;
			if(display_name.indexOf(" Number")> -1 ){
				display_name1 = display_name.replace("Number", "#");
			}
			stmtFindField.text = "SELECT * FROM field WHERE entity = '" + entity + "' AND (display_name = '" + display_name + "' or display_name = '" + display_name1 + "')" ;
			
			exec(stmtFindField);
			var result:SQLResult = stmtFindField.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
	}
}