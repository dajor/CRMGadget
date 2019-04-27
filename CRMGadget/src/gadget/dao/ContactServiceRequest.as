package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class ContactServiceRequest extends SubobjectTable
	{
		public function ContactServiceRequest(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, "Contact", "Service Request");
		}
	}
}