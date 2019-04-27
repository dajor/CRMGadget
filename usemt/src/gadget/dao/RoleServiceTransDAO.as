package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class RoleServiceTransDAO extends SimpleTable {
		
		public function RoleServiceTransDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				drop_table:true,
				create_cb:function(struct:Object):void { Database.lastsyncDao.unsync('gadget.sync.task::RoleService'); },
				table: "role_service_trans",
				unique: [ 'RoleServiceRoleName,LanguageCode' ],
				index:[]
			});
		}
		
		override public function getColumns():Array {
			return [
				"RoleServiceRoleName",
				"LanguageCode",
				"RoleName",
			];
		}
	}
}
