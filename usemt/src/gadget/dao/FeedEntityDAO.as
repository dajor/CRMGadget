package gadget.dao
{
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class FeedEntityDAO extends SimpleTable {
		
		public function FeedEntityDAO(sqlConnection:SQLConnection, workerFunction:Function){
			super(sqlConnection, workerFunction, {
				table:"feed_entities",
				unique : ["Entity, Id"],
				columns: {
					'TEXT' : [ 'Entity', 'Id', 'OwnerId', 'Alias' ]
				}
			});
		}
		
		public function select_feed_entities():ArrayCollection {
			return new ArrayCollection(select("*"));
		}
		
		public function select_distinct_feed_entities():ArrayCollection {
			return new ArrayCollection(select("distinct Entity, OwnerId"));
		}
		
		public function select_feed_entity(entity:String, id:String):ArrayCollection {
			return new ArrayCollection(select("*", null, {'Entity':entity, 'Id': id}));
		}
		
		public function isFeedEntityExist(entity:String, id:String):Boolean {
			var rst:ArrayCollection = select_feed_entity(entity,id);
			if(rst.length == 0) return false;
			else return true;
		}
		
	}
}
