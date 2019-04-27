package gadget.dao {
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class DashboardLayoutDAO extends SimpleTable {
		
		private var stmtDeleteByFilterId:SQLStatement;
		private var stmtQueryDashboardReport:SQLStatement;
		
		public function DashboardLayoutDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'dashboard_layout',
				unique : ["column_name, col, row"],
				columns: { 'TEXT' : textColumns, "INTEGER": integerColumns}
			});
			
			stmtDeleteByFilterId = new SQLStatement();
			stmtDeleteByFilterId.sqlConnection = sqlConnection;
			stmtDeleteByFilterId.text = "DELETE FROM dashboard_layout WHERE column_name IN (SELECT column_name FROM dashboard_filter WHERE value = :value)";
			
			stmtQueryDashboardReport = new SQLStatement();
			stmtQueryDashboardReport.sqlConnection = sqlConnection;
			
		}
		
		private var textColumns:Array = [
			"column_name", 
			"custom"
		];
		
		private var integerColumns:Array = [
			"col",
			"row"
		];
		
		override public function insert(data:Object):SimpleTable {
			return super.insert(data);
		}
		
		public function findLayout(column_name:String):Object {
			var result:Array = fetch({column_name: column_name});
			return result.length > 0 ? result[0] : null;
		}
		
		public function deleteLayout(filter_id:String):void {
			stmtDeleteByFilterId.parameters[":value"] = filter_id;
			exec(stmtDeleteByFilterId);
		}
		
		public function selectLayout():ArrayCollection {
			return new ArrayCollection(super.select("*"));
		}
		
		public function getQueryReport(query:String):ArrayCollection {
			stmtQueryDashboardReport.text = query;
			exec(stmtQueryDashboardReport);
			var result:SQLResult = stmtQueryDashboardReport.getResult();
			if (result.data == null) return new ArrayCollection();
			return new ArrayCollection(result.data);
		}
		
	}
}