package gadget.control {
    import flashx.textLayout.formats.VerticalAlign;
    
    import mx.collections.ArrayCollection;
    import mx.containers.HBox;
    import mx.containers.Panel;
    import mx.controls.Button;
    import mx.controls.ComboBox;
    import mx.controls.Label;
    import mx.controls.LinkBar;
    import mx.controls.VRule;
    import mx.events.ItemClickEvent;

    public class ButtonPanel extends Panel {

		public var itemClick:Function;
		
        public var linkBar:LinkBar;
        public var dataProvider:ArrayCollection;
		public var cboService:ComboBox;
		private var hb:HBox;
        public function ButtonPanel()
        {
            super();
        }
                
        protected override function createChildren():void {
            super.createChildren();
            linkBar = new LinkBar();
            linkBar.visible = true;
            linkBar.includeInLayout = true;
            linkBar.addEventListener( ItemClickEvent.ITEM_CLICK, itemClickHandler );
		
			hb=new HBox();		
		
			rawChildren.addChild( hb);	
			hb.addChild(linkBar);
		
            
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {			
            super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(cboService!=null){
				hb.addChildAt(cboService,0);
//				var vrule:VRule=new VRule();				
//				vrule.height=hb.height;
//				hb.addChildAt(vrule,1);
			}
            linkBar.dataProvider = dataProvider;
            linkBar.validateNow();
			hb.validateNow();
            var x:int = width - (hb.width + 8);			
			hb.width = hb.measuredWidth;
			hb.height = hb.measuredHeight;
			hb.visible = hb.height <= unscaledHeight; 
            this.setStyle('headerHeight', hb.height + 8);
			if(dataProvider != null)
				for(var index:int = 0; index<dataProvider.length; index++){
					var data:Object = dataProvider[index];
					var btn:Button = linkBar.getChildAt(index) as Button;
					if(data.disabled == true){
						btn.enabled = false;
					}
					btn.doubleClickEnabled=true;
				}
			hb.move(x, 4);
        }
        
        private function itemClickHandler(event:ItemClickEvent):void
        {
            itemClick(event);
        }


    }

}
