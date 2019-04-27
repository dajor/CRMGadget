package com.assessment
{
	public class DtoAssessment
	{
		protected var _assessmentId:String;
		protected var _assessmentType:String;
		protected var _assessementName:String;
		private var _totalStoreToField:String;
		private var _isCreateSum:Boolean;
		
		public function DtoAssessment()
		{
		}

		public function get totalStoreToField():String{
			return this._totalStoreToField;
		}
		
		public function set totalStoreToField(field:String):void{
			this._totalStoreToField = field;
		}
		
		public function get isCreateSum():Boolean{
			return this._isCreateSum;
		}
		
		public function set isCreateSum(createSum:Boolean):void{
			this._isCreateSum = createSum;
		}
		
		public function get assessmentId():String{
			return this._assessmentId;		
		}
		
		public function set assessmentId(assId:String):void{
			this._assessmentId = assId;
		}
		
		public function get assessmentType():String{
			return this._assessmentType;
		}
		
		public function set assessmentType(assType:String):void{
			this._assessmentType = assType;
		}
		
		public function get assessementName():String{
			return this._assessementName;
		}
		public function set assessementName(assName:String):void{
			this._assessementName = assName;
		}
	}
}