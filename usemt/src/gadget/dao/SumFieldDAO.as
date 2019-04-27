package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;

	public class SumFieldDAO extends SimpleTable
	{
		private var stmtSelByColId:SQLStatement;
		private var stmtSelectBySumField:SQLStatement;
		private var textColumns:Array = [
			"ColId",  
			"ModelId",
			"ModelTotal", 
			"PageTotal",
			"SectionTotal"];
		public function SumFieldDAO(sqlConnection:SQLConnection, work:Function)
		{
			super(sqlConnection, work, {
				table: 'sumfield',
				unique:['ColId,ModelId'],
				display_name : "sumfields",				
				columns: {'gadget_id': "INTEGER PRIMARY KEY AUTOINCREMENT", 'TEXT' : textColumns}
			});
			
			stmtSelectBySumField = new SQLStatement();
			stmtSelectBySumField.sqlConnection = sqlConnection;
			stmtSelectBySumField.text = "SELECT  * FROM sumfield WHERE ModelId = :ModelId";
			
			
			stmtSelByColId = new SQLStatement();
			stmtSelByColId.sqlConnection = sqlConnection;
			stmtSelByColId.text = "SELECT  * FROM sumfield WHERE ColId = :ColId";
		}
		
		public function getAllSumField(modelId:String):Array{
			stmtSelectBySumField.parameters[":ModelId"] = modelId;
			//var result:Array =  select_order("*", "IsHasSumField", stmtSelectBySumField, "OrderNum",null);
			exec(stmtSelectBySumField);
			var data:Array = stmtSelectBySumField.getResult().data;
			return data;
		}
		
		public function getSumFieldByColId(colId:String):Array{
			stmtSelByColId.parameters[":ColId"] = colId;
			var data:Array = stmtSelByColId.getResult().data;
			return data;
		}
	
	}
}