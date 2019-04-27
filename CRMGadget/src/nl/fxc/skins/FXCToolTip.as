/*
    FXCToolTipBorder
    
    HTML supported tooltip, I just love it when code comes together
    Now with the sticky tooltip feature;
    
    version 0.3 (28-04-2007)
    -	Removerd updateDisplayList & extands FXCHTMLToolTip, cleaned up code;
    
    version 0.2.1 (01-04-2007)
    -	Cleaned up code and used Luke McLean suggestions;
    	
    version 0.2
    -	It's trying not fall off screen
    	(fix made by: Luke McLean)
    
    version 0.1
    -	Background is scaling to match htmlText;
    -	Tooltip sticks to mouse;
    
    TODO:
    - For some reason it's ignoring the style in the HTML-text
    
    Created by Maikel Sibbald
    info@flexcoders.nl
    http://labs.flexcoders.nl
    
    Free to use.... just give me some credit
*/
package nl.fxc.skins{
    
    import flash.events.Event;
    
    import mx.controls.ToolTip;
    import mx.core.Application;
    import mx.core.UITextField;
    import mx.skins.halo.ToolTipBorder;

    public class FXCToolTip extends FXCHTMLToolTip{
		private var relx:Number;
		private var rely:Number;
		
       	public function FXCToolTip():void{
        	super();
        	this.makeSticky();
        }
        
        private function makeSticky():void {
			this.addEventListener(Event.ENTER_FRAME, this.setBounds);
		}
		
		private function setBounds(event:Event):void {
			if(this.parent != null && this.parent["styleName"]!="errorTip"){
				var mouseX:Number = Application.application.mouseX;
				var mouseY:Number = Application.application.mouseY;
				var screenWidth:Number = Application.application.screen.width;
				var screenHeight:Number = Application.application.screen.height;
				
				var xBounds:Boolean = (((mouseX + parent.width - relx) < screenWidth)&&(mouseX - relx > 0));
				var yBounds:Boolean = (((mouseY + parent.height - rely) < screenHeight)&&(mouseY - rely > 0));
				
				if (xBounds && yBounds) {
					this.parent.x = mouseX - relx;
					this.parent.y = mouseY - rely;
				} else if (yBounds) {
					this.parent.y = mouseY - rely;
					relx = mouseX - parent.x;
				} else if (xBounds) {
					this.parent.x = mouseX - relx;
					rely = mouseY - parent.y;
				} else {
					relx = mouseX - parent.x;
					rely = mouseY - parent.y;
				}
			}
		} 
    }
}