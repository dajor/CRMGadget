package com.assessment
{
	public class DtoPDFColorTheme
	{
		private var _gadget_id:String;
		private var _color:String;
		private var _colorType:String;
		private var _ordering:String;
		
		public function DtoPDFColorTheme()
		{
		}

		public function get gadget_id():String{
			return _gadget_id;
		}

		public function set gadget_id(value:String):void
		{
			_gadget_id = value;
		}

		public function get ordering():String
		{
			return _ordering;
		}

		public function set ordering(value:String):void
		{
			_ordering = value;
		}

		public function get colorType():String
		{
			return _colorType;
		}

		public function set colorType(value:String):void
		{
			_colorType = value;
		}

		public function get color():String
		{
			return _color;
		}

		public function set color(value:String):void
		{
			_color = value;
		}

	}
}