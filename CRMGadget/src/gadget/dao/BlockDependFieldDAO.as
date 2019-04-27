package gadget.dao
{
	import flash.data.SQLConnection;

	public class BlockDependFieldDAO extends SimpleTable
	{
		public function BlockDependFieldDAO(sqlConnection:SQLConnection,work:Function)
		{
			super(sqlConnection, work, {
				table: 'block_dependfield',
				index: ["parent_id", "parent_field_value"],
				unique : ["entity,parent_id,parent_field_value"],
				columns: {gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT", 'TEXT' : ['parent_field_value','entity','fields','addressfields'],'isdefault':'BOOLEAN','parent_id':'INTEGER'}
			});
			
		}
		
		public function getDependFields(parentId:String):Object{
			var result:Array = fetch({'parent_id' :parentId});
			var obj:Object = new Object();
			if(result!=null){
				for each(var r:Object in result){
					obj[r.parent_field_value]=r;
				}
			}
			
			return obj;
		}
		
		
		
		
		
	}
}