package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	public class CustomLayoutConditionDAO extends SimpleTable {
		
		private var stmtFind:SQLStatement;
		private var stmtList:SQLStatement;
		private var stmtListRectype:SQLStatement;
		private var stmtInsert:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtCurrenctDelete:SQLStatement;
		private var stmtCheckExisted:SQLStatement;
		private var stmtFindByParam:SQLStatement;
		private var stmtFindDifferent:SQLStatement;
		private var stmtContainsParam:SQLStatement;
		
		public function CustomLayoutConditionDAO(sqlConnection:SQLConnection,work:Function){
			
			super(sqlConnection, work, {
				table: 'custom_layout_condition',
				index: ["entity,subtype", "column_name"],
				unique : ["entity, subtype,num"],
				columns: { 'TEXT' : ["entity","operator","column_name","params"],					
					'INTEGER':["subtype","num"]
				}
			});
			
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM custom_layout_condition WHERE entity=:entity and subtype=:subtype and num=:num";			
			
			stmtFindByParam = new SQLStatement();
			stmtFindByParam.sqlConnection = sqlConnection;
			stmtFindByParam.text = "SELECT * FROM custom_layout_condition WHERE entity=:entity and params=:params and operator='='";
			
			stmtFindDifferent = new SQLStatement();
			stmtFindDifferent.sqlConnection = sqlConnection;
			stmtFindDifferent.text = "SELECT * FROM custom_layout_condition WHERE entity=:entity and operator='!=' order by subtype asc";
			
			stmtContainsParam = new SQLStatement();
			stmtContainsParam.sqlConnection = sqlConnection;
			stmtContainsParam.text = "SELECT * FROM custom_layout_condition WHERE entity=:entity and operator='contains'";	
			
			stmtCheckExisted = new SQLStatement();
			stmtCheckExisted.sqlConnection = sqlConnection;
			stmtCheckExisted.text = "SELECT * FROM custom_layout_condition WHERE entity=:entity and subtype=:subtype";			
			
			stmtList = new SQLStatement();
			stmtList.sqlConnection = sqlConnection;
			stmtList.text = "SELECT * FROM custom_layout_condition WHERE entity=:entity and subtype=:subtype";
			
			stmtListRectype = new SQLStatement();
			stmtListRectype.sqlConnection = sqlConnection;
			stmtListRectype.text = "SELECT * FROM custom_layout_condition WHERE entity=:entity";
			
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE custom_layout_condition SET column_name = :column_name, operator = :operator, params = :params WHERE entity = :entity AND subtype = :subtype AND num = :num";
			
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO custom_layout_condition (entity, subtype, num, column_name, operator, params) VALUES (:entity, :subtype, :num, :column_name, :operator, :params)";
			
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM custom_layout_condition WHERE entity = :entity AND subtype = :subtype";
			
			stmtCurrenctDelete = new SQLStatement();
			stmtCurrenctDelete.sqlConnection = sqlConnection;
			stmtCurrenctDelete.text = "DELETE FROM custom_layout_condition WHERE entity = :entity AND subtype = :subtype AND num = :num";
			
		}
		
		public function deleteCurrently(entity:String, subtype:String, num:String):void{
			stmtCurrenctDelete.parameters[":entity"] = entity;
			stmtCurrenctDelete.parameters[":subtype"] = subtype;
			stmtCurrenctDelete.parameters[":num"] = num;
			stmtCurrenctDelete.execute();
		}
		
		public function find(entity:String, subtype:String, num:String):Object{
			stmtFind.parameters[":entity"] = entity;
			stmtFind.parameters[":subtype"] = subtype;
			stmtFind.parameters[":num"] = num;
			stmtFind.execute();
			var r:SQLResult = stmtFind.getResult(); 
			if(r.data==null || r.data.length==0) return null;
			return r.data[0];
		}
		public function findByParam(entity:String, params:String):ArrayCollection{
			stmtFindByParam.parameters[":entity"] = entity;
			stmtFindByParam.parameters[":params"] = params;
			stmtFindByParam.execute();
			return new ArrayCollection(stmtFindByParam.getResult().data);
		}
		public function findByContain(entity:String):ArrayCollection{
			stmtContainsParam.parameters[":entity"] = entity;
			stmtContainsParam.execute();
			return new ArrayCollection(stmtContainsParam.getResult().data);
		}
		
		public function findByDifferent(entity:String):ArrayCollection{
			stmtFindDifferent.parameters[":entity"] = entity;
			stmtFindDifferent.execute();
			return new ArrayCollection(stmtFindDifferent.getResult().data);
		}
		
		public function checkExisted(entity:String, column_name:String, subtype:String):Object{
			stmtCheckExisted.parameters[":entity"] = entity;
			stmtCheckExisted.parameters[":subtype"] = subtype;
			//stmtCheckExisted.parameters[":column_name"] = column_name;
			stmtCheckExisted.execute();
			var r:SQLResult = stmtCheckExisted.getResult(); 
			if(r.data==null || r.data.length==0) return null;
			return r.data[0];
		}
		
		public function list(entity:String, subtype:String):ArrayCollection{
			stmtList.parameters[":entity"] = entity;
			stmtList.parameters[":subtype"] = subtype;
			stmtList.execute();
			return new ArrayCollection(stmtList.getResult().data);
		}
		
		public function listRecordType(entity:String):ArrayCollection{
			stmtListRectype.parameters[":entity"] = entity;
			stmtListRectype.execute();
			return new ArrayCollection(stmtListRectype.getResult().data);
		}
		
		public override function insert(customLayoutCondition:Object):SimpleTable{
			exec(stmtInsert, customLayoutCondition);
			return this;
		}
		
		public function deleted(entity:String, subtype:String):void{
			stmtDelete.parameters[":entity"] = entity;
			stmtDelete.parameters[":subtype"] = subtype;
			stmtDelete.execute();
		}
		
		public override function update(customLayoutCondition:Object,criteria:Object=null, onConflict:String=""):SimpleTable{
			exec(stmtUpdate, customLayoutCondition);
			return this;
		}
		
		private function exec(stmt:SQLStatement, object:Object):void{
			stmt.parameters[":entity"] = object.entity;
			stmt.parameters[":subtype"] = object.subtype;
			stmt.parameters[":num"] = object.num;
			stmt.parameters[":column_name"] = object.column_name;
			stmt.parameters[":operator"] = object.operator;
			stmt.parameters[":params"] = object.params;
			stmt.execute();
		}
	}
}