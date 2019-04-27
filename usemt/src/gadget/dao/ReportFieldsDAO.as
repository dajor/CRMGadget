package gadget.dao{
	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;
	
	public class ReportFieldsDAO extends SimpleTable {
		
		public function ReportFieldsDAO(sqlConnection:SQLConnection, work:Function){
			super(sqlConnection, work,
				{
					table: 'report_fields',
					unique: [ 'id, num' ],
					columns: {
						'TEXT' : ['element_name'],
						'INTEGER' : ['id', 'num']
					}
				});
		}
		
		public function getFieldsReport(criteria:Object):ArrayCollection{
			return new ArrayCollection(select_order("element_name", null, criteria, "num", null));
		}		
	}
}