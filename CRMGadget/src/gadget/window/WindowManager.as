package gadget.window {
	import flash.display.Screen;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.lists.List;
	
	import mx.collections.ArrayCollection;
	import mx.core.IWindow;
	import mx.core.LayoutContainer;
	import mx.core.Window;
	import mx.managers.PopUpManager;
	

	
	public class WindowManager {

		private static var windows:ArrayCollection = new ArrayCollection();
	  
		public static function init(main:IWindow):void {
		
			openModal(main);	
		}
		
		public static function getTopWindow():IWindow {
			if (windows.length == 0) {
				return null;
			}
			return windows[windows.length - 1];
		}
		
		private static function enterHandler(event:Event):void {
			if (getTopWindow() != null) {
				getTopWindow().nativeWindow.orderToFront();
			}
		}
		
		private static function activateHandler(event:Event):void {
			if (getTopWindow() != null && event.target != getTopWindow()) {
				getTopWindow().nativeWindow.orderToFront();
			}
		}

		
		public static function openModal(window:IWindow):void {
			var topWindow:IWindow = getTopWindow();
			if (topWindow ) { //CRO #1193
				(topWindow as LayoutContainer).enabled = false;
				//CRO #1379
				if(Database.preferencesDao.getBooleanValue(PreferencesDAO.ENABLE_FUZZY))
					(topWindow as LayoutContainer).filters = [new BlurFilter(4, 4, 2)];
			}			
			 windows.addItem(window);
			(window as LayoutContainer).addEventListener(Event.CLOSE, closeHandler);
			(window as LayoutContainer).addEventListener(Event.ACTIVATE, activateHandler);
			(window as LayoutContainer).addEventListener(Event.ENTER_FRAME, activateHandler);
			if (window is Window) {
				(window as Window).open();
			}
			
			centerWindow(window);
		}
		public static function openPopup(window:IWindow):void {
			var topWindow:IWindow = getTopWindow();
			if (topWindow ) { 
				(topWindow as LayoutContainer).enabled = false;
			
				if(Database.preferencesDao.getBooleanValue(PreferencesDAO.ENABLE_FUZZY))
					(topWindow as LayoutContainer).filters = [new BlurFilter(4, 4, 2)];
			}			
			windows.addItem(window);
			(window as LayoutContainer).addEventListener(Event.CLOSE, closeHandler);
			(window as LayoutContainer).addEventListener(Event.ACTIVATE, activateHandler);
			(window as LayoutContainer).addEventListener(Event.ENTER_FRAME, activateHandler);
			if (window is Window) {
				(window as Window).open();
			}
			
			
		}
		private static function closeHandler(event:Event):void {
			var start:int;
			for (var i:int = 0; i < windows.length; i++) {
				if (windows[i] == event.target) {
					start = i;
					break;
				}
			}
			if (start+1 < windows.length) {
				windows[start+1].close();
			}
			windows.removeItemAt(start);
			if (start > 0) {
				if (start == 1) {
					((windows[start - 1] as MainWindow).navigator.selectedChild as List).list.setFocus();					
				}
				try{
					windows[start - 1].activate();
					windows[start - 1].enabled = true;
					windows[start - 1].filters = [];
				}catch(e:Error){
					//null pointer excepiont ( 
					//TypeError: Error #1009: Cannot access a property or method of a null object reference.
					//	at mx.core::Window/activate()[E:\dev\4.x\frameworks\projects\airframework\src\mx\core\Window.as:2947]
					//		at gadget.window::WindowManager$/closeHandler()[D:\Adobe Flash Builder 41\CRMGadget_general\src\gadget\window\WindowManager.as:99]
				}
			} else {
				try	{
					Database.cleanup();
				}catch(e:Error){
					//nothing to do
				}
			}

		}
		
		private static function centerWindow(window:IWindow):void {
			window.nativeWindow.x = (Screen.mainScreen.bounds.width - window.nativeWindow.width) / 2;
			window.nativeWindow.y = (Screen.mainScreen.bounds.height - window.nativeWindow.height) / 2;			
		}

	}
}
