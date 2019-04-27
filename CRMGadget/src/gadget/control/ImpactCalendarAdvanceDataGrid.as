package gadget.control
{
	import flash.display.Sprite;
	
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	
	public class ImpactCalendarAdvanceDataGrid extends AdvancedDataGrid
	{
		public function ImpactCalendarAdvanceDataGrid()
		{
			super();
		}
		public function drawColumnBackground(s:Sprite, colIndex:int,color:uint, column:AdvancedDataGridColumn):void{
			if(this.currentRowNum == 4 && colIndex>0){
				super.drawColumnBackground(s,colIndex,color,column);
			}else{
				super.drawColumnBackground(s,colIndex,color,column);
			}
			
		}
	}
}