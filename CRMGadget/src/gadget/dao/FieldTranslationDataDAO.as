// Keep the synced ranges in the database

package gadget.dao
{
	import flash.data.SQLConnection;
	
	import flexunit.utils.ArrayList;
	
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	public class FieldTranslationDataDAO extends SimpleTable {
		
		public function FieldTranslationDataDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "field_translation",
				unique: [ 'entity, Name, LanguageCode' ],
				index:[]
			});
		}
		private var vars:String = "entity, Name, ValidationErrorMsg, LanguageCode";
		public function delete_one(name:String):void {
			del(null,{name:name});
		}
		
		override public function getColumns():Array {
			return [
				'entity',
				'Name',
				'LanguageCode',
				'DisplayName',
				'ValidationErrorMsg'
			];
		}
		public function readAll(entity:String):Array{
			var where:String = " Where entity='" + entity + "'";
			return select_order("*", where, null, "DisplayName",null);
		}
		public function selectField(entity:String, fieldName:String,languageCode:String):Object {
			var where:String = "Where entity='" + entity + "' AND Name='" + fieldName + "' AND " ;
//			if(StringUtils.isEmpty(languageCode) || languageCode=="ENU"){
//				where = where + "(LanguageCode = 'ENG' OR LanguageCode = 'ENU')";
//				//languageCode = "ENG";
//			}else{
//				where = where + "LanguageCode = '" + languageCode +"'";
//			}
			var firstwhere:String = "";
			if(StringUtils.isEmpty(languageCode)){
				firstwhere = where + "LanguageCode = 'ENU'";
			}else{
				firstwhere = where + "LanguageCode = '" + languageCode +"'";
			}
			var list:ArrayCollection = new ArrayCollection(select(vars, firstwhere, null));
			if(list.length<1 && (StringUtils.isEmpty(languageCode) || languageCode=="ENU")){
				where +="LanguageCode = 'ENG'";
				list = new ArrayCollection(select(vars,where,null));	
			}
			
			if(list.length>0){
				return list[0];
			}else{
				list = new ArrayCollection(select(vars, null, {entity:entity, Name:fieldName}));
				if(list != null && list.length>0){
					return list[0];
				}
			}
			return null;
		}

	}
}
