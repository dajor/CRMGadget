package gadget.dao
{

	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class FeedDAO extends SimpleTable {
		
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtSelect:SQLStatement;
		private var stmtSelectEnabled:SQLStatement;
		private var stmtFind:SQLStatement;

		public function FeedDAO(sqlConnection:SQLConnection, workerFunction:Function){
			super(sqlConnection, workerFunction, {
				table:"feeds",
				unique : ["entity"],
				columns: {
					'TEXT' : [ 'entity','display_name' ],
					'BOOLEAN': [ 'enabled' ]
				}
			});
			
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO feeds (entity, enabled, display_name) VALUES (:entity, :enabled, :display_name)";
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE feeds SET enabled = :enabled, display_name = :display_name WHERE entity = :entity";
			
			stmtSelect = new SQLStatement();
			stmtSelect.sqlConnection = sqlConnection;
			stmtSelect.text = "SELECT * FROM feeds";
			
			stmtSelectEnabled = new SQLStatement();
			stmtSelectEnabled.sqlConnection = sqlConnection;
			stmtSelectEnabled.text = "SELECT * FROM feeds WHERE enabled = 1";
			
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM feeds WHERE entity = :entity";
			
		}
		
		public function insertFeed(feed:Object):void {
			execStatement(stmtInsert, feed);
		}
		
		public function updateFeed(feed:Object):void {
			execStatement(stmtUpdate, feed);
		}
		
		private function execStatement(stmt:SQLStatement, object:Object):void{
			stmt.parameters[":entity"] = object.entity; 
			stmt.parameters[":enabled"] = object.enabled;
			stmt.parameters[":display_name"] = object.display_name;
			exec(stmt);
		}
		
		public function getFeeds():ArrayCollection{			
			exec(stmtSelect);
			return new ArrayCollection(stmtSelect.getResult().data);
		}
		
		public function getEnabledFeeds():ArrayCollection {
			exec(stmtSelectEnabled);
			return new ArrayCollection(stmtSelectEnabled.getResult().data);
		}
		
		public function isFeedExist(entity:String):Boolean {
			stmtFind.parameters[":entity"] = entity;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0) return false;
			return true;
		}
		
		public function isFeedEnabled(entity:String):Boolean {
			stmtFind.parameters[":entity"] = entity;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0) return false;
			return result.data[0].enabled;
		}
		
		public function find(entity:String):Object {
			stmtFind.parameters[":entity"] = entity;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0) return null;
			return result.data[0];
		}
		
	}
}
