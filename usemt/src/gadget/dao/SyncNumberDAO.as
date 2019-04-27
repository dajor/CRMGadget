package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;

	public class SyncNumberDAO extends SimpleTable
	{
		private var sync_number:Number = 0;
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtRead:SQLStatement;
		
		public function SyncNumberDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, {
				table:"sync_number",
				index: [ 'number' ],
				columns: {
					'number' : 'INTEGER'
				}
			});	
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;

			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			
			
			stmtRead = new SQLStatement();
			stmtRead.sqlConnection = sqlConnection;
			
		}
		private function insertSync_number():void{
			stmtInsert.text = "INSERT INTO sync_number (number) VALUES ('"+sync_number+"')";
			exec(stmtInsert);
		}
		public function increaseSyncNumber():void{
			sync_number = getSyncNumber() + 1;
			stmtUpdate.text = "UPDATE sync_number SET number=" + sync_number;
			exec(stmtUpdate);
			
		}
		public function getSyncNumber():Number{
			stmtRead.text = "SELECT number FROM sync_number";
			exec(stmtRead);
			var result:SQLResult = stmtRead.getResult();
			if(result.data != null && result.data.length>0){
				var val :Object = result.data[0];
				sync_number = val.number
			}else{
				insertSync_number();
			}
			return sync_number;
		}

		
	}
}