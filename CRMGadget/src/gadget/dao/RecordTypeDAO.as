package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	
	public class RecordTypeDAO extends SimpleTable {
		
		public function RecordTypeDAO(sqlConnection:SQLConnection, workerFunction:Function){
			
			super(sqlConnection, workerFunction, {
				table:"record_type",
				unique:['id, name, singularName'],
				columns: {
					'TEXT' : [ 'singularName','pluralName', 'name', 'id' ]
				}
			});								
		}
		
		
		public function find(recordType:Object):Object{
			var result:Array = fetch({id:recordType.id});
			return result.length == 0?null:result[0]; 
		}
		
		public function read():Object{
			var result:Array = fetch();
			return result.length == 0?null:result[0]; 
		}
		
		
	}
}