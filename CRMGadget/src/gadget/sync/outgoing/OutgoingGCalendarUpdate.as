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

	public class OutgoingGCalendarUpdate extends GoogleCalendarUpdateService
	{
		
		protected const PAGE_SIZE:int = 1;
		protected var faulted:int = 0;
		
		private var records:ArrayCollection;
		
		public function OutgoingGCalendarUpdate(){
			super(null);		
		}
		
		override protected function eventUpdatedHandler(evt:GServiceEvent):void {
			var event:GEvent = evt.item as GEvent;
			if (evt.httpStatus == 200) {
				doNextUpdate();
				eventHandler(true, "GCalendar", event.title, "Updated");
				updateLocalActivity(event);
			} else {
				logInfo(new LogEvent(LogEvent.ERROR, "Error during update of \"" + event.title + "\""));
				end(this);
			}                    
		}   
		
		private function doNextUpdate():void {
			faulted += 1;
			doUpdate();
		}
		
		private function updateLocalActivity(event:GEvent):void {
			var cols:ArrayCollection = new ArrayCollection([{element_name:"*"}]);
			var filter:String = "GUID='" + event.uid + "'";
			var result:ArrayCollection = Database.activityDao.findAll(cols, filter);
			//Update data xml  (Note: after update to google calendar, event's linkEdit will be changed. we must save the latest update).
			//It is used to update or delete an event on google calendar.
			var itemDb:Object = result[0];
			itemDb.local_update = new Date().getTime();
			itemDb["GDATA"] = event.data;
			Database.activityDao.update(itemDb);
		}	

		override public function doUpdate():void {
			records = Database.activityDao.findGoogleUpdated(faulted, PAGE_SIZE);
			if(records.length != 0){
				if(faulted==0) logInfo(new LogEvent(LogEvent.INFO,"Starting update to google calendar..."));
				for each(var rec:Object in records){
					if(StringUtils.isEmpty(rec.GUID)) continue;
					var data:XML  = new XML(rec.GDATA);
					var isTask:Boolean = true;
				
					if(rec.Activity == "Appointment"){
						//example: 2008-05-13T06:56:40.000Z
						var startTime:String = rec.StartTime;
						startTime = startTime.substr(0,startTime.length-1)+".000Z";
						var endTime:String = rec.EndTime;
						var ns:Namespace = new Namespace('http://schemas.google.com/g/2005');
						var when:XML = data.child(new QName(ns.uri,"when"))[0];
						endTime = endTime.substr(0,endTime.length-1)+".000Z";
						when.@startTime=startTime;
						when.@endTime = endTime;			
						isTask = false;
					}
					var event:GEvent = new GEvent(data);
					if(isTask){
						event.startTime = DateUtils.parse(rec.DueDate, DateUtils.DATABASE_DATE_FORMAT);
						event.endTime = DateUtils.parse(rec.DueDate, DateUtils.DATABASE_DATE_FORMAT);
					}
					event.title = rec.Subject;
					event.content = StringUtils.isEmpty(rec.Description) ? "" : rec.Description;	
					event.where = StringUtils.isEmpty(rec.Location) ? "" : rec.Location;
					updateEvent(event);
				}
			}else{
				logInfo(new LogEvent(LogEvent.INFO,"Updating to google calendar was completed."));
				end(this);
			}
		}
		
		public function bindFunctions(logInfo:Function, logProgress:Function, logCount:Function, eventHandler:Function, end:Function):void {
			this.logInfo		= logInfo;
			this.eventHandler   = eventHandler;
			this.end		= end;
		}
				
	}
}