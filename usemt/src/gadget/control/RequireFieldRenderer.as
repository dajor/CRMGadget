package gadget.control{
	import mx.controls.Label;
	    
	public class RequireFieldRenderer extends Label	{
		private const BLACK_COLOR:uint = 0x000000; // Black
        private const RED_COLOR:uint = 0xFF0000; // Red
        
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			setStyle("color", (data.required) ? RED_COLOR : BLACK_COLOR);
		}
	}
}