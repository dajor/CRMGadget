//VAHI probably no more needed, retire when no more refefenced
package gadget.dao
{
	import flash.data.SQLConnection;

	public class SubobjectTable extends SimpleTable
	{
		private var mainId:String;
		private var subId:String;

		public function SubobjectTable(sqlConnection:SQLConnection, workerFunction:Function, main:String, sub:String)
		{
			mainId	= main.replace(/ /g,"")+"Id";
			subId	= sub.replace(/ /g,"")+"Id";

			super(sqlConnection, workerFunction, {
				table:main.toLowerCase().replace(/ /g,"_")+"_"+sub.toLowerCase().replace(/ /g,"_"),
				unique: [ "Main,Sub" ],
				index: [ "updated" ],
				columns:mandatoryColumns
			});
		}
		
		protected function get mandatoryColumns():Object{
			return  {
				Main:				"TEXT NOT NULL",
				Sub:				"TEXT NOT NULL",
				ModificationDate:	"TEXT NOT NULL",
				updated:			"INTEGER NOT NULL DEFAULT 1"
			};
		}
		
		// Params:
		// AccountID, ActivityID, ModificationDate
		public function store(First:String, Sub:String, ModificationDate:String):void {
			//begin();
			replace({First:First, Sub:Sub, ModificationDate:ModificationDate, updated:1});
			//update({ModificationDate:ModificationDate, updated:1},"where AccountID=:AccountID and ActivityID=:ActivityID and ModificationDate!=:ModificationDate",{First:First, Sub:Sub});
			//commit();
		}
	}
}