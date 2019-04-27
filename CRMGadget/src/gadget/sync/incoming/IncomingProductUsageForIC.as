package gadget.sync.incoming
{
	import com.adobe.utils.StringUtil;
	
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.util.StringUtils;

	public class IncomingProductUsageForIC extends IncomingRelationObject
	{
		public function IncomingProductUsageForIC()
		{
			super(Database.customObject7Dao.entity,new IncomingRelationObject(Database.opportunityDao.entity),{'ParentRelationId':'OpportunityId'},true);
			startTime=-1;//no need use time
			_readParentIds = true;//we need always to read parent's change from db
		}
		//always save because we get by parent id only
		protected override function canSave(incomingObject:Object,localRec:Object=null):Boolean{
			//we save only recorde from ood but not exist in local and local no change,
			//for exist we do it on merge step already
			if(localRec==null){
				return true;
			}
			if( localRec.ood_lastmodified!=incomingObject.ModifiedDate){
				return (StringUtils.isEmpty(localRec.local_update) && !localRec.deleted );
			}
			
			return false;
		}
		
		protected override function  initParentIds():void{
			parentTask.listRetrieveId = Database.opportunityDao.findAllUpdateIds();
		}
		
		override public function stop():void
		{
			//nothing to do
		}
		protected override function showCount():void {
			//nothing to do
		}
		override  public function getName() : String {
			return i18n._("CHECKING_IMPACT_CALENDAR_CHANGE_ON_OOD@Checking impact calendar changed on ood.");
		}
	}
}