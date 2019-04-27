package gadget.dao
{
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.states.OverrideBase;
	
	public class DepthStructureTreeDAO extends SimpleTable {
		
		private var stmtSelectAll:SQLStatement = null;
		
		public function DepthStructureTreeDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table:"depthstructure_tree",
				index: [ 'entity', 'column_name' ],
				columns: { 'TEXT' : textColumns ,'INTEGER' : ['num']}
			});
			stmtSelectAll = new SQLStatement();
			stmtSelectAll.sqlConnection = sqlConnection;
			stmtSelectAll.text ="select * from depthstructure_tree order by num";
		}
		
		public function selectAll():ArrayCollection{
			exec(stmtSelectAll);
			return new ArrayCollection(stmtSelectAll.getResult().data);
		}
		
		public function _delete(data:Object):void {
			delete_({entity: data.entity, column_name: data.column_name});
		}
		
		public function findDepthStructure(where:String):ArrayCollection {
			return new ArrayCollection(select_order("*", where, null, "num", null));
		}
		
		override public function insert(data:Object):SimpleTable {
			var obj:Object = new Object(); 
			for each (var col:String in textColumns) {
				obj[col] = data[col];
			}
			obj.num = data.num;
			return super.insert(obj);
		}
		
		private var textColumns:Array = [
			"entity",
			"column_name",
			"division",
			"division_value",
			"sector",
			"sector_value",
			"business_unit",
			"business_unit_value",
			"lang_text",
			"lang_text_value",
			"gbk",
			"gbk_value",
			"id",
			"pid",
			"display_name"
		];
		
	}
}