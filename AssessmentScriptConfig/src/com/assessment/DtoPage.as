package com.assessment
{
	import mx.collections.ArrayCollection;

	public class DtoPage
	{
		
		private var _recordId:String;
		private var _assessmentType:String = "";	
		private var _pageName:String = "";
		private var _totalStoreToField:String;
		private var _isCreateSum:Boolean;
		
		private var _assessmentSelectedIds:ArrayCollection = new ArrayCollection();
		
		public function DtoPage(assessmentType:String,_pageName:String,assessmentIds:ArrayCollection)
		{
			this._assessmentType = assessmentType;
			this._pageName = _pageName;
			this._assessmentSelectedIds = assessmentIds;
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
		
		public function get assessmentType():String{
			return _assessmentType;
		}
		public function get pageName():String{
			return _pageName;
		}
		public function get assessmentSelectedIds():ArrayCollection{
			if(_assessmentSelectedIds == null){
				_assessmentSelectedIds = new ArrayCollection();
			}
			return _assessmentSelectedIds;
		}
		
		public function set assessmentType(type:String):void{
			this. _assessmentType = type;
		}
		public function set pageName(model:String):void{
			this. _pageName = model;
		}
		
		public function set assessmentSelectedIds(selectedIds:ArrayCollection):void{
			this._assessmentSelectedIds = selectedIds;
		}
		
		
		public function set recordId(recordId:String):void{
			this._recordId = recordId;
		}
		
		public function get recordId():String{
			return this._recordId;
		}
	}
}