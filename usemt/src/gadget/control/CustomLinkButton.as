package gadget.control
{
	import mx.controls.LinkButton;
	import mx.core.mx_internal;
	use namespace mx_internal;
	
	public class CustomLinkButton extends LinkButton
	{
		

		
		private var spinner:Spinner;
		private var started:Boolean = true;
		
		public function CustomLinkButton()
		{
			super();
		}
		
		protected override function createChildren():void {
            super.createChildren();
            spinner = new Spinner();
            spinner.visible = true;
            spinner.includeInLayout = true;
            spinner.height = 16;
            spinner.width = 16;
			spinner.move(4, 0);
            spinner.visible = false;
            //measuredMinWidth = measuredWidth = unscaledWidth + 64;           
			
			
        }
		
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            currentIcon.visible = !started;
            var found:Boolean = false;
            for (var i:int = 0; i < numChildren; i++) {
            	if (getChildAt(i) == spinner) {
            		found = true;
            		break;
            	}
            }
            if (found) {
            	removeChild(spinner);
            }
            if (started) {
            	addChild(spinner);
           		this.spinner.visible = true;
           	}

        }
        
		public function start():void {
			started = true;
			this.data = data;
			validateNow();
		}
		
		public function stop():void {
			started = false;
			this.data = data;
			validateNow();
		}
	}
}