package gadget.control{
	
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	
	public class GridFontItemRenderer extends DataGridItemRenderer{
		
		public function GridFontItemRenderer(){
			super();
		}
		
		override public function validateNow():void{
			if (listData)
				setStyle('fontWeight', DataGrid(listData.owner).dataProvider[listData.rowIndex].hasOwnProperty("fontWeight") ? DataGrid(listData.owner).dataProvider[listData.rowIndex].fontWeight : "normal");
			super.validateNow();
		}
		
	}
}
