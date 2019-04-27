package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class CriteriaDAO extends BaseSQL {

		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtFind:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtFindWithConjunctionAnd:SQLStatement;
		private var stmtSelect:SQLStatement;
		private var stmtDeleteAll:SQLStatement;
		
		public function CriteriaDAO(sqlConnection:SQLConnection)
		{
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO filter_criteria (id, num, column_name, operator, param, conjunction)" +
				" VALUES (:id, :num, :column_name, :operator, :param, :conjunction)";
				
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM filter_criteria WHERE id = :id AND num = :num";

			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE filter_criteria SET column_name = :column_name, operator = :operator, param = :param, conjunction = :conjunction" +
				" WHERE id = :id AND num = :num";
				
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM filter_criteria WHERE id = :id";
			
			stmtFindWithConjunctionAnd = new SQLStatement();
			stmtFindWithConjunctionAnd.sqlConnection = sqlConnection;
			stmtFindWithConjunctionAnd.text = "SELECT * FROM filter_criteria WHERE id = :id";
			
			stmtSelect = new SQLStatement();
			stmtSelect.sqlConnection = sqlConnection;
			stmtSelect.text = "SELECT * FROM filter_criteria WHERE id = :id";
			
			stmtDeleteAll = new SQLStatement();
			stmtDeleteAll.sqlConnection = sqlConnection;
			stmtDeleteAll.text = "DELETE FROM filter_criteria";
		}

		public function select(filterId:String):ArrayCollection{
			stmtSelect.parameters[":id"] = filterId;
			exec(stmtSelect);
			return new ArrayCollection(stmtSelect.getResult().data);
		}
		
		public function insert(criteria:Object):void
		{
			stmtInsert.parameters[":id"] = criteria.id;
			stmtInsert.parameters[":num"] = criteria.num;
			stmtInsert.parameters[":column_name"] = criteria.column_name;
			stmtInsert.parameters[":operator"] = criteria.operator;
			stmtInsert.parameters[":param"] = criteria.param;
			stmtInsert.parameters[":conjunction"] = criteria.conjunction;
			//Bug fixing 469 CRO
			//don't need value of evaluate
//			stmtInsert.parameters[":param_display"] = criteria.param_display;
			exec(stmtInsert);
		}
		
		public function find(id:String, num:String):Object
		{
			stmtFind.parameters[":id"] = id;
			stmtFind.parameters[":num"] = num;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result!=null){
				var arrayObject:Array = result.data;
				if(arrayObject!=null && arrayObject.length>0){
					return arrayObject[0];
				}
			}
			//create order if cannot find
			var obj:Object=new Object();
			if(num=='5'){
				obj.id=id;
				obj.num=num;
				obj.param="asc";
				insert(obj);
			}
			
			return obj;
		}
		
		public function update(criteria:Object):void
		{
			stmtUpdate.parameters[":id"] = criteria.id;
			stmtUpdate.parameters[":num"] = criteria.num;
			stmtUpdate.parameters[":column_name"] = criteria.column_name;
			stmtUpdate.parameters[":operator"] = criteria.operator;
			stmtUpdate.parameters[":param"] = criteria.param;
			stmtUpdate.parameters[":conjunction"] = criteria.conjunction;
			//Bug fixing 469 CRO
			//don't need value of evaluate
//			stmtUpdate.parameters[":param_display"] = criteria.param_display;
			exec(stmtUpdate);
		}
		
		public function delete_(filter:Object):void
		{
			stmtDelete.parameters[":id"] = filter.id;
			exec(stmtDelete);
		}
		
		public function findCriterialWithConjunctionAnd(id:String):ArrayCollection{
			var arrayList:ArrayCollection = new ArrayCollection();
			var checkConjunctionOR:Boolean = false;
			stmtFindWithConjunctionAnd.parameters[":id"] = id;
			exec(stmtFindWithConjunctionAnd);
			var result:SQLResult = stmtFindWithConjunctionAnd.getResult();
			var arrayObject:Array = result.data;
			if(arrayObject==null || arrayObject.length ==0)
				return arrayList;
			for(var i:int=0; i<arrayObject.length; i++){
				if(arrayObject[i].conjunction == "OR"){
					if(arrayObject[i].column_name != ""){
						checkConjunctionOR = true;
						arrayList.addItem(arrayObject[i]);
					}
				}else if(arrayObject[i].column_name != ""){
					if(arrayList.length>0 && checkConjunctionOR){
						return new ArrayCollection();
					}
					arrayList.addItem(arrayObject[i]);
				}
			}
			return arrayList;
		}
		
		public function deleteAll():void{
			exec(stmtDeleteAll);
		}
	}
}