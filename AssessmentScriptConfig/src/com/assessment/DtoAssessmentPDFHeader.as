package com.assessment
{
	public class DtoAssessmentPDFHeader
	{
		private var _modelId:String;
		private var _gadget_id:String;
		private var _entity:String;	
		private var _elementName:String;
		private var _customText:String;
		private var _isCustomText:Boolean;
		private var _ordering:int;
		private var _display_name:String;
		
		public function DtoAssessmentPDFHeader()
		{
		}
		
		public function get display_name():String
		{
			return _display_name;
		}

		public function set display_name(value:String):void
		{
			_display_name = value;
		}

		public function get ordering():int
		{
			return _ordering;
		}

		public function set ordering(value:int):void
		{
			_ordering = value;
		}

		public function get modelId():String
		{
			return _modelId;
		}

		public function set modelId(value:String):void
		{
			_modelId = value;
		}

		public function get isCustomText():Boolean
		{
			return _isCustomText;
		}

		public function set isCustomText(value:Boolean):void
		{
			_isCustomText = value;
		}

		public function get customText():String
		{
			return _customText;
		}

		public function set customText(value:String):void
		{
			_customText = value;
		}

		public function get elementName():String
		{
			return _elementName;
		}

		public function set elementName(value:String):void
		{
			_elementName = value;
		}

		public function get entity():String
		{
			return _entity;
		}

		public function set entity(value:String):void
		{
			_entity = value;
		}

		public function get gadget_id():String
		{
			return _gadget_id;
		}

		public function set gadget_id(value:String):void
		{
			_gadget_id = value;
		}

	}
}