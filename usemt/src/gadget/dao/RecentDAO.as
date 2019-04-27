package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class RecentDAO extends SimpleTable {

		private var stmtDelete:SQLStatement;
		private var limit:int;
		
		public function RecentDAO(sqlConnection:SQLConnection, limit:int, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"recent",
				unique: [ 'num' ],
				columns: {
					'num' : 'INTEGER PRIMARY KEY',
					'TEXT' : [ 'entity', 'id' ]
				}
			});
			
			
			this.limit = limit;
	
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM recent WHERE num < (select max(num) from recent) - :limit";
		}
		
		public function insert_recently(recentObj:Object):void
		{
			if(find(recentObj) == null){
				deleteOutOfLimit();
				insert({entity:recentObj.entity, id:recentObj.id});
			}
		}
		
		private function find(recentObj:Object):Object
		{
			return select_first("*", null, {entity:recentObj.entity,id:recentObj.id}, limit.toString());
		}
		
		private function deleteOutOfLimit():void
		{
			stmtDelete.parameters[":limit"] = limit;
			exec(stmtDelete);
		}
		
		public function read():ArrayCollection
		{
			return new ArrayCollection(select_order("*",null,null,"num desc",limit.toString()));
		}
		
	}
}