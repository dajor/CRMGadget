package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import gadget.util.CacheUtils;
	import gadget.util.ImageUtils;
	import gadget.util.StringUtils;
	
	import mx.utils.StringUtil;
	
	public class CustomRecordTypeServiceDAO extends SimpleTable {
		protected var cache:CacheUtils = new CacheUtils("CUSTOM_RECORD_TYPE");
		
		public function CustomRecordTypeServiceDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "custom_record_type",
				unique: [ 'Name' ],
				index: [],
				create_cb: function(structure:Object):void {Database.incomingSyncDao.unsync_one("CustomRecordTypeService")}
			});
		}
		
		public function delete_one(name:String):void {
			del(null,{Name:name});
			var obj:Object  = cache.get("CUSTOM_RECORD_TYPE");
			if(obj!=null){
				delete obj[name];
			}
			Database.customRecordTypeTranslationsDao.delete_one(name);
		}

		override public function delete_all():void {
			del(null);
			cache.clear();
			cache.set("CUSTOM_RECORD_TYPE",null);
			Database.customRecordTypeTranslationsDao.delete_all();
		}
		
	
		
		public function readByEntity(entity:String):Object{
			entity = StringUtils.replaceAll_(entity, " ","");
			var obj:Object  = cache.get("CUSTOM_RECORD_TYPE");
			if(obj==null){
				obj = new Object();
				cache.set("CUSTOM_RECORD_TYPE",obj);
				var results:Array = fetch();
				for each(var recordObject:Object in results) {
					var name:String = recordObject.Name;
					name = StringUtils.replaceAll_(name, " ","");
					obj[name] = recordObject;					
				}
			}
			
			
			return obj[entity];
		}
		
		public function readIcon(entity:String):Class{
			return ImageUtils.getImage_custom(readIconName(entity));
		}
		
		public static function isCustomObject(entity:String):Boolean{
			var tmpEntity:String = StringUtils.replaceAll_(entity, " ", "");
			return tmpEntity.indexOf("CustomObject") != -1;
		}
		
		public function readIconName(entity:String):String{
			var iconName:String = "";
			var custom:Object = Database.customRecordTypeServiceDao.readByEntity(entity);
			if(custom){
				if(Database.preferencesDao.isModernIcon()){
					iconName = custom.ModernIconName;
				}else{
					iconName = custom.IconName;
				}
				
			}
			return iconName;
			
		}
		
		override public function getColumns():Array {
			return [
				'Name', 
				'SingularName', 
				'PluralName', 
				'ShortName', 
				'IconName',
				'ModernIconName',
			];
		}
	}
}
