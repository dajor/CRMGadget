package gadget.lists
{
	import mx.collections.ICollectionView;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderInfo;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	
	public class ListAdvanceGrid extends AdvancedDataGrid
	{
		public function ListAdvanceGrid()
		{
			super();
		}
		public function refreshCell(row:int,col:int):void{
			if(row>-1 && col>-1){
				if(row<listItems.length){
					var colRenderers:Array = listItems[row];
					if(col<colRenderers.length){
						var r:Object = colRenderers[col];
						if(r!=null){
							r.data = r.data;//refresh label
						}
					}
					
				}
			}
			
		}
		
		protected override function addSortField(columnName:String,
										columnNumber:int,
										collection:ICollectionView):void
		{
			super.addSortField(columnName,columnNumber,collection);
			if(collection.sort && collection.sort.fields ){
				for each(var sortf:SortField in collection.sort.fields){
					if(sortf.name==columnName){
						sortf.caseInsensitive = true;
					}
				}
			}
			
		}
		
			
	}
}