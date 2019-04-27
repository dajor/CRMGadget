package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	public class DailyAgendaColumnsLayoutDAO extends SimpleTable {
		
		private var stmtSelectByEntity:SQLStatement;
		
		public function DailyAgendaColumnsLayoutDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection,work, {
				table: 'daily_agenda_columns_layout',
				unique: [ 'entity,order_index,element_name'],
				name_column: [ 'entity','order_index','element_name'],
				search_columns: [ 'element_name','entity'],
				display_name : "dailyagendacolumnslayout",
				index: [ "entity","order_index","element_name"],
				columns: { 'TEXT' : textColumns,"INTEGER": integerColumns }
			});
			
			
			stmtSelectByEntity = new SQLStatement();
			stmtSelectByEntity.sqlConnection = sqlConnection;
			stmtSelectByEntity.text = "SELECT * FROM daily_agenda_columns_layout WHERE Entity=:entity Order By order_index asc";
			
		}
		
		public function selFieldByEntity(entity:String):ArrayCollection{
			stmtSelectByEntity.parameters[":entity"] = entity;
			exec(stmtSelectByEntity);
			return new ArrayCollection(stmtSelectByEntity.getResult().data);
		}
		
		
//		public function fetchColumnLayout(entity:String):ArrayCollection{
//			var res:Array;
//			var params:Object = {'entity':entity};
//			res = fetch(params); 
//			return res==null ? new ArrayCollection() : new ArrayCollection(res);
//		}
		
		public function deleteColumnLayout(entity:String):void {
			delete_({'entity': entity});
		}
		
		public function get entity():String {
			return "DailyAgendaColumnsLayoutDAO";
		}
		
		private var textColumns:Array = ['entity', 'element_name'];
		private var integerColumns:Array = ['order_index'];
		
	}
}