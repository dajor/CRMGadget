package ilog.calendar.google
{
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.net.URLRequest;
  import flash.net.URLRequestHeader;
   
  
  [Event(name="service_result", type="ilog.calendar.google.GServiceEvent")]
  
  /**
   * The calendar service is the entry point of all the google calendar services.
   * 
   * <p>
   * The following object are available:
   * <ul>
   * <li>authenticationService: allows to autheticate the user to the google calendar servers.</li>
   * <li>calendarListService: allows to retrieve the list of calendars owned by the user.</li>
   * <li>eventListService: allows to retrieve the events of the user.</li>
   * <li>eventService: allows to create/delete/update an event.</li>
   * </ul>
   * </p>
   * 
   * <p>
   * The way of using this class is to register a list on GServiceEvent events and call 
   * the sub services.
   * </p>
   */  
  public class CalendarService extends EventDispatcher
  {
    
    public static const BASE_URL:String = "http://www.google.com/calendar/feeds";
    
    public var authenticationService:AuthenticationService;   
    public var calendarListService:CalendarListService;    
    public var eventListService:EventListService;    
    public var eventService:EventService;    
    
    /**
     * Constructor
     */  
    public function CalendarService()
    {
      authenticationService = new AuthenticationService(this);    
      calendarListService = new CalendarListService(this);    
      eventListService = new EventListService(this); 
      eventService = new EventService(this);                       
    }
    
    /**
     * Set the credentials to the authentication service.
     */ 
    public function setCredentials(email:String, password:String):void {
      authenticationService.email = email;
      authenticationService.password = password;
    }
    
    /**
     * @private 
     */  
    internal function getURLRequest(url:String, data:Object=null, headers:Array=null, method:String=null):URLRequest {
            
      var urlRequest:URLRequest = new URLRequest();
      
      urlRequest.url = url;
      urlRequest.followRedirects = false;
      
      urlRequest.requestHeaders = [
        new URLRequestHeader("Authorization", "GoogleLogin auth=" 
                              + authenticationService.authKey)        
      ];
      
      if (headers != null) {        
        urlRequest.requestHeaders = urlRequest.requestHeaders.concat(headers); 
      }
      
      if (method != null) {
        urlRequest.method = method;
      }
       
      if (data != null) {
        urlRequest.data = data;
      }
                       
      return urlRequest;
    }    
       
    private var _asynchToken:uint = 0;
    
    /**
     * @private
     */ 
    internal function createAsynchToken():Object {
      return _asynchToken++;
    }
    
    /**
     * @private
     */  
    internal function sendGServiceEvent(event:GServiceEvent):void {
      dispatchEvent(event);
    }
    

  }
}