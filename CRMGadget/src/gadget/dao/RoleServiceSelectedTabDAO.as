package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class RoleServiceSelectedTabDAO extends SimpleTable {
		
		public function RoleServiceSelectedTabDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				drop_table:true,
				create_cb:function(struct:Object):void { Database.lastsyncDao.unsync('gadget.sync.task::RoleService'); },
				table: "role_service_sel_tab",
				unique: [ /*'RoleServiceRoleName,TabName' this isn't unique,*/ 'RoleServiceRoleName,Order_' ],
				index:[],
				columns: { TEXT:["RoleServiceRoleName", "TabName"], NUMBER:['Order_'] }
			});
		}
		
		override public function getColumns():Array {
			return [
				"RoleServiceRoleName",
				"TabName",
				"Order_",
			];
		}
	}
}
