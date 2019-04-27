///////////////////////////////////////////////////////////////////////////////
// Licensed Materials - Property of IBM
// 5724-Y31,5724-Z78
// © Copyright IBM Corporation 2007, 2010. All Rights Reserved.
//
// Note to U.S. Government Users Restricted Rights:
// Use, duplication or disclosure restricted by GSA ADP Schedule
// Contract with IBM Corp.
///////////////////////////////////////////////////////////////////////////////
package gadget.control
{
	import flash.display.Graphics;
	import flash.display.Shape;
	
	import gadget.dao.Database;
	import gadget.util.StringUtils;
	
	import ilog.calendar.CalendarItem;
	import ilog.calendar.CalendarItemVerticalRenderer;
	
	import mx.core.EdgeMetrics;
	import mx.core.UITextField;
	import mx.formatters.DateFormatter;
	import mx.graphics.RectangularDropShadow;
	import mx.utils.ColorUtil;
	import mx.utils.GraphicsUtil;
	
	/**
	 * This item renderer extends the vertical item renderer to add a shadow and an dary background under
	 * the start time label.
	 */   
	public class CustomVerticalRenderer extends CalendarItemVerticalRenderer
	{
		public function CustomVerticalRenderer() {
			super();                    
			
		}
		
		
		private var _shadow:RectangularDropShadow;    
		
		override protected function createChildren():void {
			
			super.createChildren();
			
			if (_shadow == null) {      
				_shadow = new RectangularDropShadow();
				_shadow.brRadius = _shadow.blRadius = _shadow.tlRadius = _shadow.trRadius = getStyle("cornerRadius");
				_shadow.color = 0x404040;
				_shadow.distance = 4;
			}
			
			if (drawing == null) {
				drawing = new Shape();
				addChild(drawing);
				drawing.x = 0;
				drawing.y = 0;
			}
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (data == null) {
				return;
			}
			
			drawing.graphics.clear();
			
			if (startTimeLabel.visible) {
				if (Database.preferencesDao.isLongTimeFormate()) {
					var sLabel:String = startTimeLabel.text;
					var eLabel:String = endTimeLabel.text;
					var fm:String="HH:NN";
					var fommater:DateFormatter = new DateFormatter();
					fommater.formatString = fm;
					var date:Date = new Date();
					var dateString:String = date.getMonth().toString()+ "/"+date.getDate().toString() +"/"+date.getFullYear().toString();
					if(!StringUtils.isEmpty(sLabel)){
						var s:String = fommater.format(dateString + " " + sLabel);
						startTimeLabel.text = s;
					}
					if(!StringUtils.isEmpty(eLabel) && endTimeLabel.visible){
						var e:String = fommater.format(dateString + " " +eLabel);
						endTimeLabel.text = e;
					}
				}
				var bm:EdgeMetrics = borderMetrics;
				
				var radius:Number = getStyle("cornerRadius");
				var height:Number = startTimeLabel.y + startTimeLabel.height; 
				
				var g:Graphics = drawing.graphics;
				var theDate:CalendarItem = CalendarItem(data);
				var color:uint = data.calendarControl.getItemColor(data);
				color = ColorUtil.adjustBrightness(color, -40);
				var w:Number = unscaledWidth-bm.left-bm.right;
				
				g.beginFill(color);
				
				if (radius == 0) {
					
					g.drawRect(bm.left, bm.top, w, height);
					
					if (endTimeLabel.visible) {            
						g.drawRect(bm.left, unscaledHeight-bm.bottom-height, w, height);
					}
					
				} else {                           
					GraphicsUtil.drawRoundRectComplex(g, bm.left, bm.top, w, height, radius, radius, 0, 0);
					
					if (endTimeLabel.visible) {
						GraphicsUtil.drawRoundRectComplex(g, bm.left, unscaledHeight-bm.bottom-height, w, height, 0, 0, radius, radius);
					}        
				}
				
				g.endFill();
				
				setChildIndex(drawing, 1); // 0 is the border
			}
			
			graphics.clear();
			
			_shadow.drawShadow(graphics, 0, 0, unscaledWidth, unscaledHeight);
			
		}
		
		
		
	}
}

