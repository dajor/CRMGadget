package gadget.control{
	
	import gadget.sync.LogEvent;
	
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridListData;
	
	public class SynLoggingColorRenderer extends Label {
		
		private const COLOR_ERROR:Object = 0xDD0000;
		private const COLOR_WARNING:Object = 0xDD8800;
		private const COLOR_SUCCESS:Object = 0x008000;
		private const COLOR_NORMAL:Object = 0x000000;
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			switch(data.type)
			{
				case LogEvent.ERROR: setStyle("color", COLOR_ERROR); break;
				case LogEvent.WARNING: setStyle("color", COLOR_WARNING); break;
				case LogEvent.SUCCESS: setStyle("color", COLOR_SUCCESS); break;
				default: setStyle("color", COLOR_NORMAL);
			}
			setStyle("fontSize", 10);
		}
	}
	
}