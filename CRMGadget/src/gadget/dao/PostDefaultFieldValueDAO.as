package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class PostDefaultFieldValueDAO extends SimpleTable
	{
		public function PostDefaultFieldValueDAO(sqlConnection:SQLConnection, work:Function)
		{
			super( sqlConnection, work, {
				table: 'post_default_fields_value',
				oracle_id: 'gadget_id',
				name_column: [ 'element_name' ],
				search_columns: [ 'element_name' ],				
				display_name : "element_name",
				index: ["element_name",'entity'],
				unique:["element_name,entity"],								
				columns: {'TEXT' : textColumns,'BOOLEAN':["postdefault"],'gadget_id': "INTEGER PRIMARY KEY AUTOINCREMENT" }
			});
		}
		
		
		public function isPostDefault(entity:String,element_name:String):Boolean{
			var obj:Object = select_first("*",null,{'element_name':element_name,'entity':entity});
			if(obj!=null){
				return obj.postdefault;
			}
			
			return false;
		}
		
		private var textColumns:Array = [		
			"element_name",
			"entity"			
		];
	}
}