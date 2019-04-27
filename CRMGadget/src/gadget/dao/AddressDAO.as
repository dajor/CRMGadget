package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.globalization.Collator;
	
	public class AddressDAO extends BaseDAO {
		
		private var stmtInsert:SQLStatement;
		public function AddressDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			var ent:String = entity;
			super(workerFunction, sqlConnection, {
				table:"address",
				unique : ["id"],
				oracle_id: 'Id',
				display_name:"address",
				create_cb: function(structure:Object):void {Database.incomingSyncDao.unsync_one(ent)},
				columns:{ 'TEXT' : textColumns
				}
			});		
			
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO address (" + _getColumns() + ")" + " VALUES (" + _getValues() +")";
			
		}
		protected override function getIndexColumns():Array{
			return ["deleted", "local_update" ,"ParentId"];			
			
		}
		
		public function _insert(object:Object):void {
			if (find(object) != null) delete_(object);
			
			for each (var col:String in textColumns){
				stmtInsert.parameters[":" + col] = object[col];
			}
			stmtInsert.parameters[":deleted"] = 0;
			stmtInsert.parameters[":local_update"] = "";
			exec(stmtInsert);
		}
		
		public function _getColumns():String {
			var cols:String="";
			for each (var col:String in textColumns){
				cols += col + ",";
			}
			return cols+ "deleted,local_update";
		}
		public function _getValues():String {
			var values:String="";
			for each (var col:String in textColumns){
				values += ":" + col + ",";
			}
			return values + ":deleted,:local_update"
		}
		
		private var textColumns:Array = [
			//Modified for WS2.0
			"Id", // "deleted", "local_update",	
			"Entity",
			"ParentId",
			"ModifiedBy",
			"ExternalSystemId",
			"CreatedBy",
			"CreatedDate",
			"ModifiedDate",
			"ModId",
			"City",
			"Country",
			"County",
			"Description",
			"IntegrationId",
			"ZipCode",
			"Province",
			"StateProvince",
			"Address",
			"StreetAddress2",
			"StreetAddress3",
			"ModifiedById",
			"CreatedById", 
			"Full_Address"
		];
		override public function get entity():String {
			return "Address"; // AM entity is user, table is allusers
		}
	
		
		public function find(address:Object):Object{		
			return(findByOracleId(address.id)); 			
		}
		
		
		
	}
}