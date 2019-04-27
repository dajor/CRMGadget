package gadget.sync.outgoing
{
	import gadget.dao.Database;
	import gadget.sync.LogEvent;
	import gadget.util.DateUtils;
	import gadget.util.StringUtils;
	
	import ilog.calendar.google.AuthenticationService;
	import ilog.calendar.google.CalendarService;
	import ilog.calendar.google.EventService;
	import ilog.calendar.google.GEvent;
	import ilog.calendar.google.GServiceEvent;
	
	import mx.collections.ArrayCollection;
	
	public class OutgoingGCalendarDelete extends GoogleCalendarDeleteService
	{
		
		protected const PAGE_SIZE:int = 1;
		protected var faulted:int = 0;
		
		private var records:ArrayCollection;
		
		private var calendarId:String;
		
		public function OutgoingGCalendarDelete(){}
		
		override protected function eventDeleteHandler(evt:GServiceEvent):void {              
			var event:GEvent = evt.item as GEvent;
			if (evt.httpStatus == 200) {
				doNextDelete();
				trace("\"" + event.title + "\" deleted successfully");
				eventHandler(true, "GCalendar", event.title, "deleted");
			} else {
				trace("Error during deletion of \"" + event.title + "\"");
				logInfo(new LogEvent(LogEvent.ERROR, "Error during deletion of \"" + event.title + "\""));
				end(this);
			}
		} 		
		
		override public function doDelete():void {			
			records = Database.activityDao.findGoogleDeleted(faulted, PAGE_SIZE);
			if(records.length != 0){
				if(faulted==0) logInfo(new LogEvent(LogEvent.INFO,"Starting delete in google calendar..."));
				for each(var rec:Object in records){
					if(StringUtils.isEmpty(rec.GUID)) continue;
					var event:GEvent = new GEvent(new XML(rec.GDATA));
					deleteEvent(event);
				}
			}else{
				logInfo(new LogEvent(LogEvent.INFO,"Deleting in google calendar was completed."));
				end(this);
			}
		}
		
		private function doNextDelete():void {
			faulted += 1;
			doDelete();
		}
		
		public function bindFunctions(logInfo:Function, logProgress:Function, logCount:Function, eventHandler:Function, end:Function):void {
			this.logInfo		= logInfo;
			this.eventHandler   = eventHandler;
			this.end			= end;
		}
	}
}