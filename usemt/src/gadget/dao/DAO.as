package gadget.dao
{
	import mx.collections.ArrayCollection;
	
	public interface DAO
	{
		function insert(object:Object,useCustomfield:Boolean=true):void;
		
		function update(object:Object):void;
		
		function updateByOracleId(object:Object,updateCustomField:Boolean=false):void;
		
		function delete_(object:Object):void;
		
		function deleteTemporary(object:Object):void;
		
		function deleteByOracleId(oracleId:String):void;
		
		function findByOracleId(oracleId:String):Object;
		
		function findByGadgetId(id:String):Object;
		
		function findCreated(offset:int, limit:int):ArrayCollection;
		
		function findUpdated(offset:int, limit:int):ArrayCollection;
		
		function findAll(columns:ArrayCollection, filter:String = null, selectedId:String = null, limit:int = 1001,order_by:String=null,addColOODLastModified:Boolean=true, group_by:String=null):ArrayCollection;
		
		function selectLastRecord():ArrayCollection;
		
		function findDuplicateByColumn(columnName:String, columnValue:String, gadget_id:String):Object;
		
		function updateReference(columnName:String, previousValue:String, nextValue:String):void;
		
		function setError(oracleId:String, error:Boolean):void;		
	}
}