package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	import gadget.control.CalculatedField;
	import gadget.i18n.i18n;
	import gadget.service.PicklistService;
	import gadget.service.UserService;
	import gadget.util.FieldUtils;
	import gadget.util.Relation;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	import org.flexunit.runner.Result;
	
	public class BaseDAO extends BaseQuery implements DAO {
		private var stmtSum:SQLStatement;
		private var stmtUpdateByFieldRelation:SQLStatement;
		private var stmtUpdateByField:SQLStatement;
		private var stmtFindAll:SQLStatement;
		private var stmtFindByOID:SQLStatement;
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtUpdateByOID:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtDeleteOracle:SQLStatement;
		private var stmtFindById:SQLStatement;
		private var stmtFindContactAccount:SQLStatement;
		private var stmtFindContactC02:SQLStatement;
		
		private var stmtSelectLastRecord:SQLStatement;
		private var stmtFindCreated:SQLStatement;
		private var stmtFindUpdated:SQLStatement;
		private var stmtDeleteTemporary:SQLStatement;
		private var stmtUndeleteTemporary:SQLStatement;
		private var stmtFindDeleted:SQLStatement;
		private var stmtUpdateRef:SQLStatement;
		private var stmtSetError:SQLStatement;
		private var stmtSetErrorGid:SQLStatement;
		private var stmtFindDuplicateByColumn:SQLStatement;
		private var stmtUpdateRelationField:SQLStatement;
		private var sqlConnection:SQLConnection;
		private var stmtFindMSId:SQLStatement;
		private var stmtIncreaseImportant:SQLStatement;
		private var stmtUpdateFavorite:SQLStatement;
		private var stmtFindOutgoingMSId:SQLStatement;
		private var stmtRemoveRelationField:SQLStatement;
		private var stmtDeletedByParentId:SQLStatement;
		private var stmtGetByParentId:SQLStatement;
		protected var stmtFindRelatedSub:SQLStatement;
		protected var stmtFindByListOID:SQLStatement;
		
		public static function getUppernameCol(num:int):String {
			if (num == 0) {
				return "uppername";
			} else {
				return "uppername" + num;
			}
		}
		
		
		protected function getIndexColumns():Array{
			var indexes:Array = ["deleted", "local_update" ];
			if(this is ProductDAO){
				indexes.push("ModifiedByDate");
			}else{
				indexes.push("ModifiedDate");
				if(!(this is AllUsersDAO)){
					indexes.push("OwnerId");
				}
			}
			
			return indexes;
		}
		
		protected function addRelationIndex(colIndexs:Array):void{			
			var referenced:ArrayCollection = Relation.getReferenced(entity);
			for each(var objRefed:Object in referenced){
				colIndexs.push(objRefed.keySrc);
			}
		}

		public function BaseDAO(work:Function, sqlConnection:SQLConnection, structure:Object) {
			var indexes:Array = getIndexColumns();
			addRelationIndex(indexes);
			this.sqlConnection=sqlConnection;
			var columns:Object = {
				gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT",
				local_update: "string",
				deleted: "boolean",
				error: "boolean",
				ood_lastmodified:"string",
				sync_number: "integer",
				important: "integer",
				favorite: "boolean"
			};
			if (structure.search_columns) {
				for (var i:int = 0; i < structure.search_columns.length; i++) {
					indexes = indexes.concat(getUppernameCol(i));
					columns[getUppernameCol(i)] = { type:"TEXT", init:"upper(" + structure.search_columns[i] + ")"};
				}
			}
			super(work, sqlConnection, structure, {
				table: (structure && structure.table) ? structure.table : entity,	//VAHI XXX TODO actually this is a hack, let it vanish if everything has been refactored
				index: indexes,
				columns: columns
			});

			if (sqlConnection==null)
				return;

			DAOUtils.register(entity, structure);
			
			stmtFindRelatedSub = new SQLStatement();
			stmtFindRelatedSub.sqlConnection = sqlConnection;
			
			//Sum number,int,currency fields
			stmtSum = new SQLStatement();
			stmtSum.sqlConnection = sqlConnection;
			
			// Find all the items, used in lists
			stmtFindAll = new SQLStatement();
			stmtFindAll.sqlConnection = sqlConnection;
			
			// Find by Oracle CRM Id
			stmtFindByOID = new SQLStatement();
			stmtFindByOID.sqlConnection = sqlConnection;
			stmtFindByOID.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE " + fieldOracleId + " = :" + fieldOracleId;
			
			// Inserts a new item
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			// Update an some fields based on Gadget's Id
			stmtUpdateByField = new SQLStatement();
			stmtUpdateByField.sqlConnection = sqlConnection;
			
			//
			stmtUpdateByFieldRelation = new SQLStatement();
			stmtUpdateByFieldRelation.sqlConnection = sqlConnection;
			
			
			// Update an item based on Gadget's Id
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
				
			// Update an item based on Oracle CRM Id
			stmtUpdateByOID = new SQLStatement();
			stmtUpdateByOID.sqlConnection = sqlConnection;
			
			// Deletes an item
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM " + tableName + " WHERE gadget_id = :gadget_id";
			
			stmtDeleteOracle = new SQLStatement();
			stmtDeleteOracle.sqlConnection = sqlConnection;
			stmtDeleteOracle.text = "DELETE FROM " + tableName + " WHERE " + fieldOracleId + " = :" + fieldOracleId;
			
			// Find an item by Gadget's Id
			stmtFindById = new SQLStatement();
			stmtFindById.sqlConnection = sqlConnection;
			stmtFindById.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE gadget_id = :gadget_id";
			
			// find account contact
			stmtFindContactAccount = new SQLStatement();
			stmtFindContactAccount.sqlConnection = sqlConnection;
			stmtFindContactAccount.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE contactId = :contactId AND accountId=:accountId";
			
			stmtFindContactC02 = new SQLStatement();
			stmtFindContactC02.sqlConnection = sqlConnection;
			stmtFindContactC02.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE contactId = :contactId AND id=:id";
			
			
			// Find an item by MS Exchange Id
			stmtFindMSId = new SQLStatement();
			stmtFindMSId.sqlConnection = sqlConnection;
			stmtFindMSId.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE ms_id = :ms_id";
			
			stmtFindOutgoingMSId = new SQLStatement();
			stmtFindOutgoingMSId.sqlConnection = sqlConnection;
			stmtFindOutgoingMSId.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE (Type is null OR Type !='Email') AND (ms_id is not null AND ms_id !='') AND (ms_local_change is not null AND ms_local_change != '') AND Activity = :activity";
			
			var msId:String = "";
			if(entity == "Activity" || entity == "Contact"){
				msId =  "AND (ms_id is null OR ms_id ='')";
			}
			// Find all items updated locally
			stmtFindUpdated = new SQLStatement();
			stmtFindUpdated.sqlConnection = sqlConnection;
			stmtFindUpdated.text = "SELECT '" + entity + "' gadget_type, *, " + DAOUtils.getNameColumn(entity) + " name FROM " + tableName + " WHERE local_update is not null AND (deleted = 0 OR deleted IS null)" + msId + " ORDER BY local_update LIMIT :limit OFFSET :offset";	

			// Find all items created locally
			stmtFindCreated = new SQLStatement();
			stmtFindCreated.sqlConnection = sqlConnection;
			//VAHI the "OR ... IS NULL" is a workaround to make Expenses work
			stmtFindCreated.text = "SELECT '" + entity + "' gadget_type, *, " + DAOUtils.getNameColumn(entity) + " name FROM " + tableName + " WHERE ( (" + fieldOracleId + " >= '#' AND " + fieldOracleId + " <= '#zzzz') OR " + fieldOracleId + " IS NULL ) AND (deleted = 0 OR deleted IS null) " + msId + " ORDER BY  " + fieldOracleId + " LIMIT :limit OFFSET :offset";	
			
			// Get or Select Last Record
			stmtSelectLastRecord = new SQLStatement();
			stmtSelectLastRecord.sqlConnection = sqlConnection;
			stmtSelectLastRecord.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE " + fieldOracleId + " is null ORDER BY gadget_id desc limit 1";
			
			// Delete temporary just updates the field deleted to true
			stmtDeleteTemporary = new SQLStatement();
			stmtDeleteTemporary.sqlConnection = sqlConnection;
			stmtDeleteTemporary.text = "UPDATE " + tableName + " SET deleted = true WHERE gadget_id = :gadget_id"; 

			stmtUndeleteTemporary = new SQLStatement();
			stmtUndeleteTemporary.sqlConnection = sqlConnection;
			stmtUndeleteTemporary.text = "UPDATE " + tableName + " SET deleted = false WHERE gadget_id = :gadget_id"; 

			stmtFindDeleted = new SQLStatement();
			stmtFindDeleted.sqlConnection = sqlConnection;
			stmtFindDeleted.text = "SELECT * FROM " + tableName + " WHERE deleted = true ORDER BY uppername LIMIT :limit OFFSET :offset";
			
			stmtUpdateRef = new SQLStatement();
			stmtUpdateRef.sqlConnection = sqlConnection;
			
			stmtFindDuplicateByColumn = new SQLStatement();
			stmtFindDuplicateByColumn.sqlConnection = sqlConnection;
			
			stmtSetError = new SQLStatement();
			stmtSetError.sqlConnection = sqlConnection;
			stmtSetError.text = "UPDATE " + tableName + " SET error = :error WHERE " + fieldOracleId + " = :" + fieldOracleId;
			
			stmtSetErrorGid = new SQLStatement();
			stmtSetErrorGid.sqlConnection = sqlConnection;
			stmtSetErrorGid.text = "UPDATE " + tableName + " SET error = :error WHERE gadget_id = :gadget_id";
			
			stmtIncreaseImportant = new SQLStatement();
			stmtIncreaseImportant.sqlConnection = sqlConnection;
			stmtIncreaseImportant.text = "UPDATE " + tableName + " SET important = :important WHERE gadget_id = :gadget_id";
			
			stmtUpdateFavorite = new SQLStatement();
			stmtUpdateFavorite.sqlConnection = sqlConnection;
			stmtUpdateFavorite.text = "UPDATE " + tableName + " SET favorite = :favorite WHERE gadget_id = :gadget_id";
			
			stmtFindByListOID = new SQLStatement();
			stmtFindByListOID.sqlConnection = sqlConnection;
		}
		public function sumFields(sqlObject:Object):Object{
			stmtSum.clearParameters();
			stmtSum.parameters[":" +sqlObject.entityId] = sqlObject[sqlObject.entityId];
			stmtSum.text = sqlObject.sql;
			exec(stmtSum);
				
			var items:ArrayCollection = new ArrayCollection(stmtSum.getResult().data);
			if(items.length >0 ){
				return items[0];
			}
			
			return null;
			
		}
		public function increaseImportant(data:Object):void {
			stmtIncreaseImportant.parameters[":important"] = data.important==null?1:data.important+1;
			stmtIncreaseImportant.parameters[":gadget_id"] = data.gadget_id;
			exec(stmtIncreaseImportant);
		}
		
		public function updateFavorite(data:Object):void {
			stmtUpdateFavorite.parameters[":favorite"] = data.favorite;
			stmtUpdateFavorite.parameters[":gadget_id"] = data.gadget_id;
			exec(stmtUpdateFavorite);
		}
		
		public function getIgnoreCopyFields():ArrayCollection{
			return new ArrayCollection();
		}
		
		public function updateRelationFields(objsVals:Object, criteria:Object):void{
			
			var where:String="";			
			var cols:String="", c:String="";			
			var col:String="";			
			var query:String = "UPDATE "+tableName + " SET ";
			stmtUpdateRelationField=new SQLStatement();
			stmtUpdateRelationField.sqlConnection=sqlConnection;
			for ( col in criteria) {
				where += " AND " +col+ "= :" + col;
				stmtUpdateRelationField.parameters[':'+col]=criteria[col];
			}
			
			for (col in objsVals) {				
				cols	+= c + " "  + col+"=:"+col;				
				c		=  ",";
				stmtUpdateRelationField.parameters[':'+col]=objsVals[col];
				
			}
			 			
			 where=where!="" ? " WHERE "+where.substr(5) : "";
			 query = query + cols + where;
			 stmtUpdateRelationField.text=query;
			exec(stmtUpdateRelationField);
			
			
		}
		
		public function removeRelationFields(fields:Array, criteria:Object):void{
			var where:String="";			
			var cols:String="", c:String="";			
			var col:String="";			
			var query:String = "UPDATE "+tableName + " SET ";
			stmtRemoveRelationField = new SQLStatement();
			stmtRemoveRelationField.sqlConnection=sqlConnection;
			
			for(col in criteria){
				where+=" AND " + col +"= :"+col;
				stmtRemoveRelationField.parameters[':'+col] = criteria[col];
			}
			
			for each(col in fields){
				cols	+= c + " "  + col+"=:"+col;				
				c		=  ",";
				stmtRemoveRelationField.parameters[':'+col]='';				
			}
			
			where=where!="" ? " WHERE "+where.substr(5) : "";
			query = query + cols + where;
			stmtRemoveRelationField.text=query;
			exec(stmtRemoveRelationField);
			
		}
		
		
		public function deleteOnlyRecordeNotErrorByParent(criteria:Object):void{
			var where:String="";			
			
			var col:String="";			
			var query:String = "DELETE FROM "+tableName ;
			stmtDeletedByParentId = new SQLStatement();
			stmtDeletedByParentId.sqlConnection = sqlConnection;
			
			for(col in criteria){
				where+=" AND " + col +"= :"+col;
				stmtDeletedByParentId.parameters[':'+col] = criteria[col];
			}
			where+=" AND (error = 0 OR error IS null) "
			
			where=where!="" ? " WHERE "+where.substr(5) : "";
			
			query = query + where;
			stmtDeletedByParentId.text=query;
			exec(stmtDeletedByParentId);
		}
		
		
		public function deleteByParentId(criteria:Object):void{
			var where:String="";			
					
			var col:String="";			
			var query:String = "DELETE FROM "+tableName ;
			stmtDeletedByParentId = new SQLStatement();
			stmtDeletedByParentId.sqlConnection = sqlConnection;
			
			for(col in criteria){
				where+=" AND " + col +"= :"+col;
				stmtDeletedByParentId.parameters[':'+col] = criteria[col];
			}
			
			
			where=where!="" ? " WHERE "+where.substr(5) : "";
			query = query + where;
			stmtDeletedByParentId.text=query;
			exec(stmtDeletedByParentId);
		}
		
		public function getByParentId(criteria:Object):Array{
			var where:String=" WHERE (deleted = 0 OR deleted IS null)";			
			
			var col:String="";			
			var query:String = "SELECT  '" + entity + "' gadget_type, * FROM " + tableName ;
			stmtGetByParentId = new SQLStatement();
			stmtGetByParentId.sqlConnection = sqlConnection;
			
			for(col in criteria){
				where+=" AND " + col +"= :"+col;
				stmtGetByParentId.parameters[':'+col] = criteria[col];
			}
			
			
			//where=where!="" ? " WHERE "+where.substr(5) : "";
			query = query + where;
			stmtGetByParentId.text=query;
			exec(stmtGetByParentId);
			var result:SQLResult = stmtGetByParentId.getResult();
			if(result!=null)
				return result.data;
			return null;			
		}
		
		
		public function get outgoingIgnoreFields():Dictionary{
			var dic:Dictionary = new Dictionary();
			for each(var field:String in getOutgoingIgnoreFields()){
				dic[field] = field;
			}
			
			var relations:ArrayCollection = Relation.getReferenced(entity);
			for each(var obj:Object in relations){
				if(obj.supportTable==null && !obj.isExceptLabelSrc){
					for each(var labelField:String in obj.labelSrc){
						dic[labelField] = labelField;
					}
				}
			}
			//read readonly fields from field management Bug #7267 CRO
			//bug#8905-----have some pb---ood not execute formula when created
//			var readOnlyFieldsLayout:Object = Database.layoutDao.getReadOnlyField(entity);
//			for (var column_name:String in readOnlyFieldsLayout){
//				dic[column_name] = column_name;
//			}
			
			var readOnlyFields:Object = Database.fieldManagementServiceDao.getReadOnlyField(entity);
			for (var name:String in readOnlyFields){
				dic[name] = name;
			}
			//always ignore field =ModId
			dic["ModId"]="ModId";
			
			return dic;
			
		}
		
		public function get incomingIgnoreFields():Dictionary{
			var dic:Dictionary = new Dictionary();
			for each(var field:String in getIncomingIgnoreFields()){
				dic[field] = field;
			}
			return dic;
		}
		
		
		public function getLinkFields():Dictionary{
			return new Dictionary();
		}
		
		protected function getOutgoingIgnoreFields():ArrayCollection{
			//need to implement in subclass
			return new ArrayCollection();
		}
		protected function getIncomingIgnoreFields():ArrayCollection{
			//need to implement in subclass
			return new ArrayCollection();
		}
		// return list of oracle id	
		public function findAllIds():ArrayCollection{
			var oracleId:String = fieldOracleId;
			var result:ArrayCollection = new ArrayCollection();
			stmtFindAll.text = "SELECT "+oracleId + " FROM "+tableName;
			exec(stmtFindAll);
			var items:ArrayCollection = new ArrayCollection(stmtFindAll.getResult().data);
			if(items.length>0){
				for each(var o:Object in items){
					var id:String = o[oracleId];
					if(id!=null && id.indexOf("#")==-1){
						result.addItem(id);	
					}
					
				}
				
			}
			return result;
		}
		
		public function findAllIdsAsDictionary():Dictionary{
			var oracleId:String = fieldOracleId;
			var result:Dictionary = new Dictionary();
			stmtFindAll.text = "SELECT "+oracleId + " FROM "+tableName;
			exec(stmtFindAll);
			var items:ArrayCollection = new ArrayCollection(stmtFindAll.getResult().data);
			if(items.length>0){
				for each(var o:Object in items){
					var id:String = o[oracleId];
					if(id!=null && id.indexOf("#")==-1){
						result[id]=id;
					}
					
				}
				
			}
			return result;
		}
		
		public function count():int{
			stmtFindAll.text = "SELECT count(*) FROM " + tableName;
			exec(stmtFindAll, false);
			
			var result:Array = stmtFindAll.getResult().data;
			if(result!=null && result.length>0){
				var obj:Object = result[0];
				return obj['count(*)'] as int;
			}
			return 0;
		}
		
		
		public function findAll(columns:ArrayCollection, filter:String = null, selectedId:String = null, limit:int = 1001,order_by:String=null,addColOODLastModified:Boolean=true, group_by:String=null):ArrayCollection {
			var cols:String = '';
			var colOODLastModified:String="";
			for each (var column:Object in columns) {
				cols += ", " + column.element_name;
			}
			
			if(addColOODLastModified){
				colOODLastModified="ood_lastmodified,";
			}
			if(!StringUtils.isEmpty(order_by)){
				order_by =" ORDER BY " +order_by;
			}else{
				order_by='';
			}			
			var hideByType:String = "";
			if(entity == "Activity"){
				var arrJoin:ArrayCollection = Database.preferencesDao.getValueSelectedActivityType();
				if(arrJoin != null && arrJoin.length>0){
					hideByType = " AND Type not in ('" + arrJoin.source.join("','") + "') " ;
				}
				
			}
//			stmtFindAll.text = "SELECT '" + entity + "' gadget_type, local_update, gadget_id, error,sync_number, "+colOODLastModified + fieldOracleId + cols + " FROM " + tableName + " WHERE " + (StringUtils.isEmpty(filter) ? "" : filter + " AND ") + "deleted != 1 ORDER BY " + order_by + ( limit==0? "":" LIMIT " + limit );
			stmtFindAll.text = "SELECT '" + entity + "' gadget_type, local_update, gadget_id, error,sync_number, "+colOODLastModified + fieldOracleId + cols + " FROM " + tableName + " WHERE " + (StringUtils.isEmpty(filter) ? "" : filter + " AND ") + "deleted != 1 " + hideByType + (StringUtils.isEmpty(group_by) ? "" : "GROUP BY " + group_by) +  order_by + ( limit==0? "":" LIMIT " + limit );
			exec(stmtFindAll, false);
			var items:ArrayCollection = new ArrayCollection(stmtFindAll.getResult().data);
			// add a specific item when selectedId arg is provided
			// this is usefull when the user follows links to add the target item
			if (selectedId != null) {
				var found:Boolean = false;
				for each (var item:Object in items) {
					if (item.gadget_id == selectedId) {
						found = true;
						break;
					}
				}
				if (!found) {
					stmtFindAll.text = "SELECT '" + entity + "' gadget_type, local_update, gadget_id, error, "+colOODLastModified + fieldOracleId + cols + " FROM " + tableName + " WHERE " + (StringUtils.isEmpty(filter) ? "" : filter + " AND ") + "(deleted = 0 OR deleted is null) AND gadget_id =" + selectedId + hideByType ;
					exec(stmtFindAll);
					items.addAll(new ArrayCollection(stmtFindAll.getResult().data));
				}
			}
			computeCategory(items);
			Utils.suppressWarning(items);
			return items;
			
		}

		
		private function computeCategory(items:ArrayCollection):void {
			var synNum:Number = Database.syncNumberDao.getSyncNumber();
			var userIsJD:Boolean = UserService.DIVERSEY==UserService.getCustomerId();
			for each (var item:Object in items) {
				if (item.error) {
					item.modified = i18n._("ERR");
				} else if (!(item[fieldOracleId]) || StringUtils.startsWith(item[fieldOracleId], "#")) {
					item.modified = i18n._("NEW");
				} else if(item.local_update) {
					item.modified = i18n._("UPD");
				} else if((item[fieldOracleId]) && item.sync_number==synNum && item.gadget_type =='Service Request' && userIsJD) {
					item.modified = i18n._("NEW");
					item.fromsync = "sync";
				} else {
					item.modified = "";
				}	
				
						
			}
		}
		// for visit customer
		public function findByListOracleId(listId:ArrayCollection):ArrayCollection {
			var strId :String="";
			var isComa:Boolean = false;
			for each(var id:String in listId){
				if(isComa){
					strId = strId + "," + "'" + id + "'";
				}else{
					strId = "'" + id + "'";
				}
				isComa = true;
			}
			if(StringUtils.isEmpty(strId)){
				return new ArrayCollection();
			}else{
				strId = "(" + strId + ")";
				stmtFindByListOID.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE " + fieldOracleId + " in " + strId;
				exec(stmtFindByListOID);
				return new ArrayCollection((stmtFindByListOID.getResult() as SQLResult).data);
			}
			
		}
		public function findByOracleId(oracleId:String):Object {
			stmtFindByOID.parameters[":" + fieldOracleId] = oracleId; 
			exec(stmtFindByOID);
			var result:SQLResult = stmtFindByOID.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		

		
		public function findByGadgetId(gadgetId:String):Object {
			stmtFindById.parameters[":gadget_id"] = gadgetId;
			exec(stmtFindById);
			var result:SQLResult = stmtFindById.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		public function findContactAccount(accountId:String,contactId:String):Object {
			stmtFindContactAccount.parameters[":accountId"] = accountId;
			stmtFindContactAccount.parameters[":contactId"] = contactId;
			exec(stmtFindContactAccount);
			var result:SQLResult = stmtFindContactAccount.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		public function findContactC02(id:String,contactId:String):Object {
			stmtFindContactC02.parameters[":id"] = id;
			stmtFindContactC02.parameters[":contactId"] = contactId;
			exec(stmtFindContactC02);
			var result:SQLResult = stmtFindContactC02.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		public function findByMSId(msId:String):Object {
			stmtFindMSId.parameters[":ms_id"] = msId;
			exec(stmtFindMSId);
			var result:SQLResult = stmtFindMSId.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		public function getMSOutgoingObject(activity:String):ArrayCollection {
//			stmtFindMSId.parameters[":ms_id"] = msId;
			stmtFindOutgoingMSId.parameters[":activity"] = activity;
			exec(stmtFindOutgoingMSId);
			var result:SQLResult = stmtFindOutgoingMSId.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return  new ArrayCollection(result.data);
		}
		
		public function findDeleted(offset:int, limit:int):ArrayCollection {
			stmtFindDeleted.parameters[":offset"] = offset; 
			stmtFindDeleted.parameters[":limit"] = limit; 
			exec(stmtFindDeleted, false);
			return new ArrayCollection(stmtFindDeleted.getResult().data);
		}

		public function findCreated(offset:int, limit:int):ArrayCollection {
			stmtFindCreated.parameters[":offset"] = offset; 
			stmtFindCreated.parameters[":limit"] = limit; 
			exec(stmtFindCreated, false);
			var list:ArrayCollection = new ArrayCollection(stmtFindCreated.getResult().data);
			//checkBindPicklist(stmtFindCreated.text,list);
			return list;
		}
		
		public function findUpdated(offset:int, limit:int):ArrayCollection {
			stmtFindUpdated.parameters[":offset"] = offset; 
			stmtFindUpdated.parameters[":limit"] = limit; 
			exec(stmtFindUpdated, false);
			var list:ArrayCollection = new ArrayCollection(stmtFindUpdated.getResult().data);
			//checkBindPicklist(stmtFindUpdated.text,list);
			return list;
		}
		
		public function checkBindPicklist(stmtFind:String,list:ArrayCollection):ArrayCollection {
			if(!StringUtils.isEmpty(entity)){
				var columns:ArrayCollection = Utils.getColumns(entity);
				var picklistFields:ArrayCollection = CalculatedField.getEntityPicklistFields(columns);
				for each(var obj:Object in list){
					for each(var objCol:Object in picklistFields){
						var str:String = obj[objCol.column];
						if(str!=null && str.indexOf("=")>-1){
							//TODO should be return picklist keyvalue
							// obj[objCol.column]=PicklistService.getId(entity,objCol.column,str.split("=")[1]);
							obj[objCol.column] = str.split("=")[1];
						} 
					}
				}
			}
			
			return list;
		}
		
		public function insert(object:Object, useCustomfield:Boolean=true):void {
			object.deleted = false;
			var fields:ArrayCollection = fieldList(useCustomfield);
			stmtInsert.clearParameters();
			stmtInsert.text = insertQuery(fields);
			execStatement(stmtInsert, object,fields,useCustomfield);
		}
		public function updateByFieldRelation(fields:Array,object:Object,relationId:String):void{
			stmtUpdateByFieldRelation.clearParameters();
			var sql:String  =  'UPDATE ' + tableName + " SET local_update = :local_update, deleted = :deleted, error = :error, sync_number = :sync_number,ood_lastmodified =:ood_lastmodified";
			
			for (var i:int=0 ;i<fields.length;i++) {
				stmtUpdateByFieldRelation.parameters[":" + fields[i] ] = object[fields[i]];
				sql = sql + "," + fields[i] +"= :"+ fields[i];
			}
			stmtUpdateByFieldRelation.text = sql + " WHERE "+ relationId + "= :" + relationId;
			stmtUpdateByFieldRelation.parameters[":"+relationId] = object[relationId];
			stmtUpdateByFieldRelation.parameters[':local_update'] = object.local_update;
			stmtUpdateByFieldRelation.parameters[':deleted'] = object.deleted;
			stmtUpdateByFieldRelation.parameters[':error'] = object.error;
			stmtUpdateByFieldRelation.parameters[':sync_number'] = object.sync_number;
			stmtUpdateByFieldRelation.parameters[':ood_lastmodified']=object.ood_lastmodified;
			exec(stmtUpdateByFieldRelation);
		}
		
		public function updateByField(fields:Array,object:Object,fieldCriteria:String = 'gadget_id'):void{
			stmtUpdateByField.clearParameters();
			var sql:String  =  'UPDATE ' + tableName + " SET local_update = :local_update, deleted = :deleted, error = :error, sync_number = :sync_number,ood_lastmodified =:ood_lastmodified";
			
			for (var i:int=0 ;i<fields.length;i++) {
				stmtUpdateByField.parameters[":" + fields[i] ] = object[fields[i]];
				sql = sql + "," + fields[i] +"= :"+ fields[i];
			}
			stmtUpdateByField.text = sql + " WHERE "+ fieldCriteria +"=:"+fieldCriteria ;
			stmtUpdateByField.parameters[":"+fieldCriteria] = object[fieldCriteria];
			stmtUpdateByField.parameters[':local_update'] = object.local_update;
			stmtUpdateByField.parameters[':deleted'] = object.deleted;
			stmtUpdateByField.parameters[':error'] = object.error;
			stmtUpdateByField.parameters[':sync_number'] = object.sync_number;
			stmtUpdateByField.parameters[':ood_lastmodified']=object.ood_lastmodified;
			exec(stmtUpdateByField);
		}
		
		public function update(object:Object):void {
			var fields:ArrayCollection = fieldList();
			stmtUpdate.clearParameters();
			stmtUpdate.text = updateQuery(fields) + " WHERE gadget_id = :gadget_id";
			stmtUpdate.parameters[":gadget_id"] = object.gadget_id;
			execStatement(stmtUpdate, object,fields);
		}

		public function updateByOracleId(object:Object,updateCustomField:Boolean=false):void {
			var fields:ArrayCollection = fieldList(updateCustomField);
			stmtUpdateByOID.clearParameters();
			stmtUpdateByOID.text = updateQuery(fields)
				+ " WHERE " + fieldOracleId + " = :" + fieldOracleId;
			execStatement(stmtUpdateByOID, object,fields,updateCustomField);
		}

		public function delete_(object:Object):void	{
			stmtDelete.parameters[":gadget_id"] = object.gadget_id;
			exec(stmtDelete);
		}
		
		public function deleteAll():void{
			exec_cmd("DELETE FROM "+tableName);
		}
		

		public function deleteTemporary(object:Object):void	{
			stmtDeleteTemporary.parameters[":gadget_id"] = object.gadget_id;
			exec(stmtDeleteTemporary);
		}

		public function undeleteTemporary(object:Object):void	{
			stmtUndeleteTemporary.parameters[":gadget_id"] = object.gadget_id;
			exec(stmtUndeleteTemporary);
		}
		
		public function deleteByOracleId(oracleId:String):void	{
			stmtDeleteOracle.parameters[":" + fieldOracleId] = oracleId;
			exec(stmtDeleteOracle);
		}
		
		private function fieldList(updateFF:Boolean=true):ArrayCollection {
			var allFields:ArrayCollection = new ArrayCollection();
			//allFields.addAll(FieldUtils.allFields(entity));
			for each(var f:Object in FieldUtils.allFields(entity)){
				if(!StringUtils.isEmpty(f.element_name)){//hope it can solved the pb parameters not match!
					allFields.addItem(f);
				}
			}
			
		
			// check if the Oracle ID is in the list
			var found:Boolean = false;
			for each (var field:Object in allFields) {
				if (field.element_name == fieldOracleId) {
					found = true;
					break;
				}
			}
			// add custom fields
			if(updateFF){
				// var customfields:ArrayCollection = Database.layoutDao.selectCustomFields(entity);
				var customfields:ArrayCollection = Database.customFieldDao.selectCustomFields(entity);
				allFields.addAll(customfields);
			}
			
			if (!found) {
				allFields.addItem({element_name:fieldOracleId});
			}
			if(entity == Database.activityDao.entity){
				found = false;
				for each (var field1:Object in allFields) {
					if (field1.element_name == ActivityDAO.PARENTSURVEYID) {
						found = true;
						break;
					}
				}
				if(!found){
					allFields.addItem({element_name:ActivityDAO.PARENTSURVEYID});
				}
				if(updateFF){
					allFields.addItem({element_name:ActivityDAO.ASS_PAGE_NAME});
				}
			}else if(entity==Database.allUsersDao.entity){
				found = false;
				for each (var field2:Object in allFields) {
					if (field2.element_name == "FullName") {
						found = true;
						break;
					}
				}
				if(!found){
					allFields.addItem({element_name:"FullName"});
				}
			}
			
			return allFields;
		}
		
		
		
		public function selectLastRecord():ArrayCollection{
			exec(stmtSelectLastRecord);
			 var res:Array = stmtSelectLastRecord.getResult().data;
			 return new ArrayCollection(res);
		}
	
		private function  insertQuery(listField:ArrayCollection):String {
			var sql:String = 'INSERT INTO ' + tableName + "(local_update, deleted, error, sync_number,ood_lastmodified";
			if(this is ActivityDAO){
				sql+=", Owner";
			}
			var i:int;
			var field:Object;
			if (daoStructure.search_columns) {
				for (i = 0; i < daoStructure.search_columns.length; i++) {
					sql += ", " + getUppernameCol(i);
				}
			}
			//var listField:ArrayCollection = fieldList(updateFF);
			for each (field in listField) {
				sql += ", " + field.element_name;
			}
			sql += ") VALUES (:local_update, :deleted, :error, :sync_number,:ood_lastmodified";
			if(this is ActivityDAO){
				sql+=", :Owner";
			}
			if (daoStructure.search_columns) {
				for (i = 0; i < daoStructure.search_columns.length; i++) {
					sql += ", :" + getUppernameCol(i);
				}
			}
			for each (field in listField) {
				sql += ", :" + field.element_name;
			}
			sql += ")";
			return sql;
		}
		
		private function updateQuery(fields:ArrayCollection):String {
			var sql:String = 'UPDATE ' + tableName + " SET local_update = :local_update, deleted = :deleted, error = :error, sync_number = :sync_number,ood_lastmodified =:ood_lastmodified";
			if (daoStructure.search_columns) {
				for (var i:int = 0; i < daoStructure.search_columns.length; i++) {
					sql += ", " + getUppernameCol(i) + " = :" + getUppernameCol(i);
				}
			}
			var field:Object;
			for each (field in fields) {
				sql += ", " + field.element_name + " = :" + field.element_name;
			}
			return sql;
		}
		
		private function get fieldOracleId():String {
			return DAOUtils.getOracleId(entity);
		}
		
		
		protected function get tableName():String {
			return DAOUtils.getTable(entity);
		}
		
		
		private function execStatement(stmt:SQLStatement, object:Object,fields:ArrayCollection,updateFF:Boolean = true):void {
			
			//var fields:ArrayCollection = fieldList(updateFF);			
			for each (var field:Object in fields) {				
				if (object[field.element_name] != null){
					stmt.parameters[":" + field.element_name] = object[field.element_name];
				}else{
					if(!updateFF){
						var fieldName:String = field.element_name;
						var oracleId:String = DAOUtils.getOracleId(entity);						
						if(getIncomingIgnoreFields().contains(fieldName)){							
							var obj:Object = findByOracleId(object[oracleId]);
							if(obj!=null){
								stmt.parameters[":" + field.element_name]=obj[fieldName];
								continue;
							}
							
						}
					}					
						
//					}
					
					stmt.parameters[":" + field.element_name] = null;
				}					
					
			}
			if (daoStructure.search_columns) {
				for (var i:int = 0; i < daoStructure.search_columns.length; i++) {
					stmt.parameters[':' + getUppernameCol(i)] = StringUtils.toUpperCase(stmt.parameters[":" + daoStructure.search_columns[i]]);
				}
			}
			stmt.parameters[':local_update'] = object.local_update;
			stmt.parameters[':deleted'] = object.deleted;
			stmt.parameters[':error'] = object.error;
			stmt.parameters[':sync_number'] = object.sync_number;
			stmt.parameters[':ood_lastmodified']=object.ood_lastmodified;
			exec(stmt);
		}

		
		public function findDuplicateByColumn(columnName:String, columnValue:String, gadget_id:String):Object{
			stmtFindDuplicateByColumn.text = 'SELECT * FROM ' + tableName + ' WHERE ' + columnName + ' = :columnValue AND gadget_id != :gadget_id';
			stmtFindDuplicateByColumn.parameters[":columnValue"] = columnValue;
			stmtFindDuplicateByColumn.parameters[":gadget_id"] = gadget_id;
			exec(stmtFindDuplicateByColumn);
			var r:SQLResult = stmtFindDuplicateByColumn.getResult();
			if(r.data==null || r.data.length==0){
				return null;
			}
			return r.data[0];
		}		
		
		public function updateReference(columnName:String, previousValue:String, nextValue:String):void {
			stmtUpdateRef.text = "UPDATE " + tableName + " SET " + columnName + " = '" + nextValue + "' WHERE " + columnName + " = '" + previousValue + "'";
			exec(stmtUpdateRef);
		}
		
		public function updateByGadgetId(columnName:String, gadgetId:String, value:String):void {
			stmtUpdateRef.text = "UPDATE " + tableName + " SET " + columnName + " = '" + value + "' WHERE gadget_id = " + gadgetId;
			exec(stmtUpdateRef);
		}
		
		public function setError(oracleId:String, error:Boolean):void {
			stmtSetError.parameters[":" + fieldOracleId ] = oracleId;
			stmtSetError.parameters[":error"] = error;
			exec(stmtSetError);
		}

		//VAHI added for more marking errors on outgoing where RowID not yet known
		public function setErrorGid(gadget_id:String, error:Boolean):void {
			stmtSetErrorGid.parameters[":gadget_id"] = gadget_id;
			stmtSetErrorGid.parameters[":error"] = error;
			exec(stmtSetErrorGid);
		}
		
		//VAHI added for scoop functions
		public function listAll():Array {
			var Id:String = fieldOracleId;

			stmtFindAll.text = "SELECT " + Id + " FROM " + tableName;
			exec(stmtFindAll);

			function reduceToOne(ob:Object, i:int, a:Array):String {
				return ob[Id];
			}
			
			var data:Array = stmtFindAll.getResult().data;
			if (data==null)	return [];
			return data.map(reduceToOne);
		}
		
		public function queryAll():ArrayCollection {
			stmtFindAll.text = "SELECT * FROM " + tableName;
			exec(stmtFindAll);
			return new ArrayCollection(stmtFindAll.getResult().data);
		}
		public function findDataByRelation(relation:Object, oracleId:String):ArrayCollection{
			
			if (relation == null) {
				return new ArrayCollection();
			}
			
			
			// hide activity type #5683 VM
			var hideByType:String = "";
			if(entity == "Activity"){
				var arrJoin:ArrayCollection = Database.preferencesDao.getValueSelectedActivityType();
				if(arrJoin != null && arrJoin.length>0){
					hideByType = " AND Type not in ('" + arrJoin.source.join("','") + "') " ;
				}
				
			}
			var arr:ArrayCollection;
			stmtFindRelatedSub.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE ( deleted = 0 OR deleted IS null ) AND " + relation.keySrc + " = '" + oracleId + "'" + hideByType;
			exec(stmtFindRelatedSub);
			var result:SQLResult = stmtFindRelatedSub.getResult();
			if (result.data == null || result.data.length == 0) {
				return new ArrayCollection();
			}
			return new ArrayCollection(result.data);
		}
		public function findDataBySubField(subField:String , oracleId:String):ArrayCollection {
			if(StringUtils.isEmpty(oracleId) || oracleId=="No Match Row Id"){
				return new ArrayCollection();
			}
			return findDataByRelation({keySrc:subField},oracleId);
		}
		
		public function findRelatedData(parentEntity:String , oracleId:String):ArrayCollection {
			//var entity:String = DAOUtils.getEntity(tableName);
			var relation:Object = Relation.getRelation(entity,parentEntity );
			if (relation == null) {
				return new ArrayCollection();
			}
			return findDataByRelation(relation,oracleId);
		}

		
		/** This is a fix hook to fix issues with a dao at Sync time.
		 *
		 * INCOMING sync calls this callback to detect a siebel RowId to update the record
		 * 
		 * @params rec:Object the record
		 * @params parent:Object parental record (if any)
		 * @returns Boolean true if checks for NULL shall be skipped, false for the normal case
		 */
		public function fix_sync_incoming(rec:Object,parent:Object=null):Boolean { return false; }
		
		/** This is a fix hook to fix issues with a dao at Sync time.
		 *
		 * INCOMING sync calls this after add when the RowID was null.
		 * 
		 * @params rec:Object the record
		 * @params parent:Object parental record (if any)
		 */
		public function fix_sync_add(rec:Object,parent:Object=null):void {}
		
		
		
		
		/** This is a fix hook to fix issues with a dao at Sync time.
		 *
		 * OUTGOING after data was uploaded with the return values right before it is updated
		 * 
		 * @params ob:Object the record, shall be modified accordingly
		 * @returns Boolean true if record must be written, false else
		 */
		public function fix_sync_outgoing(rec:Object):Boolean { return false; }
		
		public function getOwnerFields():Array{
			var mapfields:Array = [
				{entityField:"Owner", userField:"Alias"},{entityField:"OwnerId", userField:"Id"}
			];
			return mapfields;
			
		}
	}
}
