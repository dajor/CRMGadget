// Keep the synced ranges in the database

package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	public class IncomingSyncHistoryDAO extends SimpleTable {
	
		public function IncomingSyncHistoryDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "incoming_sync_hist",
				unique: [ "task,start,end" ],
				index: [ "task,end", "task,timestamp" ],
				columns: {
					task:"TEXT not null",
					start:"TEXT not null",
					end:"TEXT not null",
					count:"NUMBER NOT NULL",
					timestamp:"NUMBER not null"
				}
			});
		}
	}
}
