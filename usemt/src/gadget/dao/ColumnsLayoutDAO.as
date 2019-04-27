package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class ColumnsLayoutDAO extends SimpleTable {
		
		public function ColumnsLayoutDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"columns_layout",
				unique: [ 'entity, num, filter_type' ],
				columns: {
					'num' : 'INTEGER',
					'TEXT' : [ 'entity', 'element_name', 'filter_type' ]
				}
			});				
		}

		public function insertColumnLayout(layout:Object):void {
			insert({entity:layout.entity, element_name:layout.element_name, num:layout.num, filer_type:layout.filter_type});
		}
		
		public function deleteEntity(entity:String):void {
			delete_({'entity':entity});
		}
		
		public function deleteColumnLayout(entity:String, filter_type:String):void {
			delete_({'entity': entity, 'filter_type': filter_type});
		}
		
		public function fetchColumnLayouts(entity:String):ArrayCollection {
			return fetchColumnLayout(entity, null);
		}
		
		public function fetchColumnLayout(entity:String, filter_type:String = 'Default'):ArrayCollection{
			var res:Array;
			var params:Object = {'entity':entity};
			if(filter_type != null){
				params.filter_type = filter_type;
			}
			res = fetch(params);
			return res==null ? new ArrayCollection() : new ArrayCollection(res);
		}
		
		public function getColumnLayout(entity:String, filter_type:String):ArrayCollection {
			var res:ArrayCollection = fetchColumnLayout(entity, filter_type);
			res = res.length > 0 ? res : fetchColumnLayout(entity);
			return res;
		}
		
		public function fetchColumns(entity:String):ArrayCollection{
			var res:Array = select("DISTINCT element_name",null,{'entity':entity});
			return res==null ? new ArrayCollection() : new ArrayCollection(res);
		}
		
	}
	
}