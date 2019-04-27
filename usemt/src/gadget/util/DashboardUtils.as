package gadget.util
{
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import gadget.control.GridColumnRenderFactory;
	import gadget.control.GridFontItemRenderer;
	import gadget.dao.DAO;
	import gadget.dao.Database;
	import gadget.lists.List;
	import gadget.window.WindowManager;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.formatters.DateFormatter;
	import mx.utils.StringUtil;
	
	public class DashboardUtils
	{
		private static const MILLIS_PER_DAY:int = 1000*60*60*24;
		private static var list:List;
		public function DashboardUtils()
		{
		}
		
		private static function openDetailEntity(e:MouseEvent):void{
			var lstData:DataGrid = e.currentTarget as DataGrid;
			
			var screenDetail:Detail = new Detail();
			screenDetail.calendar = list.calendar;
			screenDetail.calendarIlog = list.calendarIlog;					
			screenDetail.item =  Database.getDao(lstData.selectedItem.gadget_type).findByGadgetId(lstData.selectedItem.gadget_id); 
			screenDetail.entity = lstData.selectedItem.gadget_type;
			screenDetail.refreshFunction = list.selectItem;
			screenDetail.mainWindow = list.mainwindow as MainWindow;
			WindowManager.openModal(screenDetail);
		}
		public static function setFilter(column_name:String, key:String, value:String):Object {
			var objFilter:Object = new Object();
			objFilter.column_name = column_name;
			objFilter.key = key;
			objFilter.value = value;
			return objFilter;
		}
		
		public static function getFilter(column_name:String, key:String):Object {
			var objFilter:Object = new Object();
			objFilter.column_name = column_name;
			objFilter.key = key;
			objFilter.value = find(column_name, key);
			return objFilter;
		}
		
		/**
		 * 
		 * @param column_name
		 * @param key
		 * @return 
		 * 
		 */
		public static function find(column_name:String, key:String):String {
			return Database.dashboardFilterDAO.find(column_name, key);
		}
		
		public static function listEnableTransaction():ArrayCollection {
			var transactions:ArrayCollection = Database.transactionDao.listEnabledTransaction();
			transactions.addItemAt({entity: ""}, 0);
			return transactions;
		}
		
		public static function getDashboardFilter(data:Object):ArrayCollection {
			
			var dashboardFilter:ArrayCollection = new ArrayCollection();
			var objFilter:Object;
			var column_name:String = data.column_name;
			var filter_id:String = find(column_name, DashboardFilter.FIELD_FILTERID);
			
			if(!StringUtils.isEmpty(filter_id)) {
				
				switch(DashboardFilter.getIndex(data)) {
					case 0:	// List							
						// LIMIT
						objFilter = getFilter(column_name, DashboardFilter.FIELD_LIMIT);
						dashboardFilter.addItem(objFilter);
						
						objFilter = getFilter(column_name, DashboardFilter.FIELD_MULTISELECTLIST);
						dashboardFilter.addItem(objFilter);	
						break;
					case 1: // Pie chart
						break;
				}				
				
				// Column filter_id
				objFilter = getFilter(column_name, DashboardFilter.FIELD_FILTERID);
				dashboardFilter.addItem(objFilter);
				
				// Column operator
				objFilter = getFilter(column_name, DashboardFilter.FIELD_OPERATOR);
				dashboardFilter.addItem(objFilter);	
				
				// Column sum
				objFilter = getFilter(column_name, DashboardFilter.FIELD_SUM);
				dashboardFilter.addItem(objFilter);
				
				// Group by column
				objFilter = getFilter(column_name, DashboardFilter.FIELD_GROUPBY);
				dashboardFilter.addItem(objFilter);
				
				// Order by column
				objFilter = getFilter(column_name, DashboardFilter.FIELD_ORDERBY);
				dashboardFilter.addItem(objFilter);
				
				// Order by desc
				objFilter = getFilter(column_name, DashboardFilter.FIELD_ORDER_DESC);
				dashboardFilter.addItem(objFilter);
				
			}
			
			return dashboardFilter;
			
		}
		
		public static function getQueryGrid(layout:Object):DisplayObject {
			
			var column_name:String = layout.column_name;
			var filter_id:String = find(column_name, DashboardFilter.FIELD_FILTERID);
			var disObject:DisplayObject = null;
			
			if(!StringUtils.isEmpty(filter_id)) {
				
				var filter:Object = Database.filterDao.findFilter(filter_id);
				
				var columns:ArrayCollection = Database.columnsLayoutDao.getColumnLayout(filter.entity, filter.type);
				var filterString:String = FieldUtils.computeFilter(filter);
				var dao:DAO = Database.getDao(filter.entity);
				
				var column_sum:String = find(column_name, DashboardFilter.FIELD_SUM);
				// alias the same column
				if(!StringUtils.isEmpty(column_sum)) {
					columns.addItem({element_name: 'SUM(' + column_sum + ') AS ' + column_sum});
				}
				var group_by:String = find(column_name, DashboardFilter.FIELD_GROUPBY);
				var order_by:String = find(column_name, DashboardFilter.FIELD_ORDERBY);
				order_by = StringUtils.isEmpty(order_by) ? null : order_by + " " + find(column_name, DashboardFilter.FIELD_ORDER_DESC);
				var limit:int = int(find(column_name, DashboardFilter.FIELD_LIMIT));
				var columnTotal:ArrayCollection = fromStringColumns(filter.entity, find(column_name, DashboardFilter.FIELD_MULTISELECTLIST));
				
				var records:ArrayCollection = dao.findAll(columns, filterString, null, limit, order_by, true, group_by);
				
				var cols:Array = [];
				for each(var col:Object in columns) {
					// don't create duplicate column
					if(col.element_name == column_sum) continue;
					var dgCol:DataGridColumn = new DataGridColumn();
					var fieldInfo:Object = FieldUtils.getField(filter.entity, StringUtils.startsWith(col.element_name, "SUM(") ? column_sum : col.element_name);
					dgCol.headerText = fieldInfo.display_name;
					dgCol.dataField = fieldInfo.element_name;
					cols.push(dgCol);
				}
				
				if(columnTotal.length > 0) {					
					
					var dgColTotal:DataGridColumn = new DataGridColumn();
					dgColTotal.width = 50;
					dgColTotal.setStyle("textAlign", "center");
					dgColTotal.headerText = "";
					dgColTotal.dataField = "Total";
					cols.unshift(dgColTotal);
					
					var dic:Dictionary = new Dictionary();
					var objR:Object = new Object();
					for each(var objT:Object in columnTotal) {
						var total:Number = 0;
						for each(objR in records) {
							objR["fontWeight"] = "normal";
							if(objR.hasOwnProperty(objT.column)) {
								total += Number(objR[objT.column]);
								objR[objT.column] = CurrencyUtils.format(objR[objT.column]);
							}
						}
						dic[objT.column] = total;
					}				
					
					var newEmptyRow:Object = new Object();
					newEmptyRow["fontWeight"] = "normal";
					records.addItem(newEmptyRow);
					
					var newRow:Object = Utils.copyModel(objR);
					for (var column:String in newRow) {
						for each(var obj:Object in columnTotal) {
							if(obj.column == column) {
								newRow[column] = CurrencyUtils.format(dic[column]);
								break;
							}else {
								newRow[column] = "";
							}
						}
					}
					newRow["Total"] = "Total";
					newRow["fontWeight"] = "bold";
					records.addItem(newRow);
					records.refresh();
					
				}
				
				var grid:DataGrid = new DataGrid();
				grid.itemRenderer = new GridColumnRenderFactory(GridFontItemRenderer);
				grid.sortableColumns = false;
				grid.horizontalScrollPolicy = "auto";
				grid.dataProvider = records;
				grid.percentWidth = 100;
				grid.columns = cols;
				
				disObject = grid;
			}
			
			return disObject;
		}
		
		public static function drawChart(layout:Object):DisplayObject {
			
			var column_name:String = layout.column_name;
			var filter_id:String = find(column_name, DashboardFilter.FIELD_FILTERID);
			var disObject:DisplayObject = null;
			
			if(!StringUtils.isEmpty(filter_id)) {
				
				var filter:Object = Database.filterDao.findFilter(filter_id);
				
				var columns:ArrayCollection = Database.columnsLayoutDao.getColumnLayout(filter.entity, filter.type);
				var filterString:String = FieldUtils.computeFilter(filter);
				var dao:DAO = Database.getDao(filter.entity);
				
				var group_by:String = find(column_name, DashboardFilter.FIELD_GROUPBY);
				var order_by:String = find(column_name, DashboardFilter.FIELD_ORDERBY);
				order_by = StringUtils.isEmpty(order_by) ? null : order_by + " " + find(column_name, DashboardFilter.FIELD_ORDER_DESC);
				var column_sum:String = find(column_name, DashboardFilter.FIELD_SUM);
				// alias the same column
				if(!StringUtils.isEmpty(column_sum)) {
					columns.addItem({element_name: 'SUM(' + column_sum + ') AS ' + column_sum});
				}
				
				var records:ArrayCollection = dao.findAll(columns, filterString, null, 1000, order_by, true, group_by);
				
				if(layout.column_name.indexOf(DashboardLayout.PIE_CHART_CODE) > -1) {
					var pieChartData:Object = new Object();
					pieChartData.field = column_sum;
					pieChartData.nameField = group_by;
					pieChartData.records = records;
					disObject = ChartUtils.createChart(pieChartData, ChartUtils.PIE_CHART);
				}else if(layout.column_name.indexOf(DashboardLayout.COLUMN_CHART_CODE) > -1) {
					var columnChartData:Object = new Object();
					columnChartData.categoryField = group_by;
					columnChartData.xField = group_by;
					columnChartData.yField = [column_sum];
					columnChartData.records = records;
					disObject = ChartUtils.createChart(columnChartData, ChartUtils.COLUMN_CHART);
				}
				
			}
			
			return disObject;
			
		}
		
		public static function deleteDashboardLayout(filter_id:String):void {
			// delete layout before delete filter
			Database.dashboardLayoutDAO.deleteLayout(filter_id);
			Database.dashboardFilterDAO.deleteFilter(filter_id);
		}
		
		public static function toStringColumns(columns:ArrayCollection):String {
			var cols:String = "", c:String = "";
			for each(var col:Object in columns) {
				cols += c + " "  + col.column;
				c =  ",";
			}
			return cols;
		}
		
		public static function fromStringColumns(entity:String, colString:String):ArrayCollection {
			var columns:ArrayCollection = new ArrayCollection();
			if(colString) {
				for each(var col:String in colString.split(",")) {
					var fieldInfo:Object = FieldUtils.getField(entity, StringUtil.trim(col));
					if(!fieldInfo) fieldInfo = FieldUtils.getField(entity, StringUtil.trim(col),false,true);
					if(fieldInfo) columns.addItem({entity: fieldInfo.entity, label: fieldInfo.display_name, column: fieldInfo.element_name, type: fieldInfo.data_type, data: fieldInfo.element_name });
				}
			}
			return columns;
		}
		
		public static function getColumns(entity:String, filter_type:String, data_type:Array=null, isEmptyLabel:Boolean=true):ArrayCollection {
			var columnLayout:ArrayCollection = Database.columnsLayoutDao.getColumnLayout(entity, filter_type);
			var columns:ArrayCollection = new ArrayCollection();
			for each(var col:Object in columnLayout) {
				var fieldInfo:Object = getField(entity, col.element_name);
				if(data_type != null && data_type.indexOf(fieldInfo.data_type) > -1) {
					columns.addItem({entity: fieldInfo.entity, label: fieldInfo.display_name, column: fieldInfo.element_name, type: fieldInfo.data_type, data: fieldInfo.element_name});
				}else if(data_type == null) {
					columns.addItem({entity: fieldInfo.entity, label: fieldInfo.display_name, column: fieldInfo.element_name, type: fieldInfo.data_type, data: fieldInfo.element_name});
				}
			}
			if(isEmptyLabel) columns.addItemAt({entity: "", label: "", column: "", type: "", data: ""}, 0);
			return columns;
		}
		
		private static function getField(entity:String, element_name:String):Object {
			var fieldInfo:Object = FieldUtils.getField(entity, element_name);
			return fieldInfo != null ? fieldInfo : FieldUtils.getField(entity, element_name, false, true);
		}
		
		public static function getColumnNameUsedInLayout(filter_id:String):String {
			var result:Array = Database.dashboardFilterDAO.selectColumnName(filter_id);
			var cols:String = "", c:String = "";
			if(result.length > 0) {
				for each(var col:Object in result) {
					cols += c + " "  + col.column_name;
					c =  ",";
				}
			}
			return cols;
		}
		private static function getNewObjCriteria(field:String,alias:String=""):String{
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYYMMDD";
			var day:int = 30;
			var today:Date = new Date();
			var todayMinusOneMonth:Date = new Date(today.getTime() - MILLIS_PER_DAY*day);
			var todayMinusOneMonthFormat:String = dateFormatter.format(todayMinusOneMonth);		
			return " (substr("+alias + field +", 1, 4) || substr("+alias +  field + ", 6, 2) || substr("+alias + field + ", 9, 2) >= '" + todayMinusOneMonthFormat + "' or " + alias +  field + " is null)";
		}
		private static function getNextObjCriteria(field:String):String{
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYYMMDD";
			var todayMinusOneMonth:Date = new Date();
			var todayMinusOneMonthFormat:String = dateFormatter.format(todayMinusOneMonth);		
			return " substr("+ field +", 1, 4) || substr(" +  field + ", 6, 2) || substr(" + field + ", 9, 2) >= '" + todayMinusOneMonthFormat + "'";
		}
		private static const DEFAULT_DASHBOARD_REPORT:Array = [
			{key: DashboardLayout.OPPORTUNITY_BY_ACCOUNT, entity: 'Opportunity', column_renderer: 'AccountName', columns: ['AccountName', 'OpportunityName', 'SalesStage', 'Revenue',  'CloseDate'], query: "SELECT AccountName, OpportunityName, SalesStage, Revenue, STRFTIME('%m/%d/%Y', CloseDate) AS CloseDate " +
				" FROM opportunity INNER JOIN allusers AS au ON OwnerId=au.Id AND AccountName IS NOT NULL ORDER BY AccountName limit 12"},
			{key: DashboardLayout.OPPORTUNITY_BY_SALES_STAGE, entity: 'Opportunity', columns: ['SalesProcess', 'SalesStage', 'OpportunityName', 'AccountName',  'CloseDate'], query: "SELECT SalesProcess, SalesStage, OpportunityName, AccountName, STRFTIME('%m/%d/%Y', CloseDate) AS CloseDate" +
				" FROM opportunity INNER JOIN allusers AS au ON OwnerId=au.Id AND AccountName IS NOT NULL AND STRFTIME('%Y', CloseDate) = STRFTIME('%Y', 'now') ORDER BY AccountName limit 12"},
			{key: DashboardLayout.ACTIVITIES_BY_OPPORTUNITY, entity: 'Activity', columns: ['OpportunityName', 'Subject', 'Status', 'DueDate'], query: "SELECT a.OpportunityName, a.Subject, a.Status, STRFTIME('%m/%d/%Y', DueDate) as DueDate" +
				" FROM activity AS a INNER JOIN allusers AS au ON OwnerId=au.Id AND STRFTIME('%Y', a.DueDate) = STRFTIME('%Y', 'now') AND a.OpportunityName IS NOT NULL ORDER BY a.DueDate DESC limit 12"},
			{key: DashboardLayout.ACCOUNTS_BY_SALES_REP, entity: 'Account', columns: ['User Name', 'AccountName', 'Location', 'MainPhone', 'MainFax'], query: "SELECT 'Account' gadget_type,AccountId,a.gadget_id,au.LastName||', '||au.FirstName AS 'User Name', AccountName, Location, MainPhone, MainFax" +
				" FROM account As a INNER JOIN allusers AS au ON OwnerId=au.Id  ORDER BY AccountName limit 12"},
			{key: DashboardLayout.CONTACT_MAILING_LIST, entity: 'Contact', columns: ['AccountName', 'ContactFullName', 'JobTitle', 'ContactEmail'], query: "SELECT AccountName, ContactFullName, JobTitle, ContactEmail" +
				" FROM Contact WHERE AccountName IS NOT NULL ORDER BY AccountName limit 12"},
			{key: DashboardLayout.EMPLOYEES_AND_MANAGERS_LIST, entity: 'User', columns: ['User Name', 'ManagerFullName', 'PhoneNumber', 'WorkFax', 'CellPhone'], query: "SELECT  LastName||', '||FirstName AS 'User Name', ManagerFullName, PhoneNumber, WorkFax, CellPhone"+
				" FROM allusers ORDER BY 'User Name' limit 12"},
			//change request #1061 CRO
			{key: DashboardLayout.NEXT_BIRSTDAY, entity: 'Contact', columns: [ 'ContactFullName','AccountName', 'DateofBirth'], query: "SELECT   ContactFullName,AccountName, DateofBirth FROM  Contact Where " + getNextObjCriteria("DateofBirth")  + " ORDER BY DateofBirth limit 12"},
			
			{key: DashboardLayout.NEW_CONTACTS, entity: 'Contact', columns: [ 'ContactFullName','AccountName', 'JobTitle'], query: "SELECT   ContactFullName,AccountName, JobTitle FROM  Contact Where " + getNewObjCriteria("CreatedDate") + " limit 12"},
			
			{key: DashboardLayout.NEW_OPPORTUNITIES, entity: 'Opportunity', columns: [ 'OpportunityName', 'SalesStage',  'CloseDate', 'User Name'], query: "SELECT   SalesStage, OpportunityName, CloseDate, au.LastName||', '||au.FirstName AS 'User Name' FROM opportunity as o INNER JOIN allusers AS au ON OwnerId=au.Id And " + getNewObjCriteria("CreatedDate","o.") + " limit 12"},
			
			{key: DashboardLayout.NEW_MODIFIED_CUSTOMERS, entity: 'Account', columns: [ 'AccountName', 'Location', 'MainPhone', 'MainFax' ], query: "SELECT  AccountName, Location,MainPhone,MainFax FROM  Account Where " + getNewObjCriteria("ModifiedDate") + " limit 12"},
				
			{key: DashboardLayout.NEW_CUSTOMERS, entity: 'Account', columns: [ 'AccountName', 'Location', 'MainPhone', 'MainFax'], query: "SELECT  AccountName, Location,MainPhone,MainFax FROM  Account Where " + getNewObjCriteria("CreatedDate") + " limit 12"}
			
		];
		
		/**
		 * 
		 * @param key DashboardLayout.OPPORTUNITY_BY_ACCOUNT, DashboardLayout.OPPORTUNITY_BY_SALES_STAGE, DashboardLayout.ACTIVITIES_BY_OPPORTUNITY
		 * 			  DashboardLayout.ACCOUNTS_BY_SALES_REP, DashboardLayout.CONTACT_MAILING_LIST, DashboardLayout.EMPLOYEES_AND_MANAGERS_LIST
		 * @return 
		 * 
		 */
		public static function getDashboardReport(key:String,lst:List):DisplayObject {
			list = lst;
			var disObject:DisplayObject = null;
			var objectReport:Object;
			for each(var object:Object in DEFAULT_DASHBOARD_REPORT) {
				if(object.key == key) {
					objectReport = object;
					break;
				}
			}			
			if(objectReport!=null) {
				
				var records:ArrayCollection = Database.dashboardLayoutDAO.getQueryReport(objectReport.query);
				
				if(records.length > 0) {
					var cols:Array = [];
					var columns:Array = objectReport.columns;
					for (var i:int = 0; i < columns.length; i++) {
						var dgCol:DataGridColumn = new DataGridColumn();
						if(columns[i] == objectReport.column_renderer) {
							//dgCol.itemRenderer = new ClassFactory(DataGridLinkRenderer);
						}else {
							var fieldInfo:Object = FieldUtils.getField(objectReport.entity, columns[i]);
							dgCol.headerText = fieldInfo!=null ? fieldInfo.display_name : columns[i];
							dgCol.dataField = fieldInfo!=null ? fieldInfo.element_name : columns[i];
						}
						cols.push(dgCol);
					}
					
					var grid:DataGrid = new DataGrid();
					grid.sortableColumns = false;
					grid.horizontalScrollPolicy = "off";
					grid.dataProvider = records;
					grid.percentWidth = 100;
					grid.columns = cols;
					grid.doubleClickEnabled = true;
					grid.addEventListener(MouseEvent.DOUBLE_CLICK,openDetailEntity);
					grid.setStyle("headerColors",["#05c9e6","#05c9e6"]);
					grid.setStyle("verticalheaderColors","0xFFFFFF");
					grid.setStyle("verticalGridLines",true);
					grid.setStyle("verticalGridLineColor","0xFFFFFF");
					grid.setStyle("verticalGridLines",true);
					grid.setStyle("rollOverColor","0x2addf8");
					grid.setStyle("selectionColor","0x2addf8");
					grid.setStyle("backgroundAlpha", 0.25);
					grid.setStyle("alternatingItemColors", [0xF7F7F7,0x59def2]);
			
					disObject = grid;
				}
			}
			return disObject;
		}
	}
}