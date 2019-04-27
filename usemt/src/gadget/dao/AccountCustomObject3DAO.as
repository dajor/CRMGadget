package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class AccountCustomObject3DAO extends SubobjectTable
	{
		public function AccountCustomObject3DAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, "Account", "Custom Object 3");
		}
	}
}