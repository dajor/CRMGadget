package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class AccessProfileServiceEntryDAO extends SimpleTable {
		
		public function AccessProfileServiceEntryDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "access_profile_entry",
				unique: [ 'AccessProfileServiceName,AccessObjectName' ],
				index:[]
			});
		}
		
		public function selectAll(limit:String,offset:String):Array{
			runSQL("select * from access_profile_entry",null,null,null,limit,offset);
			return stmt.getResult().data; 
		}
		
		
		
		override public function getColumns():Array {
			return [
				'AccessProfileServiceName',
				'AccessObjectName',
				'PermissionCode',
			];
		}
	}
}
