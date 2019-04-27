package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class OrderTemplate extends SimpleTable
	{
		public function OrderTemplate(sqlConnection:SQLConnection, work:Function)
		{
			super( sqlConnection, work, {
				table: 'order_template',
				oracle_id: 'gadget_id',
				name_column: [ 'Name' ],
				search_columns: [ 'Name' ],
				drop_table:true,
				display_name : "Name",
				unique:['gadget_id', "Name"],								
				columns: {'TEXT' : textColumns,"gadget_id":"INTEGER PRIMARY KEY AUTOINCREMENT" }
			});
		}
		
		
		private var textColumns:Array = [
			
			"Name",			
			"Description",
			"Area"];
	}
}