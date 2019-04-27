package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class ReportAdminDAO extends SimpleTable {
		
		public function ReportAdminDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table:"report_admin",
				index: [ 'type' ],
				columns: {					
					'TEXT' : [ "type", "report_path","auditor" ]
				}
			});
			
		}
		
		override public function insert(data:Object):SimpleTable {			
			delete_all();
			return super.insert(data);
		}
		
	}
}