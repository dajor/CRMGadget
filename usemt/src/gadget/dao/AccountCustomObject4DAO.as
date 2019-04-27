package gadget.dao
{
	import flash.data.SQLConnection;

	public class AccountCustomObject4DAO extends SubobjectTable
	{
		public function AccountCustomObject4DAO(sqlConnection:SQLConnection, workerFunction:Function){
			super(sqlConnection, workerFunction, "Account", "CustomObject4");
		}
	}
}