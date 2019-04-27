package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class RoleServiceAvailableTabDAO extends SimpleTable {
		
		public function RoleServiceAvailableTabDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				drop_table:true,
				create_cb:function(struct:Object):void { Database.lastsyncDao.unsync('gadget.sync.task::RoleService'); },
				table: "role_service_avail_tab",
				unique: [ 'RoleServiceRoleName,AvailableTab' ],
				index:[]
			});
		}
		
		override public function getColumns():Array {
			return [
				"RoleServiceRoleName",
				"AvailableTab",
			];
		}
	}
}
