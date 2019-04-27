package gadget.service
{
	import com.adobe.rtc.core.connect_internal;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.util.FieldUtils;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	import org.purepdf.pdf.ArabicLigaturizer;

	/**
	 * Class that stores field info for support tables. 
	 * i.e. Activity_product.
	 */
	public class SupportService
	{
		public function SupportService()
		{
		}
		
		/**
		 * Mapping table used for matching oracle fields. 
		 */
		private static const FIELD_MAPPING:Object = {
			"BOOL"	 : "CustomBoolean",
			"TEXTLG" : "CustomText",
			"TEXTSM" : "CustomText",
			"PICK" 	 : "CustomPickList",
			"INT" 	 : "CustomInteger",
			"DATE": "CustomDate",
			"TIME": "CustomDate"
		};
		
		private static const PVG_FIELD_MAPPING:Object={
			"ZPick" 	 : "CustomPickList"
		};
		
		
		public static function getPVGField(tmpName:String):String{	
			if(tmpName!=null){
				var strSplit:Array = tmpName.split('_');
				var key:String = strSplit[0];
				if(PVG_FIELD_MAPPING.hasOwnProperty(key)){
					return PVG_FIELD_MAPPING[key]+strSplit[1];
				}
			}
			
			return tmpName;
		}
		
		private static const FIELD_MAPPING_OOD:Object = {
			"BOOL"	 : "CustomBoolean",
			"TEXTLG" : "CustomText",
			"TEXTSM" : "CustomText",
			"PICK" 	 : "CustomPickList",
			"INT" 	 : "CustomInteger",
			"DATE": "CustomDate",
			"TIME": "CustomDateTime",
			"CUR" : "CustomCurrency",
			"NUM" : "CustomNumber"
		};
		
		/**
		 * Check if names from translation table and field table are equivalent. 
		 * @param trans Field name from CRMOD translation table.
		 * @param field Field name from CRMOD field table.
		 * @return True if both fields are equivalent. 
		 */
		
		public static function match(trans:String, field:String):Boolean {
			if(trans == null){
				return false;
			}
			// "Indexed Pick 0" becomes "IndexedPick0"... 
			if (trans.replace(/ /g, "") == field) {
				return true;
			}
			// "BOOL_000" is the same than "CustomBoolean0", etc.
			for (var key:String in FIELD_MAPPING) {
				if (StringUtils.startsWith(trans, key + "_")) {
					var num:int = int(trans.substring(key.length + 1));
					if (trans.indexOf("TEXTSM") != -1) { //Must be plus 30 for data type is Short(Text).
						num += 30;
					}else if(trans.indexOf("TIME") != -1){
						num += 25;
					}
					if (field == FIELD_MAPPING[key] + num) {

						return true;
					}
				}
			}
			return false;
		}
		//bug #1912
		public static function matchOOD(oodField:String):String {
			var field:String = oodField.replace(/ /g, ""); 
			for (var key:String in FIELD_MAPPING_OOD) {
				var num:int = int(oodField.substring(key.length + 1));
				if(oodField.indexOf(key) != -1){
					field = FIELD_MAPPING_OOD[key];
					if (oodField.indexOf("TEXTSM") != -1) { //Must be plus 30 for data type is Short(Text).
						num += 30;
					}else if(oodField.indexOf("TIME") != -1){
						num += 25;
					}
					return field + num ;
				}
				
			}
			return field;
		}
		
		/**
		 * Returns the list of fields to display for a support entity.
		 * fakes Array like FieldDAO.listFields()
		 * @param entity Support entity to consider.
		 * @return The entity's list of fields.
		 */
		public static function getFields(entity:String):ArrayCollection {
			var crmodEntity:String = DAOUtils.getRecordType(entity);
			if (crmodEntity == null) crmodEntity = entity;
			var languageCode:String = LocaleService.getLanguageInfo().LanguageCode;
			var transArray:Array = Database.fieldTranslationDataDao.fetch({entity:crmodEntity, LanguageCode:languageCode});			
			
			var fields:ArrayCollection = new ArrayCollection();
			var daoFields:Object = SupportRegistry.allFields(entity);
			var parentDaos:Array = entity.split(".");
			var parentDaoFields:ArrayCollection = new ArrayCollection();
			parentDaoFields.addAll(FieldUtils.allFields(parentDaos[0]));
			parentDaoFields.addAll(FieldUtils.allFields(parentDaos[1]));
			for (var fieldName:String in daoFields) {
				// try to find the display name in field_translation table
				var field:Object = daoFields[fieldName];
				var displayName:String = null;
				// 1. search in translation table
				for each (var transData:Object in transArray) {
					if (match(transData.Name, field.name)) {
						displayName = transData.DisplayName;
						break;
					}
				}
				// 2. search in fields table of parent daos
				if (displayName == null) {
					for each (var parentData:Object in parentDaoFields) {
						if (field.name == parentData.element_name) {
							displayName = parentData.display_name;
							break;
						}
					}
				}
				// 3. if we have found nothing, let's use the field name
				if (displayName == null) {
					displayName = field.name;
				}
				fields.addItem({entity:entity, element_name:field.name, display_name:displayName, data_type:field.type});
			}
			return fields;
		}
	}
}