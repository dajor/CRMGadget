package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class AccountCustomObject2DAO extends SubobjectTable
	{
		public function AccountCustomObject2DAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, "Account", "Custom Object 2");
		}
	}
}