package gadget.dao {
	
	import com.adobe.utils.StringUtil;
	import com.hurlant2.util.der.Integer;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.utils.Dictionary;
	
	import gadget.control.CalculatedField;
	import gadget.service.LocaleService;
	import gadget.service.PicklistService;
	import gadget.util.CacheUtils;
	import gadget.util.FieldUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	public class CustomFieldDAO extends SimpleTable {		
		
		private var stmtAddRemoveColumn:SQLStatement = new SQLStatement();
		
		public static const DEFAULT_LANGUAGE_CODE:String = "ENU";
		
		public function CustomFieldDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'custom_field',
				index: ["entity", "column_name"],
				unique : ["entity, column_name, subtype"],
				columns: { 'TEXT' : textColumns}
			});
			
			// add or disable columns
			stmtAddRemoveColumn.sqlConnection = sqlConnection;
		}
		
		private var textColumns:Array = [
			"entity", 
			"column_name",
			"fieldName", 
			"displayName",
			"fieldType",
			"value",
			"subtype",
			"defaultValue",
			"bindField",
			"bindValue",
			"parentPicklist",
			"field_copy",
			"sum_field_name",
			"sum_entity_name",
			"relation_id"
		];
		
		
		public static var vars:String = "entity, column_name, fieldName, displayName, fieldType, value, subtype, defaultValue, bindField, bindValue,parentPicklist,field_copy,sum_entity_name,sum_field_name,relation_id";
		
		public static function newCustomField():Object {
			var obj:Object = new Object();
			var arrayVars:Array = vars.split(",");
			for(var i:int;i<arrayVars.length;i++){
				var key:String =StringUtil.trim(arrayVars[i]); 
				obj[key] = "";
			}			
			return obj;
		}
		
		public function getObjectValue(field:Object):Object {
			var asignObject:Object = new Object();
			var arrayVars:Array = vars.split(",");
			for(var i:int;i<arrayVars.length;i++){
				var key:String =StringUtil.trim(arrayVars[i]); 
				asignObject[key] = field[key];
			}
			return asignObject;
		}
		
		public function allCustomField(entity:String):ArrayCollection {
			var result:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity})); 
			//export sub object's fields
			for each (var sub:String in SupportRegistry.getSubObjects(entity)) {
				var subDao:SupportDAO = SupportRegistry.getSupportDao(entity,sub);
				result.addAll(new ArrayCollection(select(vars, null, {entity:subDao.entity})));
			}
			
			return result; 
		}
		
		public function customField(entity:String,languageCode:String=DEFAULT_LANGUAGE_CODE):ArrayCollection {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity}));
			return checkTranslation(list,languageCode);
		}
		
		public function findFieldsByDisplayName(entity:String, displayName:String,languageCode:String=DEFAULT_LANGUAGE_CODE):ArrayCollection{
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, displayName:displayName}));
			return checkTranslation(list,languageCode);
		}
		
		public function selectCustomField(entity:String, column_name:String,languageCode:String=DEFAULT_LANGUAGE_CODE,addKeyValue:Boolean=false):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, column_name:column_name}));
			if(list.length>0){
				return checkTranslation(list,languageCode,addKeyValue)[0];
			}
			return null;
		}
		
		public function selectCustomFieldWithSubTypeAsDic(entity:String, subtype:int,languageCode:String=DEFAULT_LANGUAGE_CODE,addKeyValue:Boolean=false):Dictionary {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity,subtype:subtype}));
			var result:ArrayCollection = checkTranslation(list,languageCode,addKeyValue);
			var dic:Dictionary = new Dictionary();
			for each(var obj:Object in result){
				dic[obj.column_name] = obj;
			}
			
			return dic;
		}
		
		
		public function selectCustomFieldWithSubType(entity:String, column_name:String,subtype:int,languageCode:String=DEFAULT_LANGUAGE_CODE,addKeyValue:Boolean=false):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, column_name:column_name, subtype:subtype}));
			if(list.length>0){
				return checkTranslation(list,languageCode,addKeyValue)[0];
			}
			return null;
		}
		
		public function selectCustomFieldByFieldName(entity:String, fieldName:String,languageCode:String=DEFAULT_LANGUAGE_CODE,addKeyValue:Boolean=false):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, fieldName:fieldName}));
			if(list.length>0){
				return checkTranslation(list,languageCode,addKeyValue)[0];
			}
			return null;
		}
		
		public function selectCustomFields(entity:String):ArrayCollection {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity}));
			var customFieldlist:ArrayCollection = new ArrayCollection();
			for each(var obj:Object in list){
				if (obj.column_name.indexOf(CustomLayout.CUSTOMFIELD_CODE) > -1){
					var customFieldInfo:Object = FieldUtils.getField(obj.entity, obj.column_name,true);
					if(customFieldInfo){
						customFieldlist.addItem(customFieldInfo);
					} 
				}
			}
			return customFieldlist;
		}
		
		
		public function selectCustomFormularFields(entity:String):ArrayCollection {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity,fieldType:'Formula'}));
			var customFieldlist:ArrayCollection = new ArrayCollection();
			for each(var obj:Object in list){
				
				if(!StringUtils.isEmpty(obj.fieldName)){
					customFieldlist.addItem(obj);
				} 
				
			}
			return customFieldlist;
		}
		
		
		public function selectCustomFieldsSum(child:String):ArrayCollection {
			
			return new ArrayCollection(select(vars, null, {sum_entity_name:child}));
		}
		
		public function checkTranslation(resutls:ArrayCollection,languageCode:String,addKeyValue:Boolean=false):ArrayCollection{
			if(resutls!=null && resutls.length>0){
				var dic:Dictionary = Database.customFieldTranslatorDao.selectFieldsByEntity(resutls.getItemAt(0).entity,languageCode);
				for each(var objF:Object in resutls){
					var objFTran:Object = dic[objF.column_name];
					if(objFTran!=null){				
						if(addKeyValue){
							objF["keyValue"] = objF["value"];
							objF["bindKey"] = objF["bindValue"];
						} 
						objF["displayName"] = objFTran["displayName"];
						objF["value"] = objFTran["value"];
						objF["bindValue"] = Utils.checkNullValue(objFTran["bindValue"]);
					}
				}	
			}
			return resutls;
		}
		
		public function getPicklistValue(entity:String, column_name:String,languageCode:String=DEFAULT_LANGUAGE_CODE):ArrayCollection {
			var customPicklist:ArrayCollection = new ArrayCollection();
			var objField:Object = selectCustomField(entity,column_name,languageCode,true);
			// var objFieldTra:Object = selectCustomField(entity,column_name,languageCode);
			if(objField){	
				var keys:Array= Utils.checkNullValue(objField.keyValue).split(";");
				var values:Array= Utils.checkNullValue(objField.value).split(";");
				if(StringUtils.isEmpty(objField.keyValue)) keys = values;
				for (var i:int=0;i<keys.length;i++){
					if(!StringUtils.isEmpty(keys[i])){
						var key:String = Utils.checkNullValue(keys[i]);//.split("=")[0];
						var value:String = Utils.checkNullValue(values[i]);//.split("=")[1];
						customPicklist.addItem(Utils.createNewObject(["data","label"],[key,value]));
					}
				}				
			}
			customPicklist.addItemAt(Utils.createNewObject(["data","label"],["",""]),0);
			return customPicklist;
		}
		
		public function getPicklistValueByFieldName(entity:String, fieldName:String,languageCode:String=DEFAULT_LANGUAGE_CODE):ArrayCollection {
			var customPicklist:ArrayCollection = new ArrayCollection();
			var objField:Object = selectCustomFieldByFieldName(entity,fieldName,languageCode,true);
			// var objFieldTra:Object = selectCustomField(entity,column_name,languageCode);
			if(objField){	
				var keys:Array= Utils.checkNullValue(objField.keyValue).split(";");
				var values:Array= Utils.checkNullValue(objField.value).split(";");
				if(StringUtils.isEmpty(objField.keyValue)) keys = values;
				for (var i:int=0;i<keys.length;i++){
					if(!StringUtils.isEmpty(keys[i])){
						var key:String = Utils.checkNullValue(keys[i]);//.split("=")[0];
						var value:String = Utils.checkNullValue(values[i]);//.split("=")[1];
						customPicklist.addItem(Utils.createNewObject(["data","label"],[key,value]));
					}
				}				
			}
			customPicklist.addItemAt(Utils.createNewObject(["data","label"],["",""]),0);
			return customPicklist;
		}
		
		public function getBindPicklistValue(entity:String, fieldName:String,languageCode:String=DEFAULT_LANGUAGE_CODE,addKeyValue:Boolean=false,code:String=null):ArrayCollection {
			var objField:Object = selectCustomFieldByFieldName(entity,fieldName,languageCode,addKeyValue);
			return(getBindPicklist(objField,false,code));
		}
		
		public function getBindCascadingPicklist(entity:String,languageCode:String=DEFAULT_LANGUAGE_CODE):ArrayCollection {			
			var customCuscadingPicklist:ArrayCollection = new ArrayCollection();
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity,fieldType:"Related Picklist"}));			
			if(list.length>0){
				checkTranslation(list,languageCode,true);
			}
			for each(var objField:Object in list){
				if(!StringUtils.isEmpty(objField.parentPicklist)){
					customCuscadingPicklist.addAll(getBindPicklist(objField,true));
				}
			}			
			return customCuscadingPicklist;
		}
		
	
		
		private function getBindPicklist(objField:Object,cascading:Boolean=false,code:String =null):ArrayCollection{
			var bindPicklist:ArrayCollection = new ArrayCollection();
			if(objField && objField.fieldType == "Related Picklist"){ // if bind picklist
				var strArrayKey:Array= Utils.checkNullValue(objField.bindKey).split("##");
				var strArrayValue:Array= Utils.checkNullValue(objField.bindValue).split("##");
				if(StringUtils.isEmpty(objField.bindKey)) strArrayKey = strArrayValue;
				if(StringUtils.isEmpty(objField.bindValue)) strArrayValue = strArrayKey;
				if(strArrayKey.length != strArrayValue.length) strArrayValue = correctArrayValueLength(strArrayKey,strArrayValue);
				for(var k:int=0;k<strArrayKey.length;k++){
					var strParentKey:Array= strArrayKey[k].split(":");  // split parent and child value.
					var strParentValue:Array= strArrayValue[k].split(":");
					var keys:Array= Utils.checkNullValue(strParentKey[1]).split(";");
					var values:Array= Utils.checkNullValue(strParentValue[1]).split(";");					
					for (var i:int=0;i<keys.length;i++){
						if(!StringUtils.isEmpty(keys[i])){
							var objPic:Object = new Object();
							var vals:Array = Utils.checkNullValue(values[i]).split("=");
							if(code !=null){
								if(vals.length>1 && code != vals[1] && (code != vals[1]+"$$"+keys[i].split("=")[0]) ){
									continue;
								}
							}
							if(cascading){
								objPic["entity"] = objField.entity;
								objPic["parent_picklist"] = objField.parentPicklist;
								objPic["child_picklist"] = objField.bindField;
								objPic["parent_value"] = strParentValue[0];
								objPic["child_value"] = values[i];	// Utils.checkNullValue(keys[i]).split("=")[0];
								objPic["parent_code"] = strParentKey[0];
								objPic["child_code"] = keys[i];
							}else{
								objPic["data"] = Utils.checkNullValue(keys[i]);
								objPic["label"] = vals[0];
								objPic["parent"] = strParentKey[0];
							}						
							bindPicklist.addItem(objPic);
						}
					}	
				}
			}								
			return bindPicklist;
		}
		
		public function correctArrayValueLength(strArrayKey:Array,strArrayValue:Array):Array {
			var newArrayValue:Array = new Array();
			var objMap:Object = new Object();
			for each(var tmpValue:String in strArrayValue){
				objMap[tmpValue.split(":")[0]] = tmpValue.indexOf(":")>0?tmpValue.split(":")[1]:"";
			}
			for(var k:int=0;k<strArrayKey.length;k++){
				var tmpKey:String = Utils.checkNullValue(strArrayKey[k]).split(":")[0];
				newArrayValue[k] = tmpKey + ":" + Utils.checkNullValue(objMap[tmpKey]);
			}
			return newArrayValue;
		}
		
		public function checkExistingFieldName(entity:String, fieldName:String,customOnly:Boolean=false):Boolean {
			var listField:ArrayCollection = Database.fieldDao.listFields(entity);
			var listCustomField:ArrayCollection = selectAll(entity);
			for each(var objCustomField:Object in listCustomField){
				if(Utils.checkNullValue(objCustomField.fieldName).toLocaleLowerCase() == fieldName.toLocaleLowerCase()){
					return true;
				}
			}
			if(!customOnly){
				for each(var objField:Object in listField){
					if(Utils.checkNullValue(objField.fieldName).toLocaleLowerCase() == fieldName.toLocaleLowerCase()){
						return true;
					}
				}
			}
			return false;
		}
		
		public function selectByFieldName(entity:String, fieldName:String,languageCode:String=DEFAULT_LANGUAGE_CODE):Object {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, fieldName:fieldName}));
			if(list.length>0) return list[0];
			return null;
		}
				
		public function deleteCustomField(fieldObject:Object):void{
			// Database.customFieldTranslatorDao.deleteFieldByColumnName(fieldObject.entity,fieldObject.column_name);
			delete_({entity:fieldObject.entity, column_name:fieldObject.column_name});
		}
		
		public function deleteLayout(entity:String, subtype:int):void {
			// Database.customFieldTranslatorDao.deleteField(entity,column_name);
			delete_({entity:entity, subtype:subtype});
		}
		
		public function selectAll(entity:String,languageCode:String=DEFAULT_LANGUAGE_CODE):ArrayCollection {
			var resutls:ArrayCollection = new ArrayCollection(select_order(vars,null, {entity: entity}, "displayName", null));		
			return checkTranslation(resutls,languageCode);	
		}
		
		public function countColumnName(colName:String):int {			
			stmtAddRemoveColumn.text = "SELECT column_name FROM custom_field Where column_name like '%" + colName + "%' order by column_name";
			try {
				exec(stmtAddRemoveColumn);
				var list:ArrayCollection = new ArrayCollection(stmtAddRemoveColumn.getResult().data);
				colName = "{"+colName;
				var num:int = 0;
				for (var i:int = 0; i < list.length; i++) {
					var tmp:int = parseInt(list.getItemAt(i).column_name.substring(colName.length));
					if (tmp >= num) {
						num = tmp + 1;
					}
				} 
				return num;
			} catch (e:SQLError) {
				trace(e.message);
			}
			return 0;
		}
	
		public function updateField(field:Object):void {
			deleteCustomField(field);
			insert(field);
		}
		
		public function addTableColumn(entity:String, column:String, type:String, newValue:String = null):void {		
			
			var table:String = DAOUtils.getTable(entity);
			stmtAddRemoveColumn.text = "SELECT " + column + " FROM " + table + " LIMIT 0";
			try {
				exec(stmtAddRemoveColumn);
			} catch (e:SQLError) {
				// column is missing
				stmtAddRemoveColumn.text = "ALTER TABLE " + table + " ADD " + column + " " + type;
				exec(stmtAddRemoveColumn);
			} catch(e1:Error){
				trace(e1.message);
			}
			
		}
		
		
		public static function checkBindPicklist(entity:String,field:String,list:ArrayCollection):ArrayCollection{
			var newList:ArrayCollection = new ArrayCollection();
			var customMap:Object = new Object();
			var cache_parent_value:CacheUtils = new CacheUtils("cascading_child_values");
			for each (var tmp:Object in list){
				var key:String = Utils.checkNullValue(tmp.data);
				if(StringUtils.isEmpty(tmp.parent)){    // if(key.indexOf("=")<0){
					newList.addItem(tmp);
				}else{
					var code:String = key.split("=")[1];
					if(!StringUtils.isEmpty(customMap[code])){
						code= code + "$$" + key.split("=")[0];
						tmp.data = code;
						newList.addItem(tmp);
					} 
					customMap[code] = tmp.label;
					var key2:String = entity + "/" + field + "/" + code + "/" + tmp.parent;
					cache_parent_value.put(key2,tmp.label);					
				}
			}
			
			for each (var newtmp:Object in newList){
				var key1:String = Utils.checkNullValue(newtmp.data);
				if(!StringUtils.isEmpty(customMap[key1])){
					newtmp.label = customMap[key1];
				}  			
			}
			return newList;
		}
		
		public static function getHeaderValue(value:String):String {
			var languageCode:String = LocaleService.getLanguageInfo().LanguageCode;
			if(value.indexOf(languageCode)<0) languageCode = CustomFieldDAO.DEFAULT_LANGUAGE_CODE;
			var headers:Array = Utils.checkNullValue(value).split(";");
			for each (var header:String in headers){
				if(!StringUtils.isEmpty(header) && header.indexOf(":")>0){
					if(header.split(":")[0]== languageCode){
						return header.split(":")[1];
					}
				}
			}
			return "";
		}
		
	}
}