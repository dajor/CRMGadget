package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class DefaultFieldValueDAO extends SimpleTable
	{
		public function DefaultFieldValueDAO(sqlConnection:SQLConnection, work:Function)
		{
			super( sqlConnection, work, {
				table: 'default_fields_value',
				oracle_id: 'gadget_id',
				name_column: [ 'element_name' ],
				search_columns: [ 'element_name' ],				
				display_name : "element_name",
				index: ["element_name",'entity'],
				unique:['gadget_id'],								
				columns: {'TEXT' : textColumns,'gadget_id': "INTEGER PRIMARY KEY AUTOINCREMENT" }
			});
		}
		
		private var textColumns:Array = [		
			"element_name",
			"entity",
			"default_value"
		];
	}
}