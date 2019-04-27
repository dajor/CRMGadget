package gadget.util {
	
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import gadget.control.AccountListImageRenderer;
	import gadget.control.ContactListImageRenderer;
	import gadget.dao.ActivityUserDAO;
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.ITeam;
	import gadget.dao.PreferencesDAO;
	import gadget.i18n.i18n;
	import gadget.service.PicklistService;
	import gadget.service.RightService;
	import gadget.window.WindowManager;
	
	import ilog.calendar.Calendar;
	import ilog.calendar.CalendarItemRendererBase;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.List;
	import mx.controls.Menu;
	import mx.controls.TileList;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridItemRenderer;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.SpriteAsset;
	import mx.core.UITextField;
	import mx.events.MenuEvent;
	
	public class MenuUtils {
		
		private static var objMenu:ArrayCollection = new ArrayCollection();
		private static var TYPE:String = 'TYPE';
		private static var PRIORITY:String = 'PRIORITY';
		private static var PARENT_PRIORITY:String = 'PARENT_PRIORITY';
		private static var PARENT_TYPE:String = 'PARENT_TYPE';
		private static var picklist:ArrayCollection = null;
		private static var lstRecords:int =0;

		public static function getContextMenu(aboutRecord:Function,recordCount:Function,mainWindow:MainWindow, list:IListItemRenderer, openLinkTo:Function, deleteItem:Function, editDetail:Function, batchUpdate:Function, addLead:Function, addActivity:Function, openDaschboard:Function, exportDetailPDF:Function,addNote:Function, entity:String):void {
			
			var rootMenu:XML = <root />;
			var openMenu:XML = new XML('<menuitem data="' + i18n._('BROWSELOCALFILEDIALOG_DETAILBUTTONBAR_BUTTONLABEL_OPEN') + '" label="' + i18n._('BROWSELOCALFILEDIALOG_DETAILBUTTONBAR_BUTTONLABEL_OPEN') + '" icon="openIcon" />');
			var editMenu:XML = new XML('<menuitem data="' + i18n._('GLOBAL_EDIT') + '" label="' + i18n._('GLOBAL_EDIT') + '" icon="editIcon" />');
			var linkMenu:XML = new XML('<menuitem data="' + i18n._('GLOBAL_LINK') + '" label="' + i18n._('GLOBAL_LINK') + '" icon="linkIcon" />');
			var deleteMenu:XML = new XML('<menuitem data="' + i18n._('GLOBAL_DELETE') + '" label="' + i18n._('GLOBAL_DELETE') + '" icon="deleteIcon" />');
			var addNoteMenu:XML = new XML('<menuitem data="' + i18n._('GLOBAL_ADD_NOTE') + '" label="' + i18n._('GLOBAL_ADD_NOTE') + '" icon="addIcon" />');
			var addLeadMenu:XML = new XML('<menuitem data="' + i18n._('GLOBAL_ADD_LEADS') + '" label="' + i18n._('GLOBAL_ADD_LEADS') + '" icon="addIcon" />');			
			var dashboard:XML = new XML('<menuitem data="' + i18n._('GLOBAL_DASHBOARD') + '" label="' + i18n._('GLOBAL_DASHBOARD') + '" icon="netbreezeSmallIcon" />');
			// CH 24-July-2013
			//var dashboardReport:XML = new XML('<menuitem data="' + i18n._('GLOBAL_DASHBOARDREPORT') + '" label="' + i18n._('GLOBAL_DASHBOARDREPORT') + '" icon="netbreezeSmallIcon" />');
			var printPDF:XML = new XML('<menuitem data="' + i18n._('GLOBAL_PRINT') + '" label="' + i18n._('GLOBAL_PRINT') + '" icon="printerIcon" />');	
			
			var copyAccountAddressToClipboard:XML = new XML('<menuitem data="' + i18n._('GLOBAL_COPY_ADDRESS') + '" label="' + i18n._('GLOBAL_COPY_ADDRESS') + '" icon="clipboardIcon" />'); // #257
			//Bug fixing 368 CRO
			var recCound:XML = new XML('<menuitem data="' + i18n._('GLOBAL_RECORD_COUNT') + '" label="' + i18n._('GLOBAL_RECORD_COUNT') + '" icon="clipboardIcon" />'); 
			var aboutRec:XML = new XML('<menuitem data="' + i18n._('GLOBAL_ABOUT_RECORD') + '" label="' + i18n._('GLOBAL_ABOUT_RECORD') + '" icon="infoIcon" />'); 
			var addActivityMenu:XML = new XML('<menuitem data="' + i18n._('GLOBAL_ADD') + '" label="' + i18n._('GLOBAL_ADD') + '" icon="addIcon">'+
				'<menuitem data="' + i18n._('GLOBAL_NEW_TASK') + '" label="' + i18n._('GLOBAL_NEW_TASK') + '" icon="activityIcon" />'+
				'<menuitem data="' + i18n._('GLOBAL_NEW_APPOINTMENT') + '" label="' + i18n._('GLOBAL_NEW_APPOINTMENT') + '" icon="activityAppointmentIcon" />'+ 
				'<menuitem data="' + i18n._('GLOBAL_NEW_CALL') + '" label="' + i18n._('GLOBAL_NEW_CALL') + '" icon="activityCallIcon" />'+
				'</menuitem>');
			// #252
			var sendContactEmailMenu:XML = new XML('<menuitem data="' + i18n._('GLOBAL_SEND_EMAIL') + '" label="' + i18n._('GLOBAL_SEND_EMAIL') + '" icon="emailIcon">'+
				'<menuitem data="' + i18n._('GLOBAL_WITHOUT_TEMPLATE') + '" label="' + i18n._('GLOBAL_WITHOUT_TEMPLATE') + '" icon="" />'+
				'<menuitem data="' + i18n._('GLOBAL_ALL_TEMPLATE') + '" label="' + i18n._('GLOBAL_ALL_TEMPLATE') + '" icon="" enabled="false" />'+ 
				'<menuitem data="' + i18n._('GLOBAL_SALES') + '" label="' + i18n._('GLOBAL_SALES') + '" icon="" enabled="false" />'+
				'<menuitem data="' + i18n._('GLOBAL_MARKETING') + '" label="' + i18n._('GLOBAL_MARKETING') + '" icon="" enabled="false" />'+
				'</menuitem>');
//			var batchUpdateMenu:XML = <menuitem label="Batch Update" icon="editIcon" />
				
			var canUpdate:Boolean = RightService.canUpdate(entity);
			editMenu.@enabled = canUpdate;
			linkMenu.@enabled = canUpdate;
//			batchUpdateMenu.@enabled = canUpdate;
				
			var canDelete:Boolean = RightService.canCreate(entity);
			deleteMenu.@enabled = canDelete;	
			
			
			if(canUpdate){
				rootMenu.appendChild(editMenu);
			}else{
				rootMenu.appendChild(openMenu);
			}
			
			if(!Database.preferencesDao.getBooleanValue(PreferencesDAO.DISABLE_PDF_EXPORT, 0)){
				rootMenu.appendChild(printPDF);
			}
//			rootMenu.appendChild(batchUpdateMenu);
			
			if (entity == "Activity"){
				//-----VM --- #224,225
				var subMenuPriority :String="";
				picklist = new ArrayCollection();
				picklist = PicklistService.getPicklist(entity, 'Priority');
				
				for each(var sub:Object in picklist){
					if(sub['label'] != null && sub['label'] !=""){
						subMenuPriority += '<menuitem data="'+ sub['data'] +'" label="'+ sub['label'] +'" dataType="PRIORITY" />';					
					}
				}
				picklist = new ArrayCollection();
				picklist = PicklistService.getPicklist(entity, 'Type');
				var subType:String ="";
				for each(var type:Object in picklist){
					if(type['label'] != null && type['label'] !=""){
						subType += '<menuitem data="'+ type['data'] +'" label="'+ type['label'] +'" dataType="TYPE"/>';					
					}
				}
				var changeType:XML = new XML ('<menuitem data="PARENT_TYPE" label="'+i18n._('MENUUTILS_MENU_ITEM_LABEL_CHANGE_TYPE')+'" icon="typeIcon" >'+
					subType +
					'</menuitem>');
				var  changePriority:XML = new XML ('<menuitem data="PARENT_PRIORITY" label="'+i18n._('MENUUTILS_MENU_ITEM_LABEL_CHANGE_PRIORITY')+'" icon="priorityIcon" >'+
					subMenuPriority +
					'</menuitem>');
				
				rootMenu.appendChild(changePriority);
				rootMenu.appendChild(changeType);
				
			}
			if (FieldUtils.linkableEntities(entity).length != 0) {
				rootMenu.appendChild(linkMenu);
			}
			rootMenu.appendChild(deleteMenu);
			if (entity == Database.campaignDao.entity){
				rootMenu.appendChild(addLeadMenu);
				rootMenu.appendChild(addNoteMenu);
			}
			if (entity == Database.contactDao.entity){
				addActivityMenu.appendChild(addNoteMenu);
				rootMenu.appendChild(addActivityMenu);				
				rootMenu.appendChild(sendContactEmailMenu);
				//rootMenu.appendChild(addNoteMenu);
			}
			if(entity == Database.accountDao.entity) {
				rootMenu.appendChild(copyAccountAddressToClipboard); // #257
				if(Database.preferencesDao.getValue("netbreeze_tab", 0) == 1) rootMenu.appendChild(dashboard);
				rootMenu.appendChild(addNoteMenu);
			}
			
			if(entity == Database.opportunityDao.entity){
				rootMenu.appendChild(addNoteMenu);	
			}
			
			if(entity == Database.serviceDao.entity){
				rootMenu.appendChild(addNoteMenu);
			}
			//bug fixing 368 CRO 17.02.2011
			//rootMenu.appendChild(recCound);
			rootMenu.appendChild(aboutRec);
			var obj:Object;
			var myMenu:Menu = Menu.createMenu(mainWindow, rootMenu, false);
			myMenu.iconField="@icon";
			myMenu.labelField="@label";
			
            myMenu.addEventListener(MenuEvent.ITEM_CLICK, function handleMenuItem(e:MenuEvent):void {
				var object:Object;
				if(obj == null) {
					myMenu.hide();
					Alert.show(i18n._('MENU_UTILS_ALERT_TEXT_PLEASE_SELECT_RECORD_BEFORE_EXECUTE_THIS_OPERATOR'), "", 4, mainWindow);
					return;
				}
				var parent:XML = e.item as XML;
				for each (var ch:XML in parent.parent){
					var d:String = ch.@data[0];
				}
				switch(e.item.@data[0].toString()){
					
					
					case i18n._('BROWSELOCALFILEDIALOG_DETAILBUTTONBAR_BUTTONLABEL_OPEN'):
						editDetail(obj); 
						break;
					case i18n._('GLOBAL_EDIT'):
						editDetail(obj); //openDetail(obj.data);
						break;
					//case "Link":
					case i18n._('GLOBAL_LINK'):
						openLinkTo(obj);
						break;
					//case "Delete":
					case i18n._('GLOBAL_DELETE'):
						deleteItem(obj);
						break;
					//case "Dashboard":
					case i18n._('GLOBAL_ADD_LEADS'):
						openDaschboard(obj);
						break;
					//case "Add Leads":
					case i18n._('GLOBAL_ADD_LEADS'):
						addLead(obj);
						break;
					//case "New Task":
					case i18n._('GLOBAL_NEW_TASK'):
						addActivity(getPrimaryContact(entity, obj)); // Bug #311
						break;
					//case "New Appointment":
					case i18n._('GLOBAL_NEW_APPOINTMENT'):
						addActivity(getPrimaryContact(entity, obj), 1); // Bug #311
						break;
					//case "New Call":
					case i18n._('GLOBAL_NEW_CALL'):
						addActivity(getPrimaryContact(entity, obj), 2); // Bug #311
						break;
					case i18n._('GLOBAL_ADD_NOTE'):
						addNote(obj);
						break;
					case i18n._('GLOBAL_COPY_ADDRESS'):
						// AccountName, PrimaryBillToStreetAddress, PrimaryBillToStreetAddress2, PrimaryBillToStreetAddress3, PrimaryBillToPostalCode, PrimaryBillToCity, PrimaryBillToCountry
						var accountAddress:String = obj.AccountName + '\n'
						+ (obj.PrimaryBillToStreetAddress ? obj.PrimaryBillToStreetAddress + '\n' : ' ')
						+ (obj.PrimaryBillToPostalCode ? obj.PrimaryBillToPostalCode + ' ' : '')
						+ (obj.PrimaryBillToCity ? obj.PrimaryBillToCity : '');
						// #257
						Utils.copyToClipboard(accountAddress, mainWindow);
						break;
					// #252
					case i18n._('GLOBAL_WITHOUT_TEMPLATE'):
						var email:String = obj.ContactEmail ? obj.ContactEmail : '';
						Utils.sendContactEmail(email, "", "");
						break;
					case i18n._('GLOBAL_ALL_TEMPLATE'):
						break;
					case i18n._('GLOBAL_SALES'):
						break;
					case i18n._('GLOBAL_MARKETING'):
						break;
					// #256
					case i18n._('GLOBAL_PRINT'):
						var item:Object = Database.getDao(entity).findByGadgetId(obj.gadget_id);
						exportDetailPDF(item);
						break;
					///-- VM --- #254,255//
					case isCaseInPicklist(e,TYPE) :
						if(obj == null){
							Alert.show(i18n._('LIST_ALERT_MSG_PLEASE_SELECT_THE') + " " + entity ,"" , Alert.OK,mainWindow);
							break;
						}
						object = Database.getDao(entity).findByGadgetId(obj["gadget_id"]);
						object.local_update = new Date().getTime();
						object.Type = e.label;
						object.ModifiedDate =DateUtils.format(new Date(), DateUtils.DATABASE_DATETIME_FORMAT);;
						Database.getDao(entity).update(object);
						mainWindow.selectList(entity).selectItem(object);
						break;
					case isCaseInPicklist(e,PRIORITY):
						if(obj == null){
							Alert.show(i18n._('LIST_ALERT_MSG_PLEASE_SELECT_THE') + " " + entity ,"" , Alert.OK,mainWindow);
							break;
						}
						object = Database.getDao(entity).findByGadgetId(obj["gadget_id"]);
						object.local_update = new Date().getTime();
						object.Priority = e.item.@data[0].toString();
						object.PriorityValue = e.label;
						object.ModifiedDate =DateUtils.format(new Date(), DateUtils.DATABASE_DATETIME_FORMAT);
						Database.getDao(entity).update(object);
						mainWindow.selectList(entity).selectItem(object);
							
						break;
					case i18n._('GLOBAL_RECORD_COUNT'):
						 recordCount();
						 break;
					case i18n._('GLOBAL_ABOUT_RECORD'):
						aboutRecord();
						break;
//					case "Batch Update":
//						batchUpdate();
//						break;
				}
			});			
			list.addEventListener(MouseEvent.RIGHT_CLICK, 
				function showMenu(e:MouseEvent):void{
					myMenu.hide();
					myMenu.show(e.stageX, e.stageY);
					if (e.target is SpriteAsset) {
						// do nothing
					} else if (e.target is AdvancedDataGridItemRenderer) {
						obj = e.target.data;
					} else if (e.target.document is AccountListImageRenderer || e.target.document is ContactListImageRenderer) {
						obj = e.target.document.document.data; 
					} else if (e.currentTarget is TileList) {
						var selectedItem:Object = e.target.document.data;
						if(selectedItem == null && selectedItem.data == null) return;
						obj = selectedItem.data;
					} else {
						var d:AdvancedDataGrid = e.currentTarget as AdvancedDataGrid;
						obj = d.selectedItem;
					}
					disabledContextMenu(myMenu, entity, obj);
				}
			);
		}
		
		private static function isCaseInPicklist(e:MenuEvent,type:String):String{
			//Bug #255
			if(e.item.@dataType[0] != null){
				
				if(e.item.@dataType[0].toString() == type){
					return e.item.@data[0].toString();
				}
			}
			
			return "";
		}
		
		// Bug #311
		// Add PrimaryContact into Activity from Contact context menu 
		private static function getPrimaryContact(entity:String, obj:Object):Object {
			var contact:Object = Database.getDao(entity).findByGadgetId(obj.gadget_id);
			obj["PrimaryContactId"] = contact.ContactId;
			obj["PrimaryContact"] = contact.ContactFullName;
			return obj;
		}		
		
		private static function disabledContextMenu(myMenu:Menu,entity:String,obj:Object):void{
			
			var menu:XMLListCollection = myMenu.dataProvider as XMLListCollection;
			if(obj!=null){
				obj=Database.getDao(entity).findByGadgetId(obj.gadget_id);
			}
			
			for each(var menuItem:XML in menu){
				if(entity == "Activity"){
					for each(var sub:XML in menuItem.children()){
						sub.@enabled=true;
						if(menuItem.@data == PARENT_PRIORITY && obj != null && obj['Priority']==sub.@data){
							sub.@enabled=false;	
						}else if(menuItem.@data == PARENT_TYPE && obj != null && obj['Type']==sub.@data ){
							sub.@enabled=false;
							
						}
					}
				}				
				if(obj != null){
					var oidName:String = DAOUtils.getOracleId(entity);
					
					var currentUser:Object = Database.userDao.read();
					
					var oracleId:String = obj[oidName];
					var isOwner:Boolean = (oracleId!=null && oracleId.indexOf("#")!=-1)||currentUser.id==obj.OwnerId;
					
					if(menuItem.@data==i18n._('GLOBAL_EDIT')){						
						menuItem.@enabled = RightService.canUpdate(entity,isOwner);
					}
					if (menuItem.@data==i18n._('GLOBAL_DELETE')){						
						menuItem.@enabled = RightService.canDelete(entity,isOwner);
					}
					if(menuItem.@data==i18n._('GLOBAL_LINK')){						
						menuItem.@enabled = RightService.canUpdate(entity,isOwner);;
					}
				}
				
			}
		}
		
		public static function getContextMenuFilter(bookmarkFilter:Function, editFilter:Function, deleteFilter:Function, makeDefault:Function):ContextMenu {
			var customContextMenu:ContextMenu = new ContextMenu();
			customContextMenu.hideBuiltInItems();
			//CRO 05.01.2011
			var menuItem:ContextMenuItem = new ContextMenuItem(i18n._('GLOBAL_BOOKMARK'));
			menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,  
				function bookmarkFilterHandler(evt:ContextMenuEvent):void {
					var obj:Object = getObjectUITextField(evt);
					bookmarkFilter(obj);
				}
			);
			customContextMenu.customItems.push(menuItem);
			
			menuItem = new ContextMenuItem(i18n._('MENU_UTILS_CONTEXT_MENU_ITEM_MAKE_DEFAULT'));
			menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, 
				function makeDefaultHandler(evt:ContextMenuEvent):void{
					var obj:Object = getObjectUITextField(evt);
					makeDefault(obj);
				}
			);
			customContextMenu.customItems.push(menuItem);
			
			menuItem = new ContextMenuItem(i18n._('GLOBAL_EDIT'));
			menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, 
				function editFilterHandler(evt:ContextMenuEvent):void {
					var obj:Object = getObjectUITextField(evt);
					editFilter(obj);
				}
			);
			customContextMenu.customItems.push(menuItem);
			
			menuItem = new ContextMenuItem(i18n._('GLOBAL_DELETE'));
			menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,  
				function deleteFilterHandler(evt:ContextMenuEvent):void {
					var obj:Object = getObjectUITextField(evt);
					deleteFilter(obj);
				}
			);
			customContextMenu.customItems.push(menuItem);
			
			return customContextMenu;			
		}
		
		private static  function getObjectUITextField(evt:ContextMenuEvent):Object{
			var obj:Object = null;
			if((evt.mouseTarget.parent as Object) != null && (evt.mouseTarget.parent as Object).hasOwnProperty('data')){
				obj =(evt.mouseTarget.parent as Object).data;
			}
			if(evt.mouseTarget is UITextField){
				obj = (evt.mouseTarget as UITextField).document.data;
			}			
			return obj;
		}
		
		public static function getContextMenuDetailLayout(list:List,removeField:Function, updateProperty:Function):void {
			var rootMenu:XML = <root />;
			var removeMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_REMOVE')+'" icon="editIcon"/>');
			var readOnlyMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_READ_ONLY')+'" type="check" toggled="false"/>');
			var mandatoryMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_MANDATORY')+'" type="check" toggled="false"/>');	
			var maxCharMenu:XML = new XML('<menuitem label="'+i18n._('MENU_UTILS_MAXIMUME_FIELD_LENGTH')+'" type="inputText" toggled="false" enabled = "false"/>');	
			rootMenu.appendChild(removeMenu);
			rootMenu.appendChild(readOnlyMenu);
			rootMenu.appendChild(mandatoryMenu);
			rootMenu.appendChild(maxCharMenu);
			
			var obj:Object;
			var target:Object;
			var myMenu:Menu = Menu.createMenu(list, rootMenu, false);
			objMenu.addItem(myMenu);
			myMenu.iconField="@icon";
			myMenu.labelField="@label";
			
			myMenu.addEventListener(MenuEvent.ITEM_CLICK, function handleMenuItem(e:MenuEvent):void {
				switch(e.label){
					case i18n._('GLOBAL_REMOVE'):
						removeField(list, obj);
						break;
					case i18n._('GLOBAL_READ_ONLY'):
						if(obj){
							obj.readonly = !obj.readonly;
							obj.mandatory = false;
							updateProperty(list, target, obj);
						}
						break;
					case i18n._('GLOBAL_MANDATORY'):
						if(obj){
							obj.readonly = false;
							obj.mandatory = !obj.mandatory;
							updateProperty(list, target, obj);
						}
						break;
					case i18n._('MENU_UTILS_MAXIMUME_FIELD_LENGTH'):
						var maxChars:MaxChars = new MaxChars();
						maxChars.obj = obj;
						WindowManager.openModal(maxChars);
						break;
				}
			});
			
			list.addEventListener(MouseEvent.RIGHT_CLICK, 
				function showMenu(e:MouseEvent):void{
					if (e.target is SpriteAsset) {
						return;
					}					
					if(e.target.document.document.data){
						obj = e.target.document.document.data;
						var isMandatory:Boolean = FieldUtils.getDefaultMandatory(obj.entity, obj.column_name);
						readOnlyMenu.@toggled = obj.readonly;
						// mandatoryMenu.@toggled = obj.mandatory;
						mandatoryMenu.@toggled = isMandatory ? true : obj.mandatory;
						mandatoryMenu.@enabled = isMandatory ? false : true; // disallow user click able when it default mandatory field
						for each(var oMenu:Menu in objMenu) {
							oMenu.hide();
						}
						//myMenu.hide();
						myMenu.show(e.stageX, e.stageY);
						target = e.target;
						
						//VM --
						// 1 = text input
						if(FieldUtils.getIndexFieldItemRenderer(obj)==1){
							maxCharMenu.@enabled = true;
						}else if(obj.column_name.indexOf(CustomLayout.BLOCK_DYNAMIC_CODE)>-1){
							maxCharMenu.@enabled = false;
							mandatoryMenu.@enabled = false;
							
						}else{
							maxCharMenu.@enabled = false;
						}
					}
				}
			);
			
		}
		
		
		
		public static function getContextMenuCalendar(calendar:TileList, addActivity:Function, openDetail:Function, deleteItem:Function):void {
			var myMenu:Menu;
			calendar.addEventListener(MouseEvent.RIGHT_CLICK, 
				function showMenu(e:MouseEvent):void{
					if(myMenu != null) myMenu.hide();
					if (e.target is SpriteAsset) {
						// do nothing
					}else{
						var obj:Object;
						var rootMenu:XML = new XML('<root>' +
												'<menuitem label="'+i18n._('GLOBAL_NEW_TASK')+'" icon="activityIcon"/>' +
												'<menuitem label="'+i18n._('GLOBAL_NEW_APPOINTMENT')+'" icon="activityAppointmentIcon"/>'+
											'</root>');
						var selectedItem:Object = e.target.document.data;
						if(selectedItem != null && selectedItem.col != 0){ //don't display the context menu when r-click on the time column	
							if(selectedItem.data != null){ //display the edite menu item when it has data
								var editMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_EDIT')+'" icon = "@Embed(\'/assets/edit.png\')" />');
								var deleteMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_DELETE')+'" icon = "@Embed(\'/assets/delete.png\')" />');

								rootMenu.appendChild(editMenu);
								rootMenu.appendChild(deleteMenu);
							}
							myMenu = Menu.createMenu(calendar, rootMenu, false);
							myMenu.iconField="@icon";
							myMenu.labelField="@label";							
							myMenu.addEventListener(MenuEvent.ITEM_CLICK, function handleMenuItem(e:MenuEvent):void {
								switch(e.label){
									//case "New Task":
									case i18n._('GLOBAL_NEW_TASK'):
										addActivity(obj);
										break;
									//case "New Appointment":
									case i18n._('GLOBAL_NEW_APPOINTMENT'):
										addActivity(obj,1);
										break;
									//case "Edit":
									case i18n._('GLOBAL_EDIT'):	
										openDetail(selectedItem.data);
										break;
									//case "Delete":
									case i18n._('GLOBAL_DELETE'):
										deleteItem(selectedItem.data);
										break;
								}
							});							
							myMenu.show(e.stageX, e.stageY);
							obj = selectedItem;
						}
					}
				}
			);
		}	
		
		/*
		*	createContextMenu(new ArrayCollection([
									{command:'New Task',icon:'newTask.png',action:newTask},
									{command:'New Appointment',icon:'newAppointment.png',action:newAppointment},
									{command:'Edit',icon:'edit.png',action:edit},
									])
							);
		*/

		public static function getContextMenuIBMCalendar(calendar:Calendar, addActivity:Function, openDetail:Function, deleteItem:Function):void {
			var myMenu:Menu;
			calendar.addEventListener(MouseEvent.RIGHT_CLICK, 
				function showMenu(e:MouseEvent):void{
					var selectedItem:Object;
					var dateSelection:Date;
					var timeRangeSelection:Array;

					if(myMenu != null) myMenu.hide();
					
					dateSelection = (e.currentTarget as Calendar).getTime(e.stageX,e.stageY,true);
					timeRangeSelection = (e.currentTarget as Calendar).timeRangeSelection;
					
					if(e.target is CalendarItemRendererBase){
						//trace(e.target.data.summary);
						selectedItem = e.target.data;
					}else if(e.target is UITextField){
						//trace(e.target.parent.parent.data.summary);
						selectedItem = e.target.parent.parent.data;
					}
					var canCreated:Boolean = RightService.canCreate(Database.activityDao.entity);
					
					var rootMenu:XML = new XML('<root>'+
											'<menuitem label="'+i18n._('GLOBAL_NEW_TASK')+'" icon="activityIcon"'+' enabled="'+canCreated+'"/>'+
											'<menuitem label="'+i18n._('GLOBAL_NEW_APPOINTMENT')+'" icon="activityAppointmentIcon"'+' enabled="'+canCreated+'"/>'+											
											'</root>');
					
					if(Database.preferencesDao.getBooleanValue(PreferencesDAO.ENABLE_BUTTON_ACTIVITY_CREATE_CALL)){
						var newCall:XML=new XML('<menuitem label="'+i18n._('GLOBAL_NEW_CALL')+'" icon="activityCallIcon"'+' enabled="'+canCreated+'"/>');
						rootMenu.appendChild(newCall);
					}
					if(selectedItem != null){
						var editMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_EDIT')+'" icon = "editIcon"'+' enabled="'+RightService.canUpdate(Database.activityDao.entity)+'" />');
						var deleteMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_DELETE')+'" icon = "deleteIcon"'+' enabled="'+RightService.canDelete(Database.activityDao.entity)+'" />');
						var copyMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_COPY')+'" icon = "copyIcon" />');
						rootMenu.appendChild(editMenu);
						rootMenu.appendChild(copyMenu);
						rootMenu.appendChild(deleteMenu);
						//should be used enable property
//						if(RightService.canDelete(Database.activityDao.entity)){ // CRO #5064
//							rootMenu.appendChild(deleteMenu);
//						}
					}
					
					myMenu = Menu.createMenu(calendar, rootMenu, false);
					myMenu.iconField="@icon";
					myMenu.labelField="@label";					

					myMenu.addEventListener(MenuEvent.ITEM_CLICK, function handleMenuItem(e:MenuEvent):void {
						switch(e.label){
							//case "New Task":
							case i18n._('GLOBAL_NEW_TASK'):
								addActivity(dateSelection,timeRangeSelection);
								break;
							//case "New Appointment":
							case i18n._('GLOBAL_NEW_APPOINTMENT'):
								addActivity(dateSelection,timeRangeSelection,1);
								break;
							//case "New Call":
							case i18n._('GLOBAL_NEW_CALL'):
								addActivity(dateSelection,timeRangeSelection,2);
								break;
							//case "Edit":
							case i18n._('GLOBAL_EDIT'):
								openDetail(selectedItem.data.data);
								break;
							//case "Copy":
							case i18n._('GLOBAL_COPY'):
								openDetail(selectedItem.data.data,true);
								break;
							//case "Delete":
							case i18n._('GLOBAL_DELETE'):
								deleteItem(selectedItem.data.data);
								break;
						}
					});	
					myMenu.show(e.stageX, e.stageY);
				}
			);
		}		
		
		public static function getContextMenuMiniRelationGrid(detail:Detail, grid:AdvancedDataGrid, handler:Function,entity:String):void{
			var canCreate:Boolean = RightService.canCreate(entity);
			var canDelete:Boolean = RightService.canDelete(entity);
			
			var rootMenu:XML = <root />;
			var addMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_ADD')+'" icon="addIcon" enabled="'+canCreate+'" />');
			var deleteMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_REMOVE')+'" icon="deleteIcon" />');
			rootMenu.appendChild(addMenu);
			rootMenu.appendChild(deleteMenu);
			var myMenu:Menu = Menu.createMenu(detail, rootMenu, false);
			myMenu.iconField="@icon";
			myMenu.labelField="@label";
			var selectedItem:Object = null;			
			myMenu.addEventListener(MenuEvent.ITEM_CLICK, function handleMenuItem(e:MenuEvent):void {
				handler(detail,grid, e.label, selectedItem);
			});
			grid.addEventListener(MouseEvent.RIGHT_CLICK, 
				function showMenu(e:MouseEvent):void{
					selectedItem = null;
					if (e.target is SpriteAsset) {
						return;
					}
					myMenu.hide();
					var dao:BaseDAO = Database.getDao(entity,false);
					if(dao is ITeam){						
						if(dao is ActivityUserDAO){
							deleteMenu.@enabled =(detail.item['OwnerId']!=grid.selectedItem['Id']);
						}else{
							deleteMenu.@enabled =(detail.item['OwnerId']!=grid.selectedItem['UserId']);
						}
						
					}else{
						deleteMenu.@enabled = true;
					}
					
					myMenu.show(e.stageX, e.stageY);
					if(e.target is DataGridItemRenderer){	
						selectedItem = e.target.data;
					}
				}
			);
		}
		
		public static function getContextMenuMiniDetail(detail:Detail, grid:AdvancedDataGrid, openDetail:Function, objectSQLQuery:Object,refreshGrid:Function,entity:String):void {
			
			// Feature #58 Diversey
			//var enabled:Boolean = GUIUtils.isEnableSR(detail);
			var canCreate:Boolean = RightService.canCreate(entity) ;
			var canUpdate:Boolean = RightService.canUpdate(entity) ;
			var canDelete:Boolean = RightService.canDelete(entity);
			var rootMenu:XML = <root />;
			var addMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_ADD')+'" icon="@Embed(\'/assets/accept.png\')" enabled="'+canCreate+'" />');
			var updateMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_UPDATE')+'" icon="@Embed(\'/assets/edit.png\')" enabled="'+canUpdate+'" />');
			var deleteMenu:XML = new XML('<menuitem label="'+i18n._('GLOBAL_DELETE')+'" icon="@Embed(\'/assets/delete.png\')" enabled="'+canDelete+'" />');
			rootMenu.appendChild(addMenu);
			rootMenu.appendChild(updateMenu);
			rootMenu.appendChild(deleteMenu);
			var myMenu:Menu = Menu.createMenu(detail, rootMenu, false);
			myMenu.iconField="@icon";
			myMenu.labelField="@label";
			
			myMenu.addEventListener(MenuEvent.ITEM_CLICK, function handleMenuItem(e:MenuEvent):void {
				// openDetail(grid, objectSQLQuery, e.label, detail.subtype, detail.refreshLinkList);
				openDetail(detail,grid, objectSQLQuery,e.label,refreshGrid);
			});	
			
			grid.addEventListener(MouseEvent.RIGHT_CLICK, 
				function showMenu(e:MouseEvent):void{
					if (e.target is SpriteAsset) {
						return;
					}
					myMenu.hide();
					myMenu.show(e.stageX, e.stageY);
					if(e.target is DataGridItemRenderer){	
						objectSQLQuery.target = e.target.data;
					}else{
						objectSQLQuery.target = null;
					}
				}
			);
			
			
//			grid.addEventListener(MouseEvent.RIGHT_CLICK, 
//				function showMenu(e:MouseEvent):void{
//					myMenu.hide();
//					myMenu.show(e.stageX, e.stageY);
//					if (e.target is SpriteAsset) {
//						// do nothing
//					} else if (e.target is DataGridColumn) {
//						obj = e.target.data;
//					} else {
//						var d:AdvancedDataGrid = e.currentTarget as AdvancedDataGrid;
//						obj = d.selectedItem;
//					}
//				}
//			);
		}
		
		
	}
}
