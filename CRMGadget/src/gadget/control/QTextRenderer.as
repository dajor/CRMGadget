package gadget.control
{
	import com.adobe.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import gadget.dao.OpportunityDAO;
	import gadget.i18n.i18n;
	import gadget.util.NumberLocaleUtils;
	import gadget.util.StringUtils;
	import gadget.window.WindowManager;
	
	import mx.collections.ArrayCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.core.Window;
	import mx.events.CloseEvent;

	public class QTextRenderer extends TextInput
	{
		
		private var column:AdvancedDataGridColumn;		
		private var grid:MyAdvancedDataGrid = null;
		private var tabOrEnterDown:Boolean = false;
		private var isChanged:Boolean = false;
		public function QTextRenderer()
		{
			
			addEventListener(Event.CHANGE,function(e:Event):void{
				isChanged=true;
			});
			
			addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,function(e:Event):void{
				if(tabOrEnterDown || !isChanged) return;
				var oldValStr:String = column.labelFunction(data,column);
				if(StringUtils.isEmpty(oldValStr)){
					onChange(e);					
				}else{
					var oldVal:Number = parseFloat(oldValStr);
					var newVal:Number = parseFloat(text);
					if(oldVal!=newVal){
						
						Alert.show(i18n._("OVERRIDE_QUATER_MONTHS_MSSAGE@Do you want to override the existing monthly value based on this new quarterly value?"),i18n._("GLOBAL_WARNINGO@Warning"),Alert.YES|Alert.NO,Window(WindowManager.getTopWindow()),function(event:CloseEvent):void{
							if(event.detail==Alert.YES){
								onChange(e);							
							}else{
								text=oldValStr;
							}
							
							
						});
						
					}
					isChanged=false;
				}
			});
		
			
			addEventListener(KeyboardEvent.KEY_DOWN,function(keyEvent:KeyboardEvent):void{
				//fixed npe error when click tab
				if(keyEvent.keyCode==Keyboard.TAB || keyEvent.keyCode==Keyboard.ENTER){
					tabOrEnterDown=true;
					var oldValStr:String = column.labelFunction(data,column);
					if(StringUtils.isEmpty(oldValStr)){
						onChange(keyEvent);			
						tabOrEnterDown=false;
					}else{
						var oldVal:Number = parseFloat(oldValStr);
						var newVal:Number = parseFloat(text);
						if(oldVal!=newVal){
							
							Alert.show(i18n._("OVERRIDE_QUATER_MONTHS_MSSAGE@Do you want to override the existing monthly value based on this new quarterly value?"),i18n._("GLOBAL_WARNINGO@Warning"),Alert.YES|Alert.NO,Window(WindowManager.getTopWindow()),function(event:CloseEvent):void{
								if(event.detail==Alert.YES){
									onChange(keyEvent);							
								}else{
									text=oldValStr;
								}
								tabOrEnterDown=false;
								
							});
							
						}else{
							tabOrEnterDown=false;
						}
					}
				}
			});
			super();
		}
		
		override  public function set text(value:String):void
		{
			if(value!=null){
				value = StringUtil.trim(value);
			}
			super.text = value;
		}
		

		override public function set data(value:Object):void{
			super.data = value;
			setFocus();
			if(!StringUtils.isEmpty(super.text)){
				setSelection(super.text.length,super.text.length);
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
		
		public function get quater():Object{
			return super.data[column.dataField];
		}
		
		private function onChange(e:Event):void{
			if(column != null){
				var quater:Object = super.data[column.dataField];
				if(quater==null||quater==''){
					quater = new Object();
					super.data[column.dataField] = quater;
				}
				var q1:Number = parseFloat(NumberLocaleUtils.parse(super.text));
				if(!isNaN(q1)){
					var val:Number = q1/3;
					for each(var f:String in OpportunityDAO.MONTH_FIELD_FOR_EACH_Q){
						
						quater[f]=val.toFixed(4);//store 4digit after .
					}					
				}else{
					for each(var f:String in OpportunityDAO.MONTH_FIELD_FOR_EACH_Q){
						
						quater[f]="0";//reset them to zero
					}			
				}
				
				grid.refreshRow(super.listData.rowIndex);
				isChanged = false;
				
			}
		}
	
		override public function set listData(value:BaseListData):void
		{			
			super.listData = value;
			if(value!=null){
				grid = value.owner as MyAdvancedDataGrid;
				var list:AdvancedDataGridListData = value as AdvancedDataGridListData;
				if(list!=null){					
					column = grid.columns[list.columnIndex];
					column = grid.columns[list.columnIndex];
					if(column != null){
						column.setStyle("textAlign","right");
					}
				}
				
			}
		}
		
		
	}
}