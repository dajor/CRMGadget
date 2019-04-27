package com.rubenswieringa.interactivemindmap {
	
	import com.adobe.flex.extras.controls.springgraph.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import mx.core.*;
	
	public class NodeRendererShell extends UIComponent implements IDataRenderer {
		
		private var nodeRenderer:NodeRenderer/*Base///*/ = new NodeRenderer();/// as NodeRendererBase;
		private var _data:Object;
		private var _xml:XML;
		private var lastMouseDown:int = 0;
		
		private static const MAX_CLICKINTERVAL:int = 200; // in milliseconds
		public static const ACTIVATE:String = "onNodeRendererShellActivate";
		
		public function NodeRendererShell ():void {
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.timeMouseDown);
		}
		
		override protected function createChildren ():void {
			super.createChildren();
			this.addChild(this.nodeRenderer);
		}
		
		/**
		 * Unfolds sub-structure which this node is part of.
		 * Typically called as a listener of the click event.
		 */
		private function activate (event:MouseEvent=null):void {
			if (event != null && getTimer()-this.lastMouseDown > NodeRendererShell.MAX_CLICKINTERVAL){
				return;
			}
			this.dispatchEvent(new Event(NodeRendererShell.ACTIVATE, true, true));
		}
		
		/**
		 * Stores the time at which the left mousebutton was last pressed.
		 * This method prevents dragging from being interpreted as clicking.
		 * Called as a listener of the click event.
		 */
		private function timeMouseDown (event:MouseEvent):void {
			this.lastMouseDown = getTimer();
		}
		
		private function startup (event:Event=null):void {
			this._xml = Controller.getXML(this._data.id);
			
			this.nodeRenderer.text = this._xml.@value.toString();
			this.nodeRenderer.toolTip = this._xml.@value; //this._xml.@description;
			if(!this.nodeRenderer.setSkinByID(this._xml.@id)){
				this.nodeRenderer.setSkinByDepth(Controller.getXMLDepthDifference(Controller._instance._model.words.word[0], this._xml)+1);
			}
			var color:int = (this._xml.@type == "main") ? this._xml.childIndex() : Controller.getNearestMainTypedParent(this._xml).childIndex();
			this.nodeRenderer.setColor(color+1);
			
			Controller.instance.addEventListener(Controller.BUILT, this.refresh);
		}
		
		private function refresh (event:Event=null):void {
			
			// stop if not existent anymore:
			if (!Controller.instance.graph.hasNode(this._data.id)){
				Controller.instance.removeEventListener(Controller.BUILT, this.refresh);
				return;
			}
			
			// notChildOrSelf indicates whether or not this item is a 
			// child of or is (the nearest main-typed parent of) the 
			// distinguished Item:
			var nearestMainTypedParent:XML	= Controller.getNearestMainTypedParent(Controller.getXML(Controller.instance.graph.distinguishedItem.id));
			var notChildOrSelf:Boolean		= (nearestMainTypedParent.@id != this._data.id && nearestMainTypedParent..word.(@id == this._data.id).length() == 0);
			
			// mouse settings:
			var clickable:Boolean = (notChildOrSelf || (this._xml.@type == "main" && nearestMainTypedParent.@id != this._data.id));
			this.nodeRenderer.useHandCursor	= clickable;
			this.nodeRenderer.buttonMode	= clickable;
			this.nodeRenderer.mouseChildren	= clickable;
			if (clickable){
				this.addEventListener(MouseEvent.CLICK, this.activate);
			}else{
				this.removeEventListener(MouseEvent.CLICK, this.activate);
			}
			
			// visual effects:
			this.nodeRenderer.transparent = notChildOrSelf;
			
		}
		
		public function get data ():Object {
			return this._data;
		}
		public function set data (value:Object):void {
			this._data = value;
			this.startup();
		}
		
	}
	
}