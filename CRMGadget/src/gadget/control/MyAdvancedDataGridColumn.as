package gadget.control
{
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	
	public class MyAdvancedDataGridColumn extends AdvancedDataGridColumn
	{
		private var _mandatory:Boolean = false;
		
		public function MyAdvancedDataGridColumn(columnName:String=null)
		{
			super(columnName);
		}
		
		public function get mandatory():Boolean
		{
			return _mandatory;
		}

		public function set mandatory(value:Boolean):void
		{
			_mandatory = value;
		}

	}
}