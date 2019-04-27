package ilog.calendar.google
{
  import flash.events.Event;
  import flash.events.HTTPStatusEvent;
  import flash.events.IOErrorEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.net.URLVariables;
  
  import mx.core.Application;
  
  use namespace atom;
  
  /**
   * The event list service allows to retrieve the events of a user.
   */  
  public class EventListService extends GServiceBase 
  {
    private var _calendarService:CalendarService;    
    
    public static const EVENT_LIST:String = "eventList";
    
    /**
     * Contructor.
     * 
     * @param service The calendar service instance.
     */ 
    public function EventListService(service:CalendarService) {      
      _calendarService = service;
    }    
    
    /**
     * Retrieves the events.
     * @param calendar Retrieve the events of this particular calendar.
     * @param range Retrieve the events in this particular time range.
     */  
    public function getFeed(calendar:GCalendar=null, range:Array=null):Object {
      return getFeedImpl(calendar, range); 
    }
           
    private function getFeedImpl(calendar:GCalendar=null, range:Array=null, url:String=null, data:EventListServiceData=null):Object {
      
      var url:String;
      
      if (url == null) {      
        if (calendar == null) {
          url = CalendarService.BASE_URL +"/default/private/full";
        } else {
          url = calendar.linkAlternate;
        }
      }
                       
      var params:URLVariables;
      var asynchToken:Object;
      
      if (data == null) {
        
        params = new URLVariables();
        params.singleevents = "true";
            
        if (range != null) {
          
          params["start-min"] = GUtil.encodeDate(range[0] as Date);
          params["start-max"] = GUtil.encodeDate(range[1] as Date);
          //start-min=2006-03-16T00:00:00&start-max=2006-03-24T23:59:59
        }
        
        asynchToken = _calendarService.createAsynchToken();
        
      } else {
        
        params = data.params;
        asynchToken = data.asynchToken;                
      }                      
                       
           
      var req:URLRequest = _calendarService.getURLRequest(url, params);
                      
      var loader:URLLoader = new URLLoader();           
      loader.addEventListener(Event.COMPLETE, eventCompleteHandler, false, 0, true);
      loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler, false, 0, true);        
      loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, loader_httpResponseHandler, false, 0, true);
      
      var data:EventListServiceData = new EventListServiceData();
      data.asynchToken = asynchToken;
      data.calendar = calendar;
      data.params = params;
      
      registerLoader(loader, data);      
      loader.load(req);
      
      return asynchToken;              
    }    
    
    private function eventCompleteHandler(event:Event):void {
      
      if (status == 302) {
        return;
      }
      
      var loader:URLLoader = event.target as URLLoader;
      
      var data:EventListServiceData = retrieveData(loader) as EventListServiceData;      
      var calendar:GCalendar = data.calendar;
      
      var events:Array = [];
                 
      var eventListData:XML = XML(loader.data);      
      
      for each (var child:XML in eventListData.entry) {
        var evt:GEvent = new GEvent(child);
        if (calendar == null) {          
          calendar = _calendarService.calendarListService.getCalendar(evt.calendarId);
          evt.calendar = calendar;
        } else {
          evt.calendar = calendar;  
        }
        
        events.push(evt);
      }
      
      calendar.events = events;
      
      var gsEvent:GServiceEvent = new GServiceEvent();
      gsEvent.asynchToken = data.asynchToken;
      gsEvent.operation = EVENT_LIST;
      gsEvent.list = events;
      gsEvent.item = calendar;
      gsEvent.httpStatus = status; 
      
      _calendarService.sendGServiceEvent(gsEvent);    
      
      clearLoaderData(loader);        
    }
    
    private function loader_ioErrorHandler(event:IOErrorEvent):void {
      var res:XML = XML(event.target.data);
                 
      if (status == 302) {
        // manually managed        
        return;
      }
                  
      var loader:URLLoader = event.target as URLLoader;      
      var data:EventListServiceData = retrieveData(loader) as EventListServiceData;
      
      var gsEvent:GServiceEvent = new GServiceEvent();
      gsEvent.asynchToken = data.asynchToken;
      gsEvent.operation = EVENT_LIST;      
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
          var loader:URLLoader = event.target as URLLoader;
          var data:EventListServiceData = retrieveData(loader) as EventListServiceData;                                    
          var newURL:String = GUtil.getRedirectURL(event.responseHeaders);          
          Application.application.status = "Redirect to " + newURL;
          getFeedImpl(null, null, newURL, data);
          clearLoaderData(loader);
        }                       
      }      
    }
  }
}