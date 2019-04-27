/*
    FXCHTMLToolTip
    
    HTML supported tooltip, I just love it when code comes together
    
    version 1.2
    Fixed bug in width and height
    
    version 1.1
    Background is scaling to match htmlText
    
    Thank you IDS - Again!!
    http://idsklijnsma.nl/blog/
    
    Created by Maikel Sibbald
    info@flexcoders.nl
    http://labs.flexcoders.nl
    
    Free to use.... just give me some credit
*/
package nl.fxc.skins{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    
    import mx.controls.ToolTip;
    import mx.core.Application;
    import mx.core.UITextField;
    import mx.effects.Fade;
    import mx.events.EffectEvent;
    import mx.managers.ToolTipManager;
    import mx.skins.halo.ToolTipBorder;

    public class FXCHTMLToolTip extends ToolTipBorder{
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            var toolTip:ToolTip = (this.parent as ToolTip);
            var textField:UITextField = toolTip.getChildAt(1) as UITextField;
            textField.htmlText = textField.text;
            
            var calHeight:Number = textField.height;
            calHeight += this.parent["getStyle"]("borderThickness")*2;
            calHeight += (textField.y*2);
    		
    		var calWidth:Number = textField.textWidth;
            var addWidth:Number = unscaledWidth - textField.width;
            calWidth += addWidth
            calWidth += textField.x/2;
	            
    		if(calWidth < unscaledWidth){
	     		calWidth = unscaledWidth;
	     	}
            
            super.updateDisplayList(calWidth, calHeight);
        }
       	

    }
}