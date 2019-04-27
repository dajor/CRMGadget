package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class SalesStageDAO  extends BaseSQL {

		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtFind:SQLStatement;
		private var stmtFindAll:SQLStatement;
		private var stmtFindBySalesPro:SQLStatement;
		private var stmtGetSaleProByOptType:SQLStatement;
		public function SalesStageDAO(sqlConnection:SQLConnection) {
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO salesstage (id, sales_proc_id, name, sales_stage_order, probability, sales_category_name)" +
				" VALUES (:id, :sales_proc_id, :name, :sales_stage_order, :probability, :sales_category_name)";
				
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM salesstage WHERE id = :id";

			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE salesstage SET name = :name, sales_proc_id = :sales_proc_id, sales_stage_order = :sales_stage_order, probability= :probability, sales_category_name= :sales_category_name" +
				" WHERE id = :id";
				
			stmtFindAll = new SQLStatement();
			stmtFindAll.sqlConnection = sqlConnection;
			stmtFindAll.text = "SELECT s.* FROM salesstage as s INNER JOIN salesproc as sl ON s.sales_proc_id=sl.id and sl.default_stage ='Y' order by sales_stage_order/1";
			
			 
			stmtFindBySalesPro = new SQLStatement();
			stmtFindBySalesPro.sqlConnection = sqlConnection;
			stmtFindBySalesPro.text = "SELECT * FROM salesstage where sales_proc_id =:sales_proc_id order by sales_stage_order/1";
			stmtGetSaleProByOptType  = new SQLStatement();
			stmtGetSaleProByOptType.sqlConnection = sqlConnection;
			stmtGetSaleProByOptType.text = "SELECT s.* FROM salesstage as s INNER JOIN process_opportunity as po ON s.sales_proc_id=po.process_id where po.opportunity_type_name=:OpportunityType order by sales_stage_order/1";

		}

	    public function findBySalesProId(sales_proc_id:String):ArrayCollection{
			stmtFindBySalesPro.parameters[":sales_proc_id"] = sales_proc_id;
			exec(stmtFindBySalesPro);
			var result:SQLResult = stmtFindBySalesPro.getResult();
			return new ArrayCollection(result.data);
		}
		
		public function findBySalesByOpptType(optType:String):ArrayCollection{
			stmtGetSaleProByOptType.parameters[":OpportunityType"] = optType;
			exec(stmtGetSaleProByOptType);
			var result:SQLResult = stmtGetSaleProByOptType.getResult();
			return new ArrayCollection(result.data);
		}
		
		public function insert(salesstage:Object):void {
			executeStatement(stmtInsert,salesstage);
		}
		
		public function find(salesstage:Object):Object {
			stmtFind.parameters[":id"] = salesstage.id;
			exec(stmtFind);
			
			var result:SQLResult = stmtFind.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		public function update(salesstage:Object):void {
			executeStatement(stmtUpdate,salesstage);	
		}
		
		private function executeStatement(stmt:SQLStatement,salesstage:Object):void {
			stmt.parameters[":name"] = salesstage.name;
			stmt.parameters[":sales_proc_id"] = salesstage.sales_proc_id;
			stmt.parameters[":sales_stage_order"] = salesstage.sales_stage_order;
			stmt.parameters[":id"] = salesstage.id;
			stmt.parameters[":probability"] = salesstage.probability;
			stmt.parameters[":sales_category_name"] = salesstage.sales_category_name;
			exec(stmt);
		}
		
		public function findAll():ArrayCollection {
			exec(stmtFindAll);
			var result:SQLResult = stmtFindAll.getResult();
			return new ArrayCollection(result.data);
		}
		
	}
}