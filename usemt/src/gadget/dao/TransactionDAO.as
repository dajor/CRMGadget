package gadget.dao
{
	
	
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.i18n.i18n;
	import gadget.util.CacheUtils;
	import gadget.util.ObjectUtils;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	
	public class TransactionDAO extends BaseSQL {
		
		public static var ALL_TYPE:Number =0;
		public static var ONE_YEAR_TYPE:Number =1;
		public static var SIX_MONTH_TYPE:Number =2;
		public static var THREE_MONTH_TYPE:Number =3;
		public static var ONE_MONTH_TYPE:Number =4;
		public static var SEVEN_DAY_TYPE:Number =5;
		public static var DEFAULT_BOOK_TYPE:Number = -15;
		
		
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtAllTransaction:SQLStatement;
		private var stmtAllEnabledTransaction:SQLStatement;
		private var stmtAllDisabledTransaction:SQLStatement;
		private var stmtFind:SQLStatement;
		private var stmtSetDefaultFilter:SQLStatement;
		private var stmtUpdateAllField:SQLStatement;
		private var stmtUpdateSyncOrder:SQLStatement;
		private var stmtUpdSortCol:SQLStatement;
		
		public function TransactionDAO(sqlConnection:SQLConnection) {
			//super(sqlConnection);
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			// #311: hange request - Diversey sales - Prefernces
			stmtInsert.text = "INSERT INTO transactions (entity, enabled, display_name,display, filter_id, default_filter, sync_ws20, sync_activities, sync_attachments, rank, read_only, "+
				" filter_disable, read_only_disable, sync_activities_disable, sync_attachments_disable, entity_disable, sync_order, authorize_deletion, authorize_deletion_disable" +
				", advanced_filter, hide_relation ,parent_entity,column_order,order_type) VALUES (:entity, :enabled, :display_name,:display, :filter_id, :default_filter, :sync_ws20, :sync_activities, :sync_attachments, :rank, :read_only, " +
				" :filter_disable, :read_only_disable, :sync_activities_disable, :sync_attachments_disable, :entity_disable,:sync_order,:authorize_deletion" +
				",:authorize_deletion_disable,:advanced_filter,:hide_relation,:parent_entity,:column_order,:order_type)";
			
			stmtUpdSortCol = new SQLStatement();
			stmtUpdSortCol.sqlConnection = sqlConnection;
			stmtUpdSortCol.text = "UPDATE transactions SET column_order = :column_order, order_type = :order_type WHERE entity = :entity";

			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE transactions SET enabled = :enabled, display_name = :display_name,display = :display, filter_id = :filter_id, sync_ws20 = :sync_ws20, sync_activities = :sync_activities, sync_attachments = :sync_attachments, read_only = :read_only, rank = :rank" +
				",authorize_deletion = :authorize_deletion,advanced_filter = :advanced_filter,parent_entity = :parent_entity WHERE entity = :entity";
			
			stmtAllTransaction = new SQLStatement();
			stmtAllTransaction.sqlConnection = sqlConnection;
			stmtAllTransaction.text = "SELECT * FROM transactions ORDER BY rank";
			
			stmtAllEnabledTransaction = new SQLStatement();
			stmtAllEnabledTransaction.sqlConnection = sqlConnection;
			stmtAllEnabledTransaction.text = "SELECT * FROM transactions WHERE enabled = 1 ORDER BY sync_order asc";
			
			stmtAllDisabledTransaction = new SQLStatement();
			stmtAllDisabledTransaction.sqlConnection = sqlConnection;
			stmtAllDisabledTransaction.text = "SELECT * FROM transactions WHERE enabled = 0 ORDER BY sync_order asc";
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM transactions WHERE entity = :entity";
			
			stmtSetDefaultFilter = new SQLStatement();
			stmtSetDefaultFilter.sqlConnection = sqlConnection;
			stmtSetDefaultFilter.text = "UPDATE transactions SET default_filter = :default_filter WHERE entity = :entity"
			
			stmtUpdateAllField = new SQLStatement();
			stmtUpdateAllField.sqlConnection = sqlConnection;
			// #311: hange request - Diversey sales - Prefernces
			stmtUpdateAllField.text = "UPDATE transactions SET enabled = :enabled, display_name = :display_name, display = :display, filter_id = :filter_id, default_filter = :default_filter, rank = :rank,"+ 
				" sync_ws20 = :sync_ws20, sync_activities = :sync_activities, sync_attachments = :sync_attachments, read_only =:read_only, sync_order= :sync_order, authorize_deletion= :authorize_deletion,authorize_deletion_disable= :authorize_deletion_disable," +
				" filter_disable = :filter_disable, read_only_disable = :read_only_disable, sync_activities_disable = :sync_activities_disable, sync_attachments_disable = :sync_attachments_disable, entity_disable = :entity_disable, advanced_filter =:advanced_filter, hide_relation =:hide_relation, parent_entity = :parent_entity,  " + 
				" column_order = :column_order, order_type =:order_type WHERE entity = :entity";
			
			stmtUpdateSyncOrder=new SQLStatement();
			stmtUpdateSyncOrder.text="UPDATE transactions SET  sync_order= :sync_order,display=:display where entity = :entity ";
			stmtUpdateSyncOrder.sqlConnection=sqlConnection;
			
		
		}
		
		
		
		public function insert(transaction:Object):void {
			stmtInsert.parameters[":rank"] = transaction.rank; 
			execStatement(stmtInsert, transaction);
		}
		
		public function updateSyncOrder(transaction:Object):void{
			stmtUpdateSyncOrder.parameters[":sync_order"]=transaction.sync_order;
			stmtUpdateSyncOrder.parameters[":display"]=transaction.display;
			stmtUpdateSyncOrder.parameters[":entity"]=transaction.entity;			
			exec(stmtUpdateSyncOrder);
		}
		
		public function updateSortCol(transaction:Object):void{
			stmtUpdSortCol.parameters[":column_order"]=transaction.column_order;
			stmtUpdSortCol.parameters[":order_type"]=transaction.order_type;
			stmtUpdSortCol.parameters[":entity"]=transaction.entity;
			exec(stmtUpdSortCol);
		}
		
		
		// why is there updateAllField and update ????
		// there should be only one function
		//VAHI: update() does not change the default_filter, see also makeDefaultFilter()
		public function update(transaction:Object):void {
			stmtUpdate.parameters[":entity"] = transaction.entity; 
			stmtUpdate.parameters[":enabled"] = transaction.enabled;
			stmtUpdate.parameters[":display_name"] = transaction.display_name;
			stmtUpdate.parameters[":display"] = transaction.display;
			stmtUpdate.parameters[":filter_id"] = transaction.filter_id;
			stmtUpdate.parameters[":sync_ws20"] = transaction.sync_ws20;
			stmtUpdate.parameters[":sync_activities"] = transaction.sync_activities;
			stmtUpdate.parameters[":sync_attachments"] = transaction.sync_attachments;
			stmtUpdate.parameters[":read_only"] = transaction.read_only;
			stmtUpdate.parameters[":rank"] = transaction.rank;
			//stmtUpdate.parameters[":sync_order"] = transaction.sync_order;
			stmtUpdate.parameters[":authorize_deletion"] = transaction.authorize_deletion;
			stmtUpdate.parameters[":advanced_filter"] = transaction.advanced_filter;
			stmtUpdate.parameters[":parent_entity"] = transaction.parent_entity;
			
			exec(stmtUpdate);
		}
		
		public function updateAllFields(transaction:Object):void{
			execStatement(stmtUpdateAllField, transaction);
		}
		
		// #311: hange request - Diversey sales - Prefernces
		private function execStatement(stmt:SQLStatement, object:Object):void{
			stmt.parameters[":entity"] = object.entity; 
			stmt.parameters[":enabled"] = object.enabled;
			stmt.parameters[":display_name"] = object.display_name;
			stmt.parameters[":display"] = object.display;
			stmt.parameters[":filter_id"] = object.filter_id;
			stmt.parameters[":default_filter"] = object.default_filter;
			stmt.parameters[":sync_ws20"] = object.sync_ws20;
			stmt.parameters[":sync_activities"] = object.sync_activities;
			stmt.parameters[":sync_attachments"] = object.sync_attachments;
			stmt.parameters[":read_only"] = object.read_only;			
			stmt.parameters[":filter_disable"] = object.filter_disable;
			stmt.parameters[":read_only_disable"] = object.read_only_disable;
			stmt.parameters[":sync_activities_disable"] = object.sync_activities_disable;
			stmt.parameters[":sync_attachments_disable"] = object.sync_attachments_disable;
			stmt.parameters[":entity_disable"] = object.entity_disable;
			stmt.parameters[":sync_order"] = object.sync_order;
			stmt.parameters[":authorize_deletion"] = object.authorize_deletion;
			stmt.parameters[":rank"]=object.rank;
			stmt.parameters[":authorize_deletion_disable"] = object.authorize_deletion_disable;
			stmt.parameters[":advanced_filter"] = StringUtils.isEmpty(object.advanced_filter)?1:object.advanced_filter;
			stmt.parameters[":hide_relation"]=object.hide_relation;
			stmt.parameters[":parent_entity"]=object.parent_entity;
			stmt.parameters[":column_order"]=object.column_order;
			stmt.parameters[":order_type"]=object.order_type;
			exec(stmt);
		}
		
		
		/** 
		 * That function return a list with all the fields by param
		 */
		public function listTransaction():ArrayCollection{			
			exec(stmtAllTransaction);
			return new ArrayCollection(stmtAllTransaction.getResult().data);
		}
		
		public function listEnabledTransaction():ArrayCollection {
			exec(stmtAllEnabledTransaction);
			return new ArrayCollection(stmtAllEnabledTransaction.getResult().data);
		}
		public function listDisabledTransaction():ArrayCollection {
			exec(stmtAllDisabledTransaction);
			return new ArrayCollection(stmtAllDisabledTransaction.getResult().data);
		}
		public function transactionExists(entity:String):Boolean
		{
			stmtFind.parameters[":entity"] = entity;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0) return false;
			return true;
		}
		
		public function find(entity:String):Object{
			// #bug 78
			stmtFind.parameters[":entity"] = entity;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0) return null;
			return result.data[0];
		}
		public function isHideRelation(entity:String):Boolean{
			// #bug 5683
			stmtFind.parameters[":entity"] = entity;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0) return false;
			
			return parseInt(result.data[0].hide_relation,0)==1?true:false;
		}
		//VAHI the new visibilities will be usable with WS2.0 queries
		private var sodTransactions:Object = {
			X0: {nr:0,		sod:"Broadest",		name:"All"},
			X1: {nr:-1,		sod:"Personal",		name:"My"},
			X10: {nr:-10,	sod:"Manager",		name:"Employee Team"},
			X11: {nr:-11,	sod:"EmployeeManager",name:"Employee"},
			X12: {nr:-12,	sod:"Sales Rep",	name:"My Team"},
			X13: {nr:-13,	sod:"Organization",	name:"My Organization"},			
			X14: {nr:-14,	sod:"AllBooks",		name:"All Book"},
			X15: {nr:-15,	sod:"Context",		name:"Default Book"}
			
		};
		
		public var advancedfilter:ArrayCollection = new ArrayCollection([
			{type:ALL_TYPE,				name:i18n._("PREFERENCE_ADVANCE_FILTER_SHOW_ALL@Show All")},
			{type:ONE_YEAR_TYPE,		name:i18n._("PREFERENCE_ADVANCE_FILTER_ONE_YEAR@One Year")},
			{type:SIX_MONTH_TYPE,		name:i18n._("PREFERENCE_ADVANCE_FILTER_6_MONTHS@6 Months")},
			{type:THREE_MONTH_TYPE,		name:i18n._("PREFERENCE_ADVANCE_FILTER_3_MONTHS@3 Months")},
			{type:ONE_MONTH_TYPE,		name:i18n._("PREFERENCE_ADVANCE_FILTER_1_MONTHS@1 Month")},
			{type:SEVEN_DAY_TYPE,		name:i18n._("PREFERENCE_ADVANCE_FILTER_7_DAYS@7 Days")}
		]);
		
		//VAHI I would like to write, because it's more clear:
		// return [trans for each var trans:Object in sodTransactions]
		// but saddly this isn't supported by AIR yet
		public function getStdTransactions():Array {
			var arr:Array = ObjectUtils.values(sodTransactions);
			arr.sortOn("nr",Array.DESCENDING|Array.NUMERIC);
			return arr;
		}
		
		/** Return the SoD WS20 ViewMode.
		 * (VAHI: Should this probably better go into gadget.util.ws20?)
		 *
		 * @param entity the transaction to use
		 * @return String ViewMode
		 */
		public function getTransactionViewMode(entity:String):String {
			//hack
			if(entity == Database.bookDao.entity){
				return "Personal";
			}
			
			var transaction:Object = find(entity);
			if (transaction!=null) {
				var ix:String = "X"+(-transaction.filter_id);
				if (ix in sodTransactions)
					return sodTransactions[ix].sod;
			}
			return "Broadest";
		}
		
		
		public function getTransactionViewType(entity:String):Number {
			var transaction:Object = find(entity);
			if (transaction!=null) {
				var ix:String = "X"+(-transaction.filter_id);
				if (ix in sodTransactions)
					return sodTransactions[ix].nr;
			}
			return -99;
		}
		
		
		public function getAdvancedFilterType(entity:String):Number{
			var transaction:Object = find(entity);
			if (transaction!=null) {
				return transaction.advanced_filter;
			}
			return -99;
			
		}
		
		
		public function makeDefaultFilter(default_filter:int, entity:String):void{
			stmtSetDefaultFilter.parameters[":default_filter"] = default_filter;
			stmtSetDefaultFilter.parameters[":entity"] = entity;
			exec(stmtSetDefaultFilter);
		}
	}
}
