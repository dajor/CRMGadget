package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import gadget.util.CacheUtils;
	
	public class CustomRecordTypeTranslationsDAO extends SimpleTable {
		protected var cache:CacheUtils = new CacheUtils("CUSTOM_RECORD_TYPE_TRANS");
		protected static const LIST_CACHE_TRANSLATE:String = "listCustomTranslate";
		private var stmtSelectOne:SQLStatement ;
		public function CustomRecordTypeTranslationsDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "custom_record_type_trans",
				unique: [ "CustomRecordTypeServiceName, LanguageCode" ],
				index: [],
				create_cb: function(structure:Object):void {Database.incomingSyncDao.unsync_one("CustomRecordTypeService")} // refetch the parent!
			});
			stmtSelectOne=new SQLStatement();
			stmtSelectOne.sqlConnection=sqlConnection;
			stmtSelectOne.text="select * from custom_record_type_trans";
		}
		
		override public function delete_all():void {
			cache.clear();
			cache.set(LIST_CACHE_TRANSLATE,null);
			super.delete_all();
		}
		
		public function selectCustomRecordTypeByEntity(entity:String,langcode:String="ENG"):Object{
			var key:String = entity+"_"+langcode;
			var listTrans:Object = cache.get(LIST_CACHE_TRANSLATE);
			if(listTrans==null){
				listTrans = new Object();
				cache.set(LIST_CACHE_TRANSLATE,listTrans);
				exec(stmtSelectOne);
				var result:SQLResult=stmtSelectOne.getResult();
				if(result!=null){
					var data:Array=result.data;
					if(data!=null && data.length>0){						
						for each(var obj:Object in data){
							var realKey:String = obj.CustomRecordTypeServiceName+"_"+obj.LanguageCode
							listTrans[realKey] = obj;
						}
					}
				}
				
			}
			return listTrans[key];
			
			
		}

		public function delete_one(name:String):void {
			del(null,{name:name});
		}
		
		override public function getColumns():Array {
			return [
				'CustomRecordTypeServiceName',
				'LanguageCode',
				'SingularName',
				'PluralName',
				'ShortName',
			];
		}
	}
}
