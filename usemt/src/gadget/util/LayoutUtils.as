package gadget.util
{
	
	
	import gadget.dao.Database;
	
	import mx.collections.ArrayCollection;

	public class LayoutUtils
	{
		public function LayoutUtils(){}
		
		public static function getSubtypeIndex(item:Object):int {
			var subtypeIndex:String = getItemLayoutType(item);
			if(subtypeIndex != "") return int(subtypeIndex);
			return 0;
		}

		public static function getObjectSubtype(entity:String,subtype:String):Object{
			var objSubtype:Object;
			for each(var codition:Object in Database.customLayoutConditionDAO.list(entity, subtype)){
				if(codition.operator == "="){
					objSubtype = codition;
					break;
				}
			}
			return objSubtype;
		}
		
		private static function getItemLayoutType(item:Object):String {
			var layouts:ArrayCollection = Database.customLayoutDao.read(item.gadget_type);
			var subtype:String = '';
			var maxIndex:int = 0;
			for each (var layout:Object in layouts) {
				
				var countCondition:int = 0;
				var totalCondition:int = 0;
				var condition1:Boolean = false;
				var condition2:Boolean = false;
				var condition3:Boolean = false;
				var condition4:Boolean = false;
				for each(var codition:Object in Database.customLayoutConditionDAO.list(layout.entity, layout.subtype)){
					var checkCondition:Boolean = false;
					var key:String = item[codition.column_name];
					if(codition.operator == "!="){												
						var realVal:String = codition.params;
						if(realVal=='NULL' || StringUtils.isEmpty(realVal)){
							if(!StringUtils.isEmpty(key)){
								checkCondition = true;
							}
						}else if(realVal!=key){
							checkCondition = true;
						}
					}
					//CRO #1274 toUpperCase
					if(codition.operator == "="){
						if(StringUtils.isEmpty(key)){
							key="NULL";//empty mean null
						}
						if(key != null && codition.params != null && key.toLowerCase() == (codition.params as String).toLowerCase()){
							//subtype = layout.subtype;
							checkCondition = true;
						}
					}

					if(codition.operator!=""){
						if(checkCondition){
							countCondition ++;
						}
						totalCondition ++;
					}
				}
				
				if(totalCondition==countCondition){
					// All Conditions is true
					if(totalCondition>maxIndex) {
						maxIndex = totalCondition;
						subtype = layout.subtype;
					}
				}
			}
			return subtype;
		}	
		
//		public static function getSubtypeName(entity:String, subtype:int):String {
//			var subtypeName:String = "";
//			if(entity == "Activity"){
//				subtypeName = subtype == 0 ? "Task" : "Appointment";
//			}else{
//				subtypeName = Database.transactionDao.getDisplayName(entity);
//			}
//			return subtypeName;
//		}		
		
		public static function convertSubtypeNameToSubtypeIndex(entity:String, subtypeName:String):int {
			var subtypeIndex:int = 0;
			if( entity == "Activity" ) {
				if( subtypeName == "Appointment") subtypeIndex = 1;
			}
			return subtypeIndex;
		}
		
	}
}