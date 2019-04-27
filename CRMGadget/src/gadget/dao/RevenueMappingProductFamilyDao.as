package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class RevenueMappingProductFamilyDao extends SimpleTable
	{

		public function RevenueMappingProductFamilyDao(conn:SQLConnection, work:Function)
		{
			super(conn,work,  {
				table: 'revenue_mapping_product_family',
				index: ["ProductFamily"],
				columns: { 'TEXT' : textColumns }
			});
		}
		
		private var textColumns:Array = [
			"HIERARCHY_LV1",
			"HIERARCHY_LV2",
			"HIERARCHY_LV3",
			"HIERARCHY_LV4",
			"ProductFamily"
		];
		
	}
}