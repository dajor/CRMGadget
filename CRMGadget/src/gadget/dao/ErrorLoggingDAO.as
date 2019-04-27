//VAHI Store errors while syncing into database.
// We could store it into memory as well, but this way I can see it
// more easily while the app is running by looking into the DB.

package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.Event;
	
	import gadget.sync.SyncProcess;
	import gadget.util.StringUtils;
	import gadget.util.Utils;

	public class ErrorLoggingDAO extends SimpleTable {

		private var nr:Number;
		private var date:String;
		public static const SYNC_LOGS:String="Synchronize logs";
		public function ErrorLoggingDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "error_log",
				unique: [ "nr,name" ],
				columns: {
					nr:"NUMBER NOT NULL",
					name:"TEXT NOT NULL",
					date:"TEXT NOT NULL",
					len:"NUMBER NOT NULL",
					err:"TEXT NOT NULL"
				}
			});
		}

		private function insert_err(ob:Object):Number {
			for (var name:String in ob) {
				var o:Object = ob[name];
				var tmp:String = o!=null ? o.toString() : "(null)";
				insert({nr:nr, name:name, date:date, len:(o!=null ? tmp.length : 0), err:tmp});	//VAHI Now save all - I found out the hard way that this is a must.
			}
			return nr;
		}

		//VAHI call "add(e,{xml:xml.toXMLString(), ...})" in error handlers to record everything
		public function add(err:Error, args:Object):void {

			date = new Date().toUTCString();
			nr	= parseInt(select_one("ifnull(max(nr),0)+1").toString());

			//insert_err({caller:arguments.callee.caller});
			if (err!=null) {
				insert_err({error:err.toString(), stack:err.getStackTrace(), errId:err.errorID, errMsg:err.message});
				trace(err);
				trace(err.getStackTrace());
			}
			if (args!=null) {
				//expcet log 2032 CRO
				if(args.hasOwnProperty('event') ){
					
					if(args.event != null && args.event.toString().indexOf('#2032')<-1){
						insert_err(args);	
					}
				}else{
					insert_err(args);	
				}
				
			}
		}
		
		public function addSqlError(sqlError:String):void{
			date = new Date().toUTCString();
			nr	= parseInt(select_one("ifnull(max(nr),0)+1").toString());
			if(!StringUtils.isEmpty(sqlError)){
				insert_err({'error': 'Error while executing: '+sqlError});
			}
		}
		
		//VAHI dump all entries into some format suitable to send via eMail
		public function dump():String {
			var all:String;
			var version:Object = Utils.getAppInfo().version;
		
			all	= "";
			for each (var ob:Object in select("nr,name,date,len,err","order by nr,name")) {
				all += ob["nr"]+" "+ob["date"]+" -- <Version "+ version + "> - " + ob["name"]+" ("+ob["len"]+"): "+escape(ob["err"])+"\n";
			}
			return all;
		}
		
		// Bug #195
		public function dumpOnlyError():String {
			var all:String;
			var version:Object = Utils.getAppInfo().version;
			
			all	= "";
			//err like '%fault%' or err like '%error%' order by nr,name
			for each (var ob:Object in select("nr,name,date,len,err","where err like '%fault%' or err like '%error%' or name='" + SYNC_LOGS + "'")) {
				all += ob["nr"]+" "+ob["date"]+" -- <Version "+ version + "> - " + ob["name"]+" ("+ob["len"]+"): "+escape(ob["err"])+"\n";
			}
			return all;
		}
	}
}
