package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class ImageDAO extends BaseDAO {
		
		private var stmtSelectImageById:SQLStatement;
		
		private var stmtSelectAll:SQLStatement;
		
			public function ImageDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'image',
				//oracle_id: 'AccountId',
				name_column: [ 'Name' ],
				search_columns: [ 'Name'],
				display_name : "images",
				index: [ "Id" ],
				columns: { 'TEXT' : textColumns }
			});
				
			stmtSelectImageById = new SQLStatement();
			stmtSelectImageById.sqlConnection = sqlConnection;
			stmtSelectImageById.text = "SELECT * FROM Image WHERE Id=:Id";
			
			stmtSelectAll = new SQLStatement();
			stmtSelectAll.sqlConnection = sqlConnection;
			stmtSelectAll.text = "SELECT * FROM Image WHERE (error IS NULL OR error = 0)";
			
		}
		
		public function selectAll():ArrayCollection{
			exec(stmtSelectAll);
			return new ArrayCollection(stmtSelectAll.getResult().data);
		}
			
		public function getImageById(ImageId:String):Object {
			stmtSelectImageById.parameters[":Id"] = ImageId;
			exec(stmtSelectImageById);
			var result:SQLResult = stmtSelectImageById.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
	
		override public function get entity():String {
			return "Image";
		}
		
		private var textColumns:Array = [
			'Id',
			'Name',
			'body'
		];
	}
}