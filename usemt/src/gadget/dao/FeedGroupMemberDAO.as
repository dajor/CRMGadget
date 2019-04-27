package gadget.dao
{

	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;
	
	public class FeedGroupMemberDAO extends SimpleTable {

		public function FeedGroupMemberDAO(sqlConnection:SQLConnection, workerFunction:Function){
			super(sqlConnection, workerFunction, {
				table:"feed_group_members",
				unique: [ 'Id, GroupId' ],
				columns: {
					'INTEGER': [ 'GroupId' ],
					'TEXT' : [ 'Id', 'Alias' ]
				}
			});
		}
		
		public function select_member(groupId:String):ArrayCollection {
			return new ArrayCollection(select("*", null, {'GroupId':groupId}));
		}
		
		public function select_members():ArrayCollection {
			return new ArrayCollection(select("*"));
		}
		
	}
}