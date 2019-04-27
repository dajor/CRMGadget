package gadget.dao
{
	import com.adobe.utils.StringUtil;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import gadget.service.LocaleService;
	import gadget.service.PicklistService;
	import gadget.util.CacheUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	public class CascadingPicklistDAO extends SimpleTable {
		
		private var stmtSelectCascadingEntitys:SQLStatement;
		private var stmtInsert:SQLStatement;
		public static const CUSTOM_FIELD_TYPE:String ="customfield";
		
		private var cache_child_value:CacheUtils = new CacheUtils("cascading_child_values");
		private var cache_parent_field:CacheUtils = new CacheUtils("cascading_parent_field");
		
		
		public function CascadingPicklistDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"cascading_picklist",
				drop_table:true,
				//VAHI
				// Added parent_picklist into index, too, due to following artificial case:
				// Country: Germany, Bavaria
				// County: Bavaria
				// City: Munich
				// Contact:(County,City)=(Bavaria,Munich)
				// Contact:(Country,City)=(Bavaria,Munich)
				// With parent_picklist missing this creates a constraint violation.
				unique: [ 'entity, parent_picklist, child_picklist, parent_value, child_value,parent_code,child_code' ],
				columns: { 'TEXT': [
								'entity',
								'parent_picklist',
								'child_picklist',
								'parent_value',
								'child_value',
								'parent_code',
								'child_code',
								'temp2_code'
							] }
			});
			
			stmtSelectCascadingEntitys = new SQLStatement();
			stmtSelectCascadingEntitys.sqlConnection = sqlConnection;
			stmtSelectCascadingEntitys.text = "select distinct(entity) from cascading_picklist";
			
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO cascading_picklist (entity, parent_picklist, child_picklist, parent_value, child_value, parent_code, child_code)" +
				" VALUES (:entity, :parent_picklist, :child_picklist, :parent_value, :child_value,:parent_code, :child_code)";
		}
		
		public static var vars:String = "entity, parent_picklist, child_picklist, parent_value, child_value, parent_code, child_code";
		
		public function selectAll(entity:String,customCacading:Boolean=false):ArrayCollection {			
			var allPicklist:ArrayCollection = new ArrayCollection;
			allPicklist.addAll(select_oodCascading(entity));		
			allPicklist.addAll(select_crmCascading(entity));
			return allPicklist;
		}
		
		public function insert_(cascading:Object):void{
			stmtInsert.parameters[":entity"] = cascading.entity;
			stmtInsert.parameters[":parent_picklist"] = cascading.parent_picklist;
			stmtInsert.parameters[":child_picklist"] = cascading.child_picklist;
			stmtInsert.parameters[":parent_value"] = cascading.parent_value;
			stmtInsert.parameters[":child_value"] = cascading.child_value;
			stmtInsert.parameters[":parent_code"] = cascading.parent_code;
			stmtInsert.parameters[":child_code"] = cascading.child_code;
			exec(stmtInsert);
		}
		
		public function checkPicklistCode_(objCascading:Object):void{
			
			//for each(var objCascading:Object in listCascading){
			
			
			 var parentField:String = objCascading['parent_picklist'];
			 var childField:String = objCascading['child_picklist'];
			 var entity:String =objCascading["entity"];
			 var childVal:String = objCascading["child_value"];
			 var parentVal:String =objCascading["parent_value"];
			 var lanCode:String = LocaleService.getLanguageInfo().LanguageCode;
			 var parentCode:String = PicklistService.getId(entity,parentField,parentVal,lanCode);
			 var childCode:String = PicklistService.getId(entity,childField,childVal,lanCode);
				
			 
			 if(StringUtils.isEmpty(childCode)){
				 childCode = PicklistService.getId(entity,childField,childVal);
				  
			 }
			 
			 if(StringUtils.isEmpty(parentCode)){
				 parentCode = PicklistService.getId(entity,parentField,parentVal); 
			 }
			
			 
			 if(Database.preferencesDao.isUsedSSO()){				 
				 
				 if(!StringUtils.isEmpty(parentCode)){
					 parentVal = PicklistService.getValueOOD(entity,parentField,parentCode,lanCode);
				 }
				 
				 if(!StringUtils.isEmpty(parentCode)){
					 childVal = PicklistService.getValueOOD(entity,childField,childCode,lanCode);
				 } 
			 }
			 
			 
			 if(!StringUtils.isEmpty(parentVal)){				 
				 objCascading["parent_value"]=parentVal;
				 
			 }
			 if(!StringUtils.isEmpty(childVal)){
				 
				 objCascading["child_value"] = childVal;
				 var key:String = entity + "/" + childField + "/" + childCode + "/" + parentCode;
				 cache_child_value.put(key, childVal);					 
				 cache_parent_field.put(entity + "/" + childField,parentField);
				 
			 }
			 objCascading['child_code'] = childCode;
			 objCascading['parent_code'] = parentCode;
			 
			 
		}
		
		private function getPiclistCode(objCascading:Object,keyValue:String,allPiclistValues:ArrayCollection):Object {
			for(var i:int=0;i<allPiclistValues.length;i++){						
				var objPicklist:Object = allPiclistValues.getItemAt(i);
				if(objCascading[keyValue] == objPicklist.label || 
					"[" + objCascading[keyValue] + "]" ==  objPicklist.label ){
					i = allPiclistValues.length;
					return objPicklist;
				}
			}	
			return null;
		}
		
		public function getAllCascadingEntity():ArrayCollection{
			exec(stmtSelectCascadingEntitys);
			return new ArrayCollection(stmtSelectCascadingEntitys.getResult().data);
		}
		
		public function find_cascading_parent(entity:String):void {
			var alllist:ArrayCollection = selectAll(entity);
//			var cache_child_value:CacheUtils = new CacheUtils("cascading_child_values");
//			var cache_parent_field:CacheUtils = new CacheUtils("cascading_parent_field");
			var lst:ArrayCollection = new ArrayCollection();
			
			for each(var cascading:Object in alllist){
				
					
				var key:String = entity + "/" + cascading.child_picklist + "/" + cascading.child_code+ "/" + cascading.parent_code;
				if(key.indexOf("=")<0){
					var value:String = Utils.checkNullValue(cache_child_value.get(key));					
					if(StringUtils.isEmpty(value)){
						cache_child_value.put(key, cascading.child_value);
					} 
					cache_parent_field.put(cascading.entity + "/" + cascading.child_picklist,cascading.parent_picklist);
				}else{
					 key = entity + "/" + cascading.child_picklist + "/" + cascading.child_code.split("=")[1]+ "/" + cascading.parent_code;
					 cache_child_value.put(key, CUSTOM_FIELD_TYPE);					 
					 cache_parent_field.put(cascading.entity + "/" + cascading.child_picklist,cascading.parent_picklist);
				}
			}
		}
	
		
		public function select_oodCascading(entity:String):ArrayCollection {
			var cache:CacheUtils = new CacheUtils("cascading_ood");	
			
			var picklist:ArrayCollection = cache.get(entity) as ArrayCollection;			
			if (picklist != null) {				
				return new ArrayCollection(picklist.source);
			}			
			picklist = new ArrayCollection(select(vars, null, {entity:entity}));		
			//checkPicklistCode(entity,"child_picklist","child_code","child_value",picklist);
			//checkPicklistCode(entity,"parent_picklist","parent_code","parent_value",picklist);
			cache.put(entity, picklist);
			return picklist;
		}
		
		public function select_crmCascading(entity:String):ArrayCollection {
			var cache:CacheUtils = new CacheUtils("cascading_crm");				
			var picklist:ArrayCollection = cache.get(entity) as ArrayCollection;			
			if (picklist != null) {				
				return new ArrayCollection(picklist.source);
			}			
			picklist = Database.customFieldDao.getBindCascadingPicklist(entity,LocaleService.getLanguageInfo().LanguageCode);
			cache.put(entity, picklist);
			return picklist;
		}
		
		/*private function checkPicklistCode(entity:String,keyField:String,keyCode:String,keyValue:String,listCascading:ArrayCollection):void{
			
			for each(var objCascading:Object in listCascading){				
				objCascading[keyCode] = objCascading[keyValue];
				var field:String = objCascading[keyField];
				var allPiclistValues:ArrayCollection = PicklistService.getBindPicklist(entity,field,false);
				/*if(entity=="Custom Object 1" && field =="IndexedPick0"){
					trace("checkPicklistCode");
				}*/
				// var allPiclistValues:ArrayCollection = PicklistService.getPicklist(entity,field,false);
				/*for(var i:int=0;i<allPiclistValues.length;i++){						
					var objPicklist:Object = allPiclistValues.getItemAt(i);
					if(objCascading[keyValue] == objPicklist.label || 
						"[" + objCascading[keyValue] + "]" ==  objPicklist.label ){
						i = allPiclistValues.length;
						objCascading[keyCode] = objPicklist.data;		
						objCascading[keyValue] = objPicklist.label;
					}
				}			
				
				var objPicklist:Object = getPiclistCode(objCascading,keyValue,allPiclistValues);
				if(!objPicklist){
					objPicklist = PicklistService.getPicklistId(entity,field,objCascading[keyValue]);
					if(objPicklist){
						objPicklist.label = PicklistService.getValue(entity,field,objPicklist.data);
					}
					
				}
				if(objPicklist){
					objCascading[keyCode] = objPicklist.data;		
					objCascading[keyValue] = objPicklist.label;
				}
			}
		}*/
		
		public function selectParentColumn(entity:String,child_picklist:String):String{
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity,child_picklist:child_picklist},"1"));
			if(list.length>0){
				return list.getItemAt(0).parent_picklist;
			}
			return null;
			
		}
									 
		
		
		public function selectParent(entity:String,child_picklist:String,customCacading:Boolean=false):ArrayCollection {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity,child_picklist:child_picklist}));
			return list;
		}
	}
}
