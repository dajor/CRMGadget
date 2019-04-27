package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	public class PvgDAO extends BaseDAO {
		
		public function PvgDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'pvg_obj',
				oracle_id: 'PicklistValueGroupId',
				name_column: [ 'PicklistValueGroupName' ],
				search_columns: [ 'PicklistValueGroupName' ],
				display_name : "PicklistValueGroupName",
				index: [ "PicklistValueGroupId"],
				columns: { 'TEXT' : textColumns }
			});
		
			
		}
		protected override function getIndexColumns():Array{
			var indexes:Array = ["deleted", "local_update" ];			
			indexes.push("PicklistValueGroupName");
			return indexes;
		}		
		
		override public function get entity():String {
			return "PiclistValueGroup";
		}
		
		protected override function fieldList(updateFF:Boolean=true):ArrayCollection {
			var allFields:ArrayCollection = new ArrayCollection();
			//allFields.addAll(FieldUtils.allFields(entity));
			for each(var f:String in textColumns){
				allFields.addItem({'element_name':f});
			}
			
			
			
			return allFields;
		}
		
		
		private var textColumns:Array = [
			"PicklistValueGroupName",
			"PicklistValueGroupId",
			"Description"
			];
	}
}