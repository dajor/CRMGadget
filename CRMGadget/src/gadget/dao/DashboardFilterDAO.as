package gadget.dao {
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	public class DashboardFilterDAO extends SimpleTable {
		
		private var stmtSelectColumnName:SQLStatement;
		private var stmtDeleteByFilterId:SQLStatement;
		
		public function DashboardFilterDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'dashboard_filter',
				index: ["column_name", "key"],
				unique : ["column_name, key"],
				columns: { 'TEXT' : textColumns}
			});
			
			stmtSelectColumnName = new SQLStatement();
			stmtSelectColumnName.sqlConnection = sqlConnection;
			stmtSelectColumnName.text = "SELECT column_name FROM dashboard_filter WHERE value = :value";
			
			stmtDeleteByFilterId = new SQLStatement();
			stmtDeleteByFilterId.sqlConnection = sqlConnection;
			stmtDeleteByFilterId.text = "DELETE FROM dashboard_filter WHERE column_name IN (SELECT column_name FROM dashboard_filter WHERE value = :value)";
			
		}
		
		private var textColumns:Array = [
			"column_name",
			"key", // store const FIELD_FILTERID, FIELD_OPERATOR, FIELD_SUM, FIELD_GROUPBY, FIELD_ORDERBY, FIELD_ORDER_DESC, FIELD_LIMIT, ...
			"value", // store column_name AccountName, AccountType
		];
		
		override public function replace(data:Object):SimpleTable {
			return super.replace(data);
		}
		
		public function selectColumnName(filter_id:String):Array {
			stmtSelectColumnName.parameters[":value"] = filter_id;
			exec(stmtSelectColumnName);
			var res:Array = stmtSelectColumnName.getResult().data;
			return (res != null && res.length > 0) ? res : [];
		}
		
		public function deleteFilter(filter_id:String):void {
			stmtDeleteByFilterId.parameters[":value"] = filter_id;
			exec(stmtDeleteByFilterId);
		}
		
		public function find(column_name:String, key:String):String {
			var result:Object = super.first({column_name: column_name, key: key});
			return result ? result.value : "";
		}
		
	}
}