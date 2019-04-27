package
{
	import gadget.dao.Database;
	import gadget.sync.LogEvent;
	import gadget.util.StringUtils;
	
	import ilog.calendar.google.GEvent;
	import ilog.calendar.google.GServiceEvent;
	
	import mx.collections.ArrayCollection;

	public class GoogleCalendarDeleteService extends GoogleCalendarService
	{
		
		private var _records:ArrayCollection;
		private var _item:Object;
		private var i:int;

		public function GoogleCalendarDeleteService(records:ArrayCollection=null){
			_records = records;
			i=0;
		}
		
		override protected function auth_completeHandler(event:GServiceEvent):void {				
			if (event.httpStatus == 200) {
				trace("login sucessfully");
				doDelete();
			} else {
				trace("Problem with login information");
				if(logInfo != null) logInfo(new LogEvent(LogEvent.ERROR, "Problem with google calendar login information"));
				if(end != null) end(this);
			}         
		}
		
		override protected function eventDeleteHandler(evt:GServiceEvent):void {              
			var event:GEvent = evt.item as GEvent;
			if (evt.httpStatus == 200) {
				trace("\"" + event.title + "\" deleted successfully");
				if(eventHandler != null) eventHandler(true, "GCalendar", event.title, "deleted");
			} else {
				trace("Error during deletion of \"" + event.title + "\"");
				if(logInfo != null) logInfo(new LogEvent(LogEvent.ERROR, "Error during deletion of \"" + event.title + "\""));
			}
			doNextDelete();
		} 	
		
		private function doNextDelete():void{
			i++;
			doDelete();
		}
		
		public function doDelete():void {			
			if(_records != null && i<_records.length){
				var _item:Object = _records.getItemAt(i);
				if(StringUtils.isEmpty(_item.GUID)) { doNextDelete(); return; }
				var event:GEvent = new GEvent(new XML(_item.GDATA));
				deleteEvent(event);
			}
		}			
		
	}
}