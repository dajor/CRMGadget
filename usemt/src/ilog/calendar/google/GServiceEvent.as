package ilog.calendar.google
{
  import flash.events.Event;

  /**
   * The event sent by the google services classes.
   */  
  public class GServiceEvent extends Event
  {
    
    public static const SERVICE_RESULT:String = "service_result";
    
    /**
     * Contructor.
     */ 
    public function GServiceEvent(type:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      if (type == null) {
        type = SERVICE_RESULT;
      }
      super(type, bubbles, cancelable);
    }
    
    /**
     * The token that identifies a request.
     */      
    public var asynchToken:Object;
    
    /**
     * The operation that was done.
     */  
    public var operation:String;
    
    /**
     * The http status code of the request response.
     */  
    public var httpStatus:int;
    
    /**
     * The item of the request. It could be a GCalendar or a GEvent instance.
     */  
    public var item:GObject;
    
    /**
     * A list result. It could be a calendar list or an event list.
     */  
    public var list:Array;  // events or calendar list
    
    /**
     * The trigger event.
     */  
    public var triggerEvent:Event;
    
  }
}