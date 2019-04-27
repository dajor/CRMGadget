package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class AccountAccountDAO extends SubobjectTable
	{
		public function AccountAccountDAO( conn:SQLConnection,work:Function)
		{
			super( conn, work,"Account", "Account");
		}
	}
}