package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class CO4C05Dao extends SubobjectTable
	{
		public function CO4C05Dao(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, "CustomObject4", "CustomObject5");
		}
	}
}