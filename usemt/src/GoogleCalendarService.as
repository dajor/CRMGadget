package
{
	import gadget.dao.Database;
	import gadget.sync.LogEvent;
	
	import ilog.calendar.google.AuthenticationService;
	import ilog.calendar.google.CalendarListService;
	import ilog.calendar.google.CalendarService;
	import ilog.calendar.google.EventListService;
	import ilog.calendar.google.EventService;
	import ilog.calendar.google.GEvent;
	import ilog.calendar.google.GServiceEvent;
	
	public class GoogleCalendarService
	{
	
		private var _logInfo:Function;
		private var _eventHandler:Function;
		private var _end:Function = null;
		
		private var _isStop:Boolean = false;
		
		private var _calendarService:CalendarService;
		
		private var calendarId:String;
		
		public function GoogleCalendarService()
		{
			_calendarService = new CalendarService();
		}
		
		public function get calendarService():CalendarService {
			return _calendarService
		}
		
		public function set logInfo(fn:Function):void {
			_logInfo = fn;
		}
		
		public function get logInfo():Function {
			return _logInfo;
		}
		
		
		public function set eventHandler(fn:Function):void {
			_eventHandler = fn;
		}
		
		public function get eventHandler():Function {
			return _eventHandler;
		}
		
		
		public function set end(fn:Function):void {
			_end = fn;
		}
		
		public function get end():Function {
			return _end;
		}
		
		private function login():void {
			var gAccount:Object = getGmailAccount();
			calendarId = gAccount.username;
			_calendarService.addEventListener(GServiceEvent.SERVICE_RESULT, calendarService_serviceResultHandler);
			_calendarService.setCredentials(gAccount.username, gAccount.password);
			_calendarService.authenticationService.clientLogin();
		}
		
		private function getGmailAccount():Object {
			var prefs:Object = Database.preferencesDao.read();
			return {username:prefs.gmail_username, password:prefs.gmail_password};
		}
		
		private function calendarService_serviceResultHandler(event:GServiceEvent):void {							
			if (event.operation == AuthenticationService.LOGIN) {
				auth_completeHandler(event);
				return;
			}          				
			if (event.httpStatus == 200 ||  // OK
				event.httpStatus == 201) {  // created
				switch(event.operation) {
					case EventService.UPDATE:
						eventUpdatedHandler(event);
						break;
					case EventService.DELETE:
						eventDeleteHandler(event);
						break;
					case CalendarListService.CALENDAR_LIST:          
						calendarListLoadHandler(event.list);
						break;
					case EventListService.EVENT_LIST:
						eventListLoadHandler(event);
						break;
				}
			}else {
				trace("An error has occurred !\nOperation:"+event.operation+"\nitem:"+event.item+"\nHTTP status:"+event.httpStatus);
				if(_end != null) _end(this);
			}
		}	
		
		protected function auth_completeHandler(event:GServiceEvent):void {}
		
		protected function eventUpdatedHandler(evt:GServiceEvent):void {}
		
		protected function eventDeleteHandler(evt:GServiceEvent):void {}
		
		protected function calendarListLoadHandler(calendars:Array):void {}
		
		protected function eventListLoadHandler(event:GServiceEvent):void {}
		
		public function updateEvent(event:GEvent):void {
			if(_isStop) return;
			_calendarService.eventService.updateEvent(event);
		}
		
		public function deleteEvent(event:GEvent):void {
			if(_isStop) return;
			_calendarService.eventService.deleteEvent(event);                             
		}
		
		public function getEvent():void{
			calendarService.calendarListService.getFeed();
		}
		
		public function start():void {
			login();
		}
		
		public function stop():void {
			_isStop = true;
		}
		
	}
}