package gadget.control
{
	import flash.display.Graphics;
	
	import mx.skins.ProgrammaticSkin;
	
	public class ToolTipSkin extends ProgrammaticSkin {
		
		private const SHADOW_DIST:int = 3;
		private const TRIANGLE_SIZE:int = 10;
		
		public function ToolTipSkin(){
			
		}
		override protected function updateDisplayList(w:Number, h:Number):void {
			
			graphics.clear();
			 
			// we draw the shadow
			graphics.lineStyle(NaN);
			graphics.beginFill(0, 0.2);
			graphics.drawRoundRect(SHADOW_DIST, SHADOW_DIST, w, h, 8, 8);
			graphics.endFill();			
			
			var bgColor:Number = getStyle("backgroundColor");
			graphics.beginFill(bgColor);
			graphics.drawRoundRect(0, 0, w, h, 8, 8);
			graphics.endFill();
			
			graphics.beginFill(bgColor);
			graphics.moveTo(20, 0);
			graphics.lineTo(20 + TRIANGLE_SIZE/2, -TRIANGLE_SIZE);
			graphics.lineTo(20 + TRIANGLE_SIZE, 0);
			graphics.moveTo(20, 0);
			graphics.endFill();
		}
	}
}