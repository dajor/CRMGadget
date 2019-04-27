package gadget.dao
{
	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;

	public class SubColumnLayoutDAO extends SimpleTable 
	{
		public function SubColumnLayoutDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, {
				table:"sub_column_layout",
				unique: [ 'parent_entity,entity, num' ],
				columns: {
					'num' : 'INTEGER',
					'TEXT' : [ 'parent_entity','entity', 'element_name' ]
				}
			});		
		}
		
		public function insertColumnLayout(layout:Object,rows:Object):void {
			deleteColumnLayout(layout.entity,layout.parent_entity);
			var index:int=1;
			var entity:String = layout.entity;
			var parent_entity:String = layout.parent_entity;
			for each(var o:Object in rows) {
				insert({entity:entity, element_name:o.element_name, num:index, parent_entity:parent_entity});
				index += 1;
			}
			
		}
		public function fetchColumnLayout(parent_entity:String, entity:String):ArrayCollection{
			var res:Array;
			var params:Object = {'entity':entity,'parent_entity':parent_entity};
			
			res = fetch(params);
			return res==null ? new ArrayCollection() : new ArrayCollection(res);
		}
		public function deleteColumnLayout(entity:String, parent_entity:String):void {
			delete_({'entity': entity, 'parent_entity': parent_entity});
		}
	}
}