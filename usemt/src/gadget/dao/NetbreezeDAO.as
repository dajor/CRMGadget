package gadget.dao
{
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	public class NetbreezeDAO extends BaseSQL {

		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtFind:SQLStatement;
		private var stmtRead:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var netbreezeDAO: NetbreezeDAO;
		public function NetbreezeDAO(sqlConnection:SQLConnection)
		{
			if(netbreezeDAO == null)
			{
				stmtInsert = new SQLStatement();
				stmtInsert.sqlConnection = sqlConnection;
				stmtInsert.text = "INSERT INTO netbreezeuser (id, full_name, user_sign_in_id, netbreeze_id)" +
					" VALUES (:id, :full_name, :user_sign_in_id, :netbreeze_id)";
				
				stmtFind = new SQLStatement();
				stmtFind.sqlConnection = sqlConnection;
				stmtFind.text = "SELECT * FROM netbreezeuser WHERE id = :id";
				
				stmtUpdate = new SQLStatement();
				stmtUpdate.sqlConnection = sqlConnection;
				stmtUpdate.text = "UPDATE netbreezeuser SET full_name = :full_name, user_sign_in_id = :user_sign_in_id, netbreeze_id = :netbreeze_id" +
					" WHERE id = :id";
				
				stmtRead = new SQLStatement();
				stmtRead.sqlConnection = sqlConnection;
				stmtRead.text = "SELECT * FROM netbreezeuser";
				
				stmtDelete = new SQLStatement();
				stmtDelete.sqlConnection = sqlConnection;
				stmtDelete.text = "DELETE FROM netbreezeuser";	
			}else
				netbreezeDAO = this;
			
		}
		
		public function deleteAll():void
		{
			exec(stmtDelete);
		}
		
		public function insert(netbreezeUser:Object):void
		{
			executeStatement(stmtInsert,netbreezeUser);
		}
		
		public function findByUserId(netbreezeUser:Object):Object
		{
			stmtFind.parameters[":id"] = netbreezeUser.id;
			exec(stmtFind);
			
			var result:SQLResult = stmtFind.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		public function update(user:Object):void
		{
			executeStatement(stmtUpdate,user);	
		}
		
		private function executeStatement(stmt:SQLStatement,netbreezeUser:Object):void
		{
			stmt.parameters[":id"] = netbreezeUser.id;
			stmt.parameters[":full_name"] = netbreezeUser.full_name;
			stmt.parameters[":user_sign_in_id"] = netbreezeUser.user_sign_in_id;
			stmt.parameters[":netbreeze_id"] = netbreezeUser.netbreeze_id;
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