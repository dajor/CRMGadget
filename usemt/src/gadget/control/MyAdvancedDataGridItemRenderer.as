package gadget.control
{
	import mx.controls.advancedDataGridClasses.AdvancedDataGridItemRenderer;
	
	public class MyAdvancedDataGridItemRenderer extends AdvancedDataGridItemRenderer
	{
		public function MyAdvancedDataGridItemRenderer()
		{
			super();
		}
		
		override public function validateNow():void
		{			
			
			
			backgroundColor = 0xFFFFCC;
			
			super.validateNow();
		}
	}
}