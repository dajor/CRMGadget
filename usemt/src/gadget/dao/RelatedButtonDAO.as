package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class RelatedButtonDAO extends BaseSQL
	{
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtAll:SQLStatement;
		private var stmtDisableRelatedButton:SQLStatement;
		public function RelatedButtonDAO(sqlConnection:SQLConnection)
		{
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO related_button (parent_entity, entity, disable) VALUES (:parent_entity, :entity, :disable)";
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE related_button SET disable = :disable WHERE parent_entity = :parent_entity AND entity = :entity";
			stmtDisableRelatedButton = new SQLStatement();
			stmtDisableRelatedButton.sqlConnection = sqlConnection;
			stmtDisableRelatedButton.text = "SELECT * FROM related_button WHERE parent_entity = :parent_entity AND entity = :entity";
			
			stmtAll = new SQLStatement();
			stmtAll.sqlConnection = sqlConnection;
			stmtAll.text = "SELECT * FROM related_button WHERE parent_entity = :parent_entity Order By entity";
		}
		
		public function insert(relatedButton:Object):void{
			stmtInsert.parameters[":parent_entity"]=relatedButton.parent_entity;
			stmtInsert.parameters[":entity"]=relatedButton.entity;
			stmtInsert.parameters[":disable"]=relatedButton.disable;
			exec(stmtInsert);
		}
		
		public function upsert(relatedButton:Object):void{
			if(find(relatedButton.parent_entity,relatedButton.entity) != null ){
				stmtUpdate.parameters[":parent_entity"]=relatedButton.parent_entity;
				stmtUpdate.parameters[":entity"]=relatedButton.entity;
				stmtUpdate.parameters[":disable"]=relatedButton.disable;
				exec(stmtUpdate);
			}else{
				insert(relatedButton);
			}
		}
		public function find(parent_entity:String,entity:String):Object{
			stmtDisableRelatedButton.parameters[":parent_entity"]=parent_entity;
			stmtDisableRelatedButton.parameters[":entity"]=entity;
			exec(stmtDisableRelatedButton);
			var result:SQLResult = stmtDisableRelatedButton.getResult();
			if(result.data==null || result.data.length==0) return null;
			return result.data[0];
		}
		public function getDisable(parent_entity:String,entity:String):Boolean{
			stmtDisableRelatedButton.parameters[":parent_entity"]=parent_entity;
			stmtDisableRelatedButton.parameters[":entity"]=entity;
			exec(stmtDisableRelatedButton);
			var result:SQLResult = stmtDisableRelatedButton.getResult();
			if(result.data==null || result.data.length==0) {
				return false;
			}else{
				return result.data[0].disable;
			}
		}
		
		public function findByParent(parent_entity:String):ArrayCollection{
			stmtAll.parameters[":parent_entity"]=parent_entity;
			exec(stmtAll);
			return new ArrayCollection(stmtAll.getResult().data);
		}
		/**key= child entity*/
		public function findDisableByParent(parent_entity:String):Dictionary{
			stmtAll.parameters[":parent_entity"]=parent_entity;
			exec(stmtAll);
			var dic:Dictionary = new Dictionary();
			for each(var obj:Object in new ArrayCollection(stmtAll.getResult().data)){
				if(obj.disable){
					var key:String = obj.enity;
					dic[key]=obj.disable;
				}
			}
			return dic;
		}
		
	}
}