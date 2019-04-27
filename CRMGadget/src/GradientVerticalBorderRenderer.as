///////////////////////////////////////////////////////////////////////////////
// Licensed Materials - Property of IBM
// 5724-Y31,5724-Z78
// © Copyright IBM Corporation 2007, 2010. All Rights Reserved.
//
// Note to U.S. Government Users Restricted Rights:
// Use, duplication or disclosure restricted by GSA ADP Schedule
// Contract with IBM Corp.
///////////////////////////////////////////////////////////////////////////////
package
{
  import flash.display.GradientType;
  import flash.geom.Matrix;
  
  import ilog.calendar.CalendarItemRendererBorder;
  
  import mx.core.EdgeMetrics;
  import mx.utils.ColorUtil;
  
  public class GradientVerticalBorderRenderer extends CalendarItemRendererBorder
  {
    override protected function drawBackground(color:uint, radius:Number, width:Number, height:Number):void
    {
      var bm:EdgeMetrics = borderMetrics;
      if (parent['data'])
        color = this.parent['data'].data.color;
      if (radius != 0)
      {    
        var darkColor:uint = ColorUtil.adjustBrightness(color, -50);
        var lightColor:uint = ColorUtil.adjustBrightness(color, 100);
        
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(width, height);                   
        drawRoundRect(
                      bm.left, bm.top,
                      width - (bm.left + bm.right),
                      height - (bm.top + bm.bottom), 
                      radius,
                      [color, darkColor], 1, horizontalGradientMatrix(bm.left, bm.top, width - (bm.left + bm.right), height - (bm.top + bm.bottom)),
                      GradientType.LINEAR, null,
                      null);
        drawRoundRect(
                      bm.left, bm.top,
                      width - (bm.left + bm.right),
                      height - (bm.top + bm.bottom), 
                      radius,
                      [lightColor,color], 0.6, verticalGradientMatrix(bm.left, bm.top, width - (bm.left + bm.right), height - (bm.top + bm.bottom)),
                      GradientType.LINEAR, null,
                      null);

      } 
      else
      {          
        graphics.beginFill(color, alpha);
        graphics.drawRect(bm.left, bm.top,
                          width - bm.right - bm.left, height - bm.bottom - bm.top);
        graphics.endFill();
      }
    } 
  }
}