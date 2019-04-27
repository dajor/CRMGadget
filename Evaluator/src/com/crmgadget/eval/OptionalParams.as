package com.crmgadget.eval
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class OptionalParams
	{
		protected var existExecuteField:Dictionary = new Dictionary();
		public	var objEntity:Object=null;
		public	var doGetPickList:Function=null;
		public	var doGetPickListId:Function=null;
		public	var doGetXMLValueField:Function=null;
		public	var isFiltered:Boolean=false;
		public	var doGetJoinField:Function=null;
		public	var getFieldNameFromIntegrationTag:Function=null;
		public	var sqlLists:ArrayCollection=null;
		public var current_field:String = null;
		public var doGetOracleId:Function;
		public var entity:String;
		public var owner:Object;
		public function OptionalParams()
		{
			existExecuteField=new Dictionary();
		}
		
		public function isExecuting(field:String):Boolean{
			return existExecuteField.hasOwnProperty(field);
		}
		
		public function addExecuting(field:String):void{
			existExecuteField[field]=field;
		}
	}
}