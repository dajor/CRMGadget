package gadget.util
{
	
	
	
	

	import com.adobe.utils.NumberFormatter;
	import com.crmgadget.eval.Evaluator;
	import com.google.analytics.debug._Style;
	
	import flash.display.DisplayObject;
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import flexunit.utils.ArrayList;
	
	import gadget.control.AutoComplete;
	import gadget.control.DDStepper;
	import gadget.control.EntityTypeComboBox;
	import gadget.control.GoogleLocalSearchAddress;
	import gadget.control.GoogleSearchImage;
	import gadget.control.GridHeaderRendererFactory;
	import gadget.control.ImageTextInput;
	import gadget.control.ImageTreeFinder;
	import gadget.control.LinkButtonColRenderer;
	import gadget.control.MultiSelectList;
	import gadget.dao.BaseDAO;
	import gadget.dao.CustomFieldDAO;
	import gadget.dao.CustomPicklistValueDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.dao.SupportDAO;
	import gadget.i18n.i18n;
	import gadget.lists.List;
	import gadget.service.LocaleService;
	import gadget.service.PicklistService;
	import gadget.service.RightService;
	import gadget.service.SupportService;
	import gadget.service.UserService;
	import gadget.window.WindowManager;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.Canvas;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.DataGrid;
	import mx.controls.DateField;
	import mx.controls.HTML;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.LinkButton;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;
	import mx.core.Window;
	import mx.events.AdvancedDataGridEvent;
	import mx.events.CalendarLayoutChangeEvent;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	import mx.formatters.DateFormatter;
	import mx.utils.StringUtil;
	
	import spark.components.NumericStepper;
	
	public class GUIUtils{
		private static const SMALL_FIELDS:Array = ["CreatedBy", "ModifiedBy"];
		public static const millisecondsPerHour:int = 1000 * 60 * 60;
		public static const MONDAY:uint = 1;

		private static const API_KEY:Object = {
			//key: "ABQIAAAAiO1dtdpNPgdon_xaew6tzRT-y38ddP0OAp0wGY0-KVK-F9BaeBRMjT17OBIemS1u9mT4oWQFaqWZ7w",
			key: "ABQIAAAADLVFWzMFYMu28dkOxNfgART-y38ddP0OAp0wGY0-KVK-F9BaeBTlJb_TNeDzXn7pdnOV1YkAG5Qthw",
			url: "http://desktop.crm-gadget.com"
		};
		//CRO #1336
		public static function getItemFinderLabel(objName:String, finder:String):String{
			var languageCode:String =  Database.allUsersDao.ownerUser().LanguageCode;
			if("SVE" == languageCode){
				return "Sök artikel";
			}else{
				return objName + finder;
			}
		}
		//CRO #1345
		public static function getListName(objName:String, list:String):String{
			var languageCode:String =  Database.allUsersDao.ownerUser().LanguageCode;
			if("PTG" == languageCode){
				return list + " de " + objName;
			}else{
				return objName + list;
			}
		}
		
		public static function getHeaderTranslate(objField:Object):DisplayObject {
			if(objField.customField!=null){
				var headerValue:String = CustomFieldDAO.getHeaderValue(objField.customField.value);
				if(!StringUtils.isEmpty(headerValue)) return getHeader(headerValue);
			}
			return getHeader(objField.custom);
		}
		
		public static function getHeader(headerText:String):DisplayObject {
			var displayObj:Canvas = new Canvas();
			(displayObj as Canvas).percentWidth = 100;
			var subCanvas:Canvas = new Canvas();
			var label:Label = new Label();
			label.text = headerText;	
			label.setStyle("fontWeight", "bold");
			subCanvas.setStyle("borderSides", "bottom");
			subCanvas.setStyle("borderStyle", "solid");
			subCanvas.percentWidth = 100;
			subCanvas.height = 20;
			subCanvas.addChild(label);
			(displayObj as Canvas).addChild(subCanvas);
			return displayObj;
		}
		//Bug fixing #466 CRO only show detail sqlGrid not editable
		public static function openReadOnlySqlGridDetail(detail:Detail, grid:AdvancedDataGrid,selectedEntity:String):void{
			var selectedItem:Object = grid.selectedItem;
			if(selectedItem == null){
				Alert.show(i18n._('GLOBAL_PLEASE_SELECT_A_ROW_TO_VIEW_DETAIL'), "" , Alert.OK , grid);
				return;
			}
			var item:Object = Database.getDao(selectedEntity).findByGadgetId(selectedItem.gadget_id);
			detail.mainWindow.getListByEntity(selectedEntity).editScreenDetail(item);
//			var screenDetail:Detail = new Detail();
//			screenDetail.isReadOnlyFields = true;
//			screenDetail.item = Database.getDao(selectedEntity).findByGadgetId(selectedItem.gadget_id); 
//			screenDetail.entity = selectedEntity;
//			screenDetail.mainWindow = detail.mainWindow;
//			WindowManager.openModal(screenDetail);
			
		}
		
		public static function checkCustomPicklistValue(item:Object,fields:ArrayCollection,entity:String,this_:Window):void{
			var customPickList:Dictionary = Database.customPicklistValueDAO.selectByEntityAsDic(entity);
			for (var i:int = 0; i < fields.length; i++) {
				var columnName:String = fields[i].column_name!=null?fields[i].column_name:fields[i].element_name;
				var fieldInfo:Object = FieldUtils.getField(entity, columnName);
				if (fieldInfo && fieldInfo.data_type=='Picklist') {
					var customPicklistValue:Object = customPickList[(columnName+item.gadget_id)];
					if(customPicklistValue!=null){
						var customCode:String = customPicklistValue.crmCode;
						if(customCode.indexOf('$$')<0) customCode = customCode.replace("/","$$"); 
						item[columnName] = customCode;
					} 
				}
			}	
		}
		public static function saveCustomPicklistValue(item:Object,fields:ArrayCollection,entity:String,this_:Window):void{
			var ownerUser:Object = Database.allUsersDao.ownerUser();
			for (var i:int = 0; i < fields.length; i++) {
				if (fields[i].component is ComboBox) {
					var colName:String = fields[i].column_name;
					if(fields[i].formField) colName = fields[i].formField.element_name;
					var picValue:String = item[colName];
					if(picValue){
						var picklistValue:Object = CustomPicklistValueDAO.newObject();
						picklistValue.entity = entity;
						picklistValue.fieldName = colName;
						// picklistValue.oracleCode = picValue.split("/")[0];
						picklistValue.oracleCode = picValue.split("$$")[0];
						picklistValue.crmCode = picValue;
						picklistValue.oracleId = item.IntegrationId;
						picklistValue.gadgetId = item.gadget_id;
						if(picValue.indexOf('$$')>0){
							Database.customPicklistValueDAO.update_(picklistValue);
							item[colName] = picklistValue.oracleCode;
						}else{
							Database.customPicklistValueDAO.deleteByFieldName(picklistValue);
						}
					}
				}else{
					//CRO #1118 (fields[i].column_name)
					if(fields[i].column_name && fields[i].column_name.indexOf(CustomLayout.CUSTOMFIELD_CODE)>-1){
						var objectCustomField:Object = fields[i].customField;
						if(objectCustomField!=null && objectCustomField.fieldType=="Formula"){
							item[objectCustomField.fieldName] = Utils.doEvaluate(objectCustomField.value,ownerUser, objectCustomField.entity, objectCustomField.fieldName, item,Utils.getSqlListCounts(item,fields));
						}
					}
				}
			}
		}
		
		public static function findEvaluatorDefaultValue(entity:String,fieldName:String,item:Object):String{
			var fieldInfo:Object = FieldUtils.getField(entity, fieldName);
			if(!fieldInfo) fieldInfo = FieldUtils.getField(entity, fieldName,false,true);
			if(fieldInfo){
				// var defaultValueExpressions:Array = Database.fieldManagementServiceDao.getDefaultFieldValue(entity,fieldInfo.display_name);
				var fieldName:String = Utils.convertFldAccTypeToType(entity,fieldInfo.element_name);
				var fieldManagement:Object = Database.fieldManagementServiceDao.getByName(entity,fieldName);
				var userData:Object = Database.allUsersDao.ownerUser();
				if(fieldManagement!=null){
					if(!StringUtils.isEmpty(fieldManagement.DefaultValue)){
						var defaultValue:String = fieldManagement.DefaultValue;
						var val:String = Utils.doEvaluate(defaultValue,userData,entity,fieldInfo.element_name,item,null);
						//get Value from Id to display CRO
						if (fieldInfo.data_type == "Picklist") {
							val = PicklistService.getId(entity,fieldInfo.element_name,val,userData.LanguageCode);
						}
						if(val=='-1' && entity==Database.customObject1Dao.entity && fieldInfo.element_name=='CustomInteger0'){
							val="";
						}
						return val;
					}
				}
			}
			return "";
		}	
		
		
		
		public static function checkValidationRule(item:Object,entity:String,this_:Window,sqlList:ArrayCollection=null):Boolean{
			var sqlListCounts:ArrayCollection = new ArrayCollection();
			if(sqlList!=null){
				for each(var objSql:Object in sqlList){
					var objectSQLQuery:Object = objSql.objectSQLQuery;
					var displayObj:DisplayObject = objSql.displayObj;
					if(displayObj is VBox) {
						var grid:AdvancedDataGrid = ((displayObj as VBox).getChildAt(0)) as AdvancedDataGrid;
						if(grid!=null){
							var count:int = (grid.dataProvider as ArrayCollection).length;
							sqlListCounts.addItem(Utils.createNewObject(["key","count"],[objectSQLQuery.column_name,count<0?0:count]));
						}
					}
				}
			}
			var list:ArrayCollection = Database.validationRuleDAO.selectAll(entity);
			var ownerUser:Object = Database.allUsersDao.ownerUser();
			var langCode:String = LocaleService.getLanguageInfo().LanguageCode;
			for each (var obj:Object in list){
				var active:Boolean = obj.active=="1"?true:false;
				//var checkRule:String = Evaluator.evaluate(obj.value,ownerUser, entity, null, item, PicklistService.getValue,PicklistService.getId,null,false,null,null,sqlListCounts); //object[objectSQLQuery.displayName];
				var checkRule:String =Utils.doEvaluate(obj.value,ownerUser,entity,null,item,sqlListCounts);
				if(active && checkRule=='true'){
					var valTran:Object = Database.validationRuleTranslotorDAO.selectField(obj.entity,obj.ruleName,langCode);
					if(valTran != null && !StringUtils.isEmpty(valTran['errorMessage'])){
						Alert.show(valTran.errorMessage,i18n._("GLOBAL_CHECK_VALIDATION_RULE"), Alert.OK, this_);
					}else{
						Alert.show(obj.errorMessage,i18n._("GLOBAL_CHECK_VALIDATION_RULE"), Alert.OK, this_);
					}
					
					return true;
				}
			}
			return false;
		}
		
		public static function openSqlGridBatchInsert(detail:Detail, generateProductList:Function):void {
			var miniDetail:MiniDetail2;
			detail.updateItemFields();
			miniDetail = new MiniDetail2();
			miniDetail.generateProductList = generateProductList;
			WindowManager.openModal(miniDetail);
		}
		//for jd only
		public static function calculateTotalHours(item:Object,entity:String):void{
			//only for JD user
			if(entity==Database.customObject1Dao.entity && UserService.DIVERSEY==UserService.getCustomerId()){
				//hack code
				var fieldsManagement:Array =Database.fieldManagementServiceDao.getDefaultFieldValue(entity,"NUM_000");
				item.CustomNumber0=getTotalHour(item,entity,fieldsManagement);
				fieldsManagement =Database.fieldManagementServiceDao.getDefaultFieldValue(entity,"INT_000");								
				item.CustomInteger0=getTotalHour(item,entity,fieldsManagement);
			}
		}
		
		private static function getTotalHour(item:Object,entity:String,fieldsManagement:Array):String{
			if(fieldsManagement!=null && fieldsManagement.length>0){
				var value:String=fieldsManagement[0].DefaultValue;
				if(value!=null && value!=''){
					var total:String=Utils.doEvaluate(value,null,entity,'IndexedPick1',item,null);
					return total;
				}
			}
			return "";
		}
		public static function mapPickListValueSqlGrid(sqlGrid:ArrayCollection,objectSQLQuery:Object): void{
			for each(var objectField:Object in objectSQLQuery.fields){
				if (objectField.hidden) continue;
				//CRO picklist display Code to Value
				if(objectField.data_type=="Picklist"){
					for each(var obj:Object in sqlGrid){
						var value:String = PicklistService.getValue(objectField.entity,objectField.element_name,obj[objectField.element_name],obj);
						if(!StringUtils.isEmpty(value)){
							obj[objectField.element_name] = value;	
						}
						
					}
				}
				
			}
		}
		
		public static function openMassSqlGridDetail(detail:Detail, grid:AdvancedDataGrid, objectSQLQuery:Object, status:String, subtype:int):void {
			//Apply only to Working Hours and Material Used in ServiceRequest with Add and Update command only 
			if(detail.entity == "Service Request"){
				detail.updateItemFields();
				if(objectSQLQuery.entity == 'Custom Object 2'){
					var listEditableWindow:MaterialUsedListWindow = new MaterialUsedListWindow();
					listEditableWindow.entity = objectSQLQuery.entity;
					listEditableWindow.fields = objectSQLQuery.fields;
					listEditableWindow.arrayDefaultObject = objectSQLQuery.arrayDefaultObject;
					listEditableWindow.refreshGrid = function():void {
						grid.dataProvider = Database.queryDao.executeQuery(objectSQLQuery.sqlString);
						var data:ArrayCollection = grid.dataProvider as ArrayCollection;
						mapPickListValueSqlGrid(data,objectSQLQuery);
						detail.innerListUpdate();
					};
					if( status==i18n._('GLOBAL_MASS_INSERT') ) {
						listEditableWindow.create = true;
						listEditableWindow.items = new ArrayCollection();
					} else if( status==i18n._('GLOBAL_MASS_UPDATE') ){
						listEditableWindow.create = false;
						listEditableWindow.items = Database.queryDao.executeQuery(objectSQLQuery.sqlString);
					}
					WindowManager.openModal(listEditableWindow);
				}else if(objectSQLQuery.entity == 'Custom Object 1'){
					var workingHoursWindow:WorkingHoursCostsListWindow = new WorkingHoursCostsListWindow();
					workingHoursWindow.entity = objectSQLQuery.entity;
					workingHoursWindow.fields = objectSQLQuery.fields;
					workingHoursWindow.arrayDefaultObject = objectSQLQuery.arrayDefaultObject;
					workingHoursWindow.refreshGrid = function():void {
						grid.dataProvider = Database.queryDao.executeQuery(objectSQLQuery.sqlString);
						var data:ArrayCollection = grid.dataProvider as ArrayCollection;
						mapPickListValueSqlGrid(data,objectSQLQuery);
						detail.innerListUpdate();
					};
					if( status==i18n._('GLOBAL_MASS_INSERT') ) {
						workingHoursWindow.create = true;
						workingHoursWindow.items = new ArrayCollection();
					} else if( status==i18n._('GLOBAL_MASS_UPDATE') ){
						workingHoursWindow.create = false;
						workingHoursWindow.items = Database.queryDao.executeQuery(objectSQLQuery.sqlString);
					}
					WindowManager.openModal(workingHoursWindow);
				}
			}			
		}
		
		
		private static function refreshSqlGrid(detail:Detail, grid:AdvancedDataGrid,objectSQLQuery:Object ):void{
			//bug 1725
			var lstData:ArrayCollection = Database.queryDao.executeQuery(objectSQLQuery.sqlString);
			Utils.parseCurrency(detail.item.CurrencyCode,objectSQLQuery,lstData);
			grid.dataProvider = lstData;
			var data:ArrayCollection = grid.dataProvider as ArrayCollection;
			mapPickListValueSqlGrid(data,objectSQLQuery);
			detail.innerListUpdate();
			//Bug #1727: update the sum in expenses report CRO
			if(objectSQLQuery.entity == Database.activityDao.entity && detail.entity == Database.customObject14Dao.entity){
				var tmpObj:Object = new Object();
				var lstGrid:ArrayCollection  = grid.dataProvider as ArrayCollection;
				var value:Number = 0;
				for(var i:int;i<data.length;i++){
					//get value from CostValue because Cost field for displaying currency(EUR 5000)
					value = value + parseFloat(data[i].CostValue);
				}
				if(value > 0){ 
					detail.item["CustomCurrency0"] = value;
				}else if(data.length == 0){
					detail.item["CustomCurrency0"] = 0;
				}
				tmpObj["gadget_id"] = detail.item["gadget_id"];
				tmpObj["CustomCurrency0"] = detail.item["CustomCurrency0"];
				tmpObj['local_update'] = detail.item.local_update;
				tmpObj['deleted'] = detail.item.deleted;
				tmpObj['error'] = detail.item.error;
				tmpObj['sync_number'] = detail.item.sync_number;
				tmpObj['ood_lastmodified']=detail.item.ood_lastmodified;
				Database.customObject14Dao.updateByField(["CustomCurrency0"],tmpObj);
				detail.refreshData();
			}
			
		}
		public static function openSqlGridDetail(detail:Detail, grid:AdvancedDataGrid, objectSQLQuery:Object, status:String, refreshGrid:Function,newItem:Function=null):void {
			

			if(newItem ==null){
				if(objectSQLQuery.newItem !=null && objectSQLQuery.newItem is Function){
					newItem = objectSQLQuery.newItem;
				}
			}
			
			var selectedItem:Object = objectSQLQuery.target;
			var newObj:Object = newItem==null?new Object():newItem();
			if(selectedItem==null) selectedItem = grid.selectedItem;

			detail.updateItemFields();
			if (status==i18n._('GLOBAL_ADD')) {
				
				
				//if(objectSQLQuery.entity==Database.opportunityProductRevenueDao.entity || objectSQLQuery.entity==Database.activitySampleDroppedDao.entity){
					openDetailScreen(true,detail.mainWindow,objectSQLQuery.entity,function(param:Object):void{
						objectSQLQuery.newRecord = param;
						refreshRelationGrid(detail,grid,objectSQLQuery);
					},newObj,false,0,
						function(newObject:Object):Boolean{
							return checkExistOpportunityCompetitorRelation(objectSQLQuery,newObject);
							
						}
					);
//				}else{
//					openMiniDetail(true,newObj,objectSQLQuery,function(param:Object):void {
//						objectSQLQuery.newRecord = param;
//						refreshGrid(detail,grid,objectSQLQuery);
//					},newItem);
//				}

			} else if(status==i18n._('GLOBAL_UPDATE') && selectedItem != null) {
				

				//if(objectSQLQuery.entity==Database.opportunityProductRevenueDao.entity || objectSQLQuery.entity==Database.activitySampleDroppedDao.entity){
					openDetailScreen(false,detail.mainWindow,objectSQLQuery.entity,function(param:Object):void{
				
							objectSQLQuery.newRecord = param;
							refreshRelationGrid(detail,grid,objectSQLQuery);
						
						
					},selectedItem,false,0,
						function(newObject:Object):Boolean{
							objectSQLQuery.target = selectedItem;
							return checkExistOpportunityCompetitorRelation(objectSQLQuery,newObject);
						});
//				}else{
//					var item:Object = Database.getDao(objectSQLQuery.entity).findByGadgetId(selectedItem.gadget_id);
//					openMiniDetail(false,item,objectSQLQuery,function(param:Object):void {
//						objectSQLQuery.newRecord = param;
//						refreshGrid(detail,grid,objectSQLQuery);
//					});
//				}
				

			}else if(status==i18n._('GLOBAL_DELETE') && selectedItem != null){
				//CRO 05.01.2011
				Alert.show(i18n._('GLOBAL_ARE_YOU_SURE_YOU_WANT_TO_DELETE'), i18n._('GLOBAL_DELETE'), Alert.YES|Alert.NO, grid, function(event:CloseEvent):void{
					if (event.detail==Alert.YES){
						
						selectedItem["deleted"] = true;
						var fieldOracleId:String=DAOUtils.getOracleId(objectSQLQuery.entity);
						var valOraId:String=selectedItem[fieldOracleId];
						if(valOraId.indexOf("#")==-1){
							Database.getDao(objectSQLQuery.entity).deleteTemporary(selectedItem);
						}else{
							Database.getDao(objectSQLQuery.entity).delete_(selectedItem);
						}
						Utils.removeRelation(selectedItem,objectSQLQuery.entity);
						Utils.deleteChild(selectedItem,objectSQLQuery.entity);						
						selectedItem["gadget_type"] = objectSQLQuery.entity;
						Database.customPicklistValueDAO.deleteByGadgetId(selectedItem);
						refreshGrid(detail,grid,objectSQLQuery);
//						grid.dataProvider = Database.queryDao.executeQuery(objectSQLQuery.sqlString);
//						var data1:ArrayCollection = grid.dataProvider as ArrayCollection;
//						mapPickListValueSqlGrid(data1,objectSQLQuery);				
//						detail.innerListUpdate();
						//CR #1911 CRO
						Utils.updateFieldByChild(objectSQLQuery.entity,selectedItem);
/*
						if(detail.create){
							// HSC 6656
							// Delete from memory
							trace("Delete");
						}else{
							
						}
						*/
					}
				});
				
			}else if(selectedItem == null){
				Alert.show(i18n._('GUIUTILS_ALERT_TEXT_PLEASE_SELECT_THE_ROW_TO') + " " + status.toLocaleLowerCase() + ".", "" , Alert.OK , grid);
				return;
			}   
		}
		
		private static function openMiniDetail(isCreate:Boolean,item:Object,objectSQLQuery:Object,refreshGrid:Function,newItem:Function = null):void{
			var miniDetail:MiniDetail = new MiniDetail();
			miniDetail.entity = objectSQLQuery.entity;
			miniDetail.fields = objectSQLQuery.fields;
			miniDetail.item = item;
			miniDetail.newItem = newItem;
			miniDetail.arrayDefaultObject = objectSQLQuery.arrayDefaultObject;
			miniDetail.create = isCreate;
			miniDetail.refreshGrid = refreshGrid;
			WindowManager.openModal(miniDetail);
		}
		
		
		/*private static function updateRelationGrid(grid:DataGrid, relation:Object, item:Object):void {
		grid.dataProvider = Database.getDao(relation.supportTable).findAll(
		new ArrayCollection([{element_name:relation.labelSupport}, {element_name:relation.keySupport}]), 
		relation.keySrc + " = '" + item[relation.keySrc] + "'"
		);
		}*/
		
		public static function getRelationList(relation:Object, item:Object):ArrayCollection {
			/*
			return Database.getDao(relation.supportTable).findAll(
				new ArrayCollection([{element_name:relation.labelSupport}, {element_name:relation.keySupport}]), 
				relation.keySrc + " = '" + item[relation.keySrc] + "'"
			);
			*/
			var result:ArrayCollection = null;
			if(relation.supportTable == Database.contactAccountDao.entity){
				if("Account" ==relation.entitySrc){
					
					// query contact
					//result = Database.contactDao.findAll(new ArrayCollection([{element_name:"*"}]),"ContactId in (select ContactId from Contact_Account where AccountId='"+item[relation.keySrc]+"')");
					result = Database.accountDao.getContactAccount(item[relation.keySrc]);
					//result = Database.contactDao.findDataByRelation(relation,item[relation.keySrc]);
				}else{
					//query account
					result = Database.contactDao.getContactAccount(item[relation.keySrc]);
//					result = Database.accountDao.findAll(new ArrayCollection([{element_name:"*"}]),"AccountId in (select AccountId from Contact_Account where ContactId='"+item[relation.keySrc]+"')");
				}
			}else if(relation.supportTable ==  "Contact.CustomObject2"){
				result = Database.customObject2Dao.getContactCustomObject2(item[relation.keySrc]);
			}else{
				result = Database.getDao(relation.supportTable).findDataByRelation(relation,item[relation.keySrc]);
			}
			
			return result;
			
		}
		
		
		
		/**
		 * Displays the title of News from Google News.
		 * @param item Current item.
		 * @param valueKey key to find the News on Google News.
		 * @return A VBox containing the various UI objects (grid).
		 * 
		 */
		public static function getNewsGrid(detail:Detail, item:Object, valueKey:String):DisplayObject{		
			var topic:String = SQLUtils.setParams(valueKey, item, false);
			var displayObj:VBox = new VBox();
			displayObj.percentWidth = 100;
			var grid:DataGrid = new DataGrid();
			
			var strTitles:Array = ["Date","Title","Link"];
			var strFields:Array = ["pDate","title","link"];
			var columns:Array = new Array();
			for(var k:int=0;k<strTitles.length;k++){
				var dgCol:DataGridColumn = new DataGridColumn();
				if(k==0) dgCol.width = 120;
				if(k==2) dgCol.visible = false;
				dgCol.headerText = strTitles[k];
				dgCol.dataField = strFields[k];
				columns.push(dgCol);
			}
			grid.percentWidth = 100;
			grid.columns = columns;
			grid.doubleClickEnabled = true;
			getNewsData(grid,topic);
			displayObj.addChildAt(grid, 0);
			
			grid.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:MouseEvent):void{
				if(e.target is DataGridItemRenderer && !(e.target.data is DataGridColumn)){
					openNewsPopupWindow(e);
				}
			});
			return displayObj;
		}
		
		private static function openNewsPopupWindow(e:MouseEvent):void{
			var popupLinkWindow:PopupLinkWindow = new PopupLinkWindow();
			popupLinkWindow.iconLink = ImageUtils.newsFieldImg;
			popupLinkWindow.titleLink = 'CRM Gadget - Google News : ' + StringUtils.reduceTextLength(e.target.data.title,75);
			popupLinkWindow.urlLink = e.target.data.link;
			WindowManager.openModal(popupLinkWindow);
		}
		
		public static function getNewsData(grid:DataGrid,topic:String):void{
			var request:URLRequest = new URLRequest();
			var loaderNews:URLLoader = GUIUtils.getNewsURLLoader(topic,request);
			loaderNews.addEventListener(Event.COMPLETE, function(e:Event):void {
				grid.dataProvider = getNewsList(e);				
			});
			loaderNews.load(request);
		}
		public static function getNewsURLLoader(topic:String,request:URLRequest):URLLoader{		
			var specialKey:String = "!^<>[]\/\\";
			for (var i:int=0;i<specialKey.length;i++){
				while(topic.indexOf(specialKey.charAt(i)+"")>0) 
					topic = topic.replace(specialKey.charAt(i)," ");
			}			
			topic = topic.replace(/#/g," ");
			request.url = "http://news.google.com/news?q=" + topic + "&output=rss";
			request.method = URLRequestMethod.GET;
			request.contentType = "text/xml; charset=utf-8";				
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void {
				// error when no internet access.
				trace("ioErrorHandler: " + e);
			});
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,function(e:Event):void {
				trace("securityErrorEvent: " + e);
			});
			return loader;
		}	
		public static function getNewsList(e:Event):ArrayCollection{
			// read the data from google News and save it into an XML object
			var gridData:ArrayCollection = new ArrayCollection();
			var urlLoader:URLLoader = e.currentTarget as URLLoader;
			try{
				var xml:XML = new XML(urlLoader.data);
				for each (var item:XML in xml.channel[0].item) {
					var obj:Object = new Object();
					obj.pDate = item.pubDate[0];
					obj.title = item.title[0];
					obj.link = item.link[0];
					gridData.addItem(obj);
				}
			}catch (err:Error) { trace(err.getStackTrace()); }
			
			return gridData;
		}
		
		
		private static function refreshRelationGrid(detail:Detail, grid:AdvancedDataGrid,objectSQLQuery:Object):void{
			var object:Object = objectSQLQuery.relation;
//			var newRec:Object = objectSQLQuery.newRecord ;
//			if(newRec!=null){
//				//update relation
//				var oidName:String = DAOUtils.getOracleId(object.item.gadget_type);
//				newRec[oidName] = object.item[oidName];
//				var dao:BaseDAO = Database.getDao(objectSQLQuery.entity);
//				dao.update(newRec);			
//			}

			grid.dataProvider = getRelationList(object.relation, object.item);			
			detail.innerListUpdate();
/*
			if(detail.create){
				var collection:ArrayCollection = (grid.dataProvider as ArrayCollection);
				//collection.addItem()
			}else{

			}
			grid.selectedIndex = -1;
*/			
		} 
		
		
		public static function openDetailScreen(isCreate:Boolean,mainWindow:MainWindow,entity:String,refreshFunction:Function,item:Object = null,isRefreshList:Boolean=false, subtype:int = 0,checkDoublicate:Function=null):void {
			var screenDetail:Detail = new Detail();			
			if(isCreate){
				screenDetail.item = Utils.copyModel(item);							
				Utils.doFomulaField(entity,screenDetail.item,false,subtype);
				screenDetail.item[DAOUtils.getOracleId(entity)] = Detail.DUMMY_OID;
				screenDetail.item['subtype'] = subtype;
				screenDetail.subtype = subtype;
			}else{
				if (item == null) {
					return;
				}
				var baseDOA:BaseDAO = Database.getDao(entity);
				screenDetail.item = baseDOA.findByGadgetId(item.gadget_id); 
				baseDOA.increaseImportant(screenDetail.item);
			}
			screenDetail.entity = entity;
			screenDetail.checkDoublicate = checkDoublicate;
			// HSC 6656
//			screenDetail.parentCreate = parentCreate;
			
			screenDetail.mainWindow = mainWindow;			
			screenDetail.refreshFunction = refreshFunction;
			screenDetail.create = isCreate;
			screenDetail.isRefreshList = isRefreshList;
			WindowManager.openModal(screenDetail);
		}
		
		
		/**
		 * Displays a "relation grid", i.e. a grid that allows to link items from a detail.
		 * This currently only supports MxN relations.   
		 * @param item Current item.
		 * @param related Related entity.
		 * @param readonly If true, add and delete buttons are hidden.
		 * @return A VBox containing the various UI objects (grid + buttons).
		 */
		public static function getRelationGrid(detail:Detail, item:Object, related:String, readonly:Boolean, innerListUpdate:Function = null):DisplayObject{
			var relation:Object = Relation.getMNRelation(item.gadget_type, related);
			var displayObj:VBox = new VBox();
			displayObj.percentWidth = 100;
			var subDao:SupportDAO  = Database.getDao(relation.supportTable,false) as SupportDAO;
			var grid:AdvancedDataGrid = new AdvancedDataGrid();
			
			grid.setStyle('top', 0);
			grid.setStyle('left', 8);
			grid.setStyle('right', 8);
			grid.setStyle('bottom', 8);
			grid.sortExpertMode= true;
			grid.percentWidth = 100;
			grid.percentHeight=100;
			// updateRelationGrid(grid, relation, item);
//			grid.dataProvider =  subDao.findRelatedData(item.gadget_type,item[relation.keySrc]);
			var cfields:ArrayCollection = null;
			if(relation.supportTable == Database.contactAccountDao.entity || relation.supportTable == "Contact.CustomObject2"){
				cfields = Database.subColumnLayoutDao.fetchColumnLayout(item.gadget_type,relation.entityDest);
			}else{
				cfields = Database.subColumnLayoutDao.fetchColumnLayout(item.gadget_type,relation.supportTable);
			}
			grid.dataProvider = getRelationList(relation, item);
			var columns:Array = new Array();
			var contextMenuFunction:Function;
			var isCreate:Boolean = detail.create;
			if(cfields == null || cfields.length < 1){
				
				cfields = Database.columnsLayoutDao.getColumnLayout(relation.supportTable,'0');
				
				if(cfields == null || cfields.length < 1){
					cfields = Database.columnsLayoutDao.getColumnLayout(relation.entityDest,'0');
				}
			}
			var renderer:ClassFactory = null;
			if((item.gadget_type == "Account" && related=="Contact") || (item.gadget_type == "Contact" && related=="Account")){
				renderer = new ClassFactory(LinkButtonColRenderer);
				renderer.properties = new Object();
				renderer.properties["listDetail"]=detail.list;
				
			}
			/*
			if(relation.supportTable != Database.contactAccountDao.entity){
				cfields = Database.subColumnLayoutDao.fetchColumnLayout(item.gadget_type,relation.supportTable);
			}
			*/
			if(cfields == null || cfields.length < 1){
				// default object layout
				//Mony hack 
				//var i:int=0; // SC-20110616
				//if(relation.isColDynamic){
					var labelSupport:Array = relation.labelSupport;
					var labelDest:Array = relation.labelDest;
					for (var i:int=0;i<labelSupport.length;i++) {
						var dgCol:AdvancedDataGridColumn = new AdvancedDataGridColumn();
						//var obj:Object = null;
						var colname:String = labelSupport[i];
						var obj:Object = null;
						if(relation.supportTable == "Contact.CustomObject2"){
							obj = FieldUtils.getField(relation.entityDest, colname);
						}else{
							obj = FieldUtils.getField(relation.supportTable, colname);
						}
						
						if((obj==null || obj!=null && obj.display_name==colname) && i<labelDest.length ){//try to get display name from destination label
							obj = FieldUtils.getField(relation.entityDest, labelDest[i]);
						}
//						if(subDao!=null){
//							obj = Database.fieldDao.findFieldByPrimaryKey(DAOUtils.getRecordType(subDao.entity),colname);
//						}else{
//							obj = Database.fieldDao.findFieldByPrimaryKey(related, colname);
//						}
						if(obj!=null){
							dgCol.headerText = obj.display_name;
						}else{
							dgCol.headerText=colname;
						}					
						//dgCol.headerRenderer = new GridHeaderRendererFactory(dgCol.headerText,relation.entityDest);
						dgCol.dataField = colname;
						if(renderer != null && (dgCol.dataField=="ContactLastName" || dgCol.dataField=="AccountName")){
							dgCol.itemRenderer = renderer;
						}
						columns.push(dgCol);
						//i=i+1;
					}
					
//				}else{
//					for each(var colname1:String in relation.labelSupport) {
//						var dgCol1:DataGridColumn = new DataGridColumn();
//						var objField:Object = Database.fieldDao.findFieldByPrimaryKey(related, relation.labelDest[i]);
//						if(objField!=null){
//							dgCol1.headerText = objField.display_name;
//						}else{
//							dgCol1.headerText = relation.labelDest[i];
//						}
//						
//						dgCol1.headerRenderer = new GridHeaderRendererFactory(dgCol1.headerText,relation.entityDest);
//						dgCol1.dataField = colname1;
//						columns.push(dgCol1);
//						i++;
//					}
//				}
			}else{
				//if(cfields != null || cfields.length >0){
					for each (var field:Object in cfields ){				
						var dgCol2:AdvancedDataGridColumn = List.createColumn(field,function(row:Object,col:AdvancedDataGridColumn):String{
							return List.displayDataTime(row,col,related);
						},function(row:Object,col:AdvancedDataGridColumn):String{
							return List.displayPicklistValue(row,col,related);
						});
//						//var obj2:Object = null;
//						var obj2:Object = null;
//						if(field.entity!=null){
//							obj2 = FieldUtils.getField(field.entity, field.element_name);
//						}
//						if(obj2==null){
//							if(relation.supportTable == "Contact.CustomObject2"){
//								obj2 = FieldUtils.getField(relation.entityDest, field.element_name);
//							}else{
//								obj2 = FieldUtils.getField(relation.supportTable, field.element_name);
//							}
//						}
////						if(subDao!=null){
////							obj2 = Database.fieldDao.findFieldByPrimaryKey(DAOUtils.getRecordType(subDao.entity),field.element_name);
////						}else{
////							obj2 = Database.fieldDao.findFieldByPrimaryKey(related, field.element_name);
////						}
//						if(obj2!=null){
//							dgCol2.headerText = obj2.display_name;
//						}else{
//							dgCol2.headerText=field.element_name;
//						}					
//						//dgCol.headerRenderer = new GridHeaderRendererFactory(dgCol.headerText,relation.entityDest);
//						//if(field.element_name == "Name" && "Activity.Product" == relation.supportTable){
//						//	field.element_name = "Product";
//						//}
//						dgCol2.dataField = field.element_name;
						if(renderer != null && (dgCol2.dataField=="ContactLastName" || dgCol2.dataField=="AccountName")){
							dgCol2.itemRenderer = renderer;
						}
						columns.push(dgCol2);
						
					}
				//}
			}

			grid.percentWidth = 100;
			grid.columns = columns;
			grid.doubleClickEnabled = true;
			
			var object:Object = new Object();
			object.item = item;
			object.relation = relation;
			object.related = related;
			
			grid.data = object;
			
			var hbox:HBox = new HBox();
			if (!readonly) {
				var addBtn:Button = new Button();
				hbox.addChild(addBtn);
				//CRO 21.01.2011
				addBtn.label = i18n._('GLOBAL_ADD');
				if(relation.isColDynamic){
					if(related=='User'){
						addBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
							addTeamHandler(detail, grid, addBtn.label);
//							contextMenuFunction=addTeamHandler;
						});
					}else if(related==Database.contactDao.entity && item.gadget_type == Database.opportunityDao.entity){
							addBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
								addContactRoleHandler(detail, grid, addBtn.label);
								//							contextMenuFunction=addTeamHandler;
							});
					}else{
						var updateBtn:Button = new Button();
						updateBtn.label = i18n._('GLOBAL_UPDATE');
						var objQuery:Object = new Object();
						objQuery.entity = subDao.entity;
						var recordType:String = DAOUtils.getRecordType(subDao.entity);
						var fields:Array = subDao.getLayoutFields();
						
						
						
//						for each (var f:Object in Database.fieldDao.listFields(recordType)){
//							f.entity = subDao.entity;
//							fields.push(f);
//						}
						objQuery.relation =object;
						objQuery.fields = fields;
						objQuery.arrayDefaultObject = new Array();
						function newItem():Object{
							var newItem:Object = new Object();
							var oidName:String = DAOUtils.getOracleId(detail.item.gadget_type);
							newItem[oidName] = detail.item[oidName];
							if(subDao.entity == Database.opportunityProductRevenueDao.entity){
								newItem['Probability']=detail.item['Probability'];
								newItem['ExpectedRevenue']=detail.item['ExpectedRevenue'];
								newItem['OpportunitySalesStage']=detail.item['SalesStage'];
								
							}
							return newItem;
						}
						objQuery.newItem = newItem;
						
						addBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{							
														
							objQuery.target = null;							
							openSqlGridDetail(detail, grid,objQuery, addBtn.label,refreshRelationGrid);
							
							
							
//							contextMenuFunction=function(d:Detail,g:DataGrid,l:String):void{
//								openSqlGridDetail(d, g,objQuery, l,refreshRelationGrid);
//							};
						});
						
						updateBtn.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void{
							objQuery.target = null;		
							openSqlGridDetail(detail, grid,objQuery, updateBtn.label,refreshRelationGrid);
							
							
						});						
						hbox.addChild(updateBtn);
						updateBtn.enabled = !isCreate && RightService.canUpdate(relation.supportTable);
						if(!isCreate){
							MenuUtils.getContextMenuMiniDetail(detail,grid,openSqlGridDetail,objQuery,refreshRelationGrid,relation.supportTable);
						}
						
						
					}
					
				}else{
					addBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
						relationGridHandler(detail, grid, addBtn.label);
					});
					if(!isCreate){
						MenuUtils.getContextMenuMiniRelationGrid(detail, grid, relationGridHandler,relation.supportTable);
					}
					
					
				}
				
				grid.selectedItem=null;
				var deleteBtn:Button = new Button();
				deleteBtn.label = i18n._('GLOBAL_REMOVE');
				deleteBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{	
					relationGridHandler(detail, grid, deleteBtn.label, grid.selectedItem);
				});
				
				
				addBtn.enabled = !isCreate && RightService.canCreate(relation.supportTable);
//				deleteBtn.enabled = !isCreate && RightService.canDelete(relation.supportTable);
				
				
				hbox.addChild(deleteBtn);
			}
			displayObj.addChild(hbox);			
			displayObj.addChildAt(grid, 0);
			return displayObj;
		}
		
		private static function getTeamAccess():ArrayCollection{
				return new ArrayCollection([{label:'',data:''},{label:'ReadOnly',data:'AJTA-D6XWB'},
					{label:'CN Sales Manager',data:'AJTA-1IJJE5'},{label:'CN Sales Rep',data:'AJTA-1IJPPT'},{label:'CP Sales Rep',data:'AJTA-DUBAH'}]);
			
		}
		private static function checkExistOpportunityCompetitorRelation(object:Object,objRes:Object):Boolean{
			var relation:Object = null;
			if(object.relation.supportTable != null){
				relation = object.relation;
			}else if(object.relation.relation != null){
				relation = object.relation.relation;
			}
			if(relation != null && (relation.supportTable == Database.opportunityCompetitorDao.entity || relation.supportTable == Database.activityProductDao.entity)){
				return checkExistChildRelation(object,objRes);
			}else{
				return false;
			}
		}
		private static function checkExistChildRelation(object:Object,objRes:Object):Boolean{

			var relation:Object = null;
			var item:Object = null;
			if(object.relation.supportTable != null){
				relation = object.relation;
				item = object.item;
			}else{
				relation = object.relation.relation;
				item = object.relation.item;
				
			}
			var selectedItem:Object = object.target;
			if(selectedItem != null){
				if( objRes[relation.keyDest] == selectedItem[relation.keyDest]){
					// VM #7026 if child relation doesn't change can update
					return false;
				}
			}
			var results:ArrayCollection = Database.getDao(relation.supportTable).findAll(
								new ArrayCollection([]),
								relation.keySrc + " = '" + item[relation.keySrc] + "'"
								+ " AND "
								+ relation.keySupport + " = '" + objRes[relation.keyDest] + "'");
			if (results.length > 0) {
				return true
			}
			return false
		}
		private static function addContactRoleHandler(detail:Detail, grid:AdvancedDataGrid, status:String, selectedItem:Object = null):void{
			var object:Object = grid.data;
			detail.updateItemFields();
			//var listField:ArrayCollection =		Database.fieldDao.listFields(DAOUtils.getRecordType(object.relation.supportTable));
			var addContactRole:AddContactRole = new AddContactRole();
			
			addContactRole.item=object;
			addContactRole.entity=object.relation.entitySrc;
			addContactRole.action = function(newObj:Object):void {
//				var results:ArrayCollection = Database.getDao(object.relation.supportTable).findAll(
//				new ArrayCollection([]),
//				object.relation.keySrc + " = '" + object.item[object.relation.keySrc] + "'"
//				+ " AND "
//				+ object.relation.keySupport + " = '" + newObj[object.relation.keyDest] + "'");
				if (!checkExistChildRelation(object,newObj)) {
				
					Database.getDao(object.relation.supportTable).insert(newObj);
					newObj = Database.getDao(object.relation.supportTable).selectLastRecord()[0];
					// by default, sets the OracleId as gadget_id
					newObj['Id'] = "#" + newObj.gadget_id;
					Database.getDao(object.relation.supportTable).update(newObj);
					grid.dataProvider = getRelationList(object.relation, object.item);
					detail.innerListUpdate();
				
				}else{
					Alert.show("Record already exists.","Duplicate",Alert.OK,detail);
				}
				
			}
			WindowManager.openModal(addContactRole);
		}
		private static function addTeamHandler(detail:Detail, grid:AdvancedDataGrid, status:String, selectedItem:Object = null):void{
			var object:Object = grid.data;
			detail.updateItemFields();
			//var listField:ArrayCollection =		Database.fieldDao.listFields(DAOUtils.getRecordType(object.relation.supportTable));
			var addTeam:AddTeam = new AddTeam();
			addTeam.listRole=getTeamAccess();
			addTeam.item=object;
			addTeam.entity=object.relation.entitySrc;
			addTeam.related = object.related;
			
			addTeam.elementname=object.relation.labelDest[0];
			addTeam.action = function(other:Object):void {
				// as there is no unique key constraint on the table, we check programmatically
				// the unicity
				var subDao:BaseDAO  = Database.getDao(object.relation.supportTable);
//				var results:ArrayCollection = Database.getDao(object.relation.supportTable).findAll(
//					new ArrayCollection([]),
//					object.relation.keySrc + " = '" + object.item[object.relation.keySrc] + "'"
//					+ " AND "
//					+ object.relation.keySupport + " = '" + other[object.relation.keyDest] + "'");
				if (!checkExistChildRelation(object,other)) {
					var newObj:Object = new Object();
					newObj[object.relation.keySrc] = object.item[object.relation.keySrc];
					newObj[object.relation.keySupport] = other[object.relation.keyDest];
					newObj[object.relation.labelSupport[0]] = other[object.relation.labelDest[0]];
					newObj[object.relation.labelSupport[1]] = other[object.relation.labelDest[1]];
					
					newObj["UserAlias"] = other["Alias"];
					var accessPro:String = object.relation.entitySrc+'Access';
					newObj[accessPro]=other.accessProfile;
					newObj['UserId']=other.Id;
					newObj['TeamRole']=other.TeamRole;
					if(object.relation.entitySrc==Database.accountDao.entity){
						newObj['OpportunityAccess'] = other.OpportunityAccess;
						newObj['ContactAccess'] = other.ContactAccess;
						newObj['RoleName'] = other.Role;
					}else{						
						newObj['UserRole'] = other.Role;
					}					
					
					Database.getDao(object.relation.supportTable).insert(newObj);
					newObj = Database.getDao(object.relation.supportTable).selectLastRecord()[0];
					// by default, sets the OracleId as gadget_id
					newObj['Id'] = "#" + newObj.gadget_id;
					Database.getDao(object.relation.supportTable).update(newObj);
					//set status update to item
					//						object.item.local_update = new Date().getTime();
					//						Database.getDao(object.relation.entitySrc).update(object.item);
					// updateRelationGrid(grid, object.relation, object.item);
					grid.dataProvider = getRelationList(object.relation, object.item);
					detail.innerListUpdate();
				}else{
					Alert.show("The user already added.","Duplicate",Alert.OK,detail);
				}
			};
			
			
			WindowManager.openModal(addTeam);
			
			
		}
		
		
		private static function relationGridHandler(detail:Detail, grid:AdvancedDataGrid, status:String, selectedItem:Object = null):void{
			var object:Object = grid.data;
			detail.updateItemFields();
			if(status==i18n._('GLOBAL_ADD')){
				var entityFinder:EntityFinder = new EntityFinder();
				if (UserService.getCustomerId() == UserService.VETOQUINOL) {
					if (object.relation.entitySrc == "Activity" && detail.item["AccountId"] != null && detail.item["AccountId"] != "") {
						entityFinder.filter = "AccountId = '" + detail.item["AccountId"] + "'";
					}
				}
				
				entityFinder.entity = object.related;
				
				entityFinder.action = function(other:Object):void {
					// as there is no unique key constraint on the table, we check programmatically
					// the unicity
					
					
//						var results:ArrayCollection = Database.getDao(object.relation.supportTable).findAll(
//							new ArrayCollection([]),
//							object.relation.keySrc + " = '" + object.item[object.relation.keySrc] + "'"
//							+ " AND "
//							+ object.relation.keySupport + " = '" + other[object.relation.keyDest] + "'");
						if (!checkExistChildRelation(object,other)) {
							var newObj:Object = new Object();
							newObj[object.relation.keySrc] = object.item[object.relation.keySrc];
							newObj[object.relation.keySupport] = other[object.relation.keyDest];
							//newObj[object.relation.labelSupport] = other[object.relation.labelDest];
							// SC-20110616
							for (var i:int = 0; i < object.relation.labelSupport.length; i++) {
								newObj[object.relation.labelSupport[i]] = other[object.relation.labelDest[i]];
							}
							
							var dao:BaseDAO =Database.getDao(object.relation.supportTable); 
							
							dao.insert(newObj);
							newObj = Database.getDao(dao.entity).selectLastRecord()[0];
							var oraIdField:String = DAOUtils.getOracleId(dao.entity);
							newObj[oraIdField]="#"+newObj.gadget_id;
							dao.update(newObj);
								
							// updateRelationGrid(grid, object.relation, object.item);
							grid.dataProvider = getRelationList(object.relation, object.item);
							detail.innerListUpdate();
/*
							if(detail.create == true){
								// HSC 6656
								// Todo add / update to memory
								trace("add entity relation");
								(grid.dataProvider as ArrayCollection).addItem(newObj); 
							} else {
								
							}
*/
							
							
						}
					
				};
				WindowManager.openModal(entityFinder);
			}else if(status==i18n._('GLOBAL_REMOVE')){
				if (selectedItem == null || selectedItem.gadget_id==null ||selectedItem.gadget_id=='' ) return;
				var dao:BaseDAO=Database.getDao(object.relation.supportTable);
				var obj:Object=null;
				var gadId:String="";
				if(dao.entity == Database.contactAccountDao.entity){
					var accountId:String ="";
					var contactId:String = "";
					if(object.relation.entitySrc=="Account"){
						contactId = selectedItem["ContactId"];
						accountId = object.item["AccountId"];
					}else{
						 accountId = selectedItem["AccountId"];
						 contactId = object.item["ContactId"];
					}
					obj = dao.findContactAccount(accountId,contactId);
					gadId = obj.gadget_id;
				}else if(dao.entity == Database.customObject2ContactDao.entity){
					obj = dao.findContactC02(object.item["Id"],selectedItem["ContactId"]);
					gadId = obj.gadget_id;
				}else{
					gadId = selectedItem.gadget_id;
					obj = dao.findByGadgetId(gadId);
				}
				
				var oraIdField:String = DAOUtils.getOracleId(dao.entity);
				var oraId:String = obj[oraIdField];
				if(oraId.indexOf("#")!=-1){
					dao.deleteByOracleId(oraId);
				}else{
					dao.deleteTemporary({gadget_id:gadId});
				}
				// updateRelationGrid(grid, object.relation, object.item);
				grid.dataProvider = getRelationList(object.relation, object.item);
				detail.innerListUpdate();
/*
				if(detail.create == true){
					// HSC 6656
					// Todo delete from memory
					trace("Delete");
					if (selectedItem == null) return;
					(grid.dataProvider as ArrayCollection).removeItemAt((grid.dataProvider as ArrayCollection).getItemIndex(selectedItem));
				}else{
					
				}
*/
			}
		}
		
		public static function isEnableSR(detail:Detail):Boolean {
			
			var oidName:String = DAOUtils.getOracleId(detail.entity);
			var item:Object = detail.item;
			var odiVal:String = item[oidName] as String;
			var enabled:Boolean = true;
			//Bug #1497 CRO
			if(!detail.create &&(odiVal.indexOf('#')==-1) && detail.entity==Database.serviceDao.entity 
				&& Database.preferencesDao.getBooleanValue(PreferencesDAO.ENABLE_SR_SYNC_ORDER_STATUS)){					
				if(item.CustomPickList10=="STND" || item.CustomPickList10=="ACPT" || item.CustomPickList11=="TECO"  ){  
					enabled = false;
				}
			}
			return enabled;
		}
		
		
		public static function getQueryGrid(objectSQLQuery:Object, detail:Detail, subtype:int, readonly:Boolean,showBarCodeReader:Function,isReadOnlyGrid:Boolean=false):DisplayObject{
			var displayObj:VBox = new VBox();
			displayObj.percentWidth = 100;
			var grid:AdvancedDataGrid = new AdvancedDataGrid();
			grid.setStyle('top', 0);
			grid.setStyle('left', 8);
			grid.setStyle('right', 8);
			grid.setStyle('bottom', 8);
			grid.sortExpertMode= true;
			grid.percentWidth = 100;
			grid.percentHeight=100;
			var currentUser:Object = Database.allUsersDao.ownerUser();
			try{
				var lstData:ArrayCollection = Database.queryDao.executeQuery(objectSQLQuery.sqlString);
				Utils.parseCurrency(detail.item.CurrencyCode,objectSQLQuery,lstData);
				grid.dataProvider =  lstData;//Database.queryDao.executeQuery(objectSQLQuery.sqlString);
				
			}catch(e:SQLError){
				return getHeader(i18n._('GUIUTILS_SQL_SYNTAX_ERROR'));
			}
			var columns:Array = new Array();
			for each(var objectField:Object in objectSQLQuery.fields){
				if (objectField.hidden) continue;
				var dgCol:AdvancedDataGridColumn = new AdvancedDataGridColumn();
				dgCol.dataField = objectField.element_name;
				dgCol.headerText = objectField.display_name;
				if(objectField.data_type=="Number" || objectField.data_type=="Currency" || objectField.data_type=="Integer"){
					dgCol.setStyle("textAlign","right");
				}
				//CRO picklist display Code to Value
				/*if(objectField.data_type=="Picklist"){
					for each(var obj:Object in grid.dataProvider){
						obj[objectField.element_name] = PicklistService.getValue(objectField.entity,objectField.element_name,obj[objectField.element_name]);
					}
				}*/
				var data:ArrayCollection = grid.dataProvider as ArrayCollection;
				mapPickListValueSqlGrid(data,objectSQLQuery);
				columns.push(dgCol);
			}
			grid.percentWidth = 100;
			grid.columns = columns;
			grid.doubleClickEnabled = true;
			
			// Feature #58
			var enabled:Boolean = isEnableSR(detail) && !detail.create;
			
			var hbox:HBox = new HBox();
			var addBtn:Button = new Button();
			addBtn.label = i18n._('GLOBAL_ADD');
			addBtn.enabled = enabled;
			addBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				objectSQLQuery.target = null;
				openSqlGridDetail(detail, grid, objectSQLQuery, addBtn.label, refreshSqlGrid);
				
			});
			
			var updateBtn:Button = new Button();
			updateBtn.label = i18n._('GLOBAL_UPDATE_2');
			updateBtn.enabled = enabled;
			updateBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				objectSQLQuery.target = null;
				openSqlGridDetail(detail, grid, objectSQLQuery, updateBtn.label, refreshSqlGrid);
			});
			
			var deleteBtn:Button = new Button();
			deleteBtn.label = i18n._('GLOBAL_DELETE');
			deleteBtn.enabled = enabled;
			deleteBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				objectSQLQuery.target = null;
				openSqlGridDetail(detail, grid, objectSQLQuery, deleteBtn.label, refreshSqlGrid);
			});
			
			var hbox2:HBox = new HBox();
			// Feature #56 Integration of Barcode scanner
			// if grid store Material Used (custom_object_2)
			var queryString:String = objectSQLQuery.sqlString as String;
			var barCodeBtn:Button = new Button();
			barCodeBtn.label = i18n._('GLOBAL_BARCODE');
			barCodeBtn.enabled = enabled && !detail.create;
			barCodeBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				showBarCodeReader(e);
			});
			// C.R #463 Insert more material numbers at once
			var batchInsertBtn:Button = new Button();
			batchInsertBtn.label = i18n._('GLOBAL_BATCH_INSERT');
			batchInsertBtn.enabled = enabled && !detail.create;
			batchInsertBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				objectSQLQuery.target = null;
				openSqlGridBatchInsert(detail,showBarCodeReader);
			});
			if(queryString.indexOf("custom_object_2")<0 ){
				barCodeBtn.visible = false;
				batchInsertBtn.visible = false;
			}
			
			//Mass insert and update
			var massInsertBtn:Button = new Button();
			massInsertBtn.label = i18n._('GLOBAL_MASS_INSERT');
			massInsertBtn.enabled = enabled;
			massInsertBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				objectSQLQuery.target = null;
				openMassSqlGridDetail(detail, grid, objectSQLQuery, massInsertBtn.label, subtype);
			});
			
			var massUpdateBtn:Button = new Button();
			massUpdateBtn.label = i18n._('GLOBAL_MASS_UPDATE');
			massUpdateBtn.enabled = enabled;
			massUpdateBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				objectSQLQuery.target = null;
				openMassSqlGridDetail(detail, grid, objectSQLQuery, massUpdateBtn.label, subtype);
			});
			
			massInsertBtn.visible = false;
			massUpdateBtn.visible = false;
			
			if( queryString.indexOf("custom_object_2") > 0  || queryString.indexOf("customobject1") > 0 ){
				massInsertBtn.visible = true;
				massUpdateBtn.visible = true;
			}
			//End Mass insert and upate
			
			
		    //Bug fixing 615 CRO
			if(!isReadOnlyGrid && (!readonly || (detail.entity == Database.serviceDao.entity && objectSQLQuery.entity == Database.serviceDao.entity))){
				
				grid.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:MouseEvent):void{
					//Bug fixing 502 CRO
					var selectedEntity:String = objectSQLQuery.entity;
					//--------
					objectSQLQuery.target = null;
					if(selectedEntity == Database.serviceDao.entity){
						openReadOnlySqlGridDetail(detail,grid,selectedEntity);
					}else{
						openSqlGridDetail(detail, grid, objectSQLQuery, i18n._('GLOBAL_UPDATE'), refreshSqlGrid);
					}
					//openSqlGridDetail(openReadOnlySqlGridDetail, objectSQLQuery, i18n._('GLOBAL_UPDATE'), subtype);
					
					
					
				});
				
				if(!readonly){
					MenuUtils.getContextMenuMiniDetail(detail, grid, openSqlGridDetail, objectSQLQuery,refreshSqlGrid,objectSQLQuery.entity);
					hbox.addChild(addBtn);
					hbox.addChild(updateBtn);	
					hbox.addChild(deleteBtn);
					
						
					var hbox3:HBox = new HBox();
					hbox2.addChild(massInsertBtn);
					hbox2.addChild(massUpdateBtn);
					
					hbox3.addChild(barCodeBtn);
					hbox3.addChild(batchInsertBtn);
					displayObj.addChild(hbox);
					displayObj.addChild(hbox2);
					displayObj.addChild(hbox3);
				}
			}
			
			grid.addEventListener(AdvancedDataGridEvent.COLUMN_STRETCH, function(evt:AdvancedDataGridEvent):void {
				var column:DataGridColumn = grid.columns[evt.columnIndex];
				var col:Object = {"filter_id":objectSQLQuery.column_name, "entity":objectSQLQuery.entity, "field_name":column.dataField,"width":column.width};
				var rst:Object = Database.customTableWidthConfigurationDao.find(col);
				if(rst == null){
					Database.customTableWidthConfigurationDao.insert(col);
				}else{
					Database.customTableWidthConfigurationDao.update(col);
				}
			});
			
			computeColumnGrid(objectSQLQuery,grid);
			
			displayObj.addChildAt(grid, 0);
			return displayObj;
		}
		
		private static function computeColumnGrid(objectSQLQuery:Object, grid:AdvancedDataGrid):void {
			var criteria:Object = {"filter_id":objectSQLQuery.column_name, "entity":objectSQLQuery.entity};
			var rsts:ArrayCollection = Database.customTableWidthConfigurationDao.select(criteria);
			if(rsts == null || rsts.length == 0) return;
			var mapColWidth:Object = new Object;
			for each(var rst:Object in rsts){
				mapColWidth[rst.field_name] = rst.width;
			}				
			//loop in the columnheader of list --> change each column's width to rst's width
			for(var i:int=0; i<grid.columns.length; i++){
				var column:DataGridColumn = grid.columns[i];
				if(!mapColWidth.hasOwnProperty(column.dataField)) continue;
				column.width = mapColWidth[column.dataField];
			}
			grid.validateNow();
		}
		
		public static function getSQLField(objectSQLQuery:Object):DisplayObject{
			var displayObj:DisplayObject = new FormItem();
			(displayObj as FormItem).label = objectSQLQuery.display_name;
			var labelValue:Label = new Label();
			try{
				var list:ArrayCollection = Database.queryDao.executeQuery(objectSQLQuery.sqlString);
				if(list != null && list.length>0){
					var content:String = "";
					var object:Object = list.getItemAt(0);
					labelValue.text = object[objectSQLQuery.column_name];
					labelValue.setStyle("fontWeight", "bold");
					labelValue.setStyle('color','#aab3b3');
				}
				
			}catch(e:SQLError){
				return getHeader(i18n._('GUIUTILS_SQL_SYNTAX_ERROR'));
			}
			(displayObj as FormItem).setStyle("labelWidth", 150);
			(displayObj as FormItem).addChild(labelValue);
			return displayObj;
		}
		public static function getSumFields(displayName:String,data:String):DisplayObject{
			var displayObj:DisplayObject = new FormItem();
			(displayObj as FormItem).label = displayName;
			var labelValue:Label = new Label();
				labelValue.text = data ;
				labelValue.setStyle("fontWeight", "bold");
				labelValue.setStyle('color','#aab3b3');
				labelValue.width = 260;
				(displayObj as FormItem).setStyle("labelWidth", 150);
				(displayObj as FormItem).addChild(labelValue);
				return displayObj;
		}
		public static function getFormulaField(objectCustomField:Object,entity:Object,fields:ArrayCollection=null):DisplayObject{
			var displayObj:DisplayObject = new FormItem();
			(displayObj as FormItem).label = objectCustomField.displayName;
			try{
				var ownerUser:Object = Database.allUsersDao.ownerUser();
				var v:String = objectCustomField.value;
				var value:String = Utils.doEvaluate(objectCustomField.value,ownerUser, objectCustomField.entity, objectCustomField.fieldName, entity,Utils.getSqlListCounts(entity,fields));
				if(v.indexOf("Image(") != -1){ //CRO #1012
					var image:Image = new Image();
					image.load(ImageUtils.getColorIcon()[value]);
					(displayObj as FormItem).setStyle("labelWidth", 150);
					(displayObj as FormItem).addChild(image);
				}else{
					
					var labelValue:Label = new Label();
					//Bug fixing 593 
					// labelValue.text = Evaluator.evaluate(objectCustomField.value,ownerUser, objectCustomField.entity, null, entity, PicklistService.getValue,PicklistService.getId,null,false,null,null,Utils.getSqlListCounts(entity,fields)); //object[objectSQLQuery.displayName];
					labelValue.text = value;
					//------
					labelValue.setStyle("fontWeight", "bold");
					labelValue.setStyle('color','#aab3b3');
					labelValue.width = 260;
					(displayObj as FormItem).setStyle("labelWidth", 150);
					(displayObj as FormItem).addChild(labelValue);
				}
				
			}catch(e:SQLError){
				return getHeader(i18n._('Formula Field Syntax Error'));
			}
			
			return displayObj;
		}
		
		public static function getLink(linkLabel:String, linkText:String, linkURL:String):DisplayObject {
			var displayObj:Canvas = new Canvas();
			(displayObj as Canvas).percentWidth = 100;
			var subCanvas:Canvas = new Canvas();
			var label:Label = new Label();
			label.text = linkLabel;	
			label.setStyle("fontWeight", "bold");
			label.setStyle('color','#aab3b3');
			var link:LinkButton = new LinkButton();
			link.label = linkText;
			link.setStyle("color", 0x3380DD);
			link.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
				Utils.openURL(linkURL, "_blank");
			});
			var hbox:HBox = new HBox();
			hbox.addChild(label);
			hbox.addChild(link);
			subCanvas.percentWidth = 100;
			subCanvas.height = 20;
			subCanvas.addChild(hbox);
			(displayObj as Canvas).addChild(subCanvas);
			return displayObj;
		}		
		
		public static function getInputFieldValue(component:DisplayObject, fieldInfo:Object):String {
			var value:String;
			if(component is Label) {
				value = (component as Label).text;
			}else if (component is TextInput) {		
				value = (component as TextInput).text;
			} else if (component is TextArea) {		7
				value = (component as TextArea).text;				
			} else if (component is ImageTextInput) {
				value = (component as ImageTextInput).embedText.text;
			} else if (component is AutoComplete) {
				if((component as AutoComplete).selectedItem != null) value = (component as AutoComplete).selectedItem.data;
				if(value == null) value = "";
			} else if (component is ComboBox) {
				var combo:ComboBox = component as ComboBox;
				value = combo.selectedItem.data;
				if (combo.selectedItem.keySrc) {
					value = combo.selectedItem.keyValue;
				}
				if(value == null) value = "";
			} else if (component is CheckBox) {
				value = (component as CheckBox).selected ? "true" : "false";
			} else if (component is HBox && fieldInfo.data_type == 'Date') {
				var dateControl:DateField = (component as HBox).getChildAt(0) as DateField;
				value = null;
				if (dateControl.text != '') {
					var selectedDate:Date = dateControl.selectedDate;
					//hack date
					if(fieldInfo.entity==Database.accountCompetitorDao.entity||
						fieldInfo.entity==Database.accountPartnerDao.entity ||
						fieldInfo.entity==Database.opportunityPartnerDao.entity){
						value = DateUtils.format(selectedDate, DateUtils.DATABASE_DATETIME_FORMAT);
						
					}else{
						value = DateUtils.format(selectedDate, DateUtils.DATABASE_DATE_FORMAT);
					}
				}
			} else if (component is HBox && fieldInfo.data_type == 'Date/Time') {
				var hboxControl:HBox = (component as HBox);
				var hours:int = (hboxControl.getChildAt(1) as NumericStepper).value;
				var minutes:int = (hboxControl.getChildAt(2) as NumericStepper).value;
				if(getMaxHour()==12){
					
					var ispm:Boolean = DDStepper(hboxControl.getChildAt(3)).value==1;
					if(ispm){
						if(hours<12){
							hours = hours+12;
						}
						
					}else{
						if(hours ==12){
							hours =0;
						}
					}
				}
				value = null;
				if ((hboxControl.getChildAt(0) as DateField).text != '') {
					var selectedDate2:Date = (hboxControl.getChildAt(0) as DateField).selectedDate;
					selectedDate2.setHours(hours);
					selectedDate2.setMinutes(minutes);
					if(selectedDate2!=null){
						selectedDate2=new Date(selectedDate2.getTime()-DateUtils.getCurrentTimeZone(selectedDate2)*millisecondsPerHour);
					}
					
					value = DateUtils.format(selectedDate2, DateUtils.DATABASE_DATETIME_FORMAT);
				}				
				
			} else if (component is HBox && (fieldInfo.element_name.indexOf("Email") > -1 || fieldInfo.element_name.indexOf("WebSite") > -1)) {
				var childDis:HBox = (component as HBox);
				value = (childDis.getChildAt(0) as TextInput).text;
			} else if (component is HBox && fieldInfo.data_type == 'Percent') {	
				var child:HBox = (component as HBox);
				value = (child.getChildAt(0) as NumericStepper).value.toString();				
			} else if(component is ImageTextInput){
				value = (component as ImageTextInput).text;
			} else if (component is Text) {
				value = (component as Text).text;
				
			} else if (component is MultiSelectList) { // Change Request #460
				var i:int = 0;
				value = "";
				for each(var multi:Object in (component as MultiSelectList).selectedItems) {
					value += (i==0 ? multi.data : ";" + multi.data);
					i++;
				}
				
			}else if(component is GoogleLocalSearchAddress) {
				value = (component as GoogleLocalSearchAddress).address.text;
			}else if(component is ImageTreeFinder) {
				var text:String = (component as ImageTreeFinder).embedText.text;
				value = !StringUtils.isEmpty(text) ? ((component as ImageTreeFinder).embedText.data as XML).toXMLString() : "";
			}
			return value;
		}
		
		public static function setInputFieldValue(component:DisplayObject, fieldInfo:Object, value:Object,customField:Object,fields:ArrayCollection):void{
			if(value!=null){
				if(component is Label && customField && customField.fieldType=='Formula'){
					var entity:String = customField.entity;
					var ownerUser:Object = Database.allUsersDao.ownerUser();
					(component as Label).text = Utils.doEvaluate(customField.value,ownerUser, entity, customField.fieldName, entity,Utils.getSqlListCounts(entity,fields));
				}else if (component is TextInput) {		
					(component as TextInput).text = value.toString();
				} else if (component is TextArea) {		
					(component as TextArea).text = value.toString();				
				} else if (component is ImageTextInput) {
					(component as ImageTextInput).embedText.text = value.toString();
					(component as ImageTextInput).text = value.toString();
				} else if (component is ImageTreeFinder) {
					(component as ImageTreeFinder).embedText.text = value.toString();
					(component as ImageTreeFinder).text = value.toString();
				} else if (component is AutoComplete) {
					(component as AutoComplete).typedText = value.toString();
					(component as AutoComplete).validateNow();
					(component as AutoComplete).close();
					//(component as AutoComplete).selectedIndex = Utils.getComboIndex((component as ComboBox), value.toString());
				} else if (component is ComboBox) {
					(component as ComboBox).selectedIndex = Utils.getComboIndex((component as ComboBox), value.toString());
				} else if (component is CheckBox) {
					(component as CheckBox).selected = (value=='true' || value == true)?true:false;
				} else if (component is HBox && fieldInfo.data_type == 'Date') {
					var dateControl:DateField = (component as HBox).getChildAt(0) as DateField;
					dateControl.selectedDate = DateUtils.guessAndParse(value.toString());
				} else if (component is HBox && fieldInfo.data_type == 'Date/Time') {
					var hboxControl:HBox = (component as HBox);
					// Bug #42
					var date:Date = value is Date ? value as Date : value.toString() ? DateUtils.guessAndParse(value.toString()) : null;
					var maxHour:int = getMaxHour();					
				
					if(date!=null){
						date=new Date(date.getTime()+DateUtils.getCurrentTimeZone(date)*millisecondsPerHour);
					}
					
					if(date!=null && maxHour==12){
						var intHr:int = date.getHours();
						var intMM:int = date.getMinutes();						
						if(intHr>maxHour){
							intHr = intHr-maxHour;
						}else if(intHr==0 && maxHour==12){
							intHr = 12;
						}
						var dd:int = 0;
						if(date.getHours()>=12){
							dd = 1;
						}	
						(hboxControl.getChildAt(1) as NumericStepper).value = intHr;
						(hboxControl.getChildAt(2) as NumericStepper).value = intMM;
						DDStepper(hboxControl.getChildAt(3)).value=dd;
						
					}else{
						(hboxControl.getChildAt(1) as NumericStepper).value = date==null ? 0 : date.getHours();
						(hboxControl.getChildAt(2) as NumericStepper).value = date==null ? 0 : date.getMinutes();
					}
					
					
					(hboxControl.getChildAt(0) as DateField).selectedDate = date;
					
					
					
				} else if (component is HBox && (fieldInfo.element_name.indexOf("Email") > -1 || fieldInfo.element_name.indexOf("WebSite") > -1)) {
					var childDis:HBox = (component as HBox);
					(childDis.getChildAt(0) as TextInput).text = value.toString();
				} else if (component is HBox && fieldInfo.data_type == 'Percent') {	
					var child:HBox = (component as HBox);;
					(child.getChildAt(0) as NumericStepper).value = value.toString();				
				} else if (component is Text) {
					(component as Text).text = value.toString();
				}else if(component is GoogleLocalSearchAddress){
					(component as GoogleLocalSearchAddress).addressText = value.toString();
				}
			}
		}
		
		private static function getInputFieldWithButtonLink(entity:String, value:String, readonly:Boolean, toolTip:String, hyperText:String, childObj:DisplayObject, imageClass:Class, small:Boolean = true):DisplayObject{
			childObj = new HBox();
			var textInput:TextInput = new TextInput();
			textInput.text = value;
			//textInput.enabled = !readonly;
			
			textInput = (getEditableObject(entity, readonly, textInput) as TextInput);
			
			textInput.percentWidth = 100;
			var linkBtn:LinkButton = new LinkButton();
			linkBtn.setStyle("icon", imageClass);
			linkBtn.toolTip = toolTip;
			linkBtn.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void {
				var url:String = textInput.text;
				if("mailto:" == hyperText && !StringUtils.isEmpty(url)){
					// send mail only
					Utils.openURL(hyperText + url, '_blank');
				}else if(isValidURL(toolTip, url)) {
					if(hyperText=="" && url){
						var newHyperText:String = url.indexOf("http://") != -1 ? "" : url.indexOf("https://") != -1 ? "" : "http://";
						Utils.openURL(newHyperText + url, '_blank');
					}else{
						Utils.openURL(url.indexOf(hyperText) != -1 ? url: hyperText + url, '_blank');
					}
				}
				//Utils.openURL(hyperText + url, '_blank');
			});
			(childObj as HBox).addChild(textInput);
			if(!small) (childObj as HBox).addChild(linkBtn);
			return childObj;
		}
		
		private static function isValidURL(tooltip:String, url:String):Boolean {
			var iBoolean:Boolean = false;
			if(StringUtil.trim(url) != "") {
				if(tooltip.indexOf("Send mail") != -1) {
					var regExp:RegExp = /([\w-\.]+)@((?:[\w]+\.)+)([a-zA-Z]{2,4})/;
					iBoolean = regExp.test(url); 
				}else {
					iBoolean = true;
				}
			}
			return iBoolean;
		}
		
		public static function getButtonLink(value:String, toolTip:String,hyperText:String, childObj:DisplayObject, imageClass:Class):DisplayObject{
			childObj = new HBox();
			var linkBtn:LinkButton = new LinkButton();
			linkBtn.setStyle("icon", imageClass);
			linkBtn.toolTip = toolTip;
			linkBtn.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void {
				var url:String = value;
				if(hyperText=="" && url){
					var newHyperText:String = url.indexOf("http://") != -1 ? "" : url.indexOf("https://") != -1 ? "" : "http://";
					Utils.openURL(newHyperText + url, '_blank');
				}else{
					Utils.openURL(url.indexOf(hyperText) != -1 ? url: hyperText + url, '_blank');
				}
			});
			(childObj as HBox).addChild(linkBtn);
			return childObj;
		}
		
		private static function getEditableObject(entity:String, readonly:Boolean, childObj:Object):Object {
			var accessRight:Boolean = RightService.canUpdate(entity);
			if(childObj is TextArea) {
				if(accessRight) {
					(childObj as TextArea).enabled = !readonly;
				}
				else {
					(childObj as TextArea).editable = !readonly;
					(childObj as TextArea).selectable = true;
				}
				if(readonly){
					(childObj as TextArea).setStyle("fontWeight", "bold");
					(childObj as TextArea).setStyle('backgroundAlpha','0');
					(childObj as TextArea).setStyle('borderStyle','none');
					
				}
			}
			else if(childObj is TextInput) {
				if(accessRight) {
					(childObj as TextInput).enabled = !readonly;
				}else {
					(childObj as TextInput).editable = !readonly;
					(childObj as TextInput).selectable = true;
				}
				if(readonly){
					(childObj as TextInput).setStyle('fontWeight','bold');
					(childObj as TextInput).setStyle('backgroundAlpha','0');
					(childObj as TextInput).setStyle('borderStyle','none');
				}
				
			}
			return childObj;
		}
		
		
		public static function getMaxHour():int{
			var currentUserDatePattern:Object = DateUtils.getCurrentUserDatePattern();
			
			if(currentUserDatePattern!=null && currentUserDatePattern.timeFormat!=null){
				var timeFormat:String = currentUserDatePattern.timeFormat;
				if(timeFormat.charAt(timeFormat.length-1)=='A'){
					return 12;
				}
			}
			
			return 23;
		}
		
		/**
		 * getInputField method is used to get any controls depended on the field's data_type.
		 * 
		 * @param create : is a boolean value. True means to display controls for created mode, False to display controls for edited mode. 
		 * @param functions : is an ArrayCollection of Function reference. It has _finderClick for ID Field, _referenceClick for Picklist Field and _upload for Image Field.
		 * @param entity : is an entity's name.
		 * @param item  : is an object of entity.
		 * @param fieldInfo : is an object that has information of a field. It has entity, element_name, display_name, data_type and required property.
		 * @param readonly : is a boolean value to show components as a read-only or editable control.
		 * @param small : is a boolean value. If it is true, we show it in a compact mode. ie: a date control without the clear button.
		 * @return : return the control.
		 * 
		 */
		public static function getInputField(create:Boolean, functions:Object, entity:String, item:Object, fieldInfo:Object, readonly:Boolean, small:Boolean = false,field:ArrayCollection=null):DisplayObject {
			var childObj:DisplayObject = null;
			if(SMALL_FIELDS.indexOf(fieldInfo.element_name) > -1) small = true;
			readonly = RightService.canUpdate(entity) ? readonly : true;
			
			switch (fieldInfo.data_type) {
				case "Sum":
					var objCustomField:Object = Database.customFieldDao.selectCustomField(fieldInfo.entity,fieldInfo.element_name);
					
					if(objCustomField != null){
						var value:String = item[objCustomField.fieldName];
						childObj = getSumFields(objCustomField.displayName,value== null ? "": value);
					}
					break;
				case "Formula":
					var objectCustomField:Object = Database.customFieldDao.selectByFieldName(fieldInfo.entity,fieldInfo.element_name);
					if (!objectCustomField) {
						childObj = GUIUtils.getHeader(i18n._('Empty Formula'));
					} else {
						childObj = GUIUtils.getFormulaField(objectCustomField,item);
						if(childObj){
							childObj = (childObj as FormItem).getChildAt(0);
							(childObj as Label).maxHeight = 300;
						} 
						
					}
					break;
				case "Text (Long)":
				case "Note":
					if(!small){
						childObj = new TextArea();
						(childObj as TextArea).height = 100;
						(childObj as TextArea).text = item[fieldInfo.element_name];
						childObj = (getEditableObject(entity, readonly, childObj) as TextArea);
					}else{
						childObj = new TextInput();
						(childObj as TextInput).text = item[fieldInfo.element_name];
						childObj = (getEditableObject(entity, readonly, childObj) as TextInput);
					}
					break;
				case "Text (Short)":
					if(fieldInfo.element_name.indexOf("Email") != -1){
						childObj = getInputFieldWithButtonLink(entity, item[fieldInfo.element_name], readonly, "Send mail", "mailto:", childObj, ImageUtils.emailIcon, small);
						break;
					}else if(fieldInfo.element_name.indexOf("WebSite") != -1){
						var hyperText:String = "";
						if(item[fieldInfo.element_name]){
							hyperText = item[fieldInfo.element_name].indexOf("http://") != -1 ? "" : item[fieldInfo.element_name].indexOf("https://") != -1 ? "" : "http://"; 
						}
						childObj = getInputFieldWithButtonLink(entity, item[fieldInfo.element_name], readonly, "Website", hyperText, childObj, ImageUtils.websiteIcon, small);
						break;
					}else if(fieldInfo.element_name.indexOf(/*"PrimaryBillToStreetAddress"*/"AccountName") != -1 || fieldInfo.element_name =="PrimaryShipToStreetAddress" || (entity.toLowerCase()=="lead" && fieldInfo.element_name.indexOf("Company") != -1)) {
						childObj = getFinderAddress(functions._finderAddressClick, item,readonly,field,fieldInfo.element_name);
						break;
					}
					// no break here
				case "Phone":
				case "Number":
				case "Currency":
				case "Integer":
					childObj = new TextInput();
					(childObj as TextInput).text = item[fieldInfo.element_name];	
					childObj = (getEditableObject(entity, readonly, childObj) as TextInput);
					if(entity =="Opportunity" && fieldInfo.element_name == "Revenue"){
						(childObj as TextInput).maxChars = 25;
					}
					break;
				case "Percent":				
					childObj = new HBox();
					var nsp:NumericStepper = new NumericStepper();
					nsp.width = 50;
					nsp.minimum = 0;
					nsp.maximum = 100;
					nsp.value = item[fieldInfo.element_name];
					nsp.enabled = !readonly;
					(childObj as HBox).addChild(nsp);
					break;
				case "ID":
					childObj = getFinderControl(functions._finderClick, entity, fieldInfo.element_name, readonly, item);
					break;
				case "Tree":
					childObj = getFinderTree(create, functions, entity, fieldInfo, readonly, item);
					break;
				case "Date/Time":
					childObj = new HBox();
					childObj.name = fieldInfo.element_name;
					var df:DateField = new DateField();
					var datePattern:Object = DateUtils.getCurrentUserDatePattern();
					var localeFormat:String = datePattern.dateFormat;
					df.formatString = localeFormat;
					df.yearNavigationEnabled = true;
					df.parseFunction = null;
					df.labelFunction = function(item:Date):String{
						var dformater:DateFormatter = new DateFormatter();
						dformater.formatString = localeFormat;
						return dformater.format(item);
					}
					if(fieldInfo.element_name == "StartTime"){
						df.addEventListener(CalendarLayoutChangeEvent.CHANGE,function(e:Event):void{
							if(fieldInfo.element_name == "StartTime"){
								var endDisplay:BetterFormItem = childObj.parent.parent.getChildByName("EndTime") as BetterFormItem;
								var endD:Date = DateUtils.parse(getInputFieldValue(childObj,fieldInfo), DateUtils.DATABASE_DATETIME_FORMAT);
								item.EndTime =DateUtils.format( new Date(endD.getTime() + ( 3600 *1000 )), DateUtils.DATABASE_DATETIME_FORMAT);;
								setInputFieldValue(endDisplay.getChildByName("EndTime"),fieldInfo,item.EndTime,null,null);
							}
							
						});
					}
					//CRO Bug #1567
					df.firstDayOfWeek = MONDAY;
					// We parse the item value into a date object
					var dateTimeObject:Date;
					// #336: New Appointment
					var SET_CURRENT_TIME_ON_FIELDS:Array = ["StartTime", "EndTime"];
					// set default current StartTime, EndTime
					var tmpDateTime:Object = item[fieldInfo.element_name] != null ? item[fieldInfo.element_name] : SET_CURRENT_TIME_ON_FIELDS.indexOf(fieldInfo.element_name) != -1 ? DateUtils.format(new Date(), DateUtils.DATABASE_DATETIME_FORMAT) : null;
					
					if(tmpDateTime==null && item[fieldInfo.element_name]!=null){
						if(DateUtils.isDate( item[fieldInfo.element_name])){
							tmpDateTime=DateUtils.guessAndParse(item[fieldInfo.element_name]);
						}
					}
					
					
						
					if(tmpDateTime is Date){
						dateTimeObject = tmpDateTime as Date;
					} else{
						dateTimeObject = DateUtils.guessAndParse(tmpDateTime as String);	
					}
					// convert to correct timezone
					if(dateTimeObject!=null && (!create || item[fieldInfo.element_name] != null)){
						dateTimeObject=new Date(dateTimeObject.getTime()+(DateUtils.getCurrentTimeZone(dateTimeObject)*millisecondsPerHour));
					}
					//Bug #5859 CRO
					if(item[fieldInfo.element_name] == null && create && entity == Database.activityDao.entity && fieldInfo.element_name == "EndTime"){
						dateTimeObject=new Date(dateTimeObject.getTime() + ( 3600 *1000 ));
					}else if(create && dateTimeObject == null){
						//dateTimeObject = DateUtils.guessAndParse(DateUtils.format(new Date(), DateUtils.DATABASE_DATETIME_FORMAT) as String) ;
					}
					
					
					
					df.selectedDate = dateTimeObject;					
					df.width = 90;					
					var intHr:int = dateTimeObject==null ? 0 : dateTimeObject.getHours();
					var intMM:int = dateTimeObject==null ? 0 : dateTimeObject.getMinutes();
					var maxHour:int = getMaxHour();
					if(intHr>maxHour){
						intHr = intHr-maxHour;
					}else if(intHr==0 && maxHour==12){
						intHr = 12;
					}
						
					var hr:NumericStepper = new NumericStepper();
					hr.name = "H"+fieldInfo.element_name;
					hr.width = 40;
					hr.minimum = maxHour==12?1:0;
					hr.maximum = maxHour;
					hr.value = intHr;
					hr.addEventListener(Event.CHANGE,function(e:Event):void{
						if(fieldInfo.element_name == "StartTime"){
							var endDisplay:BetterFormItem = childObj.parent.parent.getChildByName("EndTime") as BetterFormItem;
							var endD:Date = DateUtils.parse(getInputFieldValue(childObj,fieldInfo), DateUtils.DATABASE_DATETIME_FORMAT);
							item.EndTime =DateUtils.format( new Date(endD.getTime() + ( 3600 *1000 )), DateUtils.DATABASE_DATETIME_FORMAT);;
							setInputFieldValue(endDisplay.getChildByName("EndTime"),fieldInfo,item.EndTime,null,null);
						}
						
					});
					
					var mm:NumericStepper = new NumericStepper();
					mm.name = "M"+fieldInfo.element_name;
					mm.width = 40;
					mm.minimum = 0;
					mm.maximum = 59;
					if(!create){
						mm.value = intMM;
					}else{
						mm.value =0;//bug#8419
					}
					//bug#8372
					mm.valueFormatFunction = function(value:Number):String{
					
						if(value<10){
							return "0"+value;
						}
						
						return value.toString();
					}
					mm.addEventListener(Event.CHANGE,function(e:Event):void{
						if(fieldInfo.element_name == "StartTime"){
							var endDisplay:BetterFormItem = childObj.parent.parent.getChildByName("EndTime") as BetterFormItem;
							var endD:Date = DateUtils.parse(getInputFieldValue(childObj,fieldInfo), DateUtils.DATABASE_DATETIME_FORMAT);
							item.EndTime =DateUtils.format( new Date(endD.getTime() + ( 3600 *1000 )), DateUtils.DATABASE_DATETIME_FORMAT);;
							setInputFieldValue(endDisplay.getChildByName("EndTime"),fieldInfo,item.EndTime,null,null);
						}
						
					});
					
					
					//df.text = "";
					df.enabled = !readonly;
					hr.enabled = !readonly;
					mm.enabled = !readonly;
					(childObj as HBox).addChild(df);
					(childObj as HBox).addChild(hr);
					(childObj as HBox).addChild(mm);
					
					//am/pm
					var cboDD:DDStepper =null;
					if(maxHour==12){
						var currentVal:int =0;
						cboDD = new DDStepper();					
						cboDD.width=40;
						cboDD.name="DD"+fieldInfo.element_name;
						//cboDD.dataProvider=new ArrayCollection(["AM","PM"]);
						cboDD.enabled=!readonly;
						
						if(dateTimeObject!=null && dateTimeObject.getHours()>=12){
							cboDD.value=1;
						}else{
							cboDD.value=0;
						}
						(childObj as HBox).addChild(cboDD);
						
						
						cboDD.addEventListener(Event.CHANGE,function(e:Event):void{
							if(fieldInfo.element_name == "StartTime"){
								var endDisplay:BetterFormItem = childObj.parent.parent.getChildByName("EndTime") as BetterFormItem;
								var endDate:HBox = endDisplay.getChildByName("EndTime") as HBox;
								var dd:DDStepper = endDate.getChildAt(3) as DDStepper;
								dd.value = DDStepper(e.target).value;			
								var endD:Date = DateUtils.parse(getInputFieldValue(childObj,fieldInfo), DateUtils.DATABASE_DATETIME_FORMAT);															
								item.EndTime =DateUtils.format( new Date(endD.getTime() + ( 3600 *1000)), DateUtils.DATABASE_DATETIME_FORMAT);;
								setInputFieldValue(endDate,fieldInfo,item.EndTime,null,null);
								
							}
							
						});

					}
					var clearBtn:LinkButton = new LinkButton();
					clearBtn.enabled= !readonly; //Bug #1710 CRO
					clearBtn.setStyle("icon",ImageUtils.deleteIcon);
					clearBtn.width=20;
					clearBtn.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void {
						df.text = "";
						hr.value = 0;
						mm.value = 0;
						if(cboDD!=null){
							cboDD.value=0;
						}
						item[fieldInfo.element_name] = "";
					});
					if(!small) (childObj as HBox).addChild(clearBtn);
					
					break;
				case "Multi-Select Picklist": // Change Request #460
					childObj = new MultiSelectList();
					var multiPicklist:Object = PicklistService.getMultiSelectPicklist(entity, item, fieldInfo.element_name);
					(childObj as MultiSelectList).availableItems = multiPicklist.availableItems;
					(childObj as MultiSelectList).selectedItems = multiPicklist.selectedItems;
					break;
				case "Picklist":
					var picklist:ArrayCollection = null;
					// is the picklist a relation between to entites ? (eg. Contact's Account)
					// if this is the case, we use an itemFinder component
					var relation:Object = Relation.getFieldRelation(entity, fieldInfo.element_name);
					if (relation != null) {						
//						if (item.gadget_type == 'Contact' && fieldInfo.element_name == "PrimaryContact"){
//							var other:Object = Database.getDao(relation.entityDest).findByGadgetId(item.gadget_id);
//							// AM 21/10/2010 - I don't understand this - these values should have been set before 
//							item[relation.keySrc] = other[relation.keyDest];
//							for(var i:int=0; i<relation.labelDest.length; i++){
//								item[relation.labelSrc[i]] = other[relation.labelDest[i]];
//							}
//						}
//						childObj = new ImageTextInput();
//						(childObj as ImageTextInput).text = item[fieldInfo.element_name];
//						(childObj as ImageTextInput).item = {'element_name':fieldInfo.element_name, 'data':item};
//						(childObj as ImageTextInput).data = relation;
//						(childObj as ImageTextInput).clickFunc = functions._referenceClick;
//						(childObj as ImageTextInput).enabled = !readonly;
						
						childObj = getItemFinderControl(functions._referenceClick,entity,fieldInfo.element_name,fieldInfo.element_name,readonly,item);
						
					} else {
						// is the picklist a salestage picklist ?
						if ((entity == "Opportunity") && fieldInfo.element_name == "SalesStage") {
							/*var tmp:ArrayCollection = Database.salesStageDao.findAll();
							picklist = new ArrayCollection();
							picklist.addItem({data:"", label:""});
							for each (var stage:Object in tmp) {
								picklist.addItem({data:stage.name, other:"SalesStageId", key:stage.id, label:stage.name, probability:stage.probability, category:stage.sales_category_name});
							}*/
							picklist = Utils.getSalesStage();
						}
						else if (fieldInfo.element_name == "Industry") {
							picklist = Database.industryDAO.getIndustrylists(LocaleService.getLanguageInfo().LanguageCode);
						}else if(fieldInfo.element_name == "CurrencyCode") {
							// standard picklist => combobox the length need bigger than 1
							//var currencyCode:String = Database.allUsersDao.ownerUser().CurrencyCode ? Database.allUsersDao.ownerUser().CurrencyCode : "";
							picklist = new ArrayCollection();
							picklist.addItem({label: "", data: ""});
							//picklist.addItem({label: currencyCode, data: currencyCode});
							var currencyList:Array = Database.currencyServiceDao.findAll();
							for each(var currency:Object in currencyList){
								picklist.addItem({label: currency.Code, data: currency.Code});
							}
						}else if(fieldInfo.element_name == "TimeZoneName"){ //Bug #6661 CRO
							picklist = new ArrayCollection();
							picklist.addItem({label: "", data: ""});
							for each(var tz:Object in Database.timeZoneDao.findAll()){
								picklist.addItem({label: tz.TimeZoneName, data: tz.TimeZoneName});
							}
						}
						else {
							if(entity == Database.accountPartnerDao.entity ||
								entity == Database.accountCompetitorDao.entity||
								entity == Database.opportunityPartnerDao.entity ||
								//entity == Database.opportunityProductRevenueDao.entity ||
								entity == Database.relatedContactDao.entity){
								
								
								if(fieldInfo.element_name=='Owner'){
									picklist = PicklistService.getPicklist(entity, fieldInfo.element_name);
								}else{
									var langCode:String = LocaleService.getLanguageInfo().LanguageCode;
									picklist = Database.customFieldDao.getPicklistValueByFieldName(entity,fieldInfo.element_name,langCode);
								}
								
							}else{
								picklist = PicklistService.getPicklist(entity, fieldInfo.element_name);
							}
						}
						if (picklist.length == 1) {
							
							//if element_name exists in the field_finder, then display the ImageTextInput instead of TextInput
							childObj = getFinderControl(functions._finderClick, entity, fieldInfo.element_name, readonly, item);
							
						} else {
							// if the picklist is country => we use the autocomplete component
							if (fieldInfo.element_name.indexOf('Country') != - 1 
								// autocomplete on field 'Material Used' for Diversey only.
								|| ((fieldInfo.element_name.indexOf('CustomObject2Name') != - 1) && UserService.DIVERSEY==UserService.getCustomerId()) ) {
								childObj = new AutoComplete();
								(childObj as AutoComplete).dataProvider = picklist;
								(childObj as AutoComplete).typedText = Utils.getLabelCountry(picklist,item[fieldInfo.element_name]);
								(childObj as AutoComplete).lookAhead = true;
								
								// (childObj as AutoComplete).addEventListener(MouseEvent.CLICK, functions._countryChange);
								// (childObj as AutoComplete).addEventListener(MouseEvent.MOUSE_OUT, functions._countryChange);
								if(functions._countryChange!=null)
									(childObj as AutoComplete).addEventListener(FocusEvent.FOCUS_OUT, functions._countryChange);
								
								
								//Mony -should be select first item -bug#319
								/*				if (item[fieldInfo.element_name] == null && fieldInfo.required) {
								(childObj as AutoComplete).selectedIndex = 1;
								}*/
								(childObj as AutoComplete).enabled = !readonly;
							} else {
								// standard picklist => combo box
								if (fieldInfo.element_name == 'ContactType' || fieldInfo.element_name == 'AccountType') {
									childObj = new EntityTypeComboBox();
									(childObj as EntityTypeComboBox).enabled = !readonly;
								} else {
									childObj = new ComboBox();
									(childObj as ComboBox).enabled = !readonly;
								}
								
								Utils.suppressWarning(picklist);
								(childObj as ComboBox).dataProvider = picklist;
								(childObj as ComboBox).selectedIndex = Utils.getComboIndex((childObj as ComboBox), item[fieldInfo.element_name]);
								//Mony -should be select first item -bug#319
								//								if (item[fieldInfo.element_name] == null && fieldInfo.required) {
								//									(childObj as ComboBox).selectedIndex = 1;
								//								}
							}
						}
					}
					break;
				case "Checkbox":
					childObj = new CheckBox();
					//(childObj as CheckBox).selected = (item[fieldInfo.element_name] == 'Y' || item[fieldInfo.element_name] == 'true');
					//CRO
					(childObj as CheckBox).selected = (item[fieldInfo.element_name] == 'Y' || item[fieldInfo.element_name] == 'true' || item[fieldInfo.element_name] == true) ? true : false;
					(childObj as CheckBox).enabled = !readonly;
					break;
				case "Date":
					childObj = getDateControl(fieldInfo.element_name,item,readonly,small,entity,create);
//					childObj = new HBox();
//					var dateControl:DateField = new DateField();
//					var localeFormat2:String = DateUtils.getCurrentUserDatePattern().dateFormat; 
//					dateControl.formatString = localeFormat2;
//					dateControl.yearNavigationEnabled = true;
//					
//					// We parse the item value into a date object
//					var dateObject:Date;
//					var tmpDate:Object = item[fieldInfo.element_name];
//					if(tmpDate is Date){
//						dateObject = tmpDate as Date;
//					} else if(tmpDate != null && tmpDate != ""){
//						dateObject = DateUtils.guessAndParse(tmpDate as String);	
//					}
//					
//					dateControl.selectedDate = dateObject;
//					dateControl.enabled = !readonly;
//					
//					var clearDateBtn:LinkButton = new LinkButton();
//					clearDateBtn.setStyle("icon",ImageUtils.deleteIcon);
//					clearDateBtn.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void {
//						dateControl.text = "";
//						item[fieldInfo.element_name] = "";
//					});
//					
//					(childObj as HBox).addChild(dateControl);
//					if(!small) (childObj as HBox).addChild(clearDateBtn);
					
					break;
				
				case "Picture":
					childObj = getPictureObj(create, fieldInfo, item, functions._upload);
					break;
				case "{" + CustomLayout.GOOGLEMAP_CODE + "}":
					
					if(getAddress(entity, item).length == 0) break;
					
					
					var info:Object = {
					title: Utils.getTitle(entity, 0, item, create),
						addr: getAddress(entity, item),
						icon: ImageUtils.getImage(entity,0)
				};
					//childObj = MapUtils.getMapControl(apiKey,info);
					childObj = MapUtils.getGoogleMapControl(API_KEY, info);
					
					(childObj as UIComponent).doubleClickEnabled = true;
					(childObj as UIComponent).addEventListener(MouseEvent.DOUBLE_CLICK, function():void {
						var gMapWin:GoogleMapWindow = new GoogleMapWindow();
						gMapWin.apiKey = API_KEY;
						gMapWin.info = info;
						WindowManager.openModal(gMapWin);
					});
					
					break;
			}
			return childObj;
		}
		
		
		/**
		 * Generate Travel Map
		 * 
		 * @param entity : String
		 * @param items  : Array of Item
		 * @return DisplayObject
		 * 
		 */
		public static function getMapTravelComponet(entity:String, items:Array,isTravel:Boolean=true):DisplayObject{
			var childObj:DisplayObject = null;
			var request:Object = new Object();
			var locations:String = '';
			var mapColor:String = '';
			var mapLocations:Object = new Object();
			for(var k:int=0;k<items.length;k++){
				if(!StringUtils.isEmpty(items[k].address) && mapLocations[items[k].address] == null){
					locations += '"' + items[k].address.replace("'","/'") + '"' ;
					mapLocations[items[k].address] = items[k].address;
					mapColor += '"' + items[k].Color + '"' ;
					if(k + 1< items.length){
						locations += ', ';
						mapColor +=', ';
					}
				}
				
			}
			// Get origin address
			for(var i:int=0; i<items.length; i++){
				//if(getAddress(entity, items[i]).length != 0){
				if(!StringUtils.isEmpty(items[i].address)) {
					request.Start = items.splice(i, 1)[0].address //getAddress(entity, items.splice(i, 1)[0]);
					break;
				}
			}
			
			// Get destination address
			for(i=items.length-1; i>=0; i--){
				//if(getAddress(entity, items[i]).length != 0){
				if(!StringUtils.isEmpty(items[i].address)) {
					request.End = items.splice(i, 1)[0].address //getAddress(entity, items.splice(i, 1)[0]);
					break;
				}
			}
			
			//VM the same location display only one point
			var mapExistLocations:Object = new Object();
			var waypts:String = '[';
			for(i=0; i<items.length; i++){
				//if(getAddress(entity, items[0]).length != 0){
				if(!StringUtils.isEmpty(items[i].address) && mapExistLocations[items[i].address] == null) {
					mapExistLocations[items[i].address] = items[i].address;
					waypts += '{location:"' + items[i].address /*getAddress(entity, items[i])*/ + '"}';
					if(i + 1< items.length){
						waypts += ', ';
					}
					
				}
			}
			
			waypts += ']';
			request.Waypoints = waypts;
			
			if(request.Start == null) return childObj;
			
			var info:Object = {
				title: "Travel Schedule",
				addr: request,
				travel : isTravel,
				icon: ImageUtils.getImage(entity,0),
				locations: locations,
				mapColor : mapColor
			};
			
			if(request.End == null){
				info.addr = request.Start;
				if(!isTravel){
					childObj = MapUtils.getGoogleMapTravelControl(API_KEY, info);
				}else{
					info.travel = false;
					childObj = MapUtils.getGoogleMapControl(API_KEY, info);
				}
				
			}else{
				childObj = MapUtils.getGoogleMapTravelControl(API_KEY, info);
				
			}
			(childObj as UIComponent).doubleClickEnabled = true;
			(childObj as UIComponent).addEventListener(MouseEvent.DOUBLE_CLICK, function():void {
				var gMapWin:GoogleMapWindow = new GoogleMapWindow();
				gMapWin.apiKey = API_KEY;
				gMapWin.info = info;
				gMapWin.travel = true;
				WindowManager.openModal(gMapWin);
			});
			return childObj;
		}
		
		private static function getPictureObj(create:Boolean, fieldInfo:Object, item:Object, upload:Function):HBox {
			var childObj:HBox = new HBox();	
			var btnObj:VBox = new VBox();	
			childObj.percentHeight = 100;
			childObj.percentWidth = 100;
			var canvas:Canvas = new Canvas();
			canvas.setStyle("borderStyle", "solid");
			canvas.height = 188;
			canvas.width = 188;
			var img:Image = new Image();
			img.percentHeight = 100;
			img.percentWidth = 100;							
			img.scaleContent = true;							
			img.source = item[fieldInfo.element_name];
			//Fixed bug #771 CRO #844
			if(item[fieldInfo.element_name] == null && item["gadget_type"] == Database.contactDao.entity){
				if(item["MrMrs"]=="Mr."){
					img.source = ImageUtils.manIcon;
				}else if(item["MrMrs"] =="Miss." || item["MrMrs"]=="Ms." || item["MrMrs"] == "Mrs." ){
					img.source = ImageUtils.womanIcon;
				}else if(item["MrMrs"]== "Dr."){
					img.source = ImageUtils.doctorIcon;
				}	
			}
			
			img.setStyle("horizontalAlign", "center"); 
			img.setStyle("verticalAlign", "middle");
			canvas.addChild(img);
			childObj.addChild(canvas);
			// Bug #119
			var uploadBtn:LinkButton = new LinkButton();
			uploadBtn.setStyle("icon", ImageUtils.addIcon);
			uploadBtn.toolTip = i18n._('GLOBAL_UPLOAD');
			uploadBtn.visible = !create;
			uploadBtn.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{
				var fileBrowse:FileBrowse = new FileBrowse(upload, true);
				fileBrowse.show();
			});
			var clearBtn:LinkButton = new LinkButton();
			clearBtn.setStyle("icon", ImageUtils.deleteIcon);
			clearBtn.toolTip = i18n._('GLOBAL_CLEAR');
			clearBtn.visible = !create;
			clearBtn.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{
				upload("",null);
			});
			var searchImageBtn:LinkButton = new LinkButton();
			searchImageBtn.setStyle("icon", ImageUtils.websiteIcon);
			searchImageBtn.toolTip = "Search Image";
			searchImageBtn.visible = !create;
			searchImageBtn.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{
				var google:GoogleSearchImage = new GoogleSearchImage();
				google._upload = upload;
				google.item = item;
				WindowManager.openModal(google);
			});
			btnObj.addChild(uploadBtn);
			btnObj.addChild(clearBtn);
			btnObj.addChild(searchImageBtn);
			childObj.addChild(btnObj);
			return childObj;
		}
		
		private static function getFinderAddress(finderAddressClick:Function, item:Object,readonly:Boolean,fields:ArrayCollection,fieldName:String):DisplayObject {
			var childObj:DisplayObject;
			childObj = new GoogleLocalSearchAddress();
			(childObj as GoogleLocalSearchAddress).item = item;
			(childObj as GoogleLocalSearchAddress).fieldName = fieldName;
			(childObj as GoogleLocalSearchAddress).addressText = item[fieldName];
			(childObj as GoogleLocalSearchAddress).clickFunc = finderAddressClick;
			(childObj as GoogleLocalSearchAddress).enabled = !readonly;
			(childObj as GoogleLocalSearchAddress).fields = fields;
			return childObj;
		}
		
		public static function getFinderControl(finderClick:Function, entity:String, element_name:String, readonly:Boolean, item:Object):DisplayObject {
			var childObj:DisplayObject;
			var value:String = "";
			if(Database.fieldFinderDAO.getFinderTableName({'entity':entity, 'element_name':element_name}) != null){
				childObj = new ImageTextInput();
				(childObj as ImageTextInput).text = item[element_name];
				(childObj as ImageTextInput).item = {'element_name':element_name, 'data':item};
				(childObj as ImageTextInput).data = {'entity':entity, 'element_name':element_name};
				(childObj as ImageTextInput).clickFunc = finderClick;
				(childObj as ImageTextInput).enabled = !readonly;	
			}else{
				childObj = new Text();
				(childObj as Text).text = item[element_name];
				(childObj as Text).setStyle("fontWeight", "bold");
				(childObj as Text).setStyle('color','#aab3b3');
				(childObj as Text).enabled = !readonly;
			}
			return childObj;
		}
		
		private static function getFinderTree(create:Boolean, functions:Object, entity:String, fieldInfo:Object, readonly:Boolean, item:Object):DisplayObject {
			var childObj:DisplayObject;
			var node:XML = new XML(item[fieldInfo.element_name]);
			var gadget_id:String = item.gadget_id;
			var data:Object = new Object();
			if(!create){
				var myData:Object = Database.customFieldDao.first({"entity":entity, "column_name": fieldInfo.element_name});
				var mapFields:ArrayCollection = Utils.bindValueToGridPicklist(myData.bindValue ? myData.bindValue : "", ["crmData","oodData","oodLabel"]);
				var rootNode:String = "", myTree:ArrayCollection;
				// 
				if(StringUtils.isEmpty(node.@id) && myData != null) {
					var hasCriteria:Boolean ;
					var where:String = " where ";
					for each(var v:Object in mapFields) {
						if(!StringUtils.isEmpty(item[v.oodData])){
							where += v.crmData + "='" + item[v.oodData] + "' and ";
							hasCriteria = true
						}
					}
					where = where.substr(0, where.lastIndexOf(" and "));
					if(!hasCriteria) where = ""; //CRO #1187
					if(!StringUtils.isEmpty(where)) {
						rootNode = new XML(myData.value).localName().toString();
						if(rootNode == "territory")
							myTree = Database.territoryTreeDAO.findTerritory(where);
						else if(rootNode == "depthstructure")
							myTree = Database.depthStructureTreeDAO.findDepthStructure(where);
						if(myTree.length > 0) {
							data = myTree[0];
							node = <node id={data.id} display_name={data.display_name} />;
						}
					}
				}else if(!StringUtils.isEmpty(node.@id) && myData != null) {
					rootNode = new XML(myData.value).localName().toString();
					if(rootNode == "territory")
						myTree = new ArrayCollection(Database.territoryTreeDAO.fetch({id: node.@id}));
					else if(rootNode == "depthstructure")
						myTree = new ArrayCollection(Database.depthStructureTreeDAO.fetch({id: node.@id}));
					if(myTree.length > 0) {
						data = myTree[0];
					}
				}
			}
			
			//findby tree id			
			if(!create){					
				var objTree:Object = new Object();
				for each (var o:Object in mapFields){
					var fld:String = o.oodData;
					objTree[fld] = data[o.crmData];
					item[fld] = data[o.crmData+"_value"];
				}
				item.objTree = objTree;
			}
			
			childObj = new ImageTreeFinder();
			(childObj as ImageTreeFinder).text = node.@display_name;
			(childObj as ImageTreeFinder).item = {'element_name':fieldInfo.element_name, 'data':item};
			(childObj as ImageTreeFinder).fieldInfo = fieldInfo;
			(childObj as ImageTreeFinder).data = node;
			(childObj as ImageTreeFinder).clickFunc = functions._finderTreeClick;
			(childObj as ImageTreeFinder).refreshData = functions._refreshData;
			(childObj as ImageTreeFinder).enabled = !readonly;
		
			return childObj;
		}
		
		public static function getAddress(entity:String, item:Object):String {
			var address_type:String = Database.preferencesDao.getStrValue("google_map_address", "");
			if(address_type == MapUtils.BILLING_ADDRESS){
				entity += "_" + address_type;
			}
			for each (var fieldName:String in FieldUtils.getFieldsDetail(entity)) {
				if (fieldName.indexOf("|") != -1) {
					var addr:String = "";
					var parts:Array = fieldName.split("|");
					for each (var part:String in parts) {
						if (item[part] != null) {
							if (addr.length > 0) {
								addr += " ";
							}
							addr += item[part];
						}
					}
					return addr;
				} 
			}
			return '';
		}	
		
		
		public static function setupCascadingCombo(childObj:DisplayObject, fieldInfo:Object, inputFields:ArrayCollection):void {
			if (childObj is ComboBox) {
				// parent_picklist
				// fieldInfo.element_name
				var ent:String = DAOUtils.getRecordType(fieldInfo.entity);
				
				// is the combo a parent combo ?
				// var allResults:Array = Database.cascadingPicklistDAO.fetch({entity:ent});
				var allResults:ArrayCollection = Database.cascadingPicklistDAO.selectAll(ent,true);
				var results:Array = [];
				for each (var result:Object in allResults) {
					if (match(ent, result.parent_picklist, fieldInfo.element_name)) {
						results = results.concat(result);
					}
				}
				if (results.length > 0) {
					(childObj as ComboBox).addEventListener(Event.CHANGE, function(event:Event):void {
						var srcCombo:Object = null;
						for each (var inputFieldObj:Object in inputFields) {
							if (inputFieldObj.component == event.target) {
								handleCascadingCombo(inputFieldObj, inputFields,allResults);
								break;
							}
						}		
					});
					(childObj as ComboBox).dispatchEvent(new Event(Event.CHANGE));
				}
				
			}
		}	
		
		
		
		/**
		 * Correspondance table between field names provided by CascadingPicklist WS 
		 * and field names provided by GetField WS.
		 */
		private static const CASCADING_FIELDS:Array = [
			{entity:"Service Request", field1:"Cause", field2:"Severity"},
			{entity:"Service Request", field1:"SRType", field2:"Type"},
			{entity:"Service Request", field1:"Account Type", field2:"Type"}
		];
		
		public static function match(entity:String, fieldName1:String, fieldName2:String):Boolean {
			if (fieldName1 == fieldName2) {
				return true;
			}
			for each (var mapping:Object in CASCADING_FIELDS) {
				if (mapping.entity == entity && 
					((mapping.field1 == fieldName1 && mapping.field2 == fieldName2) || (mapping.field1 == fieldName2 && mapping.field2 == fieldName1))) {
					return true;
				}
			}
			return false;
		}
		
		/*public static function checkPicklist(value:String,list:ArrayCollection):Boolean{
			if(list.length>2){
				for each(var obj:Object in list){
					if(obj.label==value) return true;
				}
			}
			return false;
		}*/
		public static function getItemFinderControl(finderClick:Function, entity:String, element_name:String,id:String, readonly:Boolean, item:Object):DisplayObject {
			
			var relation:Object = Relation.getFieldRelation(entity, id);
			var childObj:ImageTextInput;
			if (relation != null) {
				if (item.gadget_type == 'Contact' && element_name == "PrimaryContact"){
					var other:Object = Database.getDao(relation.entityDest).findByGadgetId(item.gadget_id);
					// AM 21/10/2010 - I don't understand this - these values should have been set before 
					item[relation.keySrc] = other[relation.keyDest];
					for(var i:int=0; i<relation.labelDest.length; i++){
						item[relation.labelSrc[i]] = other[relation.labelDest[i]];
					}
				}
				childObj = new ImageTextInput();
				(childObj as ImageTextInput).text = item[element_name];
				(childObj as ImageTextInput).item = {'element_name':element_name, 'data':item};
				(childObj as ImageTextInput).data = relation;
				(childObj as ImageTextInput).clickFunc = finderClick;
				(childObj as ImageTextInput).enabled = !readonly;
			}
			return childObj;
			
		}
		public static function getDateControl(element_name:String,item:Object,readonly:Boolean,small:Boolean,entity:String=null,create:Boolean=false):DisplayObject{
			var childObj:HBox = new HBox();
			var dateControl:DateField = new DateField();
			var localeFormat2:String = DateUtils.getCurrentUserDatePattern().dateFormat; 
			dateControl.formatString = localeFormat2;
			dateControl.yearNavigationEnabled = true;
			//CRO Bug #1567
			dateControl.firstDayOfWeek = MONDAY;
			dateControl.width = 90;
			// We parse the item value into a date object
			var dateObject:Date;
			var tmpDate:Object = item[element_name];
			if(tmpDate is Date){
				dateObject = tmpDate as Date;
			} else if(tmpDate != null && tmpDate != ""){
				dateObject = DateUtils.guessAndParse(tmpDate as String);	
			}
			
			dateControl.selectedDate = dateObject;
			dateControl.enabled = !readonly;
			dateControl.parseFunction = null;
			dateControl.labelFunction = function(item:Date):String{
				var dformater:DateFormatter = new DateFormatter();
				dformater.formatString = localeFormat2;
				return dformater.format(item);
			}
			var clearDateBtn:LinkButton = new LinkButton();
			clearDateBtn.enabled = !readonly;  //Bug 1710 CRO
			clearDateBtn.setStyle("icon",ImageUtils.deleteIcon);
			clearDateBtn.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void {
				dateControl.text = "";
				item[element_name] = "";
			});
			//Bug #6302
			if(create && item["Activity"] == "Appointment" && element_name == "DueDate"){
				dateControl.selectedDate = null;
				dateControl.text = "";
				item[element_name] = "";
			}
			
			(childObj as HBox).addChild(dateControl);
			if(!small) (childObj as HBox).addChild(clearDateBtn);
			
			return childObj;
		}
		
		public static function drawPieChat(target:String, actual:String):HTML{
			var html:HTML = new HTML();
			html.height = 200;
			html.percentWidth = 100;
			var file:File = Utils.writeStringFile( DateUtils.format(new Date(), DateUtils.DATABASE_DATETIME_FORMAT) + '.html',  generateHTMLComponent( target, actual ));
			if(file!=null) html.location = file.url;
			html.cachePolicy = "on";
			html.validateNow();
			return html;
		}
		
		public static function generateHTMLComponent(target:String, actual:String):String{
			var html:String = '<html>' + 
				  '<head>' +
				  '<script type="text/javascript" src="https://www.google.com/jsapi"></script>' +
				  '<script type="text/javascript">' +
				/*
					'var gaugeData = new google.visualization.DataTable();' +
					'gaugeData.addColumn("number", "Target");' +
					'gaugeData.addColumn("number", "Actual");' +
					'gaugeData.addRows(2);' +
					'gaugeData.setCell(0, 0, '+ target + ');' +
					'gaugeData.setCell(0, 1, '+ actual +');' +
					'var gaugeOptions = {min: 0, max: 100, yellowFrom: 60, yellowTo: 90,' +
						    'redFrom: 91, redTo: 100, minorTicks: 5};' +
					'var gauge;' +
					'function drawGauge() {'+
						  'gauge = new google.visualization.Gauge(document.getElementById("chart_div"));'+
						  'gauge.draw(gaugeData, gaugeOptions);' +
					'}' +
				*/
				
				  'google.load("visualization", "1", {packages:["gauge"]});' +
				  'google.setOnLoadCallback(drawChart); ' +
			      'function drawChart() {' +
				      'var data = google.visualization.arrayToDataTable([' +
					  '["Label", "Value"],' +
					  '["Target", ' + target + '],' +
					  '["Actual", ' + actual + ']' +
			      ']);' +
			      'var options = {' +
					  'width: 200, height: 120,' +
				      'redFrom: 0, redTo: 90,' +
			    	  'yellowFrom:91, yellowTo: 100,' +
				  	  'greenFrom:101, greenTo: 200,'+
				 	  'max: 200,' +
				      'minorTicks: 5' +
			      '};' +
			      'var chart = new google.visualization.Gauge(document.getElementById("chart_div"));' +
			      'chart.draw(data, options);' + 
			      '}' + 
			    '</script>' +
			  '</head>' +
			  '<body>' +
			    '<div id="chart_div"></div>' +
			  '</body>' +
			'</html>';
			
			return html;
		}
		
		private static function handleCascadingCombo(combo:Object, inputFields:ArrayCollection,allDependencies:ArrayCollection):void {
			// find all depending combos
			var ent:String = DAOUtils.getRecordType(combo.formField.entity);
			// var allDependencies:ArrayCollection = new ArrayCollection(Database.cascadingPicklistDAO.fetch({entity:ent});
			//var allDependencies:ArrayCollection = Database.cascadingPicklistDAO.selectAll(ent);
			//var list:ArrayCollection = Database.customFieldDao.getBindCascadingPicklist(ent);
			//allDependencies.addAll(list);
			var dependencies:Array = [];
			var dependency:Object;
			for each (dependency in allDependencies) {
				if (match(ent, dependency.parent_picklist, combo.formField.element_name)) {
					dependencies = dependencies.concat(dependency);
				}
			}
			var childCombos:Array = [];
			for each (dependency in dependencies) {
				var depCode:String = dependency.entity + "/" + dependency.child_picklist;
				if (childCombos.indexOf(depCode) == -1) {
					childCombos = childCombos.concat(depCode);
				}
			}
			// search depending combos and set their values
			for each (var inputFieldObj:Object in inputFields) {
				if (inputFieldObj.component is ComboBox) {
					for each (var childCombo:String in childCombos) {
						var tmp:Array = childCombo.split("/");
						var ent2:String = DAOUtils.getRecordType(inputFieldObj.formField.entity);
						if (tmp[0] == ent2 && match(ent2, inputFieldObj.formField.element_name, tmp[1])) {
							// we've found a depending combo, let's set its values
							var picklist:ArrayCollection = new ArrayCollection();
							var picklistCode:ArrayCollection = new ArrayCollection();
							picklist.addItem({data:'',label:'', Order_:"0"});
							var allValues_:ArrayCollection = PicklistService.getBindPicklist(ent2, tmp[1],false);
							var comboLabel:String = (combo.component as ComboBox).selectedItem.label;
							var comboData:String = (combo.component as ComboBox).selectedItem.data;
							
							var allValues:ArrayCollection = new ArrayCollection();
							for each(var child:Object in allValues_){
								if(StringUtils.isEmpty(child.parent) || child.parent==comboData){
									allValues.addItem(child);
								}
							}
							
							if(StringUtils.isEmpty(comboLabel)){
								// picklist = new ArrayCollection(allValues.source);
								for each(var obj:Object in allValues){
									picklist.addItem(Utils.createNewObject(["data","label","parent", "Order_"],[obj.data,obj.label,obj.parent, obj.Order_ ? obj.Order_ : "9999"]));
								}
							}else{
								for each (dependency in dependencies) {
									if (dependency.entity == ent2 && dependency.child_picklist == tmp[1]){
										// if(dependency.parent_value == (combo.component as ComboBox).selectedItem.label) {
										if(dependency.parent_code == comboData) {
											// var strC:String = Utils.checkNullValue(dependency.child_value).split("=")[0];
											var strC:String = StringUtils.replaceAll(Utils.checkNullValue(dependency.child_code),"=","/");
											
											for each (var value:Object in allValues) {
												// if (value.label == strC) {
												var strP:String = StringUtils.replaceAll(Utils.checkNullValue(value.data),"=","/");
												//trace("strP == strC : " + strP + " == " + strC);
												if (strP == strC && !picklistCode.contains(strP)) {
													picklistCode.addItem(strP);
													picklist.addItem(Utils.createNewObject(["data","label","parent", "Order_"],[value.data,value.label,value.parent, value.Order_ ? value.Order_ : "9999"]));
												}
											}
										}
									}
								}
							}
							
							// CustomFieldDAO.checkBindPicklist(picklist);
							picklist = CustomFieldDAO.checkBindPicklist(ent2, tmp[1], picklist);
							
							// SCH : 6449
							sortPickList(picklist);
							
							
							//var previousItem:String = (inputFieldObj.component as ComboBox).selectedItem.label;
							var previousItem:String = (inputFieldObj.component as ComboBox).selectedItem.data;
							(inputFieldObj.component as ComboBox).dataProvider = picklist;
							if (picklist.length == 2) {
								(inputFieldObj.component as ComboBox).selectedItem = picklist[1];
							} else {
								for (var i1:int = 0; i1 < picklist.length; i1++) {
									// if (picklist[i1].label == previousItem) {
									if (picklist[i1].data == previousItem) {
										(inputFieldObj.component as ComboBox).selectedItem = picklist[i1];
										break;
									}
								}
							}
							//(inputFieldObj.component as ComboBox).visible = picklist.length > 1;
							
							handleCascadingCombo(inputFieldObj, inputFields,allDependencies);
						}		
					}
				}
			}
		}	
		
		private static function sortPickList(arr:ArrayCollection):void{
			var s:Sort = new Sort();
			var sf:SortField = new SortField("Order_");
			sf.numeric = true;
			s.fields=[sf];
			arr.sort = s;
			arr.refresh();
		}
	}
}
