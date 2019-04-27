package gadget.dao {
	
	import flash.data.SQLConnection;
	import flash.utils.Dictionary;
	
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	public class CustomFieldTranslatorDAO extends SimpleTable {		
		public function CustomFieldTranslatorDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'custom_field_translator',
				index: ["entity", "column_name","languageCode"],
				unique : ["entity,column_name,languageCode"],
				columns: { 'TEXT' : textColumns}
			});
		}
		
		private var textColumns:Array = [
			"entity", 
			"column_name",
			"fieldName", 
			"displayName",
			"languageCode",
			"value",
			"bindValue",
			"display"
		];
		
		
		private var vars:String = "entity, column_name, fieldName, displayName, languageCode, value, bindValue,display";
		
		public function customField(entity:String):ArrayCollection {
			return new ArrayCollection(select(vars, null, {entity:entity}));
		}
	
		public function selectFields(entity:String, column_name:String):ArrayCollection {
			return new ArrayCollection(select(vars, null, {entity:entity, column_name:column_name}));
		}
		
		public function selectField(entity:String, column_name:String,languageCode:String):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, column_name:column_name,languageCode:languageCode}));
			if(list.length>0) return list[0];
			return null;
		}
		
		/** key is an element name*/
		public function selectFieldsByEntity(entity:String, languageCode:String):Dictionary {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, languageCode:languageCode}));
			var result:Dictionary = new Dictionary();
			for each(var obj:Object in list){
				result[obj.column_name] = obj;
			}
			
			return result;
		}
		
		
		public function selectByFieldName(entity:String,fieldName:String,languageCode:String):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, fieldName:fieldName,languageCode:languageCode}));
			if(list.length>0) return list[0];
			return null;
		}
						
		public function deleteFieldByColumnName(entity:String,column_name:String):void{
			delete_({entity:entity, column_name:column_name});
		}
		
		public function deleteField(objF:Object):void{
			delete_({entity:objF.entity, column_name:objF.column_name,languageCode:objF.languageCode});
		}
	
		
		public function selectAll(entity:String):ArrayCollection {
			return new ArrayCollection(select_order(vars,null, {entity: entity}, "translateValue", null));
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