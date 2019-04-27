package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	public class PicklistDAO extends BaseSQL {

		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtFind:SQLStatement;
		private var stmtFindByValue:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtDeleteAll:SQLStatement;
		private var stmtSelect:SQLStatement;
		private var stmtRead:SQLStatement;
		private var stmtGetId:SQLStatement = new SQLStatement();
		
		public function PicklistDAO(sqlConnection:SQLConnection)
		{
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO picklist (record_type, field_name, code, value,disabled,Order_)" +
				" VALUES (:record_type, :field_name, :code, :value, :disabled,:Order_)";
				
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM picklist WHERE record_type = :record_type AND field_name = :field_name AND code = :code AND disabled = :disabled";

			stmtFindByValue = new SQLStatement();
			stmtFindByValue.sqlConnection = sqlConnection;
			stmtFindByValue.text = "SELECT * FROM picklist WHERE record_type = :record_type AND field_name = :field_name AND value = :value AND disabled = :disabled";
			
			// SCH : 6449
			// add Order_ property for sorting
			stmtSelect = new SQLStatement();
			stmtSelect.sqlConnection = sqlConnection;
			stmtSelect.text = "SELECT code data, value label, Order_ FROM picklist WHERE record_type = :record_type AND field_name = :field_name AND disabled = :disabled ORDER BY Order_";

			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE picklist SET value = :value" +
				" WHERE record_type = :record_type AND field_name = :field_name AND code = :code";
				
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM picklist WHERE record_type = :record_type AND field_name = :field_name AND code = :code";
			
			
			stmtGetId.sqlConnection = sqlConnection;
			stmtGetId.text = "SELECT code FROM picklist WHERE record_type = :record_type AND field_name = :field_name AND disabled = :disabled AND value =:value ";
			
			stmtDeleteAll = new SQLStatement();
			stmtDeleteAll.sqlConnection = sqlConnection;
			stmtDeleteAll.text = "DELETE FROM picklist";

			stmtRead = new SQLStatement();
			stmtRead.sqlConnection = sqlConnection;
			stmtRead.text = "SELECT * FROM picklist where disabled='N'";
		}

	
		
		public function insert(picklist:Object):void
		{
			stmtInsert.parameters[":record_type"] = picklist.record_type;
			stmtInsert.parameters[":field_name"] = picklist.field_name;
			stmtInsert.parameters[":code"] = picklist.code;
			stmtInsert.parameters[":value"] = picklist.value;
			stmtInsert.parameters[":disabled"] = picklist.disabled;
			stmtInsert.parameters[":Order_"] = picklist.Order_;
			exec(stmtInsert);
		}
		
		public function find(picklist:Object):Object
		{
			stmtFind.parameters[":record_type"] = picklist.record_type;
			stmtFind.parameters[":field_name"] = picklist.field_name;
			stmtFind.parameters[":code"] = picklist.code;
			stmtFind.parameters[":disabled"] = picklist.disabled==null?'N':picklist.disabled;
			exec(stmtFind);
			
			var result:SQLResult = stmtFind.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		public function findByValue(picklist:Object):Object
		{
			stmtFindByValue.parameters[":record_type"] = picklist.record_type;
			stmtFindByValue.parameters[":field_name"] = picklist.field_name;
			stmtFindByValue.parameters[":value"] = picklist.value;
			stmtFindByValue.parameters[":disabled"] = picklist.disabled==null?'N':picklist.disabled;
			exec(stmtFindByValue);
			
			var result:SQLResult = stmtFindByValue.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		
		public function select(fieldName:String, recordType:String):ArrayCollection{
			stmtSelect.parameters[":field_name"] = fieldName;
			stmtSelect.parameters[":record_type"] = recordType;
			stmtSelect.parameters[":disabled"] = 'N';
			exec(stmtSelect);
			// SCH : 6449
			// add Order_ field for sorting
			var items:ArrayCollection = new ArrayCollection(stmtSelect.getResult().data);
			//items.addItemAt({data:'',label:''},0);
			return items;
		}
		
		/**
		 * 
		 * @param entity
		 * @param field
		 * @param value
		 * @return 
		 * 
		 */
		public function getId(entity:String,field:String,value:String):String{
			stmtGetId.parameters[":field_name"] = field;
			stmtGetId.parameters[":record_type"] = entity;
			stmtGetId.parameters[":disabled"] = 'N';
			stmtGetId.parameters[":value"]=value;
			exec(stmtGetId);
			var result:Array = stmtGetId.getResult().data;
			if(result!=null && result.length>0){
				return result[0].code;	
			}
			return null;
		}
		
		public function update(picklist:Object):void
		{
			stmtUpdate.parameters[":disabled"] = picklist.disabled;
			stmtUpdate.parameters[":value"] = picklist.value;
			stmtUpdate.parameters[":record_type"] = picklist.record_type;
			stmtUpdate.parameters[":field_name"] = picklist.field_name;
			stmtUpdate.parameters[":code"] = picklist.code;
			exec(stmtUpdate);
		}
		
		public function delete_(picklist:Object):void
		{
			stmtDelete.parameters[":record_type"] = picklist.record_type;
			stmtDelete.parameters[":field_name"] = picklist.field_name;
			stmtDelete.parameters[":code"] = picklist.code;
			exec(stmtDelete);
		}
		
		public function delete_all():void
		{
			exec(stmtDeleteAll);
		}
		
		public function read():Object
		{
			exec(stmtRead);
			var result:SQLResult = stmtRead.getResult();
			if (result.data == null) {
				return null;
			}
			return result.data[0];
		}
		
	}
}