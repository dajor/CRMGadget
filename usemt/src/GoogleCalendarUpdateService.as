package
{
	import gadget.dao.Database;
	import gadget.sync.LogEvent;
	import gadget.util.DateUtils;
	import gadget.util.StringUtils;
	
	import ilog.calendar.google.GEvent;
	import ilog.calendar.google.GServiceEvent;
	
	import mx.collections.ArrayCollection;

	public class GoogleCalendarUpdateService extends GoogleCalendarService
	{
		
		private var _records:ArrayCollection; 
		private var i:int;
		
		public function GoogleCalendarUpdateService(records:ArrayCollection=null){
			this._records=records;
			i=0;
		}
		
		override protected function auth_completeHandler(event:GServiceEvent):void {				
			if (event.httpStatus == 200) {
				trace("login sucessfully");
				doUpdate();
			} else {
				trace("Problem with login information");
				if(logInfo != null) logInfo(new LogEvent(LogEvent.ERROR, "Problem with google calendar login information"));
				if(end != null) end(this);
			}         
		}
		
		override protected function eventUpdatedHandler(evt:GServiceEvent):void {
			var event:GEvent = evt.item as GEvent;
			if (evt.httpStatus == 200) {
				updateLocalActivity(event);
				if(eventHandler != null) eventHandler(true, "GCalendar", event.title, "Updated");
			} else {
				if(logInfo != null) logInfo(new LogEvent(LogEvent.ERROR, "Error during update of \"" + event.title + "\""));
				doNextUpdate();
			}                    
		}
		
		private function updateLocalActivity(event:GEvent):void {
			var _item:Object = _records.getItemAt(i);
			_item.local_update = null;
			_item["GDATA"] = event.data;
			Database.activityDao.update(_item);
			doNextUpdate();
		}	
		
		private function doNextUpdate():void {
			i++;
			doUpdate();
		}
		
		public function doUpdate():void {
			
			if(_records != null && i<_records.length){
				var _item:Object =_records.getItemAt(i);
				if(StringUtils.isEmpty(_item.GUID)) { doNextUpdate(); return; }
				var event:GEvent = new GEvent(new XML(_item.GDATA));
				event.title = _item.Subject;
				event.content = StringUtils.isEmpty(_item.Description) ? "" : _item.Description;	
				event.where = StringUtils.isEmpty(_item.Location) ? "" : _item.Location;
				if(_item.Activity == "Appointment"){
					event.startTime = DateUtils.parse(_item.StartTime, DateUtils.DATABASE_DATETIME_FORMAT);
					event.endTime = DateUtils.parse(_item.EndTime, DateUtils.DATABASE_DATETIME_FORMAT);
				}else{//Task
					event.startTime = DateUtils.parse(_item.DueDate, DateUtils.DATABASE_DATE_FORMAT);
					event.endTime = DateUtils.parse(_item.DueDate, DateUtils.DATABASE_DATE_FORMAT);
				}
				updateEvent(event);
			}
			
		}
		
	}
}