package ilog.calendar.google
{
  import flash.events.Event;
  import flash.events.HTTPStatusEvent;
  import flash.events.IOErrorEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  
  import mx.core.Application;
  
  use namespace atom;  
  
  /**
   * This service allows to retrieve the list of the calendars owned by the user.    
   */  
  public class CalendarListService extends GServiceBase 
  {
    private var _calendarService:CalendarService;    
    private var _calendars:Array;
    private var _idToCalendarMap:Object = {};
    
    public static const CALENDAR_LIST:String = "CalendarList";
    
    /**
     * Contructor.
     * 
     * @param service The calendar service instance.
     */       
    public function CalendarListService(service:CalendarService) {      
      _calendarService = service;
    }
    
    /**
     * The list of calendars.
     */  
    public function get calendars():Array {
      return _calendars;
    }
    
    /**
     * Retrieves the list of calendar owned by the user.          
     */
    public function getFeed():void {
      getFeedImpl();
    } 
     
    private function getFeedImpl(url:String=null, asynchToken:Object=null):void {
      
      _idToCalendarMap = {};
      
      if (url == null) {
        url = CalendarService.BASE_URL +"/default/owncalendars/full"
      }
                 
      if (asynchToken == null) {
        asynchToken = _calendarService.createAsynchToken();
      }
      var req:URLRequest = _calendarService.getURLRequest(url);
      
      var loader:URLLoader = new URLLoader();                                     
      loader.addEventListener(Event.COMPLETE, loader_completeHandler, false, 0, true);
      loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler, false, 0, true);    
      loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, loader_httpResponseHandler, false, 0, true);
                 
      registerLoader(loader, asynchToken);      
      loader.load(req);      
    }              
    
    private function loader_completeHandler(event:Event):void {
      
      if (status == 302) {
        return;
      }
      
      var res:XML = XML(event.target.data);
      
      _calendars = [];
      
      for each (var child:XML in res.entry) {
        var cal:GCalendar = new GCalendar(child);
        calendars.push(cal);
        _idToCalendarMap[GUtil.parseId(cal.linkAlternate)] = cal;
      }
      
      var loader:URLLoader = event.target as URLLoader;
      
      var asynchToken:Object = retrieveData(loader);
      
      var gsEvent:GServiceEvent = new GServiceEvent();
      gsEvent.asynchToken = asynchToken;
      gsEvent.operation = CALENDAR_LIST;
      gsEvent.list = _calendars;
      gsEvent.httpStatus = status; 
      
      _calendarService.sendGServiceEvent(gsEvent);    
      
      clearLoaderData(loader);       
    }

    public function getCalendar(id:String):GCalendar {
      return _idToCalendarMap[id];
    }

    private function loader_ioErrorHandler(event:IOErrorEvent):void {
      
      if (status == 302) {
        // manually managed      
        return;
      }
      
      var loader:URLLoader = event.target as URLLoader;      
      var asynchToken:Object = retrieveData(loader);
      
      var gsEvent:GServiceEvent = new GServiceEvent();
      gsEvent.asynchToken = asynchToken;
      gsEvent.operation = CALENDAR_LIST;      
      gsEvent.httpStatus = status; 
      gsEvent.triggerEvent = event;
      
      _calendarService.sendGServiceEvent(gsEvent);
      
      clearLoaderData(loader);              
    }

    private var status:int;
    
    private function loader_httpResponseHandler(event:HTTPStatusEvent):void {
                 
      status = event.status;
                       
      if (event.status != 200) {
                
        if (event.status == 302) {
          var newURL:String = GUtil.getRedirectURL(event.responseHeaders);                                  
          Application.application.status = "Redirect to " + newURL;
          
          var loader:URLLoader = event.target as URLLoader;      
          var asynchToken:Object = retrieveData(loader);
          clearLoaderData(loader);
              
          getFeedImpl(newURL, asynchToken);                          
        }                    
      }          
    }
    
  }
}