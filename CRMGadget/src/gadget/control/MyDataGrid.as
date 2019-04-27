package gadget.control
{
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	
	public class MyDataGrid extends DataGrid
	{
		public function MyDataGrid()
		{
			super();
		}
		
		public function refreshRow(row:int,refDependOnGrid:Boolean=true):void{
			if(row>-1 && row<listItems.length){
				var colRenderers:Array = listItems[row];
				for each(var r:Object in colRenderers){
					if (r is ButtonAddRenderer)
					{
						ButtonAddRenderer(r).data=ButtonAddRenderer(r).data;//show/hihe button
					}else if( r is LinkButtonRevenueColRenderer||r is MandatoryColRenderer || r is CalculateGridTotalRender){
						r.data = r.data;//refresh label
					}else{
						var listData:DataGridListData = DataGridListData(IDropInListItemRenderer(r).listData);
						listData.label = columns[listData.columnIndex].itemToLabel(r.data);
						IDropInListItemRenderer(r).listData = listData;
					}
					
				}
				
			}
		}
	}
}