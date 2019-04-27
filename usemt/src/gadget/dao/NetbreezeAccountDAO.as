package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	public class NetbreezeAccountDAO extends BaseSQL {

		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtFind:SQLStatement;
		private var stmtRead:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtDeleteByAccountId:SQLStatement;
		
		public function NetbreezeAccountDAO(sqlConnection:SQLConnection)
		{
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO netbreeze_account (account_id, account_name, dashboard_url, user_id)" +
				" VALUES (:account_id, :account_name, :dashboard_url, :user_id)";
			
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM netbreeze_account WHERE account_id = :account_id";
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE netbreeze_account SET account_name = :account_name, dashboard_url = :dashboard_url, user_id = :user_id" +
				" WHERE account_id = :account_id";
			
			stmtRead = new SQLStatement();
			stmtRead.sqlConnection = sqlConnection;
			stmtRead.text = "SELECT * FROM netbreeze_account";
			
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM netbreeze_account";
			
			stmtDeleteByAccountId = new SQLStatement();
			stmtDeleteByAccountId.sqlConnection = sqlConnection;
			stmtDeleteByAccountId.text = "DELETE FROM netbreeze_account WHERE account_id = :account_id";
		}
		
		public function deleteAll():void
		{
			exec(stmtDelete);
		}
		
		public function deleteByAccountId(netbreezeAccount:Object): void
		{
			stmtDeleteByAccountId.parameters[":account_id"] = netbreezeAccount.account_id;
			exec(stmtDeleteByAccountId);
		}
		
		public function insert(netbreezeAccount:Object):void
		{
			executeStatement(stmtInsert,netbreezeAccount);
		}
		
		public function findByAccountID(netbreezeAccount:Object):Object
		{
			stmtFind.parameters[":account_id"] = netbreezeAccount.account_id;
			exec(stmtFind);
			
			var result:SQLResult = stmtFind.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		public function update(netbreezeAccount:Object):void
		{
			executeStatement(stmtUpdate,netbreezeAccount);	
		}
		
		private function executeStatement(stmt:SQLStatement,netbreezeAccount:Object):void
		{
			stmt.parameters[":account_id"] = netbreezeAccount.account_id;
			stmt.parameters[":account_name"] = netbreezeAccount.account_name;
			stmt.parameters[":user_id"] = netbreezeAccount.user_id;
			stmt.parameters[":dashboard_url"] = netbreezeAccount.dashboard_url;
			exec(stmt);
		}
		
		public function read():Object
		{
			exec(stmtRead);
			var result:SQLResult = stmtRead.getResult();
			if (result.data == null) {
				return null;
			}
			return result.data[0];
		}
	}
}