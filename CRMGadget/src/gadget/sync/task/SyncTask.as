package gadget.sync.task
{	
	import flash.utils.getQualifiedClassName;
	
	import gadget.dao.DAO;
	import gadget.dao.Database;
	import gadget.util.Utils;
	
	public class SyncTask extends WebServiceBase {
		
		private var _page:int;
		protected var isClearData:Boolean=true;
		//protected var _startId:String;		// VAHI retired
		protected var _nbItems:int;
		
		private const PAGE_SIZE:int = 50;
		
		public function SyncTask() {
		}
		

		protected function get page():int {
			return _page;
		}
		
		protected function get startRow():int {
			return _page * PAGE_SIZE;
		}

		protected function notifyX(remote:Boolean, name:String, what:String, entity:String = null):void {
			if (eventHandler != null) 
				eventHandler(remote, entity == null ? getEntityName() : entity, name, what);
		}
		
		protected function notifyCreation(remote:Boolean, name:String):void {
			notifyX(remote, name, "Created");
		}
		
		protected function notifyUpdate(remote:Boolean, name:String):void {
			notifyX(remote, name, "Updated");	
		}
		
		protected function notifyDelete(remote:Boolean, name:String, entity:String = null):void {
			notifyX(remote, name, "Deleted", entity);
		}

		
		protected function resetPage():void {
			_page = 0;
			doRequest();
		}
		
		protected function nextPage(lastPage:Boolean, minRow:int=0, mustBeSame:String=''):void {
			countHandler(_nbItems);
            if (lastPage == false) {
				//VAHI we do not need it anymore, interferes with the new (ab)use of the columns
            	// updateStart(_nbItems, _startId);
            	_page ++;
            	doRequest();
            } else {
				updateLastSync(minRow, mustBeSame);
            }			
		}
  		
	}
}
