// Keep the synced ranges in the database

package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import gadget.util.DateUtils;
	import gadget.util.OOPS;
	import gadget.util.StringUtils;

	public class IncomingSyncDAO extends BaseSQL {

		private var stmt:SQLStatement;

		private static const vers:String = "version1";		 // change this if the schema changes
		private static var isInitialized:Boolean = false;

		private function init(conn:SQLConnection):void {

			if (isInitialized) return;

			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = conn;

			try {
				stmt.text = 'SELECT '+vers+' FROM incoming_sync LIMIT 0;';
				exec(stmt);
			} catch (e:SQLError){

				stmt.text = "DROP TABLE incoming_sync";
				try { exec(stmt); } catch (e:SQLError) {}
				
				stmt.text = "CREATE TABLE incoming_sync ("+
					" task TEXT not null,"+
					" start TEXT not null,"+
					" end TEXT not null,"+
					" "+vers+" TEXT"+
					" );";
				exec(stmt);

			}
			
			isInitialized	= true;
		}
	
		public function IncomingSyncDAO(sqlConnection:SQLConnection) {
			stmt				= new SQLStatement();
			stmt.sqlConnection	= sqlConnection;

			init(sqlConnection);
		}
		
		protected function runSQL(query:String, params:Object):void {
			stmt.clearParameters();
			if (params)
				for (var p:String in params)
					stmt.parameters[':'+p]	= params[p];
			stmt.text		= query;
			exec(stmt);
		}
		
		protected function all(query:String, params:Object):Array {
			runSQL(query,params);
			return stmt.getResult().data;
		}

		// Do a full sync
		public function unsync_all():void {
			runSQL("DELETE FROM incoming_sync;", null);
			Database.lastsyncDao.unsync_all();
		}

		public function unsync_one(task:String,lastSyncName:String=null):void {
			runSQL("DELETE FROM incoming_sync where task=:task;", {task:task});
			if(StringUtils.isEmpty(lastSyncName)){
				Database.lastsyncDao.unsync(task);
			}else{
				Database.lastsyncDao.unsync(lastSyncName);
			}
		}
		
		public function is_unsynced(task:String):Boolean {
			runSQL("SELECT 1 FROM incoming_sync where task=:task;", {task:task});
			return stmt.getResult().data==null;
		}





		// find all range(s) in the database which falls into the passed in range
		public function findOverlapping(task:String, range:Object):Object {
			if (range.start>range.end) throw "negative Range";
			var o:Object = {task:task, start:DateUtils.toIsoDate(range.start), end:DateUtils.toIsoDate(range.end)};
			o.res = all("SELECT start,end FROM incoming_sync WHERE task=:task and start<=:end and end>=:start and start<=end;", o);
			return o;
		}

		public function RepairSodTime(time:Date, delta:int):Date {
			var repair_offset_minutes:Number = DateUtils.getCurrentTimeZone(time)*60;//Database.preferencesDao.getIntValue("SOD_TIME_OFFSET", 120);
			return new Date(time.getTime()+delta*repair_offset_minutes*60000);
		}
		
		//VAHI this function is a big ultra mess
		public function repairSodRanges(task:String):void {
			// Find maximum date synced so far
			var ans:Array = all("SELECT max(end) as max FROM incoming_sync WHERE task=:task or task='MAX '||:task;", {task:task});
			if (ans.length<1 || ans[0].max==null)
				return;
			// Substract the SOD_TIME_OFFSET TWO TIMES
			OOPS("=fix time",'TASK '+task+' MAX '+ans[0].max);
			//var max:Date = RepairSodTime(DateUtils.fromIsoDate(ans[0].max),-2);
			//var maxVal:String = DateUtils.toIsoDate(max);
			// Find all ranges which end after the maxValue and move the end time accordingly.
			// If start-time is after max then keep it as sync barrier (this is start==end)
			//runSQL("UPDATE incoming_sync SET end=max(start,:max) where task=:task and end>:max and start<>end;", {task:task,max:maxVal});
			runSQL("DELETE FROM incoming_sync WHERE task='MAX '||:task;", {task:task});
			runSQL("INSERT INTO incoming_sync (task,start,end) VALUES ('MAX '||:task,:old,:old);", {task:task,old:ans[0].max});
			/*
				for each (var rec:Object in all("SELECT * FROM incoming_sync WHERE task=:task and end>:max and start<>end", {task:task,max:maxVal})) {
				rec.val = rec.start>maxVal ? rec.start : maxVal;
				// Fix the end time
				exec("UPDATE incoming_sync SET end=:val where task=:task and start=:start and end=:end", rec);
			}
			*/
		}

		// Find some unsynced date range
		// Try to find some which is near the end
		public function getDateRange(task:String, range:Object):Object {
			var e:Object;
			
			if (!range)
				range	= {}
			if (!range.start)
				range.start	= new Date(Date.UTC(1970,0,1,0,0,0));	// Start of the epoch
			if (!range.end)
				range.end	= new Date();				// This is bad, don't use, use the SoD date!

			var o:Object = findOverlapping(task,range);
			var loop:Boolean = true;

			while (loop) {
				loop	= false;
				var ostart:Date = DateUtils.fromIsoDate(o.start);
				var oend:Date = DateUtils.fromIsoDate(o.end);
				for each (e in o.res) {
					var estart:Date = DateUtils.fromIsoDate(e.start);
					var eend:Date = DateUtils.fromIsoDate(e.end);
					if (estart.getTime()<=ostart.getTime() && eend.getTime()>ostart.getTime()) {
						o.start	= e.end;
						loop	= true;
					}
					if (eend.getTime()>=oend.getTime() && estart.getTime()<oend.getTime()) {
						o.end	= e.start;
						loop	= true;
					}
				}
			}
			var start:Date = DateUtils.fromIsoDate(o.start);
			var end:Date = DateUtils.fromIsoDate(o.end);
			// Range is dead
			if (start.getTime()>=end.getTime()) {
				trace("dateRange: none");
				return null;
			}

			// Now we have some gap, find the bottom (newest) gap
			for each (e in o.res) {
				trace("splits",e.start,"to",e.end);
				var estart1:Date = DateUtils.fromIsoDate(e.start);
				var eend1:Date = DateUtils.fromIsoDate(e.end);
				if (start.getTime()<eend1.getTime() && eend1.getTime()<end.getTime())
					o.start	= e.end;
			}
			trace("dateRange",o.start,"to",o.end);
			return { start:DateUtils.fromIsoDate(o.start), end:DateUtils.fromIsoDate(o.end) }
		}

		// Add a range of successfully synced records
		// A range of a single date (a..a) acts as split barrier.
		// ranges are fetched including the borders, so each
		// split barrier is synced twice (if records happen to have the exact date).
		public function addRange(task:String, range:Object):void {

			// XXX do we need a transaction here?
			// Usually only a single thread is supposed to call this.

			// find an overlapping range
			var o:Object = findOverlapping(task,range);
			var ostart:Date = DateUtils.fromIsoDate(o.start);
			var oend:Date = DateUtils.fromIsoDate(o.end);
			for each (var e:Object in o.res) {
				var estart:Date = DateUtils.fromIsoDate(e.start);
				var eend:Date = DateUtils.fromIsoDate(e.end);
				if (estart.getTime()<ostart.getTime() && eend.getTime()>=ostart.getTime())
				  	o.start	= e.start;
				if (eend.getTime()>oend.getTime() && estart.getTime()<=oend.getTime())
					o.end	= e.end;
			}

			delete o.res;
			runSQL("DELETE FROM incoming_sync where task=:task and start>=:start and end<=:end;", o);
			runSQL("INSERT INTO incoming_sync ( task, start, end ) VALUES ( :task, :start, :end );", o);
		}
		
		// Split the range in half.  This is, add a barrier into it
		// Refuse to split if the range is too small
		public function splitRange(task:String, range:Object):Boolean {
			var delta:Number = range.end.getTime()-range.start.getTime();
			if (delta<300000)	// 5 minutes
				return true;
			var mid:Date = new Date(range.start.getTime()+Math.floor(delta/2));
			addRange(task,{start:mid,end:mid});
			return false;
		}

	}
}
