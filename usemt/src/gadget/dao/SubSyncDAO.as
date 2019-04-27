package gadget.dao
{
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.states.OverrideBase;
	
	public class SubSyncDAO extends SimpleTable {
		private var stmtFindSODName:SQLStatement = null;
		private var stmtSelectAll:SQLStatement = null;
		private var stmtFind:SQLStatement = null;
		private var stmtFindEnabled:SQLStatement = null;
		private var stmtFindEnabledOrder:SQLStatement = null;
		private var stmtFindByEntity:SQLStatement = null;
		private var stmtUpdate:SQLStatement = null;
		private var stmtUpdateAllByEnity:SQLStatement = null;
		private var stmtClearOrderByEnity:SQLStatement = null;
		private var stmtClean:SQLStatement = new SQLStatement();
		
		public function SubSyncDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table:"subsync",
				index: [ 'entity', 'sub' ],
				columns: { 'TEXT' : textColumns ,'BOOLEAN' : ['enabled','syncable'],'INTEGER' : ["order_num","advanced_filter"]}
			});
			stmtSelectAll = new SQLStatement();
			stmtSelectAll.sqlConnection = sqlConnection;
			stmtSelectAll.text ="select * from subsync order by num";
			
			stmtFindSODName = new SQLStatement();
			stmtFindSODName.sqlConnection = sqlConnection;
			stmtFindSODName.text = "SELECT * FROM subsync WHERE entity = :entity AND sodname = :sodname";
			
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM subsync WHERE entity = :entity AND sub = :sub";
			
			stmtFindEnabled = new SQLStatement();
			stmtFindEnabled.sqlConnection = sqlConnection;
			stmtFindEnabled.text = "SELECT * FROM subsync WHERE entity = :entity AND enabled = 1";
		
			stmtFindEnabledOrder = new SQLStatement();
			stmtFindEnabledOrder.sqlConnection = sqlConnection;
			stmtFindEnabledOrder.text = "SELECT * FROM subsync WHERE entity = :entity AND enabled = 1 order by order_num";
			
			stmtFindByEntity = new SQLStatement();
			stmtFindByEntity.sqlConnection = sqlConnection;
			stmtFindByEntity.text = "SELECT * FROM subsync WHERE entity = :entity";
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE subsync SET enabled = :enabled, advanced_filter =:advanced_filter" + 
							" WHERE entity = :entity AND sub = :sub";
			
			stmtUpdateAllByEnity = new SQLStatement();
			stmtUpdateAllByEnity.sqlConnection = sqlConnection;
			stmtUpdateAllByEnity.text = "UPDATE subsync SET enabled = :enabled" + 
				" WHERE entity = :entity";
			stmtClean.sqlConnection = sqlConnection;
			stmtClean.text = "DELETE FROM subsync where entity_name IS NULL OR entity_name=''";
			
			stmtClearOrderByEnity = new SQLStatement();
			stmtClearOrderByEnity.sqlConnection = sqlConnection;
			stmtClearOrderByEnity.text = "UPDATE subsync SET order_num = ''" + 
				" WHERE entity = :entity";
		}
		
		public function clean():void{
			exec(stmtClean);
		}
		
		public function selectAll():ArrayCollection{
			exec(stmtSelectAll);
			return new ArrayCollection(stmtSelectAll.getResult().data);
		}
		
		public function _delete(data:Object):void {
			delete_({entity: data.entity, column_name: data.column_name});
		}
		
		public function findDepthStructure(where:String):ArrayCollection {
			return new ArrayCollection(select_order("*", where, null, "num", null));
		}
		
		public function find(entity:String,sub:String):Object{
			stmtFind.parameters[":entity"] = entity;
			stmtFind.parameters[":sub"] = sub;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0) return null;
			return result.data[0];
		}
		public function findBySODName(entity:String,sodname:String):Object{
			stmtFindSODName.parameters[":entity"] = entity;
			stmtFindSODName.parameters[":sodname"] = sodname;
			exec(stmtFindSODName);
			var result:SQLResult = stmtFindSODName.getResult();
			if(result.data==null || result.data.length==0) return null;
			return result.data[0];
		}
		
		public function findByEntity(entity:String):Array{
			stmtFindByEntity.parameters[":entity"] = entity;
			exec(stmtFindByEntity);
			var result:SQLResult = stmtFindByEntity.getResult();
			if(result.data==null || result.data.length==0) return new Array();
			return result.data;
		}
		
		public function updateEnabled(obj:Object):void{
			stmtUpdate.parameters[":entity"] = obj.entity;
			stmtUpdate.parameters[":sub"] = obj.sub;
			stmtUpdate.parameters[":enabled"] = obj.enabled;
			stmtUpdate.parameters[":advanced_filter"] = obj.advanced_filter;
			exec(stmtUpdate);
		}
		
		public function updateEnabledAll(entity:String,enabled:int):void{
			stmtUpdateAllByEnity.parameters[":entity"] = entity;
			stmtUpdateAllByEnity.parameters[":enabled"] = enabled;
			exec(stmtUpdateAllByEnity);
		}
		public function clearOrder(entity:String,enabled:int):void{
			stmtClearOrderByEnity.parameters[":entity"] = entity;
			exec(stmtClearOrderByEnity);
		}
		public function listSubEnabledTransaction(entity:String):Array{
			stmtFindEnabled.parameters[":entity"] = entity;
			exec(stmtFindEnabled);
			var result:SQLResult = stmtFindEnabled.getResult();
			if(result.data==null || result.data.length==0) return new Array();
			return result.data;
		}
		
		public function listSubEnabledOrder(entity:String):Array{
			stmtFindEnabledOrder.parameters[":entity"] = entity;
			exec(stmtFindEnabledOrder);
			var result:SQLResult = stmtFindEnabledOrder.getResult();
			if(result.data==null || result.data.length==0) return new Array();
			return result.data;
		}
		
		override public function insert(data:Object):SimpleTable {
			
			return super.insert(data);
		}
		
		public function isEnableSub(entity:String,sodname:String):Boolean{
			var obj:Object = findBySODName(entity,sodname);
			if(obj != null && obj.enabled){
				return true;
			}
			return false;
		}
	
		public function getAdvancedFilterType(entity:String,subEntity:String):Number{
			var transaction:Object = find(entity,subEntity);
			if (transaction!=null) {
				return transaction.advanced_filter;
			}
			return -99;
			
		}
		private var textColumns:Array = [
			"entity",
			"sub",
			"sodname",
			"entity_name"			
		];
		
	}
}