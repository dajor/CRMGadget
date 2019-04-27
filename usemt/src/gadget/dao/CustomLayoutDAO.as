package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.utils.Dictionary;
	
	import gadget.i18n.i18n;
	import gadget.service.LocaleService;
	import gadget.service.UserService;
	import gadget.util.CacheUtils;
	import gadget.util.ImageUtils;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	public class CustomLayoutDAO extends SimpleTable {

		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtRead:SQLStatement;
		private var stmtReadSubtype:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtReadAll:SQLStatement;
		private var stmtNextSubtype:SQLStatement;
		private static var pluralCache:Object = new Object();
		private static var iconCache:Object = new Object();
		private var stmtFieldCondition:SQLStatement;
		private static const textColumns:Array=[
			"entity", 			
			"layout_name", 			
			"custom_layout_icon", 
			"background_color", 
			"display_name", 
			"display_name_plural", 
			"layout_depend_on", 
			"custom_layout_title"
		];
		
		public function CustomLayoutDAO(sqlConnection:SQLConnection,work:Function)
		{
			
			super(sqlConnection, work, {
				table: 'custom_layout',
				index: ["entity,subtype", "layout_name"],
				unique : ["entity, subtype"],
				columns: { 'TEXT' : textColumns,
						   'BOOLEAN':["deletable"],
						   'INTEGER':["subtype"]
				}
			});
			
			
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO custom_layout (entity, subtype, layout_name, deletable, custom_layout_icon, background_color, display_name, display_name_plural, custom_layout_title,layout_depend_on)" +
				" VALUES (:entity, :subtype, :layout_name, :deletable, :custom_layout_icon, :background_color, :display_name, :display_name_plural, :custom_layout_title, :layout_depend_on)";

			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE custom_layout SET layout_name = :layout_name, " +
				"deletable = :deletable, custom_layout_icon = :custom_layout_icon, background_color = :background_color, display_name = :display_name, display_name_plural = :display_name_plural," +
				" custom_layout_title = :custom_layout_title,layout_depend_on = :layout_depend_on" +
				" WHERE entity = :entity AND subtype = :subtype";
				
			stmtFieldCondition = new SQLStatement();
			stmtFieldCondition.sqlConnection = sqlConnection;
			stmtFieldCondition.text = "SELECT * FROM custom_layout where entity = :entity AND layout_depend_on = :layout_depend_on";

			stmtRead = new SQLStatement();
			stmtRead.sqlConnection = sqlConnection;
			stmtRead.text = "SELECT * FROM custom_layout where entity = :entity ORDER BY subtype DESC";
			
			stmtReadSubtype = new SQLStatement();
			stmtReadSubtype.sqlConnection = sqlConnection;
			stmtReadSubtype.text = "SELECT * FROM custom_layout where entity = :entity AND subtype = :subtype";
			
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM custom_layout WHERE entity = :entity AND subtype = :subtype"
				
			stmtReadAll = new SQLStatement();
			stmtReadAll.sqlConnection = sqlConnection;
			//stmtReadAll.text = "SELECT * FROM custom_layout ORDER BY entity, layout_name";
			stmtReadAll.text = "SELECT * FROM custom_layout ORDER BY deletable, entity";
			
			stmtNextSubtype = new SQLStatement();
			stmtNextSubtype.sqlConnection = sqlConnection;
			stmtNextSubtype.text = "SELECT MAX(subtype) max_num FROM custom_layout WHERE entity = :entity";
		}

		public override function insert(layout:Object):SimpleTable
		{
			executeStatement(stmtInsert,layout);
			return this;
		}
		
		public override function update(layout:Object,criteria:Object=null, onConflict:String=""):SimpleTable
		{
			var cache:CacheUtils = new CacheUtils("Custom_Layout");
			var key:String = layout.entity + "_" + layout.subtype;
			cache.set(key, layout);
			
			if(pluralCache[key]){
				trace("Modified plural name in cache");
				pluralCache[key] = layout.display_name_plural;
			}
			executeStatement(stmtUpdate,layout);
			return this;
		}
		
		private function executeStatement(stmt:SQLStatement,layout:Object):void
		{
			stmt.parameters[":entity"] = layout.entity;
			stmt.parameters[":subtype"] = layout.subtype;
			stmt.parameters[":layout_name"] = layout.layout_name;
//			stmt.parameters[":field"] = layout.field;
//			stmt.parameters[":operator"] = layout.operator;
//			stmt.parameters[":value"] = layout.value;
			stmt.parameters[":deletable"] = layout.deletable;
			stmt.parameters[":custom_layout_icon"] = layout.custom_layout_icon;
			stmt.parameters[":background_color"] = layout.background_color;
			stmt.parameters[":display_name"] = layout.display_name;
			stmt.parameters[":display_name_plural"] = layout.display_name_plural;
			stmt.parameters[":custom_layout_title"] = layout.custom_layout_title;
			stmt.parameters[":layout_depend_on"] = layout.layout_depend_on;
			exec(stmt);
		}
		
		public function read(entity:String):ArrayCollection
		{
			stmtRead.parameters[":entity"] = entity;
			exec(stmtRead);
			var result:SQLResult = stmtRead.getResult();
			if (result.data == null) return null;
			return new ArrayCollection(result.data);
		}
		
		//field dependon is the key
		public function getLayoutDependOnByEntity(entity:String):Dictionary{
			var result:ArrayCollection = read(entity);
			var map:Dictionary = new Dictionary();
			for each(var layout:Object in result){
				if(!StringUtils.isEmpty(String(layout.layout_depend_on))){
					map[layout.layout_depend_on] = layout;
				}
			}
			
			return map;
		}
		
		public function checkExisted(entity:String,dependOn:String):Boolean{
			stmtFieldCondition.parameters[":entity"] = entity;
			//stmtFieldCondition.parameters[":subtype"] = subtype;
			stmtFieldCondition.parameters[":layout_depend_on"] = dependOn;
			exec(stmtFieldCondition);
			var result:SQLResult = stmtFieldCondition.getResult();
			if (result.data == null) return false;
			return true ;
		}
		
		public function readSubtype(entity:String, subtype:int):Object
		{
			var cache:CacheUtils = new CacheUtils("Custom_Layout");
			var customLayout:Object;
			var key:String = entity + "_" + subtype;
			customLayout = cache.get(key);
			if(customLayout==null){
				stmtReadSubtype.parameters[":entity"] = entity;
				stmtReadSubtype.parameters[":subtype"] = subtype;
				exec(stmtReadSubtype);
				var result:SQLResult = stmtReadSubtype.getResult();
				if (result.data == null) return null;
				customLayout = result.data[0];
				cache.set(key, customLayout);
			}
			return customLayout;
		}
		
		public function delete_one(entity:String, subtype:int):void{
			var cache:CacheUtils = new CacheUtils("Custom_Layout");
			var key:String = entity + "_" + subtype;
			cache.del(key);
			stmtDelete.parameters[":entity"] = entity;
			stmtDelete.parameters[":subtype"] = subtype;
			exec(stmtDelete);
		}
		
		public function readAll():ArrayCollection{
			exec(stmtReadAll);
			return new ArrayCollection(stmtReadAll.getResult().data);
		}
		
		public function nextSubtype(entity:String):int{
			stmtNextSubtype.parameters[":entity"] = entity;
			exec(stmtNextSubtype);
			var result:SQLResult = stmtNextSubtype.getResult();
			if (result.data == null || result.data.length == 0 || result.data[0].max_num==null) {
				return 0;
			}
			return int(result.data[0].max_num) + 1;
		}
		
		public function getDisplayName(entity:String, subtype:int=0):String {
			//bug #1679 CRO add new tab
			if(MainWindow.mapCustomTab[entity] != null) return  i18n._("GLOBAL_" +entity.toUpperCase());
			var objName:String;
			var customLayout:Object = readSubtype(entity, subtype);
			if (customLayout != null) {
				//CRO Bug fixing 84 19.01.2011
				if (customLayout.display_name == null || customLayout.display_name == '') {
					objName = entity;
					if(entity == 'Activity'){
						if(subtype == 0){
							objName = i18n._("GLOBAL_TASK");
						}else if(subtype == 1){
							objName = i18n._("GLOBAL_APPOINTMENT");
						}else if(subtype == 2){
							objName =  i18n._("GLOBAL_CALL");
						}
					}else{
						var obj:Object=Database.customRecordTypeTranslationsDao.selectCustomRecordTypeByEntity(entity,
										LocaleService.getLanguageInfo().LanguageCode);
						if(obj==null){
							objName = entity == "Note" ? i18n._("PREFERENCE_TRANSACTION_NOTE@Note") : i18n._("GLOBAL_" + entity.replace(/\s/gi,"_").toUpperCase());
						}else{
							objName=obj.SingularName;
						}
					}
					return objName;
				
				}
				return customLayout.display_name;
			}
			return entity;
		}
		
		public function getPlural(entity:String, subtype:int=0):String{   
			//if(entity==Database.opportunityProductRevenueDao.entity){
			//	return Database.opportunityProductRevenueDao.getPluralName();//mony
			//}
			var objName:String;
			var customLayout:Object = readSubtype(entity, subtype);
			if (customLayout != null) {
				//CRO Bug fixing 84 19.01.2011
				if (customLayout.display_name_plural == null || customLayout.display_name_plural == '') {
					objName = entity;
					if(entity == 'Activity'){
						if(subtype == 0){
							//CRO Bug fixing 178 25.01.2011
							objName = i18n._("GLOBAL_TASKS");
						}else if(subtype == 1){
							objName = i18n._("GLOBAL_APPOINTMENTS");
						}else if(subtype == 2){
							objName =  i18n._("GLOBAL_CALLS");
						}
					}else{					
						
						var obj:Object=Database.customRecordTypeTranslationsDao.selectCustomRecordTypeByEntity(entity,
							LocaleService.getLanguageInfo().LanguageCode);
						if(obj==null){
							/*
							if(entity.indexOf(".") != -1 ){
								var arr:Array = entity.split(".");
								var parentEntity:String = arr[0];
								var subEntity:String = arr[1].toString().toUpperCase();
								if(subEntity == "PARTNER" || subEntity == "RELATED"){
									parentEntity = getDisplayName(parentEntity);
									objName = parentEntity + " " + i18n._("GLOBAL_" +subEntity+"_PLURAL");
								}else if(subEntity == "TEAM"){ //Bug #6448
									parentEntity = getDisplayName(parentEntity);
									objName = parentEntity +  i18n._("GLOBAL_" +subEntity+"_PLURAL");
								}
								else{
									objName =i18n._("GLOBAL_" +subEntity+"_PLURAL");
								}
							}else{
								objName = i18n._("GLOBAL_" + entity.replace(/\s/gi,"_").toUpperCase()+"_PLURAL");
							}
							*/
							
							
							objName = i18n._("GLOBAL_" + entity.replace(/\s/gi,"_").toUpperCase()+"_PLURAL@"+entity);
						}else{
							objName=obj.PluralName;
						}
					}
					return objName;
				}

				return customLayout.display_name_plural;
			}
			return i18n._("GLOBAL_" + entity.replace(/\s/gi,"_").toUpperCase()+"_PLURAL@"+entity);
		}
		
		public function clearCache():void{
			pluralCache = new Object();
		}
		
		public function getIcon(entity:String, subtype:int=0):Class
		{
			var key:String = entity + "_" + subtype;
			if(iconCache[key]){
				return iconCache[key];
			}
			
			if(CustomRecordTypeServiceDAO.isCustomObject(entity) || Database.preferencesDao.isModernIcon()){
				var oodIcon:Class =  Database.customRecordTypeServiceDao.readIcon(entity);
				if(oodIcon){
					iconCache[key] = oodIcon;
					return iconCache[key];
				}
			}
			
			var customLayout:Object = readSubtype(entity, subtype);
			if (customLayout != null) {
				iconCache[key] = ImageUtils.getIconByName(customLayout.custom_layout_icon);
				return iconCache[key];
			}
			return null;
		}	
		
		public function clearIconCache():void {
			iconCache = new Object();	
		}
		
	}
}