package gadget.control
{
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.graphics.codec.PNGEncoder;
	
	public class DrawingArea extends UIComponent
	{
		private var isDrawing:Boolean = false;
		private var x1:int;
		private var y1:int;
		private var x2:int;
		private var y2:int;
		
		public var drawColor:uint = 0x000000;
		
		public function DrawingArea(){
			super();
			
			addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
				if (!isDrawing){
					graphics.lineStyle(2, drawColor);
					graphics.drawCircle(x1,y1,1);
					// graphics.drawCircle(x2,y2,1);
				}
			});
			
			addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void {
				erase();
			});
			
			addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
				x1 = mouseX;
				y1 = mouseY;
				isDrawing = true;
			});
			
			addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void {
				if (!event.buttonDown){
					isDrawing = false;
				}
				var size:int = 2;
				x2 = mouseX;
				y2 = mouseY;
				if (isDrawing){
					
					graphics.lineStyle(size, drawColor);
					//graphics.lineStyle(5, drawColor, 1, false, LineScaleMode.HORIZONTAL,
					//  CapsStyle.SQUARE, JointStyle.MITER, 100);					
					// graphics.lineGradientStyle("linear", [drawColor, drawColor],  [100, 100], [0x00, 0xFF], mxBox, "reflect", "linearRGB");
					
					graphics.moveTo(x1, y1);
					// graphics.lineTo(x2, y2);
					
					// graphics.curveTo(3 +x2, 0+y2, 3 +x2, 5+y2);
					// graphics.curveTo(3 +x2, 10+y2, 2.5 + x2, 10+y2);
					// graphics.curveTo(3 +x2, 5+y2, 2+x2, 5+y2);
					// graphics.curveTo(3 + x2, y2, 2.5+x2, y2);
					graphics.curveTo(x1, y1, x2, y2);					
					// graphics.lineTo(x2, y2);
					
					
					x1 = x2;
					y1 = y2;
				}
				
			});
			
			addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void {
				isDrawing = false;
			});
		}
		
		public function erase():void
		{
			graphics.clear();
			
			graphics.beginFill(0xffffff, 0.00001);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}
		
		/*public function save():void
		{
			var bd:BitmapData = new BitmapData(width, height);
			bd.draw(this);
			
			var ba:ByteArray = (new PNGEncoder()).encode(bd);
			(new FileReference()).save(ba, "doodle.png");
		}*/
		
	}
}