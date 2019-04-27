// ActionScript file
package gadget.control{

	import mx.controls.AdvancedDataGrid;
	import mx.controls.Label;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;

    public class ColorRenderer extends Label {
		
		private static var lastRenderer:ColorRenderer;
		
		private static var lastCellSelected:Object;
		
		private const HIGHLIGHT_COLOR:Object = 0xCCFFCC;
		
		private const HAS_TASK_COLOR:Object = 0xFF8040;

		private const HAS_NO_TASK_COLOR:Object = null;
		
    	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
//			super.updateDisplayList(unscaledWidth, unscaledHeight);
//
//			var dg:AdvancedDataGrid = this.owner as AdvancedDataGrid;
//
//			if(lastRenderer != null && lastRenderer.data != this.data){
//			 	var st:String;
//				if(lastRenderer.data != null && lastRenderer.listData != null )
//				st = lastRenderer.data[AdvancedDataGridListData(lastRenderer.listData).dataField];
//				if(
//					dg.selectedCells.length > 0 &&
//					st != null  && 
//					lastCellSelected.rowIndex != dg.selectedCells[0].rowIndex && 
//					lastCellSelected.columnIndex != dg.selectedCells[0].columnIndex
//				){
//					lastRenderer.opaqueBackground = 0xFF8040;
//				}		
//			}
//
//			var str:String;
//			if(data != null && listData != null )
//				str = data[AdvancedDataGridListData(listData).dataField]; 
//			
//			var g:Graphics = graphics;
//			g.clear();
//			
//			var selectedIndex:int = dg.selectedIndex;
//			var selectedItem:Object = ( selectedIndex != -1 ? dg.dataProvider[selectedIndex] : null ); 
//			var day:ArrayList = new ArrayList(['sun','mon','tue','wed','thu','fri','sat','sun']);
//			
//			var columnIndex:int = dg.selectedCells.length > 0 ? dg.selectedCells[0].columnIndex : 0;
//			var keyObjOfDay:String = day.getItemAt(columnIndex) + 'Item'; 
//			var dataInSelectedColumn:Object = ( (selectedItem != null && selectedItem.hasOwnProperty(keyObjOfDay)) ? selectedItem[keyObjOfDay] : null );
//
//			if(str != null){
//				this.opaqueBackground = 0xFF8040;
//			}
//			else{
//				this.opaqueBackground = null
//			}
//			
//			var isCellSelected:Boolean = dg.selectedCells.length != 0;
//			
//			columnIndex = isCellSelected == true ? dg.selectedCells[0].columnIndex : -1;
//			var rowIndex:int = isCellSelected == true ? dg.selectedCells[0].rowIndex : -1;
//			if( isCellSelected 
//				&& (columnIndex == listData.columnIndex) 
//				&& (rowIndex = listData.rowIndex) 
//				&& (str == listData.label) )
//			{
//				
//				if(lastCellSelected == null) lastCellSelected = dg.selectedCells[0];
//				if(
//					lastCellSelected != null &&
//					lastCellSelected.rowIndex != dg.selectedCells[0].rowIndex &&
//					lastCellSelected.columnIndex != dg.selectedCells[0].columnIndex
//				){ 
//					lastCellSelected = dg.selectedCells[0];
//					lastRenderer = this;
//				}
//				this.opaqueBackground = 0xccffcc;
//			}
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
	
	
	
	
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			var dg:AdvancedDataGrid = this.owner as AdvancedDataGrid;

			var str:String;
			if(data != null && listData != null )
				str = data[AdvancedDataGridListData(listData).dataField]; 
			
			if(str != null){
				this.opaqueBackground = HAS_TASK_COLOR;
			}else{
				this.opaqueBackground = HAS_NO_TASK_COLOR;
			}
			
			var isCellSelected:Boolean = dg.selectedCells.length != 0;

			if(isCellSelected){
				var currentCellSelected:Object = dg.selectedCells[0];
				if(lastCellSelected == null){ 
					lastCellSelected = currentCellSelected;
					lastRenderer = this;
				}
				else if(
					lastCellSelected.rowIndex != currentCellSelected.rowIndex &&
					lastCellSelected.columnIndex != currentCellSelected.columnIndex
				){
					lastCellSelected = currentCellSelected;
					lastRenderer = this;
					lastRenderer.opaqueBackground = HAS_TASK_COLOR;
				}
				else{
					if( currentCellSelected.columnIndex == listData.columnIndex && str != null ){
						this.opaqueBackground = HIGHLIGHT_COLOR;
					}else{
						this.opaqueBackground = HAS_NO_TASK_COLOR;
					}
				}  
			}












			
			
			
			
			
			

		}
		
	}

}