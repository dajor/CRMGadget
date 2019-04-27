package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	public class AccountObjectiveDAO extends SubobjectTable
	{
		public function AccountObjectiveDAO(work:Function, sqlConnection:SQLConnection)
		{
			super(sqlConnection,work,'Account', 'Objectives');
			
		}
		
		override protected function get mandatoryColumns():Object{
			return  {
				Main:				"TEXT",
				Sub:				"TEXT",
				ModificationDate:	"TEXT",
				updated:			"INTEGER  DEFAULT 1"
			};
		}
	}
}