package gadget.dao{
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	public class ReportDAO extends SimpleTable{
		
		private var stmtSelectLastId:SQLStatement;
		
		public function ReportDAO(sqlConnection:SQLConnection, work:Function){
			super(sqlConnection, work,
				{
					table: 'report',
					unique: [ 'id' ],
					columns: {
						'id' : 'INTEGER PRIMARY KEY AUTOINCREMENT',
						'TEXT' : ['name', 'entity', 'filter_id']
					}
				});
			stmtSelectLastId = new SQLStatement();
			stmtSelectLastId.sqlConnection = sqlConnection;
			stmtSelectLastId.text = "SELECT max(id) AS id FROM report";
		}
		
		public function selectAll():ArrayCollection{
			return new ArrayCollection(select_order("*", null, null, "name", null));
		}
		
		public function select_last_id():int{
			stmtSelectLastId.execute();
			var result:SQLResult = stmtSelectLastId.getResult();
			if(result.data == null || result.data.length==0){
				return 0;
			}
			return result.data[0].id;
		}
		
		public function updateReport(reportObject:Object):void{
			var criteria:Object = new Object();
			criteria.id = reportObject.id;
			update(reportObject, criteria);
		}
	}
}