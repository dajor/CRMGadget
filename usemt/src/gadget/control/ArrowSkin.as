package gadget.control
{
	import flash.display.Graphics;
	
	import mx.skins.ProgrammaticSkin;
	
	public class ArrowSkin extends ProgrammaticSkin{
		private const SHADOW_DIST:int = 3;
		
		public function ArrowSkin(){
			
		}
		override protected function updateDisplayList(w:Number, h:Number):void {
			graphics.clear();
			var bgColor:Number = getStyle("backgroundColor");
			h -= (h % 2)
			var stepHeight:int = h / 2;

			// we draw the shadow
			graphics.lineStyle(NaN);
			graphics.beginFill(0, 0.2);
			graphics.moveTo(SHADOW_DIST, SHADOW_DIST);
			graphics.lineTo(SHADOW_DIST + stepHeight/2, SHADOW_DIST + stepHeight);
			graphics.lineTo(SHADOW_DIST, SHADOW_DIST + (stepHeight * 2));
			graphics.lineTo(SHADOW_DIST + w, SHADOW_DIST + (stepHeight * 2));
			graphics.lineTo(SHADOW_DIST + w + stepHeight/2, SHADOW_DIST + stepHeight);
			graphics.lineTo(SHADOW_DIST + w, SHADOW_DIST);
			graphics.lineTo(SHADOW_DIST, SHADOW_DIST);
			graphics.endFill();

			
			// we draw the arrow (up)
			graphics.lineStyle(NaN);
			graphics.beginFill(bgColor);
			graphics.moveTo(0, 0);
			graphics.lineTo(stepHeight/2, stepHeight);
			graphics.lineTo(w + stepHeight/2, stepHeight);
			graphics.lineTo(w, 0);
			graphics.lineTo(0, 0);
			graphics.endFill();
			
			// we draw the arrow (Down)
			var red:int = (bgColor & 0xff) * .9;
			var green:int = ((bgColor >> 8) & 0xff) * .9;
			var blue:int = ((bgColor >> 16) & 0xff) * .9;
 			var bgColor2:Number = red | green << 8 | blue << 16;
			graphics.lineStyle(NaN);
			graphics.beginFill(bgColor2);
			graphics.moveTo(stepHeight/2, stepHeight);
			graphics.lineTo(0, (stepHeight * 2));
			graphics.lineTo(w, (stepHeight * 2));
			graphics.lineTo(w + stepHeight/2, stepHeight);
			graphics.lineTo(stepHeight/2, stepHeight);
			graphics.endFill(); 
		}
	}
}