package gadget.dao
{
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.states.OverrideBase;
	
	public class TerritoryTreeDAO extends SimpleTable {
		
		private var stmtSelectAll:SQLStatement = null;
		
		public function TerritoryTreeDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table:"territory_tree",
				index: [ 'entity', 'column_name' ],
				columns: { 'TEXT' : textColumns ,'INTEGER' : ['num']}
			});		 
			stmtSelectAll = new SQLStatement();
			stmtSelectAll.sqlConnection = sqlConnection;
			stmtSelectAll.text ="select * from territory_tree order by num";
		}
		
		public function selectAll():ArrayCollection{
			exec(stmtSelectAll);
			return new ArrayCollection(stmtSelectAll.getResult().data);
		}
		
		public function _delete(data:Object):void {
			delete_({entity: data.entity, column_name: data.column_name});
		}
		
		public function findTerritory(where:String):ArrayCollection {
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
			"id",
			"cluster",
			"cluster_value",
			"region",
			"region_value",
			"subregion",
			"subregion_value",
			"sector",
			"sector_value",
			"salesoffice",
			"salesoffice_value",
			"vbez",
			"vbez_value",
			"pid",
			"display_name"
		];
		
	}
}