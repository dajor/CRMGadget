package gadget.sync.incoming
{
	import gadget.dao.Database;
	
	import mx.collections.ArrayCollection;

	public class IncomingSubobjectsByIds extends IncomingSubobjects
	{
		
		private var records:ArrayCollection;
		public function IncomingSubobjectsByIds(ID:String, _subID:String)
		{
			super(ID, _subID);
			isUsedLastModified=true;
		}
		override protected function doGetParents():ArrayCollection{
			var parentIds:ArrayCollection = new ArrayCollection();
			if(records!=null){
				for each(var obj:Object in records){
					parentIds.addItem(obj.ObjectId);
				}
			}
			
			return parentIds;
		}
		
		override protected function initOnce():void{
			super.initOnce();
			records = Database.modificationTrackingDao.getSubIdByEntity(entityIDour,subDao.entity);
		}			
		
		override protected function getSubSerachSpec():String{			
			return "";
		}
		
	}
}