package gadget.dao {
	
	import flash.data.SQLConnection;
	import flash.utils.Dictionary;
	
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	public class CustomPicklistValueDAO extends SimpleTable {		
		public function CustomPicklistValueDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'custom_picklist_value',
				index: ["entity", "fieldName","gadgetId","oracleId"],
				unique : ["entity,fieldName,gadgetId,oracleId"],
				columns: { 'TEXT' : textColumns}
			});
		}
		
		private var textColumns:Array = [
			"entity", 
			"gadgetId",
			"oracleId",
			"fieldName",
			"oracleCode",
			"crmCode",
			"value"
		];
		
		
		private static var vars:String = "entity, gadgetId, oracleId, fieldName, oracleCode, crmCode, value";
		
		public static function newObject():Object {
			var obj:Object = new Object();
			var arrayVars:Array = vars.split(",");
			for(var i:int;i<arrayVars.length;i++){
				obj[StringUtil.trim(arrayVars[i])] = "";
			}			
			return obj;
		}
		
		public function selectbyId(entity:String,oracleId:String,gadgeId:String):ArrayCollection {
			return new ArrayCollection(select(vars, null, {entity:entity,oracleId:oracleId,gadgeId:gadgeId}));
		}
	
		public function selectByFieldName(entity:String, fieldName:String,gadgetId:String):Object {
			var list:ArrayCollection =  new ArrayCollection(select(vars, null, {entity:entity, fieldName:fieldName, gadgetId:gadgetId}));
			if(list.length>0) return list[0];
			return null;
		}
		
		public function selectField(entity:String, fieldName:String):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, fieldName:fieldName}));
			if(list.length>0) return list[0];
			return null;
		}
						
		public function deleteByFieldName(item:Object):void{
			delete_({entity:item.entity, fieldName:item.fieldName, gadgetId:item.gadgetId});
		}
		
		public function deleteByGadgetId(item:Object):void{
			delete_({entity: item.gadget_type, gadgetId: item.gadget_id});
		}
		
		/**
		 *key is the fieldname+tntity 
		 */
		public function selectByEntityAsDic(entity:String):Dictionary{
			var result:ArrayCollection = selectAll(entity);
			var dic:Dictionary = new Dictionary();
			for each(var obj:Object in result){
				var key:String = obj['fieldName']+obj['gadgetId'];
				dic[key]=obj;
			}
			return dic;
		}
		
		public function selectAll(entity:String):ArrayCollection {
			return new ArrayCollection(select_order(vars,null, {entity: entity}, null, null));
		}
	
		public function update_(item:Object):void {
			deleteByFieldName(item);
			insert(item);
		}
		
	}
}