package gadget.dao
{
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	public class FavoriteDAO extends SimpleTable {
		
		private var stmtUpsert:SQLStatement;
		
		public function FavoriteDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table: "favorite",
				unique: [ "gadget_type, gadget_id" ],
				columns: { 'TEXT' : textColumns }
			});		 
			stmtUpsert = new SQLStatement();
			stmtUpsert.sqlConnection = sqlConnection;
			stmtUpsert.text = "INSERT OR REPLACE INTO favorite ( gadget_type, gadget_id ) VALUES ( :gadget_type, :gadget_id )";
		}
		
		public function upsert(data:Object):void{
			for each(var column:String in textColumns) {
				stmtUpsert.parameters[":"+column] = data[column];
			}
			exec(stmtUpsert);
		}
		
		override public function delete_(data:Object):SimpleTable {
			return super.delete_({gadget_type: data['gadget_type'], gadget_id: data['gadget_id']});
		}
		
		private var textColumns:Array = [
			"gadget_type",
			"gadget_id"
		];
		
	}
}