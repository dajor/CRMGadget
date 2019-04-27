package ilog.calendar.google
{
  import flash.events.Event;
  import flash.events.HTTPStatusEvent;
  import flash.events.IOErrorEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.net.URLRequestHeader;
  import flash.net.URLRequestMethod;
  
  import mx.core.Application;
  
  use namespace atom;
  use namespace gCal;
  use namespace gd;
  use namespace batch;
  
  /**
   * This service allows to create/delete/update an event.
   */  
  public class EventService extends GServiceBase 
  {
    private var _calendarService:CalendarService;       
        
    public static const QUICK_ADD:String = "quickAdd";
    public static const CREATE:String = "create";
    public static const UPDATE:String = "update";
    public static const DELETE:String = "delete";
    
    public var status:int;

    /**
     * Contructor.
     * 
     * @param service The calendar service instance.
     */     
    public function EventService(service:CalendarService) {
      
      _calendarService = service;
    }                     
           
    public function updateEvent(event:GEvent):Object {
      return updateEventImpl(event, event.linkEdit);
    }
      
    private function updateEventImpl(event:GEvent, url:String=null, data:EventServiceData=null):Object {
                 
      if (event == null && data == null) {
        return null;
      } 
      
      var eventData:XML;                          
      var asynchToken:Object;
      
      if (data == null) {
        eventData = event.data;
        event.data.sequence.@value = int(event.data.sequence.@value)+1;
        asynchToken = _calendarService.createAsynchToken();
      } else {
        eventData = data.data;
        asynchToken = data.asynchToken;
      }
      
      var headers:Array = [
        new URLRequestHeader("Content-Type", "application/atom+xml")        
      ];       
      
      if (url == null) {
        url = event.linkEdit;
      }
      
      var req:URLRequest = _calendarService.getURLRequest(url, eventData, headers, URLRequestMethod.PUT);
      var loader:URLLoader = new URLLoader();
      
      loader.addEventListener(Event.COMPLETE, loaderUpdate_completeHandler);
      loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler); 
      loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, loader_httpResponseHandler);           
      
      var data:EventServiceData = new EventServiceData();
      data.asynchToken = asynchToken;
      data.event = event;
      data.data = eventData;
      data.operation = UPDATE;
      
      registerLoader(loader, data);      
      loader.load(req);           
      
      return asynchToken; 
    }
    
    private function createGServiceEvent(data:EventServiceData):GServiceEvent {
      var gsEvent:GServiceEvent = new GServiceEvent();
      gsEvent.asynchToken = data.asynchToken;
      gsEvent.item = data.event;
      gsEvent.httpStatus = status;
      gsEvent.operation = data.operation;
      return gsEvent;
    }    
    
        
    private function loaderUpdate_completeHandler(event:Event):void {
      
      if (status == 302) {
        return;
      }
      
      var loader:URLLoader = event.target as URLLoader;      
      var data:EventServiceData = retrieveData(loader) as EventServiceData;
           
      
      var res:XML = XML(event.target.data);                                     
      data.event.data = res;              
      
      _calendarService.sendGServiceEvent(createGServiceEvent(data));               
    }
    
    public function quickAddEvent(s:String, calendar:GCalendar=null):Object {
      return quickAddEventImpl(s, calendar);
    }
    
    private function quickAddEventImpl(s:String, calendar:GCalendar=null, url:String=null, data:EventServiceData=null):Object {
      
      if ((s == null || s == "") && data == null) {
        return null;
      }  
      
      var eventData:XML;
      var event:GEvent;                   
      var asynchToken:Object;
      
      if (data == null) {
      
        eventData = 
          <entry xmlns='http://www.w3.org/2005/Atom' xmlns:gCal='http://schemas.google.com/gCal/2005'>          
            <gCal:quickadd value="true"/>
          </entry>;
          
        eventData.content = s;
        eventData.content.@type = "html";
        event = new GEvent(eventData);
        event.calendar = calendar;              
        asynchToken = _calendarService.createAsynchToken();
      } else {
        eventData = data.data;
        asynchToken = data.asynchToken;
        event = data.event;
      }                              
      
      if (url == null) {
        url = calendar == null ? CalendarService.BASE_URL +"/default/private/full" : 
                                 calendar.linkAlternate;
      }

      var headers:Array = [
        new URLRequestHeader("Content-Type", "application/atom+xml")        
      ];
      
      var loader:URLLoader = new URLLoader(); 
      var req:URLRequest = _calendarService.getURLRequest(url, event.data, headers, URLRequestMethod.POST);
      loader.addEventListener(Event.COMPLETE, loaderCreate_completeHandler, false, 0, true);
      loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler, false, 0, true); 
      loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, loader_httpResponseHandler, false, 0, true);
      
      var data:EventServiceData = new EventServiceData();
      data.asynchToken = asynchToken;
      data.event = event;
      data.data = eventData;
      data.operation = QUICK_ADD;
      
      registerLoader(loader, data);      
      loader.load(req);
      
      return asynchToken; 
    }
    
    public function createEvent(event:GEvent, calendar:GCalendar=null):Object {
      return createEventImpl(event, calendar);
    }
    
    public function createEventImpl(event:GEvent, calendar:GCalendar=null, url:String=null, data:EventServiceData=null):Object {
      
      if (event == null && data == null) {
        return null;
      }
      
      var eventData:XML;                          
      var asynchToken:Object;
      
      if (data == null) {
        eventData = event.data;       
        asynchToken = _calendarService.createAsynchToken();
      } else {
        event = data.event;
        eventData = data.data;
        asynchToken = data.asynchToken;
      }                     
      
      if (url == null) {
        url = calendar == null ? CalendarService.BASE_URL +"/default/private/full" : 
                                 calendar.linkAlternate;
      }

      var headers:Array = [
        new URLRequestHeader("Content-Type", "application/atom+xml")        
      ];
      
      var loader:URLLoader = new URLLoader();
      var req:URLRequest = _calendarService.getURLRequest(url, event.data, headers, URLRequestMethod.POST);
      loader.addEventListener(Event.COMPLETE, loaderCreate_completeHandler, false, 0, true);
      loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler, false, 0, true); 
      loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, loader_httpResponseHandler, false, 0, true);
      
      var data:EventServiceData = new EventServiceData();
      data.asynchToken = asynchToken;
      data.event = event;      
      data.data = eventData;
             
      data.operation = CREATE;
      
      registerLoader(loader, data);      
      loader.load(req);           
      
      return asynchToken;    
    }    
    
    private function loaderCreate_completeHandler(event:Event):void {
      
      if (status == 302) {
        return;
      }
      
      var res:XML = XML(event.target.data);
      
      var loader:URLLoader = event.target as URLLoader;      
      var data:EventServiceData = retrieveData(loader) as EventServiceData;
                 
      data.event.data = res;
      
      _calendarService.sendGServiceEvent(createGServiceEvent(data));                        
    }
    
    public function deleteEvent(event:GEvent):Object {
      return deleteEventImpl(event);  
    }
    
    public function deleteEventImpl(event:GEvent, url:String=null, data:EventServiceData=null):Object {
      
      if (event == null && data == null) {
        return null;
      }
                                     
      var asynchToken:Object;
      
      if (data == null) {        
        asynchToken = _calendarService.createAsynchToken();
      } else {        
        event = data.event;
        asynchToken = data.asynchToken;
      }           
      
      if (url == null) {
        url = event.linkEdit;
      }
      
      var loader:URLLoader = new URLLoader();
      var req:URLRequest = _calendarService.getURLRequest(url, null, null, URLRequestMethod.DELETE);
      loader.addEventListener(Event.COMPLETE, loaderDelete_completeHandler);
      loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler); 
      loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, loader_httpResponseHandler);
      
      var data:EventServiceData = new EventServiceData();
      data.asynchToken = asynchToken;
      data.event = event;      
      data.operation = DELETE;
      
      registerLoader(loader, data);      
      loader.load(req);           
      
      return asynchToken;  
    }    
    
        
    private function loaderDelete_completeHandler(event:Event):void {
      if (status == 302) {
        return;
      }
      
      var loader:URLLoader = event.target as URLLoader;      
      var data:EventServiceData = retrieveData(loader) as EventServiceData;      
      _calendarService.sendGServiceEvent(createGServiceEvent(data));      
    }
                  
    private function loader_ioErrorHandler(event:IOErrorEvent):void {
      
      if (status == 302) {
        // manually managed        
        return;
      }
      
      var loader:URLLoader = event.target as URLLoader;      
      var data:EventServiceData = retrieveData(loader) as EventServiceData;
      
      var gsEvent:GServiceEvent = createGServiceEvent(data);      
      gsEvent.triggerEvent = event;
      
      _calendarService.sendGServiceEvent(gsEvent);
      
      clearLoaderData(loader);
            
    }
    
    private function loader_httpResponseHandler(event:HTTPStatusEvent):void {
      
      status = event.status; 
            
      if (event.status != 200) {
                     
        if (event.status == 302) {
          
          // handle redirect
          var loader:URLLoader = event.target as URLLoader;
          var data:EventServiceData = retrieveData(loader) as EventServiceData;
          
          var newURL:String = GUtil.getRedirectURL(event.responseHeaders);                                  
          Application.application.status = "Redirect to ("+ data.operation +") " + newURL;
          
          switch(data.operation) {
            case QUICK_ADD:
              quickAddEventImpl(null, data.calendar, newURL, data);
            case CREATE:
              createEventImpl(data.event, null, newURL, data);
              break;
            case DELETE:
              deleteEventImpl(data.event, newURL, data);
              break;
            case UPDATE:
              updateEventImpl(data.event, newURL, data);
              break;            
          }
          
          clearLoaderData(loader);                 
        }               
      }
    }

           
  }
}