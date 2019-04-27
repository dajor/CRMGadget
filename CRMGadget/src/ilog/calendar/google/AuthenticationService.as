package ilog.calendar.google
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.HTTPStatusEvent;
  import flash.events.IOErrorEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.net.URLRequestMethod;
  import flash.net.URLVariables;
  
  
  /**
   * The authentication service allows to authenticate the user to 
   * the google calendar service.
   */  
  public class AuthenticationService extends EventDispatcher
  {
    
    /**
     * The user email.
     */  
    public var email:String;
    
    /**
     * The user password.
     */  
    public var password:String;
    
    /**
     * The authentication key used to connect to the google calendar services.
     */   
    public var authKey:String;
    
    public static const LOGIN:String = "login";
    
    private var _calendarService:CalendarService;
        
    /**
     * Contructor.
     * 
     * @param service The calendar service instance.
     */     
    public function AuthenticationService(calendarService:CalendarService) {
      _calendarService = calendarService;
    }
     
    /**
     * Authenticate the user using the client login athentication.
     */     
    public function clientLogin():void {
      
      var loader:URLLoader = new URLLoader();
      loader.addEventListener(Event.COMPLETE, loginLoader_completeHandler);
      loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
      loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, loader_httpResponseHandler, false, 0, true);
      
      var variables:URLVariables = new URLVariables();
      variables.Email = email;
      variables.Passwd = password;
      variables.service = "cl";
	  variables.accountType = "HOSTED_OR_GOOGLE";
      
      
      var request:URLRequest = new URLRequest("https://www.google.com/accounts/ClientLogin");
      request.method = URLRequestMethod.POST;
      request.data = variables;
       
      loader.load(request);        
    }
    
    private function loginLoader_completeHandler(event:Event):void {
      var loader:URLLoader = URLLoader(event.target);
      var s:String = loader.data;
      var res:Array = s.split("\n");
      var tok:Array = String(res[2]).split("=");        
      authKey = tok[1];   
      
      sendGServiceEvent(event);   
    }
    
    private function sendGServiceEvent(event:Event=null):void {
      var evt:GServiceEvent = new GServiceEvent();
      evt.httpStatus = status;
      evt.operation = LOGIN;
      evt.triggerEvent = event;
      _calendarService.sendGServiceEvent(evt);
    }
    
    private function errorHandler(event:IOErrorEvent):void {
      sendGServiceEvent(event);  
    }  
    
    private var status:int; 
    
    private function loader_httpResponseHandler(event:HTTPStatusEvent):void {                
      status = event.status;
    } 

  }
}