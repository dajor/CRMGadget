// ActionScript file
package gadget.control{

	import mx.controls.Label;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;

    public class HeaderRenderer extends Label {

    	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth-1, unscaledHeight+2);
		}
		
	}

}