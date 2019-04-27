package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.util.DateUtils;
	
	import mx.collections.ArrayCollection;
	
	public class FeedHistoryDAO extends SimpleTable {
		
		private var stmtFeedFilterCurrentDay:SQLStatement;
		private var stmtDeleteFeedHistoryByDay:SQLStatement;
		
		public function FeedHistoryDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"feed_history",
				index: [ 'commentchannel, isparent, userid, username, commenttime, commenttext, feedfilter, operation, recordid, recordname, entity, commentchildchannel' ]
			});
			stmtFeedFilterCurrentDay = new SQLStatement();
			stmtFeedFilterCurrentDay.sqlConnection = sqlConnection;
			stmtFeedFilterCurrentDay.text = "SELECT * FROM feed_history WHERE STRFTIME('%Y-%m-%d', commenttime) = STRFTIME('%Y-%m-%d', 'now')";
			
			stmtDeleteFeedHistoryByDay = new SQLStatement();
			stmtDeleteFeedHistoryByDay.sqlConnection = sqlConnection;
			stmtDeleteFeedHistoryByDay.text = "DELETE FROM feed_history WHERE STRFTIME('%Y-%m-%d', commenttime) <= STRFTIME('%Y-%m-%d', 'now', '-' || :day || 'day')";
		}
		
		public function deleteFeedHistoryByDay(day:int):void {
			stmtDeleteFeedHistoryByDay.parameters[':day'] = day;
			exec(stmtDeleteFeedHistoryByDay);
		}
		
		public function getCurrentDayFeedHistory():ArrayCollection {
			exec(stmtFeedFilterCurrentDay);
			var result:SQLResult = stmtFeedFilterCurrentDay.getResult();
			return (result.data != null && result.data.length > 0 ? new ArrayCollection(result.data) : new ArrayCollection());
		}
		
		public function getAllFeedHistory():ArrayCollection {
			return new ArrayCollection(fetch());
		}

		override public function getColumns():Array {
			return [
				'commentchannel',
				'isparent',
				'userid',
				'username',
				'commenttime',
				'commenttext',
				'feedfilter',
				'operation',
				'recordid',
				'recordname',
				'entity',
				'commentchildchannel'
			];
		}
	}
}