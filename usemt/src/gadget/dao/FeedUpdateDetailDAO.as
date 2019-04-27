package gadget.dao
{

	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;
	
	public class FeedUpdateDetailDAO extends SimpleTable {

		public function FeedUpdateDetailDAO(sqlConnection:SQLConnection, workerFunction:Function){
			super(sqlConnection, workerFunction, {
				table:"feed_update_details",
				index: [ 'FieldName' ],
				columns: {
					'INTEGER': [ 'FeedUpdateId' ],
					'TEXT' : [ 'FieldName', 'ValueBefore','ValueAfter' ]
				}
			});
		}
		
		public function select_feed_udpate_details(id:String):ArrayCollection {
			return new ArrayCollection(select("*", null, {'FeedUpdateId':id}));
		}
		
	}
}