package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class AccountServiceRequestDAO extends SubobjectTable
	{
		public function AccountServiceRequestDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, "Account", "Service Request");
		}
	}
}