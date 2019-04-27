package ilog.calendar.google
{
  /**
   * @private
   */  
  internal class EventServiceData
  {
    public function EventServiceData()
    {
    }
    
    public var params:Object;
    public var asynchToken:Object;
    public var calendar:GCalendar;
    public var event:GEvent;
    public var data:XML;
    public var operation:String;
    
  }
}