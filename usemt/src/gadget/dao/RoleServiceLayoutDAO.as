package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class RoleServiceLayoutDAO extends SimpleTable {
		
		public function RoleServiceLayoutDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				drop_table:true,
				create_cb:function(struct:Object):void { Database.lastsyncDao.unsync('gadget.sync.task::RoleService'); },
				table: "role_service_layout",
				unique: [ 'RoleServiceRoleName,Layout,RecordType' ],
				index:[]
			});
		}
		
		override public function getColumns():Array {
			return [
				"RoleServiceRoleName",
				"Layout",	//Home, Search
				"RecordType",
				"LayoutName",
			];
		}
	}
}
