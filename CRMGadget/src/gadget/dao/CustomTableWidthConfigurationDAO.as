package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	public class CustomTableWidthConfigurationDAO extends BaseSQL
	{

		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtFind:SQLStatement;
		private var stmtSelect:SQLStatement;
		
		public function CustomTableWidthConfigurationDAO(sqlConnection:SQLConnection)
		{

			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO CustomTableWidthConfiguration (filter_id, entity, field_name, width) VALUES (:filter_id, :entity, :field_name, :width)";
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE CustomTableWidthConfiguration SET width = :width WHERE filter_id = :filter_id AND entity = :entity AND field_name = :field_name";
			
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM CustomTableWidthConfiguration WHERE filter_id = :filter_id AND entity = :entity AND field_name = :field_name";	

			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM CustomTableWidthConfiguration WHERE filter_id = :filter_id AND entity = :entity AND field_name = :field_name";
				
			stmtSelect = new SQLStatement();
			stmtSelect.sqlConnection = sqlConnection;
			stmtSelect.text = "SELECT * FROM CustomTableWidthConfiguration WHERE filter_id = :filter_id AND entity = :entity";
			
		}
		
		public function insert(col:Object):Number {
			replaceParam(stmtInsert,["filter_id","entity","field_name","width"],col);
			exec(stmtInsert);
			return stmtInsert.getResult().lastInsertRowID;
		}
		
		public function update(col:Object):void {
			replaceParam(stmtUpdate,["filter_id","entity","field_name","width"],col);
			exec(stmtUpdate);
		}	
		
		public function delete_(col:Object):void {
			replaceParam(stmtDelete,["filter_id","entity","field_name"],col);
			exec(stmtDelete);
		}
		
		public function find(col:Object):Object {
			replaceParam(stmtFind,["filter_id","entity","field_name"],col);
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0){
				return null;
			}
			return result.data[0];
		}
		
		public function select(criteria:Object):ArrayCollection {
			replaceParam(stmtSelect,["filter_id","entity"], criteria);
			exec(stmtSelect);
			var result:SQLResult = stmtSelect.getResult();
			if(result.data==null || result.data.length==0){
				return null;
			}
			return new ArrayCollection(result.data);
		}
		
		private function replaceParam(sqlStatment:SQLStatement,params:Array,col:Object):void {
			for(var i:int=0; i<params.length; i++){
				var param:String = params[i];
				sqlStatment.parameters[":" + param] = col[param];
			} 
		}
		
	}
}