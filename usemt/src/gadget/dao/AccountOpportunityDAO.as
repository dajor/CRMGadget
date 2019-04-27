package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class AccountOpportunityDAO extends SubobjectTable
	{
		public function AccountOpportunityDAO(conn:SQLConnection,work:Function)
		{
			super(conn, work,"Account", "Opportunity");
		}
	}
}