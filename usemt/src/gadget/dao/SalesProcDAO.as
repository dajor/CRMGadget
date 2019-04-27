package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	public class SalesProcDAO extends BaseSQL {

		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtFind:SQLStatement;
		private var stmtRead:SQLStatement;
		private var stmtGetSalePro:SQLStatement;
		public function SalesProcDAO(sqlConnection:SQLConnection)
		{
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO salesproc (id, name, description,default_stage)" +
				" VALUES (:id, :name, :description,:default_stage)";
				
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM salesproc WHERE id = :id and default_stage ='Y'";

			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE salesproc SET name = :name, description = :description, default_stage = :default_stage" +
				" WHERE id = :id";
				
			stmtRead = new SQLStatement();
			stmtRead.sqlConnection = sqlConnection;
			stmtRead.text = "SELECT * FROM salesproc Where default_stage ='Y'";
			
			stmtGetSalePro = new SQLStatement();
			stmtGetSalePro.sqlConnection = sqlConnection;
			stmtGetSalePro.text = "SELECT * FROM salesproc Where name= :name";
			
		}

	    public function getSalesProId(name:String):String{
			stmtGetSalePro.parameters[":name"] = name;
			exec(stmtGetSalePro);
			
			var result:SQLResult = stmtGetSalePro.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0].id;
		}
		
		public function insert(salesProc:Object):void
		{
			executeStatement(stmtInsert,salesProc);
		}
		
		public function find(salesProc:Object):Object
		{
			stmtFind.parameters[":id"] = salesProc.id;
			exec(stmtFind);
			
			var result:SQLResult = stmtFind.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		public function update(salesProc:Object):void
		{
			executeStatement(stmtUpdate,salesProc);	
		}
		
		private function executeStatement(stmt:SQLStatement,salesProc:Object):void
		{
			stmt.parameters[":name"] = salesProc.name;
			stmt.parameters[":description"] = salesProc.description;
			stmt.parameters[":default_stage"] = salesProc.default_stage;
			stmt.parameters[":id"] = salesProc.id;			
			exec(stmt);
		}
		
		public function read():Object
		{
			exec(stmtRead);
			var result:SQLResult = stmtRead.getResult();
			if (result.data == null) {
				return null;
			}
			return result.data[0];
		}
		
	}
}