package gadget.sync.incoming
{
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.util.DateUtils;
	import gadget.util.GUIUtils;
	
	public class IncomingProductUsageCP extends IncomingRelationObject
	{
		public function IncomingProductUsageCP(entity:String, parentFieldId:String,full:Boolean)
		{
			super(Database.customObject7Dao.entity, new IncomingRelationObject(entity), {"ParentRelationId":parentFieldId}, true);
			_usemodfiedDateAscriteria = !full;
			_readParentIds=true;
			_test_data = false;
		}
		
		override protected function doRequest():void {	
			super.doRequest();
		}
		override public function getEntityName():String { 
			return parentTask.getEntityName()+"."+entityIDsod; 
		}
	}
}