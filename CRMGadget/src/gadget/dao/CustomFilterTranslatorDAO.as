package gadget.dao {
	
	import flash.data.SQLConnection;
	
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	public class CustomFilterTranslatorDAO extends SimpleTable {	
	
		public function CustomFilterTranslatorDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'custom_filter_translator',
				index: ["entity", "filter_name","languageCode"],
				unique : ["entity,filter_name,languageCode"],
				columns: { 'TEXT' : textColumns}
			});
		}
		
		private var textColumns:Array = [
			"entity", 
			"filter_name",
			"displayName",
			"languageCode",
			
		];
		
		
		private var vars:String = "entity, filter_name,displayName, languageCode";
		
		public function customField(entity:String):ArrayCollection {
			return new ArrayCollection(select(vars, null, {entity:entity}));
		}
	
		public function selectFields(entity:String, column_name:String):ArrayCollection {
			return new ArrayCollection(select(vars, null, {entity:entity, column_name:column_name}));
		}
		
		public function selectFT(entity:String, filter_name:String,languageCode:String):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, filter_name:filter_name,languageCode:languageCode}));
			if(list.length>0) return list[0];
			return null;
		}
		public function selectByFieldName(entity:String,fieldName:String,languageCode:String):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, fieldName:fieldName,languageCode:languageCode}));
			if(list.length>0) return list[0];
			return null;
		}
						
		public function deleteByFilterId(entity:String,filter_name:String):void{
			delete_({entity:entity, filter_name:filter_name});
		}
		public function deleteFT(entity:String,filter_name:String,languageCode:String):void{
			delete_({entity:entity, filter_name:filter_name,languageCode:languageCode});
		}
		public function selectAll(entity:String):ArrayCollection {
			return new ArrayCollection(select_order(vars,null, {entity: entity}, "translateValue", null));
		}
	
		public function insertFilter(obj:Object):void {
			var objTransaltor:Object = new Object();
			var arrayVars:Array = vars.split(",");
			for(var i:int;i<arrayVars.length;i++){
				var key:String =StringUtil.trim(arrayVars[i]); 
				objTransaltor[key] = obj[key];
			}			
			
			insert(objTransaltor);
		}
		public function updateFilter(obj:Object):void{
			var objTransaltor:Object = new Object();
			var arrayVars:Array = vars.split(",");
			for(var i:int;i<arrayVars.length;i++){
				var key:String =StringUtil.trim(arrayVars[i]); 
				objTransaltor[key] = obj[key];
			}			
			deleteFT(objTransaltor.entity,objTransaltor.filter_name,objTransaltor.languageCode)
			insert(objTransaltor);
			
		}
	}
}