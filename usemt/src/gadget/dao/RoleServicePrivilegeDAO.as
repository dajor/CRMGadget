package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class RoleServicePrivilegeDAO extends SimpleTable {
		
		public function RoleServicePrivilegeDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				drop_table:true,
				create_cb:function(struct:Object):void { Database.lastsyncDao.unsync('gadget.sync.task::RoleService'); },
				table: "role_service_priv",
				unique: [ 'RoleServiceRoleName,PrivilegeName' ],
				index:[]
//DOES NOT WORK	, columns: { TEXT:["RoleServiceRoleName", "PrivilegeName"], BOOLEAN:['Enabled'] }
			});
		}
		
		override public function getColumns():Array {
			return [
				"RoleServiceRoleName",
				"PrivilegeName",
				"Enabled",
			];
		}
	}
}
