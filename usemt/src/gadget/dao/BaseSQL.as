//VAHI New Baseclass to funnel SQL low level calls through one single interface
package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.data.SQLTransactionLockType;
	import flash.errors.SQLError;
	
	import gadget.i18n.i18n;
	
	public class BaseSQL {


		private static function catchError(fn:Function):Error {
			var loops:int = 0;
			for (;;) {
				try {
					fn();
					break;
				} catch (e:Error) {
					if (!(e is SQLError) || e.errorID!=3119) {
						return e;
					}
					if (!loops)
						trace("database locked, retrying");
					loops++;
					// Braindead AIR does not provide a synchronous sleep
					// so we busy loop here
				}
			}
			if (loops)
				trace("database available again, "+loops+" loops");
			return null;
		}

		private static function retried(fn:Function):void {
			var e:Error = catchError(fn);
			if (e==null)
				return;
			trace(e.getStackTrace());
			trace(e);
			throw e;
		}
		
		/** Execute SQL statement - with retry.
		 * 
		 * @param stmt:SQLStatement the statement to execute
		 * @return Boolean false if exec went normal, true if SQLError occured
		 */
		protected static function SQLexecError(stmt:SQLStatement):Boolean {
			function run():void {
				stmt.execute();
			}
			var e:Error = catchError(run);
			if (e==null)
				return false;
			if (!(e is SQLError)) {
				traceParameters(stmt);
				trace(e.getStackTrace());
				trace(e);
				throw e;
			}
			trace(e);
			return true;
		}
		
		/** Execute SQL statement - with retry, tracing and stuff.
		 * 
		 * @param stmt:SQLStatement the statement to execute
		 * @param traceParam false: statement only; true: with parameters
		 */
		protected static function exec(stmt:SQLStatement, traceParam:Boolean=false):void {
			if (traceParam) {
				traceParameters(stmt);
			} else {
				trace("SQL",stmt.text);
			}
			function run():void {
				stmt.execute();
			}
			var e:Error = catchError(run);
			if (e==null)
				return;
			
			trace(e.getStackTrace());
			trace(e);
			if (e is SQLError && e.errorID==3115 && stmt.text!=null ) {				
				if(stmt.text.toLowerCase().indexOf("index") != -1){
					Database.errorLoggingDao.addSqlError(stmt.text);
					Database.errorLoggingDao.add(e,null);
				}
				// "normal" error that occurs when trying to delete old indexes
				throw e;
			}
			
			throw e;
		}

		protected static function begin(conn:SQLConnection):void {
			retried(function():void{
				conn.begin(SQLTransactionLockType.EXCLUSIVE);
			});
		}
		
		protected static function commit(conn:SQLConnection):void {
			retried(function():void{
				conn.commit();
			});
		}

		protected static function rollback(conn:SQLConnection):void {
			retried(function():void{
				conn.rollback();
			});
		}
		
		protected static function loadSchema(conn:SQLConnection, type:Class, name:String):void {
			//VAHI actually this does not work.
			// If a database is locked this is treated as if the Schema does not exist.
			// Apparently, this is a BUG in AIR.
			retried(function():void{
				conn.loadSchema(type,name);
			});
		}

		private static function traceParameters(stmt:SQLStatement):void {
			trace("SQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQL");
			trace("SQL", stmt.text);
			for (var s:String in stmt.parameters) {
				trace("SQL",s,"=",stmt.parameters[s]);
			}
			trace("SQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQLSQL");
		}
	}
}
