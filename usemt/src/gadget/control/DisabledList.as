package gadget.control	
{
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import mx.core.ClassFactory;
	import mx.controls.List;      
	import mx.controls.listClasses.IListItemRenderer; 
	import mx.controls.listClasses.ListItemRenderer;
	
	
	public class DisabledList extends List
		
	{
		
		public function DisabledList()
		{
			super();
			this.itemRenderer = new ClassFactory(DisabledListItemRenderer);
		}
		
		override protected function mouseOverHandler(event:MouseEvent):void
		{
			var item:IListItemRenderer = mouseEventToItemRenderer(event);
			
			if (itemDisable(event)) 
			{
				// Disable selection.
			} 
			else 
			{
				super.mouseOverHandler(event);
			}
		}
		
		override protected function mouseDownHandler(event:MouseEvent):void 
		{
			if (itemDisable(event)) 
			{
				// Disable click.
				return;
			} 
			else 
			{
				super.mouseDownHandler(event);
			}              
		}
		
		override protected function mouseUpHandler(event:MouseEvent):void 
		{
			if (itemDisable(event)) 
			{
				// Disable click.
				return;
			} 
			else 
			{
				super.mouseUpHandler(event);
			}         
		}
		
		override protected function mouseClickHandler(event:MouseEvent):void 
		{
			if (itemDisable(event)) {
				// Disable click.
				return;
			} 
			else 
			{
				super.mouseClickHandler(event);
			}
		}
		
		override protected function mouseDoubleClickHandler(event:MouseEvent):void 
		{
			if (itemDisable(event)) 
			{
				// Disable double click.
				event.preventDefault();
			} 
			else 
			{
				super.mouseDoubleClickHandler(event);
			}
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void 
		{
			event.stopPropagation();
			
			// Disable key down event.         
			//super.keyDownHandler(event);
		}                 
		
		private function itemDisable(event:MouseEvent):Boolean 
		{
			
			var item:IListItemRenderer = mouseEventToItemRenderer(event);
			
			if (item != null && item.data != null && ((item.data is XML && item.data.@enabled == 'false') || 
				item.data.enabled==false || item.data.enabled=='false')) 
			{
				return true;
			} 
			else 
			{
				return false;
			}
		}     
	}
}