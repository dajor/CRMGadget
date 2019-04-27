package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class ContactOpportunityDAO extends SubobjectTable
	{
		public function ContactOpportunityDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, "Contact", "Opportunity");
		}
	}
}