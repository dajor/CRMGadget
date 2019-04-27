package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	public class FieldFinderDAO extends BaseSQL {
		private var stmtInsert:SQLStatement;
		private var stmtGetFinderTableName:SQLStatement;
		private var stmtDeleteAll:SQLStatement;
		private var stmtCount:SQLStatement;
		
		public function FieldFinderDAO(sqlConnection:SQLConnection)
		{		
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO field_finder (entity, element_name, finder)" +
				" VALUES (:entity, :element_name, :finder)";
			
			stmtGetFinderTableName = new SQLStatement();
			stmtGetFinderTableName.sqlConnection = sqlConnection;
			stmtGetFinderTableName.text = "SELECT finder FROM field_finder WHERE entity = :entity AND element_name = :element_name";
			
			stmtDeleteAll = new SQLStatement();
			stmtDeleteAll.sqlConnection = sqlConnection;
			stmtDeleteAll.text = "DELETE FROM field_finder";
			
			stmtCount = new SQLStatement();
			stmtCount.sqlConnection = sqlConnection;
			stmtCount.text = "SELECT COUNT(*) AS total FROM field_finder";
		}
		
		public function insert(fieldFinder:Object):void
		{
			stmtInsert.parameters[":entity"] = fieldFinder.entity;
			stmtInsert.parameters[":element_name"] = fieldFinder.element_name;
			stmtInsert.parameters[":finder"] = fieldFinder.finder;
			exec(stmtInsert);
		}
		
		public function getFinderTableName(fieldFinder:Object):String
		{
			stmtGetFinderTableName.parameters[":entity"] = fieldFinder.entity;
			stmtGetFinderTableName.parameters[":element_name"] = fieldFinder.element_name;
			exec(stmtGetFinderTableName);
			
			var result:SQLResult = stmtGetFinderTableName.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0].finder;
		}
		
		public function deleteAll():void {
			exec(stmtDeleteAll);
		}
		
		public function count():int {
			exec(stmtCount);
			var result:SQLResult = stmtCount.getResult();
			return result.data[0].total;
		}
		
	}
}