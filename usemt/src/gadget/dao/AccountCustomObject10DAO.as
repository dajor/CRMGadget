package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class AccountCustomObject10DAO extends SubobjectTable
	{
		public function AccountCustomObject10DAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, "Account", "CustomObject10");
		}
	}
}