package com.assessment
{
	import mx.collections.ArrayCollection;

	public class DtoConfiguration
	{
		
		public static const  TRYGGMAT:String = "Tryggmat";
		public static const  BUTIKS:String  = "Butiks";
		public static const  MILJO:String  = "Miljö";
		private var _recordId:String;
		private var _assessmentType:String = "";	
		private var _assessmentModel:String = "";
		private var _totalStoreToField:String;
		private var _isCreateSum:Boolean;
		private var _type:String;
		private var _sumType:String;
		
		private var _pageSelectedIds:ArrayCollection = new ArrayCollection();
		public function DtoConfiguration(assessmentType:String,assessmentModel:String,type:String,pageSelectedIds:ArrayCollection)
		{
			this._assessmentType = assessmentType;
			this._assessmentModel = assessmentModel;
			this._pageSelectedIds = pageSelectedIds;
			if(type==null || StringUtils.isEmpty(type)){
				type = matchTypeByName(assessmentModel);
			}
			this._type =type;
			
		}
		
		private function matchTypeByName(name:String):String{
			if(name.indexOf(TRYGGMAT)!=-1){
				return TRYGGMAT;
			}
			if(name.indexOf(BUTIKS)!=-1){
				return BUTIKS;
			}
			if(name.indexOf(MILJO)!=-1){
				return MILJO;
			}
			return null;
		}
		
		public function get totalStoreToField():String{
			return this._totalStoreToField;
		}
		
		public function set totalStoreToField(field:String):void{
			this._totalStoreToField = field;
		}
		
		public function set sumType(type:String):void{
			this._sumType = type;
		}
		
		public function get sumType():String{
			return this._sumType;
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
		public function get assessmentModel():String{
			return _assessmentModel;
		}
		public function get pageSelectedIds():ArrayCollection{
			if(_pageSelectedIds == null){
				_pageSelectedIds = new ArrayCollection();
			}
			return _pageSelectedIds;
		}
		
		public function set assessmentType(type:String):void{
			this. _assessmentType = type;
		}
		public function set assessmentModel(model:String):void{
			this. _assessmentModel = model;
		}
		
		public function set pageSelectedIds(selectedIds:ArrayCollection):void{
			this._pageSelectedIds = selectedIds;
		}
		
		
		public function set recordId(recordId:String):void{
			this._recordId = recordId;
		}
		
		public function get recordId():String{
			return this._recordId;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}
		
		
	}
}