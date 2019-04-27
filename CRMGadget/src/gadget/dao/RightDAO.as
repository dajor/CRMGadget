/**
 * It is used to get the User's right 
 */
package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	
	public class RightDAO extends BaseSQL {
		
		private var stmtGetRights:SQLStatement;
		private var stmtGetRole:SQLStatement;
		
		public function RightDAO(sqlConnection:SQLConnection)
		{
			stmtGetRole = new SQLStatement();
			stmtGetRole.sqlConnection = sqlConnection;
			stmtGetRole.text = "SELECT a.role FROM user u, allusers a " +
				"WHERE u.user_sign_in_id = a.userSignInId";

			
			stmtGetRights = new SQLStatement();
			stmtGetRights.sqlConnection = sqlConnection;
			// the OR criteria below is a temporary bug fix for vetoquinol
			// we should join the tables on Role ID, not Role Name
			//Bug fixing 120 CRO
			//Bug --112 Mony
			stmtGetRights.text = "SELECT r.cancreate, r.hasaccess, r.recordname, r.RoleServiceRoleName " +
			" FROM role_service_type r WHERE r.RecordName = :entity AND r.roleServiceRoleName  = :role";
		}
		
		/**
		 * Returns the current user's role. 
		 * @return Current user's role.
		 */
		public function getRole():String {
			exec(stmtGetRole);
			var result:SQLResult = stmtGetRole.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0].Role;
		}
		
		/**
		 * Returns the access right associated with a role and an entity. 
		 * @param role Role.
		 * @param entity Entity.
		 * @return Corresponding access right.
		 */
		public function getRight(role:String, entity:String):Object {
			stmtGetRights.parameters[":role"] = role;
			stmtGetRights.parameters[":entity"] = entity;
			exec(stmtGetRights);
			var result:SQLResult = stmtGetRights.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
	}
}