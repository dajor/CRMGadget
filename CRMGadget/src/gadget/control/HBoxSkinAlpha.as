package gadget.control
{
	import flash.display.Graphics;
	
	import mx.skins.ProgrammaticSkin;
	
	public class HBoxSkinAlpha extends ProgrammaticSkin{
		public function HBoxSkinAlpha(){
			
		}
		override protected function updateDisplayList(w:Number, h:Number):void {
			var g:Graphics = graphics;
			g.clear();
			drawArrow(g, 0, w, h, getStyle("backgroundColor"));
		}
		private function drawArrow(g:Graphics, startPoint:int, w:int, h:int, bgColor:Number):void{
			h = h - (h % 2)
			var stepHeight:int = h / 2;
			var shadowDist:int = 3;

			g.beginFill(bgColor,0.5);
			g.drawRect(0,0,w,h);
			g.endFill();

		}
	}
}