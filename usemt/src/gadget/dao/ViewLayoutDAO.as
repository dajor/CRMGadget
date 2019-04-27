package gadget.dao{
	
	import flash.data.SQLConnection;	
	import mx.collections.ArrayCollection;
	
	public class ViewLayoutDAO extends SimpleTable {
		public function ViewLayoutDAO(sqlConnection:SQLConnection, work:Function){
			
			super(sqlConnection, work, {
				table: 'view_layout',
				unique : ["entity, num"],
				columns: { 'TEXT' : textColumns, "INTEGER": integerColumns}
			});
		}
		
		private var textColumns:Array = ["entity", "element_name"];
		private var integerColumns:Array = ["num"];
		
		private var vars:String = "entity, num, element_name";		
		
		public function deleteEntity(entity:String):void {
			delete_({entity:entity});
		}
		
		public function insertViewLayout(layout:Object):void {
			insert({entity:layout.entity, element_name:layout.element_name, num:layout.num});
		}
		
		public function selectAll(entity:String):ArrayCollection{
			return new ArrayCollection(select_order(vars, null, {entity:entity}, "num", null));
		}
		
	}
}