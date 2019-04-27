package gadget.util
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import gadget.control.CalendarIlog;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	
	import ilog.calendar.Calendar;
	import ilog.calendar.google.GCalendar;
	import ilog.calendar.google.GEvent;
	import ilog.calendar.google.GServiceEvent;
	import ilog.utils.TimeUnit;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.formatters.DateFormatter;
	import mx.utils.ObjectProxy;
	
	public class IncomingGoogleCalendar extends GoogleCalendarService
	{	

		private var _currentCalendarIndex:int = 0;          
		private var _dataRange:Array;  
		private var _queryRange:Array;  
		private var collection:ArrayCollection;
		
		private var _cal:Calendar;
		private var _calendarILog:CalendarIlog;
		
		public var googleSync:GoogleSynchronize;
		
		public function IncomingGoogleCalendar(calendarILog:CalendarIlog){
			_calendarILog = calendarILog;
			_cal = calendarILog.cal;
		}
		
		override protected function auth_completeHandler(event:GServiceEvent):void {				
			if (event.httpStatus == 200) {
				getEvent();				
			} else {
				logMsg("Problem with login information");
				googleSync.isSynching = false;
				googleSync.initButtons();
			}         
		}
		
		override protected function eventListLoadHandler(event:GServiceEvent):void {				
			_currentCalendarIndex++;				
			var calendars:Array = calendarService.calendarListService.calendars;				
			if (_currentCalendarIndex < calendars.length) {						
				calendarService.eventListService.getFeed(calendars[_currentCalendarIndex], _queryRange);					
				if (collection != null) {            
					for each (var evt:GEvent in event.list) {
						collection.addItem(evt);  
					}
				}
			} else {
				if (collection == null) {
					for each(var gActivity:Object in createModel(calendars)){
						if(googleSync.isSynching == false) { _calendarILog.loadData(); return; }
						upsertActivity(gActivity);
						logMsg(gActivity.Subject);
					}
					googleSync.isSynching = false;
					googleSync.initButtons();
					_calendarILog.loadData();
				} else {         
					for each (evt in event.list) {
						collection.addItem(evt);  
					}
				}                                                       
			}
		}
		
		override protected function calendarListLoadHandler(calendars:Array):void {
			// initial range
			_dataRange = [
				_cal.startDisplayedDate,
				_cal.calendar.addUnits(_cal.endDisplayedDate, TimeUnit.DAY, 1)
			];                     
			if (calendars.length > 0) {
				loadEvents(_dataRange);
			} else {          
				logMsg("No calendar to load");
				googleSync.isSynching = false;
				googleSync.initButtons();
			}  
		} 		
		
		private function logMsg(taskTitle:String):void {
			var d:Date = new Date();
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "JJ:NN:SS";
			var msg:Object = {time:dateFormatter.format(d),message:taskTitle};
			googleSync.loggingMessages.addItem(new ObjectProxy(msg));
			googleSync.dgLoggingArea.validateNow();
			googleSync.dgLoggingArea.verticalScrollPosition = googleSync.dgLoggingArea.maxVerticalScrollPosition;
		}
		
		private function upsertActivity(item:Object):void {
			
			var oidName:String = DAOUtils.getOracleId("Activity");
			var cols:ArrayCollection = new ArrayCollection([{element_name:"*"}]);
			var filter:String = "GUID='" + item.GUID + "'";
			var result:ArrayCollection = Database.activityDao.findAll(cols, filter);
			
			if(result.length == 0){ //If not existed, then insert new
				delete item[oidName];
				Database.activityDao.insert(item);
				item = Database.activityDao.selectLastRecord()[0];
				item[oidName] = "#" + item.gadget_id; //by default, sets the OracleId as gadget_id
				Database.activityDao.update(item);
			}else{
				var itemDb:Object = result[0];
				itemDb.local_update = new Date().getTime();
				for (var field:String in item) {
					itemDb[field] = item[field];
				}
				Database.activityDao.update(itemDb);
			}
			
			_calendarILog.refreshFunction(item); //Refresh GUI
			
		}
		
		private function loadEvents(range:Array):void {                
			var calendars:Array = calendarService.calendarListService.calendars;
			_queryRange = range;
			_currentCalendarIndex = 0;
			// delay request
			var t:Timer = new Timer(1500, 1);
			t.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:Event):void {
				calendarService.eventListService.getFeed(calendars[0], _queryRange);
			});
			t.start();                                                    
		} 
		
		private function createModel(calendarList:Array):ICollectionView {
			var model:Array = [];
			var user:Object = Database.userDao.read();
			for each (var calendar:GCalendar in calendarList) {
				for each(var event:GEvent in calendar.events){
					var actEvent:Object = new Object();
					actEvent.IsPrivateEvent = event.visibility.toUpperCase() == "PRIVATE"; //It is private or public google event
					if(actEvent.IsPrivateEvent) continue; //if google event is private, we won't sync it to gadget or oracle
					actEvent.Subject = event.title;
					actEvent.gadget_type = "Activity";
					actEvent.Priority = "2-Medium";	
					actEvent.Type = "Event";
					actEvent.Location = event.where;
					actEvent.Description = event.content;
					actEvent.GUID = event.uid; //uid for the google event
					actEvent.GDATA = event.data;

					var stTime:Date = event.startTime;
					var edTime:Date = event.endTime;
					
					if(!event.allDayEvent){
						actEvent["Activity"] = "Appointment";
						actEvent.StartTime = DateUtils.format(new Date(stTime.fullYearUTC,stTime.monthUTC,stTime.dateUTC,stTime.hoursUTC,stTime.minutesUTC,stTime.secondsUTC), DateUtils.DATABASE_DATETIME_FORMAT);
						actEvent.EndTime = DateUtils.format(new Date(edTime.fullYearUTC,edTime.monthUTC,edTime.dateUTC,edTime.hoursUTC,edTime.minutesUTC,edTime.secondsUTC), DateUtils.DATABASE_DATETIME_FORMAT);
					}else{
						actEvent["Activity"] = "Task";
						actEvent.DueDate = DateUtils.format(stTime, DateUtils.DATABASE_DATE_FORMAT);
					}
					
					actEvent["CallType"] = "General";
					actEvent["ModifiedDate"] =DateUtils.format(new Date(), DateUtils.DATABASE_DATETIME_FORMAT);			
					actEvent["deleted"] = false;
					actEvent["error"] = false;
					if(actEvent["OwnerId"] == null || actEvent["OwnerId"]==""){
						if(user) actEvent["OwnerId"] = user.id;
					}
					
					model.push(actEvent);
				}
			}
			collection = new ArrayCollection(model);
			collection.refresh();    
			return collection;   
		}
		
	}
}