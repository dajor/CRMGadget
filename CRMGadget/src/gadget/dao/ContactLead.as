package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class ContactLead extends SubobjectTable
	{
		public function ContactLead(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, "Contact", "Lead");
		}
	}
}