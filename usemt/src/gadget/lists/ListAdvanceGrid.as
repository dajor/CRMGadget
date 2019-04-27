package gadget.lists
{
	import mx.collections.ICollectionView;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderInfo;
	
	public class ListAdvanceGrid extends AdvancedDataGrid
	{
		public function ListAdvanceGrid()
		{
			super();
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