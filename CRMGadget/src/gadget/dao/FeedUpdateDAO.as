package gadget.dao
{

	import flash.data.SQLConnection;
	
	import gadget.util.DateUtils;
	
	import mx.collections.ArrayCollection;
	
	public class FeedUpdateDAO extends SimpleTable {

		public function FeedUpdateDAO(sqlConnection:SQLConnection, workerFunction:Function){
			super(sqlConnection, workerFunction, {
				table:"feed_updates",
				unique : ["Id"],
				columns: {
					'INTEGER': [ 'Id' ],
					'TEXT' : [ 'Entity', 'ModifiedBy', 'ModifiedByAlias', 'ModifiedDate' ],
					'BOOLEAN': [ 'StatusSend' ]
				}
			});
			
		}
				
		public function insertFeedUpdate(data:Object):void {
			insert_auto_id(data);
		}
		
		public function select_feed_updates_on_date(date:Date):ArrayCollection {
			return new ArrayCollection( select("*","ModifiedDate='" + DateUtils.format(date, DateUtils.DATABASE_DATE_FORMAT) + "'") );
		}
		
		public function select_feed_updates():ArrayCollection {
			return new ArrayCollection(select("*", "StatusSend=0"));
		}
		
		public function select_last_insert():Object {
			var result:ArrayCollection = new ArrayCollection(select_order("*",null,null,"Id DESC", "1"));
			if(result.length > 0) return result[0];
			return null;
		}
		
		public function delete_feed_updates_send():void {
			delete_({'StatusSend':1});
		}
		
	}
}
