package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	public class FinderDAO extends SimpleTable {

		// private var stmtCount:SQLStatement;
		private var stmtFindAll:SQLStatement;
		
		public function FinderDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "finder",
				unique: [ 'id' ],
				columns: {
					'id' : 'TEXT PRIMARY KEY',
					'TEXT' : [ 'finder_table', 'display_column', 'key_column' ]
				}
			});
			
			/*stmtCount = new SQLStatement();
			stmtCount.sqlConnection = sqlConnection;
			stmtCount.text = "SELECT COUNT(*) AS total FROM finder";*/
			
			stmtFindAll = new SQLStatement();
			stmtFindAll.sqlConnection = sqlConnection;
		}
		
		public function insert_finder(finder:Object):void
		{
			insert({id:finder.id, finder_table:finder.finder_table, display_column:finder.display_column, key_column:finder.key_column});
		}
		
		public function read(finder:Object):Object
		{
			return fetch({id:finder.id})[0];
		}
		
		public function deleteAll():void {
			delete_all();
		}
		
		/*public function count():int {
			exec(stmtCount);
			var result:SQLResult = stmtCount.getResult();
			return result.data[0].total;
		}*/
		
		public function filterAll(columns:ArrayCollection, tableName:String, filter:String = null):ArrayCollection {
			var cols:String = '';
			for each (var column:Object in columns) {
				if(cols != '') cols += ", ";
				cols += column.element_name;
			}
			stmtFindAll.text = "SELECT " + cols + " FROM " + tableName + " WHERE " + (StringUtils.isEmpty(filter) ? "" : filter + " AND ") + " (deleted != 1)";
			trace(stmtFindAll);
			exec(stmtFindAll);
			return new ArrayCollection(stmtFindAll.getResult().data);
		}
		
	}
}