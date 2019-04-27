package gadget.control
{
	import com.adobe.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import gadget.util.NumberLocaleUtils;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.controls.listClasses.BaseListData;

	public class ImpactText extends TextInput
	{
		
		
		public var column:AdvancedDataGridColumn;
		protected var grid:AdvancedDataGrid = null;		
		private var _refreshRow:Boolean = true;
		private var _updateData:Function;
		private var _decimal:int = 4;
		public function ImpactText()
		{
			addEventListener(Event.CHANGE,onChange);
			super();
		}

		
		public function set focusOutHandler(f:Function):void{
			
			addEventListener(FocusEvent.FOCUS_OUT,function(e:FocusEvent):void{f()});
		}
		
		protected function onChange(e:Event):void{
			
					
					if(column != null){
						var colName:String = column.dataField;
						var val:String =this.text;
						if(colName.indexOf('.')!=-1){
							var fields:Array = colName.split('.');
							var q:Object = data[fields[0]];
							if(q==null){
								q=new Object();
								super.data[fields[0]]=q;
							}
							q[fields[1]]=val;
						}else{
							super.data[colName]=val;
						}
						if(updateData!=null){
							var newVal:Object = new Object();
							newVal[colName]=val;
							updateData(super.data,newVal);
						}
						
						
						if(grid is MyAdvancedDataGrid && refreshRow){
							MyAdvancedDataGrid(grid).refreshRow(super.listData.rowIndex);
						}
						
					}

		}
		override public function set data(value:Object):void{
			if(column!=null){
				listData.label=column.itemToLabel(value);
			}
			super.data = value;
			setFocus();
			var str:String = StringUtil.trim(super.text);
			if(!StringUtils.isEmpty(str)){
				setSelection(str.length,str.length);
			}
			if(value!=null && column!=null){
				if(value.hasOwnProperty("isTotal") && value.isTotal){
					var editable:Boolean = false;
					if(value.editFields!=null){
						var f:String = column.dataField;
						if(f.indexOf('.')!=-1){
							f=f.split('.')[0];							
						}
						editable = value.editFields[f];
					}
					this.enabled = editable;
				}
			}
		}
		
		override  public function set text(value:String):void
		{
			if(value!=null){
				value = StringUtil.trim(value);
			}
			super.text = value;
		}
		
		
		override public function set listData(value:BaseListData):void
		{
			
			super.listData = value;
			if(value!=null){
				grid = value.owner as AdvancedDataGrid;
				var list:AdvancedDataGridListData = value as AdvancedDataGridListData;
				if(list!=null){					
					column = grid.columns[list.columnIndex];
					if(column != null){
						column.setStyle("textAlign","right");
					}
				}
				
			}
		}

		public function get refreshRow():Boolean
		{
			return _refreshRow;
		}

		public function set refreshRow(value:Boolean):void
		{
			_refreshRow = value;
		}

		public function get updateData():Function
		{
			return _updateData;
		}

		public function set updateData(value:Function):void
		{
			_updateData = value;
		}

		public function get decimal():int
		{
			return _decimal;
		}

		public function set decimal(value:int):void
		{
			_decimal = value;
		}


	}
}