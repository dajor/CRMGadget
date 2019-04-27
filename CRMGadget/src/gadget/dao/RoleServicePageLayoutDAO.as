package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class RoleServicePageLayoutDAO extends SimpleTable {
		
		public function RoleServicePageLayoutDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				drop_table:true,
				create_cb:function(struct:Object):void { Database.lastsyncDao.unsync('gadget.sync.task::RoleService'); },
				table: "role_service_page",
				unique: [ 'RoleServiceRoleName,RecordType' ],
				index:[]
			});
		}
		
		override public function getColumns():Array {
			return [
				"RoleServiceRoleName",
				"LayoutName",
				"PageViewType",
				"RecordType",
			];
		}
	}
}
