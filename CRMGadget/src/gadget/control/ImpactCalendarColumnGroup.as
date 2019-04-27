package gadget.control
{
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
	
	public class ImpactCalendarColumnGroup extends AdvancedDataGridColumnGroup
	{
		public function ImpactCalendarColumnGroup(columnName:String=null)
		{
			super(columnName);
		}
		
		
		override public function itemToData(data:Object):*
		{
			return data;//no group data for impage
		}
	}
}