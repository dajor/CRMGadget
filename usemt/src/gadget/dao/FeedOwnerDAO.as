package gadget.dao
{

	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class FeedOwnerDAO extends BaseSQL {
		
		private var stmtGetOwner:SQLStatement;
		
		public function FeedOwnerDAO(sqlConnection:SQLConnection){
			stmtGetOwner = new SQLStatement();
			stmtGetOwner.sqlConnection = sqlConnection;
		}
		
		public function getOwner(entity:String):ArrayCollection {
			stmtGetOwner.text = "SELECT DISTINCT OwnerId, Owner FROM " + entity;
			exec(stmtGetOwner);
			return new ArrayCollection(stmtGetOwner.getResult().data);
		}
		
	}
}
