package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class OrderTemplateItem extends SimpleTable
	{
		public function OrderTemplateItem(sqlConnection:SQLConnection, work:Function)
		{
			super( sqlConnection, work, {
				table: 'order_template_item',
				oracle_id: 'gadget_id',
				name_column: [ 'ItemName' ],
				search_columns: [ 'ItemId' ],
				drop_table:true,
				display_name : "ItemName",
				index: ["TemplateId",'TemplateName'],
				unique:['gadget_id'],								
				columns: {'TEXT' : textColumns,'gadget_id': "INTEGER PRIMARY KEY AUTOINCREMENT" }
			});
		}
		
		private var textColumns:Array = ["TemplateId",	"TemplateName",	"Qty",				
			"ItemNo",
			"ItemId",
			"ItemName",
			"PlantId",
			"PlantName"
		];
	}
}