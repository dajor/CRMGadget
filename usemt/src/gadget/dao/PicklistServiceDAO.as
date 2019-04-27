package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import mx.collections.ArrayCollection;
	
	public class PicklistServiceDAO extends SimpleTable {
		private var stmtSelect:SQLStatement;
		private var stmtSelectOne:SQLStatement;
		private var stmtSelectByValue:SQLStatement;
		public function PicklistServiceDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"picklist_service",
				//VAHI fix Issue #13, see comment at end
				unique: [ 'ObjectName, Name, ValueId, LanguageCode, Order3_' ],
				index: [ 'ObjectName, Name, LanguageCode, Order3_', 'ObjectName, FieldName, LanguageCode, Order3_' ],
				columns: { 'TEXT' : getColumns(),
					'INTEGER':['Order3_']}
			});
			
			stmtSelect = new SQLStatement();
			stmtSelect.sqlConnection = sqlConnection;
			stmtSelect.text = "SELECT ValueId data,Value label,Order3_ Order_  FROM picklist_service WHERE LanguageCode=:LanguageCode and  ObjectName = :record_type AND FieldName = :field_name AND Disabled = :disabled ORDER BY Order3_ asc";
			
			stmtSelectOne = new SQLStatement();
			stmtSelectOne.sqlConnection = sqlConnection;
			stmtSelectOne.text = "SELECT Value FROM picklist_service WHERE LanguageCode=:LanguageCode and  ObjectName = :record_type AND FieldName = :field_name AND Disabled = :disabled AND ValueId = :code  ORDER BY Order3_ asc";
			
			stmtSelectByValue = new SQLStatement();
			stmtSelectByValue.sqlConnection = sqlConnection;
			stmtSelectByValue.text = "SELECT Value FROM picklist_service WHERE LanguageCode=:LanguageCode and  ObjectName = :record_type AND FieldName = :field_name AND Disabled = :disabled AND Value = :value  ORDER BY Order3_ asc";
			
			
		}
		
		public function delete_one(entity:String):void {
			del(null,{ObjectName:entity});
		}
		
		
		

		public function getPicklistsValue(fieldName:String, entity:String,code:String, langCode:String='ENU'):String{
			
			var obj:Object = getPicklistsObject(fieldName,entity,code,langCode);
			if(obj!=null){
				return obj.Value;
			}
			return null;
			
		}
		
		public function getPicklistsId(fieldName:String, entity:String,label:String, langCode:String='ENU'):String{
			
			var obj:Object = getPicklistsObjectByValue(fieldName,entity,label,langCode);
			if(obj!=null){
				return obj.ValueId;
			}
			return null;
			
		}
		
		public function getPicklistsObjectByValue(fieldName:String, entity:String,label:String, langCode:String='ENU'):Object{
			stmtSelectByValue.parameters[":field_name"] = fieldName;
			stmtSelectByValue.parameters[":record_type"] = entity;
			stmtSelectByValue.parameters[":LanguageCode"] = langCode;
			stmtSelectByValue.parameters[":disabled"] = "false";
			stmtSelectByValue.parameters[":value"] = label;
			exec(stmtSelectByValue);
			var result:Array=stmtSelectByValue.getResult().data;
			if(result!=null && result.length>0){
				return result[0];
			}
			return null;
			
		}
		public function getPicklistsObject(fieldName:String, entity:String,code:String, langCode:String='ENU'):Object{
			
			stmtSelectOne.parameters[":field_name"] = fieldName;
			stmtSelectOne.parameters[":record_type"] = entity;
			stmtSelectOne.parameters[":LanguageCode"] = langCode;
			stmtSelectOne.parameters[":disabled"] = "false";
			stmtSelectOne.parameters[":code"] = code;
			exec(stmtSelectOne);
			var result:Array=stmtSelectOne.getResult().data;
			if(result!=null && result.length>0){
				return result[0];
			}
			return null;
			
		}	
		
		public function getPicklists(fieldName:String, entity:String, langCode:String='ENU'):ArrayCollection{
			
			stmtSelect.parameters[":field_name"] = fieldName;
			stmtSelect.parameters[":record_type"] = entity;
			stmtSelect.parameters[":LanguageCode"] = langCode;
			stmtSelect.parameters[":disabled"] = "false";
			exec(stmtSelect);
			var result:Array=stmtSelect.getResult().data;
			var pick:ArrayCollection = new ArrayCollection(result);
			//items.addItemAt({data:'',label:''},0);
//			return items;
//			
//			
//			var pick:ArrayCollection = new ArrayCollection();
//			
//			
//			
//			var got:Array = fetch({
//				ObjectName:   entity,
//				FieldName:    fieldName,
//				LanguageCode: langCode,
//				Disabled:     "false"
//			});
			
			// SCH : 6449
			// add Order_ property for sorting//Mony--do not loop we can make it in sql query
//			for each (var r:Object in result) {
//				pick.addItem({ data:r.ValueId, label:r.Value, Order_:r.Order3_ });
//			}
			return pick;
		}

		override public function getColumns():Array {
			return [
				'FieldName',	//VAHI added, hopefully our internal name

				'ObjectName',
				'Name',
				'ValueId',
				'Disabled',
				'LanguageCode',
				'Value',
				//'Order_',
			];
		}
	}
}

/** Example bug #13 seen live:
 *	<ns1:PicklistSet>
 *		<ns1:ObjectName>Campaign</ns1:ObjectName> 
 *		<ns1:ListOfPicklists>
 *		<ns1:Name>Customer Target Type</ns1:Name> 
 *		<ns1:ListOfPicklistValues>
 *			<ns1:PicklistValue>
 *				<ns1:ValueId>Email</ns1:ValueId> 
 *				<ns1:Disabled>false</ns1:Disabled> 
 *				<ns1:ListOfValueTranslations>
 *					<ns1:ValueTranslation>
 *						<ns1:LanguageCode>ENU</ns1:LanguageCode> 
 *						<ns1:Value>Email</ns1:Value> 
 *						<ns1:Order>2</ns1:Order> 
 *					</ns1:ValueTranslation>
 *				</ns1:ListOfValueTranslations>
 *			</ns1:PicklistValue>
 *			<ns1:PicklistValue>
 *				<ns1:ValueId>Email</ns1:ValueId> 
 *				<ns1:Disabled>false</ns1:Disabled> 
 *				<ns1:ListOfValueTranslations>
 *					<ns1:ValueTranslation>
 *						<ns1:LanguageCode>ENU</ns1:LanguageCode> 
 *						<ns1:Value>Email</ns1:Value> 
 *						<ns1:Order>18</ns1:Order> 
 *					</ns1:ValueTranslation>
 *				</ns1:ListOfValueTranslations>
 *			</ns1:PicklistValue>
 */
