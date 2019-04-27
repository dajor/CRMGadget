package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class FinderMapDAO extends BaseSQL {

		private var stmtInsert:SQLStatement;
		private var stmtRead:SQLStatement;
		private var stmtDeleteAll:SQLStatement;
		private var stmtCount:SQLStatement;
		
		public function FinderMapDAO(sqlConnection:SQLConnection)
		{
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO finder_map (id, field, column)" +
				" VALUES (:id, :field, :column)";
				
			stmtRead = new SQLStatement();
			stmtRead.sqlConnection = sqlConnection;
			stmtRead.text = "SELECT * FROM finder_map WHERE id = :id";
			
			stmtDeleteAll = new SQLStatement();
			stmtDeleteAll.sqlConnection = sqlConnection;
			stmtDeleteAll.text = "DELETE FROM finder_map";
			
			stmtCount = new SQLStatement();
			stmtCount.sqlConnection = sqlConnection;
			stmtCount.text = "SELECT COUNT(*) AS total FROM finder_map";
		}
		
		public function insert(finderMap:Object):void
		{
			stmtInsert.parameters[":id"] = finderMap.id;
			stmtInsert.parameters[":field"] = finderMap.field;
			stmtInsert.parameters[":column"] = finderMap.column;
			exec(stmtInsert);
		}
		
		public function read(finderMap:Object):ArrayCollection
		{
			stmtRead.parameters[":id"] = finderMap.id;
			exec(stmtRead);
			
			var result:SQLResult = stmtRead.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return new ArrayCollection(result.data);
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