package gadget.dao
{

	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class FeedUserDAO extends SimpleTable {
		
		private var stmtInsert:SQLStatement;
		private var stmtSelect:SQLStatement;

		public function FeedUserDAO(sqlConnection:SQLConnection, workerFunction:Function){
			super(sqlConnection, workerFunction, {
				table:"feed_users",
				unique : ["Id"],
				columns: {
					'TEXT' : [ 'Id', 'uppername', 'MrMrs', 'FirstName', 'LastName', 'Alias', 'JobTitle', 'EMailAddr', 'PhoneNumber', 'Department', 'Avatar' ]
				}
			});	
		}
				
	}
}
