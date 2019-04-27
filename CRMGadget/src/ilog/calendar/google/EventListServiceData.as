package ilog.calendar.google
{
  import flash.net.URLVariables;
  
  /**
   * @private
   */ 
  internal class EventListServiceData
  {
    public function EventListServiceData()
    {
    }
    
    public var params:URLVariables;
    public var asynchToken:Object;
    public var calendar:GCalendar;

  }
}