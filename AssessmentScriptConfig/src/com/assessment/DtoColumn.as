package com.assessment
{
	import mx.controls.CheckBox;

	public class DtoColumn
	{
		public static const CHECK_BOX_TYPE:String = "CHECKBOX";
		public static const DATE_TYPE:String = "GLOBAL_DATE";
		public static const TEXT_TYPE:String = "TEXTBOX";
		public static const RADIO_TYPE:String = "RADIO";
		
		protected var _recordId:String;
		protected var _colProperty:String;
		protected var _title:String;
		protected var _order:int;		
		protected var _dataType:String;
		protected var _isDefault:Boolean;
		protected var _visible:Boolean = true;
		protected var _isHasSumField:Boolean = false;
		protected var _modelId:String;
		private var _description:String;
		
		
		public function DtoColumn()
		{
		}
		
		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}

		public function get modelId():String{
			return this._modelId;
		}
		public function set modelId(prop:String):void{
			this._modelId = prop;
		}
		public function get colProperty():String{
			return this._colProperty;
		}
		public function set colProperty(prop:String):void{
			this._colProperty = prop;
		}
		public function set isHasSumField(sum:Boolean):void{
			this._isHasSumField = sum;
		}
		public function get isHasSumField():Boolean{
			return this._isHasSumField?true:false;
		}
		
		
		public function get title():String{
			return this._title;
		}
		public function set title(title:String):void{
			if(_colProperty==null && _recordId==null){
				var pattern:RegExp = /\W/g;
				this._colProperty = title.replace(pattern,"");
			}
			this._title = title;
		}
		
		public function get order():int{
			return this._order
		}
		
		public function set order(order:int):void{
			this._order = order;
		}
		
	
		
		public function get isCheckbox():Boolean{
			return this.dataType ==CHECK_BOX_TYPE;
		}
		
		public function get dataType():String{
			return this._dataType;
		}
		public function set dataType(type:String):void{
			this._dataType = type;
		}
		
		public function get isDefault():Boolean{
			return this._isDefault;
		}
		public function set isDefault(isDefault:Boolean):void{
			this._isDefault = isDefault;
		}
		
		public function get recordId():String{
			return this._recordId;
		}
		
		public function set recordId(id:String):void{
			this._recordId = id;
		}
		
		public function get visible():Boolean{
			return this._visible;
		}
		
		public function set visible(visible:Boolean):void{
			this._visible = visible;
		}
		
		
		
	}
}