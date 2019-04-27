package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	public class RoleServiceDAO extends SimpleTable {
		private var stmtGetOwnerAccessPf:SQLStatement;
		private var stmtGetDefaultSaleProcess:SQLStatement;
		public function RoleServiceDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				drop_table:true,
				create_cb:function(struct:Object):void { Database.lastsyncDao.unsync('gadget.sync.task::RoleService'); },
				table: "role_service",
				unique: [ 'RoleName' ],
				index:[]
			});
			
			stmtGetOwnerAccessPf = new SQLStatement();
			stmtGetOwnerAccessPf.sqlConnection = sqlConnection;
			stmtGetOwnerAccessPf.text = "SELECT * FROM role_service rs " +
				"WHERE rs.RoleName = :rolename";
			
			
			stmtGetDefaultSaleProcess = new SQLStatement();
			stmtGetDefaultSaleProcess.sqlConnection = sqlConnection;
			stmtGetDefaultSaleProcess.text = "SELECT DefaultSalesProcess FROM role_service rs " +
				"WHERE rs.RoleName = :rolename";
		}
		
		public function getRole(roleServiceName:String):Object{
			stmtGetOwnerAccessPf.parameters[":rolename"]=roleServiceName;
			exec(stmtGetOwnerAccessPf);
			var result:SQLResult = stmtGetOwnerAccessPf.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
			
		}
		
		public function getDefaultSaleProcess(roleServiceName:String):String{
			stmtGetDefaultSaleProcess.parameters[":rolename"]=roleServiceName;
			exec(stmtGetDefaultSaleProcess);
			var result:SQLResult = stmtGetDefaultSaleProcess.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0].DefaultSalesProcess;
		}
		override public function delete_all():void {
			del(null);
			// Yuck!
			Database.roleServiceAvailableTabDao.delete_all();
			Database.roleServiceLayoutDao.delete_all();
			Database.roleServicePageLayoutDao.delete_all();
			Database.roleServicePrivilegeDao.delete_all();
			Database.roleServiceRecordTypeAccessDao.delete_all();
			Database.roleServiceSelectedTabDao.delete_all();
			Database.roleServiceTransDao.delete_all();
		}
		
		override public function getColumns():Array {
			return [
				"RoleName",
				"Description",
				"DefaultSalesProcess",
				"ThemeName",
				"LeadConversionLayout",
				"ActionBarLayout",
//				"AccessProfile",
				"DefaultAccessProfile",
				"OwnerAccessProfile",

/*
				"ListOfHomepageLayoutAssignment",
				"ListOfPageLayoutAssignment",
				"ListOfPrivilege",
				"ListOfRecordTypeAccess",
				"ListOfRoleTranslation",
				"ListOfSearchLayoutAssignment",
*/
/*
				"TabAccessAndOrder",
				=>"ListOfAvailableTab"
				=>"ListOfSelectedTabData"
*/
			];
		}
	}
}
