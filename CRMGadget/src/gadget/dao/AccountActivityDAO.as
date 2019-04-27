//VAHI THIS IS NO MORE NEEDED I THINK
package gadget.dao
{
	import flash.data.SQLConnection;

	public class AccountActivityDAO extends SubobjectTable
	{
		public function AccountActivityDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, "Account", "Activity");
		}
	}
}