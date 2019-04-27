package gadget.control
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.Text;
	import mx.core.IToolTip;
	import mx.managers.ISystemManager;
	
	public class CloseableToolTip extends Canvas implements IToolTip
	{
		private var _hbox:HBox;
		private var _label:Text;
		private var _button:Button;
		private var _text:String;
		private var _systemManager:ISystemManager;
		[Embed(source='/assets/close_button_blue.gif')] [Bindable] private static var closeImg:Class;
		
		public function CloseableToolTip(pSystemManager:ISystemManager) {
			super();
			_systemManager = pSystemManager;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			_hbox = new HBox();
			_hbox.setStyle("borderSkin", ToolTipSkin);
			_hbox.setStyle("backgroundColor", "#DD2222");
			_hbox.setStyle("paddingBottom", 4);
			_hbox.setStyle("paddingTop", 4);
			_hbox.setStyle("paddingLeft", 4);
			_hbox.setStyle("paddingRight", 4);
/*			_hbox.setStyle("alpha", "1");
			_hbox.setStyle("borderThickness", "1");
			_hbox.setStyle("borderColor", "#000000");
			_hbox.setStyle("borderStyle", "solid");
*/			_button = new Button();
			_button.setStyle("skin", closeImg);
			_button.addEventListener(MouseEvent.CLICK, close);
			_button.width = 12;
			_button.height = 12;
			_label = new Text();
			_label.text = _text;
			_label.setStyle("color", "#FFFFFF");
			_label.setStyle("fontWeight", "bold");
			
			_hbox.addChild(_label);
			_hbox.addChild(_button);
			addChild( _hbox );    
		}
		
		public function close(event:Event = null):void {
			if (_systemManager.toolTipChildren.contains(this)) {
				_systemManager.toolTipChildren.removeChild(this);
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();   
		}
		
		public function get text() : String
		{
			return _button.label;
		}
		public function set text( value:String ) : void
		{
			_text = value;
		}    
	}
}