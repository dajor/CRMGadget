package gadget.sync.outgoing
{
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.sync.incoming.MSExchangeService;
	
	public class OutgoingMSExchange extends MSExchangeService
	{
		
		public function OutgoingMSExchange(entiy:String)
		{
			super(entiy);	
			
		}

		
		override  public function getName() : String {
			return i18n._('Sending "{1}" data to MS Exchange server', getEntityName());
		}
	
		
		
		override protected function handleResponse(request:XML, response:XML):int{
			var xmlResponse:XMLList = response.child(new QName(ns.uri,'ResponseMessages'));
			var list:XMLList = xmlResponse.child(new QName(ns.uri,'UpdateItemResponseMessage'));
			for each (var data:XML in list) {
				var item:XMLList = data.child(new QName(ns.uri,'Items'));
				var calendarItem:XMLList = item.child(new QName(nsChange.uri,'CalendarItem'));
				var listItem:XMLList = calendarItem.child(new QName(nsChange.uri,'ItemId'));
				var id:String = (listItem.@Id as XMLList)[0] == null ? '': (listItem.@Id as XMLList)[0].toString();
				updateLocal(id);
			}
			successHandler('Successful: '+getName() );
			return 0;
		}
		private function updateLocal(id:String):void{
			var tampObj:Object = Database.activityDao.findByMSId(id);
			if(tampObj != null){
				tampObj.ms_local_change = null;	
				Database.activityDao.update(tampObj);
				_logInfo('Update ' + tampObj.Subject);
			}
			
		}
		
	}
}