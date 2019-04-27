package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class PicklistValueGroupDAO extends SimpleTable {
		
		public function PicklistValueGroupDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"picklist_value_group",				
				unique: [ 'PicklistValueGroupId, ObjectName, FieldName, LicName' ],
				index: [ 'PicklistValueGroupId', 'ObjectName', 'FieldName' ],
				columns: { 'TEXT' : getColumns()}
			});
			
		}
		
		
		public function getPickList(entity:String,groupId:String,fieldName:String):ArrayCollection{			
			var result:Array = select("*",null,{'PicklistValueGroupId':groupId,'ObjectName':entity,'FieldName':fieldName});
			if(result==null || result.length<1){
				var realName:Object = Database.fieldManagementServiceDao.getByName(entity,fieldName);
				if(realName!=null){
					//try to get with meta name
					result =  select("*",null,{'PicklistValueGroupId':groupId,'ObjectName':entity,'FieldName':realName.HtmlName});	
				}
				
			}
			if(result==null || result.length<1){
				//try to get with meta name
				result =  select("*",null,{'PicklistValueGroupId':groupId,'ObjectName':Database.getDao(entity).metaDataEntity,'FieldName':fieldName});
				if(result==null || result.length<1){
					var realName1:Object = Database.fieldManagementServiceDao.getByName(entity,fieldName);
					if(realName1!=null){
						//try to get with meta name
						result =  select("*",null,{'PicklistValueGroupId':groupId,'ObjectName':Database.getDao(entity).metaDataEntity,'FieldName':realName1.HtmlName});	
					}
					
				}
			}
			
			
			
			return new ArrayCollection(result);
		}
		
		override public function getColumns():Array {
			return [
				'ObjectName',	
				'PicklistValueGroupId',
				'PicklistValueGroupName',
				'FieldName',
				'LicName',
			];
		}
		
	}
}