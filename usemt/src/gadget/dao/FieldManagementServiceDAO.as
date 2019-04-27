// Keep the synced ranges in the database

package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.utils.Dictionary;
	
	public class FieldManagementServiceDAO extends SimpleTable {
		
		public function FieldManagementServiceDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"field_management",
				unique: [ 'entity, Name' ],
				index: [],
				create_cb: function(structure:Object):void {Database.incomingSyncDao.unsync_one("FieldManagementService")}
			});
		}
		
		public function delete_one(name:String):void {
			del(null,{name:name});
			Database.fieldTranslationDataDao.delete_one(name);
		}
		
		public function getDefaultFieldValue(entity:String, displayName:String):Array{
			var where:String = " Where entity='" + entity + "' and (DisplayName='" + displayName + "' or Name='" + displayName + "')";
			return select_order("*", where, null, "DisplayName",null);
		}
		
		public function getByIntegrationTag(entity:String, integrationTagName:String):Object{
			var where:String = " Where entity='" + entity + "' and IntegrationTag='" + integrationTagName + "'";
			var result:Array = select_order("*", where, null, null,null);
			if(result!=null && result.length>0){
				return result[0];
			}
			
			return null;
			
		}
		
		public function getReadOnlyField(entity:String):Dictionary{
			var where:String = " Where entity='" + entity + "' and ReadOnly='true'";
			var result:Array = select_order("*", where, null, null,null);
			var dic:Dictionary = new Dictionary();
			if(result!=null && result.length>0){
				for each(var obj:Object in result){
					dic[obj.Name]=obj;
				}
			}
			
			return dic;
		}
		
		public function getByName(entity:String,name:String):Object{
			
			var where:String = " Where entity='" + entity + "' and Name='" + name + "'";
			var result:Array = select_order("*", where, null, null,null);
			if(result!=null && result.length>0){
				return result[0];
			}
			
			return null;
		}
		
		public function readAll(entity:String):Dictionary{
			var where:String = " Where entity='" + entity + "'";
			var result:Array = select_order("*", where, null, "DisplayName",null);
			var dic:Dictionary = new Dictionary();
			if(result!=null && result.length>0){
				for each(var obj:Object in result){
					dic[obj.Name]=obj;
				}
			}
			return dic;
			
		}
		
		public function readAllDefaultValueFields(entity:String):Dictionary{
			var where:String = " Where (DefaultValue is not null AND DefaultValue!='') AND  entity='" + entity + "'";
			var result:Array = select_order("*", where, null, "DisplayName",null);
			var dic:Dictionary = new Dictionary();
			if(result!=null && result.length>0){
				for each(var obj:Object in result){
					if(entity==Database.customObject11Dao.entity && obj.Name=='CustomText54'){//bug#8825
						obj.PostDefault='true';
					}
					dic[obj.Name]=obj;
				}
			}
			return dic;
			
		}
		
		override public function delete_all():void {
			del(null);
			Database.fieldTranslationDataDao.delete_all();
		}

		override public function getColumns():Array {
			return [
				'entity',
				'Name',
				'DefaultValue',
				'DisplayName',
				'FieldType',
				'FieldValidation',
				'IntegrationTag',
				'PostDefault',
				'ReadOnly',
				'Required',
				'ValidationErrorMsg'
			];
		}
	}
}
