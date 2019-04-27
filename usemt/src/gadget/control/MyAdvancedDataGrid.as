package gadget.control
{
	import flash.display.Sprite;
	
	import gadget.assessment.AssessmentSectionTotal;
	
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	
	public class MyAdvancedDataGrid extends AdvancedDataGrid
	{
		public function MyAdvancedDataGrid()
		{
			super();
		}
		
		
			
			protected override function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void{
				if(collection!=null){
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
			
			
		
	}
}