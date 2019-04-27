package gadget.control
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import spark.components.HScrollBar;
	import spark.components.List;
	
	/**
	 * This list is used in AutoCompleteSkin.
	 * keyDownHandler is overridden so that the list can handle keyboard events for navigation.  
	 */	
	public class ListAutoCompleteAddress extends List
	{
		
		override protected function keyDownHandler(event:KeyboardEvent):void {
			
			super.keyDownHandler(event);
			
			if (!dataProvider || !layout || event.isDefaultPrevented())
				return;
			
			adjustSelectionAndCaretUponNavigation(event); 
			
		}
	}
}