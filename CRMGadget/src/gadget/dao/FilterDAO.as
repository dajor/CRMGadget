package gadget.dao {
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.utils.Dictionary;
	
	import gadget.util.CacheUtils;
	
	import mx.collections.ArrayCollection;
	
	public class FilterDAO extends BaseSQL {
		private var stmtListColumns:SQLStatement;
		private var stmtListFilters:SQLStatement;
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtList:SQLStatement;
		private var stmtExists:SQLStatement;
		private var stmtDeleteByName:SQLStatement;
		private var stmtDeleteAll:SQLStatement;
		private var stmtDeleteByEntity:SQLStatement;
		
		private var stmtListDefaultFilters:SQLStatement;
		private var stmtListDashboardFilters:SQLStatement;
		private var stmtDefaultFilter:SQLStatement;
		private var stmtFindFilter:SQLStatement;
		private var stmtIncreaseType:SQLStatement;
		private static const LIST_CACHE_FILTER:String="listfilterbyentity";
		private var cache:CacheUtils = new CacheUtils("Filter_DAO");
		private var stmtSelectDefaultFilter:SQLStatement;
		public function FilterDAO(sqlConnection:SQLConnection) {
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO filter (name, entity, predefined, type,isowner) VALUES (:name, :entity, :predefined, :type,:isowner)";
			
			stmtListFilters = new SQLStatement();
			stmtListFilters.sqlConnection = sqlConnection;
			stmtListFilters.text = "SELECT * FROM filter WHERE entity = :entity ORDER BY predefined desc, type desc";
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE filter SET name = :name, entity = :entity, predefined = :predefined, type = :type,isowner=:isowner WHERE id = :id";
			
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM filter WHERE id = :id";	
			
			stmtList = new SQLStatement();
			stmtList.sqlConnection = sqlConnection;
			stmtList.text = "SELECT * FROM filter";
			
			stmtExists = new SQLStatement();
			stmtExists.sqlConnection = sqlConnection;
			stmtExists.text = "SELECT * FROM filter WHERE name = :name";
			
			//stmtDeleteByName
			stmtDeleteByName = new SQLStatement();
			stmtDeleteByName.sqlConnection = sqlConnection;
			stmtDeleteByName.text = "delete FROM filter WHERE name = :name";
			
			
			stmtDeleteAll = new SQLStatement();
			stmtDeleteAll.sqlConnection = sqlConnection;
			stmtDeleteAll.text = "DELETE FROM filter";
			
			stmtDeleteByEntity = new SQLStatement();
			stmtDeleteByEntity.sqlConnection = sqlConnection;
			stmtDeleteByEntity.text = "DELETE FROM filter WHERE entity = :entity";
			
			
			stmtListDefaultFilters = new SQLStatement();
			stmtListDefaultFilters.sqlConnection = sqlConnection;
			stmtListDefaultFilters.text = "SELECT * FROM filter WHERE predefined = 1";
			
			stmtListDashboardFilters = new SQLStatement();
			stmtListDashboardFilters.sqlConnection = sqlConnection;
			stmtListDashboardFilters.text = "SELECT * FROM filter WHERE entity = :entity AND predefined = 0";
			
			stmtDefaultFilter = new SQLStatement();
			stmtDefaultFilter.sqlConnection = sqlConnection;
			stmtDefaultFilter.text = "SELECT * FROM filter WHERE entity = :entity AND type = :type";
			
			stmtFindFilter = new SQLStatement();
			stmtFindFilter.sqlConnection = sqlConnection;
			stmtFindFilter.text = "SELECT * FROM filter WHERE id = :id";
			
			stmtIncreaseType = new SQLStatement();
			stmtIncreaseType.sqlConnection = sqlConnection;
			stmtIncreaseType.text = "SELECT MAX(type) AS type FROM filter WHERE entity = :entity";
			
			stmtSelectDefaultFilter = new SQLStatement();
			stmtSelectDefaultFilter.sqlConnection = sqlConnection;
			stmtSelectDefaultFilter.text = "SELECT * from filter where entity=:entity and type=(select default_filter from transactions where entity = :entity) ";
			
		}
		
		public function insert(filter:Object):Number {
			stmtInsert.parameters[":name"] = filter.name;
			stmtInsert.parameters[":entity"] = filter.entity;
			stmtInsert.parameters[":predefined"] = filter.predefined;
			stmtInsert.parameters[":type"] = filter.type;
			stmtInsert.parameters[":isowner"]=filter.isowner==null?0:filter.isowner;
			//			stmtInsert.parameters[":bookmarked"] = filter.bookmarked;
			exec(stmtInsert);
			var id:Number = stmtInsert.getResult().lastInsertRowID;
			var dicOBject:Object = cache.get(LIST_CACHE_FILTER);
			if(dicOBject!=null){
				var key:String = filter.entity + "_" + filter.type;
				filter.id=id;
				dicOBject[key]=filter;
			}
			return id;
		}
		
		public function update(filter:Object):void {
			
			var dicOBject:Object = cache.get(LIST_CACHE_FILTER);
			if(dicOBject!=null){
				var key:String = filter.entity + "_" + filter.type;
				dicOBject[key]=filter;
			}
			
			stmtUpdate.parameters[":id"] = filter.id;
			stmtUpdate.parameters[":name"] = filter.name;
			stmtUpdate.parameters[":entity"] = filter.entity;
			stmtUpdate.parameters[":predefined"] = filter.predefined;
			stmtUpdate.parameters[":type"] = filter.type;
			stmtUpdate.parameters[":isowner"]=filter.isowner==null?0:filter.isowner;
			//			stmtUpdate.parameters[":bookmarked"] = filter.bookmarked;
			exec(stmtUpdate);
		}
		
		public function delete_(filter:Object):void	{
			var dicOBject:Object = cache.get(LIST_CACHE_FILTER);
			if(dicOBject!=null){
				var key:String = filter.entity + "_" + filter.type;
				delete dicOBject[key];
			}
			
			stmtDelete.parameters[":id"] = filter.id;
			exec(stmtDelete);
			//auto delete criteria
			Database.criteriaDao.delete_(filter);
			//CRO #1345
			Database.customFilterTranslatorDao.deleteByFilterId(filter.entity,filter.name);
		}
		
//		public function listFilters(entity:String):ArrayCollection {
//			var filters:ArrayCollection = new ArrayCollection();
//			for each(var objectFilter:Object in listFiltersCriteria(entity)){
//				var object:Object = new Object();
//				object.name = objectFilter.name;
//				object.id = objectFilter.type;
//				object.entity = objectFilter.entity;
//				filters.addItem(object);
//			}
//			return filters;
//		}
		
		public function listFiltersCriteria(entity:String):ArrayCollection{
			stmtListFilters.parameters[":entity"] = entity;
			exec(stmtListFilters);
			return new ArrayCollection(stmtListFilters.getResult().data);
		}
		
		
		public function listFilters():Array {
			exec(stmtList);
			return stmtList.getResult().data;
		}
		
		public function findByName(name:String){
			stmtExists.parameters[":name"] = name;
			exec(stmtExists);
			var result:Array = stmtExists.getResult().data;
			if(result!=null && result.length>0){
				return  result[0];
			}
			return null;
		}
		
		public function exists(name:String):Boolean {			
			return findByName(name) != null;
		}
		
		public function deleteByName(filterName):void{
			stmtDeleteByName.parameters[":name"] = filterName;
			exec(stmtDeleteByName);
		}
		
		
		
		
		public function deleteByEntity(entity:String):void{
			stmtDeleteByEntity.parameters[":entity"] = entity;
			exec(stmtDeleteByEntity);
		}
		
		public function deleteAll():void{
			exec(stmtDeleteAll);
		}
		
		public function listDefaultFilters():ArrayCollection{
			exec(stmtListDefaultFilters);
			return new ArrayCollection(stmtListDefaultFilters.getResult().data);
		}
		
		public function listDashboardFilters(entity:String):ArrayCollection {
			stmtListDashboardFilters.parameters[":entity"] = entity;
			exec(stmtListDashboardFilters);
			var listDashboard:ArrayCollection = new ArrayCollection(stmtListDashboardFilters.getResult().data);
			listDashboard.addItemAt({id: "", enitty: "", name: "", predefined: "", type: ""}, 0);
			return listDashboard;
		}
		
		public function getObjectFilter(entity:String, type:int):Object{		
			var dicOBject:Object = cache.get(LIST_CACHE_FILTER);
			var key:String = entity + "_" + type;
			if(dicOBject==null){
				dicOBject = new Object();
				cache.set(LIST_CACHE_FILTER,dicOBject);
				exec(stmtList);
				var result:SQLResult = stmtList.getResult();
				if(result.data != null && result.data.length>=0){
					for each(var filter:Object in result.data){
						var realKey:String = filter.entity+"_"+filter.type;
						dicOBject[realKey] = filter;
					}
				}
			}
			
			return dicOBject[key];
		}
		
		public function findFilter(id:String):Object{
			stmtFindFilter.parameters[":id"] = id;
			exec(stmtFindFilter);
			var result:SQLResult = stmtFindFilter.getResult();
			if(result.data==null || result.data.length==0){
				return null;
			}
			return result.data[0];
		}
		
		public function increaseType(entity:String):int{
			stmtIncreaseType.parameters[":entity"] = entity;
			exec(stmtIncreaseType);
			return stmtIncreaseType.getResult().data[0].type + 1;
		}
		
		public function getDefaultFilter(entity:String):Object{
			stmtSelectDefaultFilter.parameters[":entity"] = entity;
			exec(stmtSelectDefaultFilter);
			var result:Array = stmtSelectDefaultFilter.getResult().data;
			if(result!=null){
				return result[0];
			}
			return null;
		}
		
		
	}
}
