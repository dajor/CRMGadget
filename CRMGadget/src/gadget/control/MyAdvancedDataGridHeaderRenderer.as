package gadget.control
{

	
	import com.google.analytics.debug._Style;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gadget.i18n.i18n;
	import gadget.util.ImageUtils;
	
	import mx.containers.HBox;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.LinkButton;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderRenderer;
	import mx.core.ClassFactory;
	import mx.core.IUITextField;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	
	public class MyAdvancedDataGridHeaderRenderer extends AdvancedDataGridHeaderRenderer
	{
		private var _addColapeOrExpand:Boolean=false;
		private var _colapOrExpandClick:Function;

		public function get colapOrExpandClick():Function
		{
			return _colapOrExpandClick;
		}

		public function set colapOrExpandClick(value:Function):void
		{
			_colapOrExpandClick = value;
		}

		public function get addColapeOrExpand():Boolean
		{
			return _addColapeOrExpand;
		}

		public function set addColapeOrExpand(value:Boolean):void
		{
			_addColapeOrExpand = value;
		}


		public function MyAdvancedDataGridHeaderRenderer()
		{
			super();
		}
		private var _switchCol:LinkButton;
		private var _expanded:Boolean = false;
		private var _colName:String;
		private function switchCol(e:Event):void{
			
			_expanded=!_expanded;
			
			setIcon(false);
			if(colapOrExpandClick!=null){
				colapOrExpandClick(_expanded,_colName);
			}
			
			storeStatusToProperties();
			
		}

		private function storeStatusToProperties():void{
			var col:AdvancedDataGridColumn = super.data as AdvancedDataGridColumn;
			if(col!=null){
				//save action to memory
				ClassFactory(col.headerRenderer).properties.expanded = _expanded;
			}
		}
		private function retrieveStatusFromProperties():void{
			var col:AdvancedDataGridColumn = super.data as AdvancedDataGridColumn;
			if(col!=null && ClassFactory(col.headerRenderer).properties.expanded!=null){
				//get action to memory
				 _expanded = ClassFactory(col.headerRenderer).properties.expanded;
			}
		}
		
		protected override function createChildren():void{
			super.createChildren();
			if(addColapeOrExpand && _switchCol==null){
				//<mx:LinkButton id="switchFilter" width="12" height="24" icon="{ImageUtils.leftIcon}" click="switchFilterList(event)" />
				_switchCol = new LinkButton();
				_switchCol.width=12;
				_switchCol.height=20;
				setIcon(false);
				//storeStatusToProperties();
				_switchCol.addEventListener(MouseEvent.CLICK,switchCol);
				
				addChild(_switchCol);
				
				
			}
		}
		
		
		protected function setIcon(isCalRetrieveStatus:Boolean = true):void{
			if(_switchCol!=null){
				if(isCalRetrieveStatus){
					retrieveStatusFromProperties();
				}
				if(!expanded){
					_switchCol.setStyle("icon", ImageUtils.rightIcon);
					_switchCol.toolTip = i18n._('SHOW_MONTHS@Show Months');					
				}else{
					_switchCol.setStyle("icon", ImageUtils.leftIcon);
					_switchCol.toolTip = i18n._('HIDE_MONTHS@Hide Months');
				}
			}
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			//trace(this.uid);
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(_switchCol!=null){
				
				_switchCol.x=unscaledWidth-15;
			}
			
			setIcon();
			
		}

		public function get colName():String
		{
			return _colName;
		}

		public function set colName(value:String):void
		{
			_colName = value;
		}

		public function get expanded():Boolean
		{
			return _expanded;
		}

		public function set expanded(value:Boolean):void
		{
			_expanded = value;
			setIcon(value);
		}

		


	}
}