package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class ReportAdminChildDAO extends SimpleTable {
		
		public function ReportAdminChildDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table:"report_admin_child",
				index: [ 'report_name' ],
				columns: {					
					'TEXT' : [ 'report_name', 'report_code' ]
				}
			});
			
		}
		
		override public function insert(data:Object):SimpleTable {
			return super.insert(data);
		}
		
	}
}