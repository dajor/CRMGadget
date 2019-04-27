package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class SQLListDAO extends SimpleTable {
		
		public function SQLListDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table:"sql_filter_criteria",
				index: [ 'entity_src', 'entity_dest' ],
				columns: {					
					'TEXT' : [ 'entity_src', 'list_name', 'entity_dest', 'column_name', 'operator', 'param', 'conjunction', 'columns' ],
					'INTEGER' : ['num']
				}
			});		
			
		}
		
		public function _select(entity_src:String, list_name:String):ArrayCollection {
			return new ArrayCollection(fetch({entity_src: entity_src, list_name: list_name}));
		}
		
		public function find(entity_src:String, list_name:String, num:String):Object {
			var result:Array = fetch({entity_src: entity_src, list_name: list_name, num: num});
			return result.length == 0 ? null : result[0];
		}
		
		public function _delete(entity_src:String, list_name:String):void {
			delete_({entity_src: entity_src, list_name: list_name});
		}
		
	}
}