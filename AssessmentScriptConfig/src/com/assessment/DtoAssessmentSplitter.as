package com.assessment{
	import mx.collections.ArrayCollection;
	
	public class DtoAssessmentSplitter{
		
		private var _recordId:String;
		private var _modelId:String;
		private var _delimiter:String;
		private var _selectedFields:ArrayCollection;
		
		public function DtoAssessmentSplitter(){			
			
		}
		
		
		public function get delimiter():String
		{
			return _delimiter;
		}

		public function set delimiter(value:String):void
		{
			_delimiter = value;
		}

		public function get selectedFields():ArrayCollection
		{
			return _selectedFields;
		}

		public function set selectedFields(value:ArrayCollection):void
		{
			_selectedFields = value;
		}

		public function get modelId():String{
			return this._modelId;
		}
		
		public function set modelId(mId:String):void{
			this._modelId = mId;
		}

		public function get recordId():String
		{
			return _recordId;
		}

		public function set recordId(value:String):void
		{
			_recordId = value;
		}

	}
}