package gadget.control
{
		
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import gadget.assessment.AssessmentSectionTotal;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.FlexSprite;
	import mx.core.IInvalidating;
	import mx.core.UIComponent;
	
	public class MyAdvancedDataGrid extends AdvancedDataGrid
	{
		
		private var _drawBg:Boolean=true;
		private var _refreshFunction:Function;
		private var _impactCalendarGrid:Boolean=false;
		private var _widthDependParent:Boolean = true;
		private var _groupId:String;
		public function MyAdvancedDataGrid()
		{
			super();
		}
		
		
			
			protected override function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void{
				if(collection!=null && _drawBg){
					var row:Object=rowNumberToData(dataIndex);		       
					if(row!=null && !(row is AssessmentSectionTotal)){		  
						if(!row["hasCheckbox"] ){
							color=0xECECEC;   		
						}else{
							color=0xFFFFFF;
						}			     		     
					} 		      
				}
				super.drawRowBackground(s,rowIndex,y,height,color,dataIndex);		    
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
							var listData:AdvancedDataGridListData = AdvancedDataGridListData(IDropInListItemRenderer(r).listData);
							listData.label = _columns[listData.columnIndex].itemToLabel(r.data);
							IDropInListItemRenderer(r).listData = listData;
						}
						
					}
					if(refDependOnGrid){
						refreshDependOnGrid();
					}
				}
			}
			
			public function refreshRowByRecordId(recId:String,idField:String,refDependOnGrid:Boolean=true):void{
				for(var i:int=0;i<listItems.length;i++){
					var firstCol:Object = listItems[i][0];
					if(firstCol!=null){
						var row:Object = firstCol.data;
						if(row!=null && row[idField]==recId){
							refreshRow(i,false);
						}
					}
				}
				if(refDependOnGrid){
					refreshDependOnGrid();
				}
			}
			
			public function refreshCols(col:int):void{
				if(col<0){
					return;
				}
				for each(var row:Array in listItems){
					if(row.length>col){
						var r:Object = row[col];
						var listData:AdvancedDataGridListData = AdvancedDataGridListData(IDropInListItemRenderer(r).listData);
						listData.label = _columns[col].itemToLabel(r.data);
						IDropInListItemRenderer(r).listData = listData;
					}
				} 
				refreshDependOnGrid();
			
			}
			private function refreshDependOnGrid():void{
				if(this._refreshFunction!=null){
					this._refreshFunction();
					
				}
			}
			public function refreshCell(row:int,col:int):void{
				if(row>-1 && col>-1){
					if(row<listItems.length){
						var colRenderers:Array = listItems[row];
						if(col<colRenderers.length){
							var r:Object = colRenderers[col];
							
							var listData:AdvancedDataGridListData = AdvancedDataGridListData(IDropInListItemRenderer(r).listData);
							listData.label = _columns[col].itemToLabel(r.data);
							IDropInListItemRenderer(r).listData = listData;
						}
						refreshDependOnGrid();
					}
				}
				
			}

		public function set drawBg(value:Boolean):void
		{
			_drawBg = value;
		}

		public function set refreshFunction(value:Function):void
		{
			_refreshFunction = value;
		}
			
		override protected function editorKeyDownHandler(event:KeyboardEvent):void
		{
			if(editedItemPosition!=null){
				super.editorKeyDownHandler(event);
			}
		}	
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(widthDependParent && impactCalendarGrid){	
				this.width= parent.width;
			}
		}
		
		public function get verticalScroll():ScrollBar{
			return this.verticalScrollBar;
		}
		
		override public function getStyle(styleProp:String):*{
			if("defaultDataGridItemRenderer"==styleProp && impactCalendarGrid){
				return MyAdvancedDataGridItemRenderer;
			}
			return super.getStyle(styleProp);
		}
		
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			super.keyDownHandler(event);
//			if(event.keyCode==Keyboard.TAB){
//				if(editedItemPosition!=null){
//					var renderer:Object = listItems[editedItemPosition.rowIndex][editedItemPosition.columnIndex];
//				}
//			}
			if(editedItemPosition!=null && impactCalendarGrid && event.keyCode==Keyboard.TAB){
				
			}
			
		}

		public function get impactCalendarGrid():Boolean
		{
			return _impactCalendarGrid;
		}

		public function set impactCalendarGrid(value:Boolean):void
		{
			_impactCalendarGrid = value;			
		}
		
		
		override protected function drawRowBackgrounds():void
		{
			
			if(!impactCalendarGrid){
				super.drawRowBackgrounds();
				return;
			}
			var rowBGs:Sprite = Sprite(listContent.getChildByName("rowBGs"));
			if (!rowBGs)
			{
				rowBGs = new FlexSprite();
				rowBGs.mouseEnabled = false;
				rowBGs.name = "rowBGs";
				listContent.addChildAt(rowBGs, 0);
			}
			
			var colors:Array = getStyle("alternatingItemColors");
			
			if (!colors || colors.length == 0)
				return;
			
			styleManager.getColorNames(colors);
			
			var curRow:int = 0;
			
			var i:int = 0;
			var actualRow:int = verticalScrollPosition;
			var actualLockedRow:int = 0;
			var n:int = listItems.length;			
			// for Locked rows
			while (curRow < lockedRowCount && curRow < n)
			{				
				drawRowBackground(rowBGs, i++, rowInfo[curRow].y, rowInfo[curRow].height, colors[getColorRow(actualLockedRow) % colors.length], actualLockedRow);				
				curRow++;
				actualLockedRow++;
				actualRow++;
			}
			
			// for unlocked rows
			while (curRow < n)
			{
				drawRowBackground(rowBGs, i++, rowInfo[curRow].y, rowInfo[curRow].height, colors[getColorRow(actualRow) % colors.length], actualRow);				
				curRow++;
				actualRow++;
			}
			
			while (rowBGs.numChildren > i)
			{
				rowBGs.removeChildAt(rowBGs.numChildren - 1);
			}
		}
		
		
		public function setNewDataProvider(dataProvider:Object,isRefreshDependOnTable:Boolean = true):void{
			super.dataProvider = dataProvider;
			if(isRefreshDependOnTable){
				refreshDependOnGrid();
			}
			
		}

		private function getColorRow(curRow:int):int{
			
			if(!StringUtils.isEmpty(groupId)){
				
				var row:Object = rowNumberToData(curRow);				
			
				if(row!=null){
					//must be integer
					return row[groupId];
				}
				
				
			}
			
			return curRow;
		}
		
		public function getColumnIndex(dataField:String):int{
			for(var i:int=0;i<columnCount;i++){
				var c:AdvancedDataGridColumn = columns[i];
				if(c.visible && c.dataField==dataField){
					return i;
				}
			}
			//not found
			return -1;
		}

		public function get groupId():String
		{
			return _groupId;
		}

		public function set groupId(value:String):void
		{
			_groupId = value;
		}

		public function get widthDependParent():Boolean
		{
			return _widthDependParent;
		}

		public function set widthDependParent(value:Boolean):void
		{
			_widthDependParent = value;
		}

		
	}
}