package gadget.sync.incoming
{
	import flash.utils.Dictionary;
	
	import gadget.dao.ContactAccountDAO;
	import gadget.dao.Database;
	
	import mx.collections.ArrayCollection;

	public class IncomingSubContact extends IncomingSubobjects
	{
		
		protected var insert:int =0;
		public function IncomingSubContact(ID:String, _subID:String)
		{
			super(ID, _subID);
			isUsedLastModified=false;
		}
		override protected function doRequest():void {
			startTime=-1;//always get all sub by parentid
			super.doRequest();
		}
		
		
		
	override	protected function deleteOracleRecordByParentId(parentId:String):void{
			var criteria:Object = new Object();
			if(subDao is ContactAccountDAO){
				criteria['AccountId'] = parentId;
			}else{
				criteria['ContactId'] = parentId;	
			}
			
			subDao.deleteOnlyRecordeNotErrorByParent(criteria);
		}
		
		
		
		
	}
}