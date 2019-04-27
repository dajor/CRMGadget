package gadget.dao {
	
	import com.adobe.utils.StringUtil;
	import com.hurlant2.util.der.Integer;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import gadget.control.CalculatedField;
	import gadget.service.PicklistService;
	import gadget.util.FieldUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	public class ValidationRuleDAO extends SimpleTable {		
		
		private var stmtAddRemoveColumn:SQLStatement = new SQLStatement();
		
		public function ValidationRuleDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'validation_rule_2',
				index: ["entity","ruleName"],
				unique : ["entity,ruleName"],
				columns: { 'INTEGER':['orderNo'],
							'TEXT' : textColumns 							
							}
			});		
			// add or disable columns
			stmtAddRemoveColumn.sqlConnection = sqlConnection;
		}
		
		private var textColumns:Array = [
			"entity", 
			"ruleName",
			"active",
			"message",
			"value",
			"errorMessage"
		];
		
		private static var vars:String = "entity, ruleName, active, value, message, errorMessage, orderNo";
		
		public static function newRule():Object {
			var obj:Object = new Object();
			var arrayVars:Array = vars.split(",");
			for(var i:int;i<arrayVars.length;i++){
				var key:String =StringUtil.trim(arrayVars[i]); 
				obj[key] = "";
			}			
			obj["orderNo"] = 0;
			return obj;
		}
		
		public function selectAll(entity:String):ArrayCollection {
			return new ArrayCollection(select_order(vars, null, {entity:entity},"orderNo",null));
		}
		
		public function selectByRuleName(entity:String, ruleName:String):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, ruleName:ruleName}));
			if(list.length>0){
				return list[0];
			}
			return null;
		}
				
		public function deleteByRuleName(fieldObject:Object):void{
			delete_({entity:fieldObject.entity, ruleName:fieldObject.ruleName});
		}
		
		
		public function upSert(field:Object):void {
			deleteByRuleName(field);
			insert(field);
		}
		
		public function checkExistingRuleName(rule:Object):Boolean {
			var objRule:Object = selectByRuleName(rule.entity,rule.ruleName);
			if(objRule) return true;
			return false;
		}
		
	}
}