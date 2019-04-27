package gadget.dao
{
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class RelationManagementDAO extends SimpleTable {
	
		private var stmtSelectAll:SQLStatement = null;
		private var stmtFind:SQLStatement = null;
		private var stmtFindEnabled:SQLStatement = null;
		private var stmtFindByEntity:SQLStatement = null;
		private var stmtUpdate:SQLStatement = null;
		private var stmtUpdateAllByEnity:SQLStatement = null;
		
		public function RelationManagementDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table:"relation_management",
				index: [ 'parent_entity', 'sub_entity' ],
				columns: { 'TEXT' : textColumns ,'BOOLEAN' : ['enabled'],'INTEGER' : ["order_num"]}
			});
			stmtSelectAll = new SQLStatement();
			stmtSelectAll.sqlConnection = sqlConnection;
			stmtSelectAll.text ="select * from relation_management order by order_num";
			
			
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM relation_management WHERE parent_entity = :parent_entity AND sub_entity = :sub_entity";
			
			stmtFindEnabled = new SQLStatement();
			stmtFindEnabled.sqlConnection = sqlConnection;
			stmtFindEnabled.text = "SELECT * FROM relation_management WHERE parent_entity = :parent_entity AND enabled = 1";
		
			stmtFindByEntity = new SQLStatement();
			stmtFindByEntity.sqlConnection = sqlConnection;
			stmtFindByEntity.text = "SELECT * FROM relation_management WHERE parent_entity = :parent_entity order by order_num";
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE relation_management SET enabled = :enabled" + 
							" WHERE parent_entity = :parent_entity AND sub_entity = :sub_entity AND order_num = :order_num";
			
			stmtUpdateAllByEnity = new SQLStatement();
			stmtUpdateAllByEnity.sqlConnection = sqlConnection;
			stmtUpdateAllByEnity.text = "UPDATE relation_management SET enabled = :enabled" + 
				" WHERE parent_entity = :parent_entity";
		}
		
		public function selectAll():ArrayCollection{
			exec(stmtSelectAll);
			return new ArrayCollection(stmtSelectAll.getResult().data);
		}
		
		public function _delete(data:Object):void {
			delete_({parent_entity: data.parent_entity, column_name: data.column_name});
		}
		
		public function findDepthStructure(where:String):ArrayCollection {
			return new ArrayCollection(select_order("*", where, null, "num", null));
		}
		
		public function find(parent_entity:String,sub_entity:String):Object{
			stmtFind.parameters[":parent_entity"] = parent_entity;
			stmtFind.parameters[":sub_entity"] = sub_entity;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0) return null;
			return result.data[0];
		}
		
		
		public function findByEntity(parent_entity:String):Array{
			stmtFindByEntity.parameters[":parent_entity"] = parent_entity;
			exec(stmtFindByEntity);
			var result:SQLResult = stmtFindByEntity.getResult();
			if(result.data==null || result.data.length==0) return new Array();
			return result.data;
		}
		
		public function updateEnabled(obj:Object):void{
			stmtUpdate.parameters[":parent_entity"] = obj.parent_entity;
			stmtUpdate.parameters[":sub_entity"] = obj.sub_entity;
			stmtUpdate.parameters[":parent_field"] = obj.parent_field;
			stmtUpdate.parameters[":sub_field"] = obj.sub_field;
			stmtUpdate.parameters[":enabled"] = obj.enabled;
			stmtUpdate.parameters[":order_num"] = obj.order_num;
			stmtUpdate.parameters[":display_name"] = obj.display_name;
			
			exec(stmtUpdate);
		}
		
		public function updateEnabledAll(parent_entity:String,enabled:int):void{
			stmtUpdateAllByEnity.parameters[":parent_entity"] = parent_entity;
			stmtUpdateAllByEnity.parameters[":enabled"] = enabled;
			exec(stmtUpdateAllByEnity);
		}
		
		public function listSubEnabledTransaction(parent_entity:String):Array{
			stmtFindEnabled.parameters[":parent_entity"] = parent_entity;
			exec(stmtFindEnabled);
			var result:SQLResult = stmtFindEnabled.getResult();
			if(result.data==null || result.data.length==0) return new Array();
			return result.data;
		}
		
		override public function insert(data:Object):SimpleTable {
			
			return super.insert(data);
		}
		
	
		private var textColumns:Array = [
			"parent_entity",
			"sub_entity",
			"sub_field",
			"parent_field",
			"display_name"
			
		];
		
	}
}