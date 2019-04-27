package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	public class QueryDAO extends BaseSQL {
		
		private var stmtQuery:SQLStatement; 
		
		public function QueryDAO(sqlConnection:SQLConnection) {
			stmtQuery = new SQLStatement();
			stmtQuery.sqlConnection = sqlConnection;
		}
		
		public function executeQuery(sqlString:String,isGetDelete:Boolean=false):ArrayCollection{
			stmtQuery.text = sqlString;
			exec(stmtQuery, false);
			var result:SQLResult = stmtQuery.getResult();
			var cols:ArrayCollection=new ArrayCollection();
			if (result.data == null || result.data.length == 0) {
				return cols;
			}
			for each(var obj:Object in result.data){
				if(obj.deleted && !isGetDelete){
					continue;
				}
				cols.addItem(obj);
			}
			
			return cols;
		}
		
		public function executeQueryObject(sqlString:String):Object{
			stmtQuery.text = sqlString;
			exec(stmtQuery, false);
			var result:SQLResult = stmtQuery.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
	}
}