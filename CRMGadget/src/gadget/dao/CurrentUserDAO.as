package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;

	public class CurrentUserDAO extends BaseSQL
	{
		
		private var stmtGetCurrentUser:SQLStatement;
		
		public function CurrentUserDAO(sqlConnection:SQLConnection)
		{
			super();
			
			stmtGetCurrentUser = new SQLStatement();
			stmtGetCurrentUser.sqlConnection = sqlConnection;
			stmtGetCurrentUser.text = "SELECT u.id, u.full_name, u.Avatar, au.userloginid, u.user_sign_in_id FROM user u inner join allusers au on u.id = au.id";

		}
		
		public function getCurrentUser():Object {
			exec(stmtGetCurrentUser);
			var result:SQLResult = stmtGetCurrentUser.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
	}
}