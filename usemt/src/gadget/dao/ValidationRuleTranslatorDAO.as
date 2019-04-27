package gadget.dao {
	
	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	public class ValidationRuleTranslatorDAO extends SimpleTable {		
		public function ValidationRuleTranslatorDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'validation_rule_translator',
				index: ["entity", "ruleName","languageCode"],
				unique : ["entity,ruleName,languageCode"],
				columns: { 'TEXT' : textColumns}
			});
		}
		
		private var textColumns:Array = [
			"entity", 
			"ruleName",
			"errorMessage", 
			"languageCode"
		];
		
		
		private var vars:String = "entity, ruleName, errorMessage, languageCode";
		
		public function validationRuleTran(entity:String):ArrayCollection {
			return new ArrayCollection(select(vars, null, {entity:entity}));
		}
	
		public function selectFields(entity:String, ruleName:String):ArrayCollection {
			return new ArrayCollection(select(vars, null, {entity:entity, ruleName:ruleName}));
		}
		
		public function selectField(entity:String, ruleName:String,languageCode:String):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, ruleName:ruleName,languageCode:languageCode}));
			if(list.length>0) return list[0];
			return null;
		}
		
		public function deleteByRuleName(objF:Object):void{
			delete_({entity:objF.entity, ruleName:objF.ruleName});
		}
		public function deleteField(objF:Object):void{
			delete_({entity:objF.entity, ruleName:objF.ruleName,languageCode:objF.languageCode});
		}
	
		
		public function selectAll(entity:String):ArrayCollection {
			return new ArrayCollection(select_order(vars,null, {entity: entity}, "ruleName", null));
		}
	
		public function updateField(field:Object):void {
			var objTransaltor:Object = new Object();
			var arrayVars:Array = vars.split(",");
			for(var i:int;i<arrayVars.length;i++){
				var key:String =StringUtil.trim(arrayVars[i]); 
				objTransaltor[key] = field[key];
			}			
			deleteField(objTransaltor);
			insert(objTransaltor);
		}
		
	}
}