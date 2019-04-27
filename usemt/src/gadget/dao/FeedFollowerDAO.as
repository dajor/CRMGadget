package gadget.dao
{

	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class FeedFollowerDAO extends SimpleTable {

		public function FeedFollowerDAO(sqlConnection:SQLConnection, workerFunction:Function){
			super(sqlConnection, workerFunction, {
				table:"feed_followers",
				unique : ["Id"],
				columns: {
					'TEXT' : [ 'Id', 'uppername', 'MrMrs', 'FirstName', 'LastName', 'Alias', 'JobTitle', 'EMailAddr', 'PhoneNumber', 'Department', 'Avatar' ]
				}
			});	
		}
				
	}
}
