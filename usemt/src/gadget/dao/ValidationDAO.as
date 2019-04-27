package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	public class ValidationDAO extends SimpleTable {
		
		public function ValidationDAO(sqlConnection:SQLConnection, work:Function) {
			
			super(sqlConnection, work, {
				table: 'validation_rule',
				unique : ["entity, num"],
				columns: { 'TEXT' : textColumns, "INTEGER": integerColumns}
			});
			
		}
		
		private var vars:String = "entity, num, rule_name, field, operator, value, message";
		
		private var textColumns:Array = [
			"entity",
			"rule_name",
			"field",
			"operator",
			"value",
			"message"
		];
		
		private var integerColumns:Array = [
			"num"
		];
		
		
		public function insertValidation(validation:Object):void{
			insert(validation);
		}
		
		public function deleteValidation(validation:Object):void{
			delete_({entity:validation.entity, num:validation.num});
		}
		
		public function selectRuleName(validation:Object):ArrayCollection {
			return new ArrayCollection(select_order(vars, null, {entity:validation.entity, num:validation.num}, "num", null));
		}
		
		public function selectEntity(entity:String):ArrayCollection {
			return new ArrayCollection(select_order(vars, null, {entity:entity}, "num", null));
		}		
		
		public function selectByEntityAsMap(entity:String):Dictionary{
			var dic:Dictionary = new Dictionary();
			for each(var obj:Object in selectEntity(entity)){
				dic[obj.field] = obj;
			}
			return dic;
		}
		
		public function count():int {
			var result:Array = select(vars);
			if (result == null || result.length == 0) {
				return 0;
			}
			return result.length;
		}
		
		public function updateValidation(validation:Object):void{
			update(validation, {entity:validation.entity, num:validation.num});			
		}

		public function deleteAll(entity:String):void{
			delete_({entity:entity});
		}
	}
}