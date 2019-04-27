package gadget.dao
{

	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;
	
	public class FeedGroupDAO extends SimpleTable {

		public function FeedGroupDAO(sqlConnection:SQLConnection, workerFunction:Function){
			super(sqlConnection, workerFunction, {
				table:"feed_groups",
				unique : ["GroupName"],
				index: [ 'GroupName' ],
				columns: {
					'INTEGER': [ 'Id' ],
					'TEXT' : [ 'GroupName']
				}
			});
		}
		
		public function addGroup(group:Object):void {
			insert_auto_id(group);
		}
		
		public function select_groups():ArrayCollection {
			return new ArrayCollection(select("*"));
		}
		
	}
}