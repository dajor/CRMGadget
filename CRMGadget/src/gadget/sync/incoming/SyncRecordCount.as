package gadget.sync.incoming
{
	import flash.utils.Dictionary;
	
	import gadget.util.StringUtils;

	public class SyncRecordCount
	{
		protected var reccount:int=0;
		protected var recIds:Dictionary = new Dictionary();
		public function SyncRecordCount()
		{
		}
		
		public function count(recId:String):void{
			if(StringUtils.isEmpty(recId)){
				return;
			}
			if(!recIds.hasOwnProperty(recId)){
				recIds[recId]=recId;
				reccount++;
			}
		}
		
		public function getRecCount():int{
			return reccount;
		}
	}
}