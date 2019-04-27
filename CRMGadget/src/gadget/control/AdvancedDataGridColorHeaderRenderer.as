package gadget.control
{
	import flash.display.DisplayObject;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderRenderer;
	
	public class AdvancedDataGridColorHeaderRenderer extends AdvancedDataGridHeaderRenderer
	{
		
		private var _bgColor:uint=0x40E0D0;//default color
		
		public function AdvancedDataGridColorHeaderRenderer()
		{
			super();
			//setStyle("backgroundColor","#40E0D0");
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			// Set background size, position, color
			if (background && !isNaN(bgColor))
			{
				background.graphics.clear();
				background.graphics.beginFill(bgColor, bgColor); // transparent
				background.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				background.graphics.endFill();
				setChildIndex( DisplayObject(background), 0 );
			}
		}

		public function get bgColor():uint
		{
			return _bgColor;
		}

		public function set bgColor(value:uint):void
		{
			_bgColor = value;
		}
		
		
	}
}