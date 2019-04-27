package com.rubenswieringa.interactivemindmap {
	
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import mx.flash.UIMovieClip;
	
	public class NodeRendererBase extends UIMovieClip {
		
		private var _transparent:Boolean = false;
		private var _text:String = "";
		
		private static const NUM_DEPTHS:uint = 5;
		
		public function NodeRendererBase ():void {
			this.cacheAsBitmap = true;
			// set settings for all TextFields:
			var i:int;
			var textField:TextField;
			for (i=1; i<=NodeRendererBase.NUM_DEPTHS; i++){
				textField = this.getChildByName("textField"+i) as TextField;
				textField.autoSize = TextFieldAutoSize.CENTER;
			}
		}
		
		public function setSkinByID (id:String):Boolean {
			this.gotoAndStop(id);
			if (this.currentLabel != id){
				return false;
			}
			this.applyText();
			return true;
		}
		
		public function setSkinByDepth (depth:int):Boolean {
			return this.setSkinByID("depth"+depth);
		}
		
		public function get text ():String {
			return this._text
		}
		public function set text (value:String):void {
			if (this._text == value){
				return;
			}
			this._text = value;
			this.applyText();
		}
		
		/**
		 * 
		 */
		private function applyText ():void {
			var i:int;
			// this method is not needed if the item-renderer is not displaying a certain depth:
			if (this.currentLabel.slice(0, 5) != "depth"){
				return;
			}
			// textField (TextField):
			var textField:TextField;
			for (i=1; i<=NodeRendererBase.NUM_DEPTHS; i++){
				textField = this.getChildByName("textField"+i) as TextField;
				textField.embedFonts = false;
				if (i.toString() == this.currentLabel.slice("depth".length)){
					textField.text = this._text;
				}else{
					textField.text = "";
				}
			}
			// background (MovieClip):
			var background:DisplayObject;
			for (i=1; i<=NodeRendererBase.NUM_DEPTHS; i++){
				background = this.getChildByName("background_mc"+i);
				if (i.toString() == this.currentLabel.slice("depth".length)){
					textField = this.getChildByName("textField"+i) as TextField;
					background.height = textField.height + (textField.y - background.y) * 2;
				}else{
					background.visible = false;
				}
			}
		}
		
		public function setColor (index:int):void {
			var background:DisplayObject = this.getChildByName("background_mc"+this.currentLabel.slice("depth".length));
			background['gotoAndStop'](index);
		}
		
		public function get transparent ():Boolean {
			return this._transparent;
		}
		public function set transparent (value:Boolean):void {
			if (this._transparent == value){
				return;
			}
			this._transparent = value;
			// set visuals:
			var newFilters:Array = (value) ? [new BlurFilter(3, 3)] : [];
			this.filters = newFilters;
		}
		
	}
	
}