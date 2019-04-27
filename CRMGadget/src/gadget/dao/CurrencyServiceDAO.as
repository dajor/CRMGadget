package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import mx.collections.ArrayCollection;
	
	public class CurrencyServiceDAO extends SimpleTable {
		
		private var stmtFind:SQLStatement;
		private var stmtFindAll:SQLStatement;
		
		public function CurrencyServiceDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"currency_service",
				//VAHI fix Issue #13, see comment at end
				unique: [ 'Name,Code' ],
				index: [ 'Name,Code' ],
				columns: { 'TEXT' : getColumns()}
			});
			
//			stmtSelect = new SQLStatement();
//			stmtSelect.sqlConnection = sqlConnection;
//			stmtSelect.text = "SELECT * FROM picklist_service WHERE LanguageCode=:LanguageCode and  ObjectName = :record_type AND FieldName = :field_name AND Disabled = :disabled ORDER BY Order2_ asc";
//			
//			stmtSelectOne = new SQLStatement();
//			stmtSelectOne.sqlConnection = sqlConnection;
//			stmtSelectOne.text = "SELECT Value FROM picklist_service WHERE LanguageCode=:LanguageCode and  ObjectName = :record_type AND FieldName = :field_name AND Disabled = :disabled AND ValueId = :code  ORDER BY Order2_ asc";
//			
//			stmtSelectByValue = new SQLStatement();
//			stmtSelectByValue.sqlConnection = sqlConnection;
//			stmtSelectByValue.text = "SELECT Value FROM picklist_service WHERE LanguageCode=:LanguageCode and  ObjectName = :record_type AND FieldName = :field_name AND Disabled = :disabled AND Value = :value  ORDER BY Order2_ asc";
			
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM currency_service WHERE Name = :name AND Code = :code AND code = :code";
			
			stmtFindAll = new SQLStatement();
			stmtFindAll.sqlConnection = sqlConnection;
			stmtFindAll.text = "SELECT * FROM currency_service ORDER BY Code";
		}
		
		public function delete_one(entity:String):void {
			del(null,{ObjectName:entity});
		}
		
		public function find(currency:Object):Object
		{
			stmtFind.parameters[":name"] = currency.name;
			stmtFind.parameters[":code"] = currency.code;
			exec(stmtFind);
			
			var result:SQLResult = stmtFind.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		public function findAll():Array{
			exec(stmtFindAll);			
			var result:SQLResult = stmtFindAll.getResult();
			if (result.data == null || result.data.length == 0) {
				return new Array() ;
			}
			return result.data;
		}

		override public function getColumns():Array {
			return [
				'Name',
				'Code',
				'Symbol',
				'IssuingCountry',
				'Active'
			];
		}
		
	}
}
