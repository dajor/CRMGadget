package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class ProcessOpportunityDAO extends BaseSQL {
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtFindAll:SQLStatement;
		private var stmtFind:SQLStatement;
		
		public function ProcessOpportunityDAO(sqlConnection:SQLConnection){
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO process_opportunity (process_id, opportunity_type_id, opportunity_type_name)" +
				" VALUES (:process_id, :opportunity_type_id, :opportunity_type_name)";
				
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE process_opportunity SET name = :opportunity_type_name WHERE process_id = :process_id AND opportunity_type_id = :opportunity_type_id";
				
			stmtFindAll = new SQLStatement();
			stmtFindAll.sqlConnection = sqlConnection;
			stmtFindAll.text = "SELECT * FROM process_opportunity";
			
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM process_opportunity WHERE process_id = :process_id AND opportunity_type_id = :opportunity_type_id";
		}
		
		
		public function insert(processOpportunity:Object):void {
			executeStatement(stmtInsert,processOpportunity);
		}
		
		public function update(processOpportunity:Object):void {
			executeStatement(stmtUpdate,processOpportunity);	
		}
		
		private function executeStatement(stmt:SQLStatement,processOpportunity:Object):void {
			stmt.parameters[":opportunity_type_name"] = processOpportunity.opportunity_type_name;
			stmt.parameters[":process_id"] = processOpportunity.process_id;
			stmt.parameters[":opportunity_type_id"] = processOpportunity.opportunity_type_id;
			exec(stmt);
		}
		
		public function findAll():ArrayCollection {
			exec(stmtFindAll);
			var result:SQLResult = stmtFindAll.getResult();
			return new ArrayCollection(result.data);
		}
		
		public function find(processOpportunity:Object):Object{
			stmtFind.parameters[":process_id"] = processOpportunity.process_id;
			stmtFind.parameters[":opportunity_type_id"] = processOpportunity.opportunity_type_id;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0)
				return null;
			return result.data[0];
		}

	}
}