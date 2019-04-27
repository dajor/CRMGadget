package ilog.calendar.google
{
  import mx.utils.ColorUtil;
  
  use namespace atom;
  use namespace gCal;
  
  /**
   * The GCalendar is the ActionScript representation of a Google Calendar calendar.
   * The XML data used during server transactions is wrapped by this object.
   * This base implementation only exposes the minimal set of properties but can be 
   * easily improved. 
   */   
  public class GCalendar extends GObject
  {
    private var _events:Array;
    
    /**
     * Constructor.
     * 
     * @param data The wrapped calendar XML data.
     *  
     */ 
    public function GCalendar(data:XML) {
      super(data);
    }
    
    /**
     * The title of this calendar.
     */  
    public function get title():String {
      return data == null ? null : data.title;
    }
    
    /**
     * The summary of this calendar.
     */  
    public function get summary():String {
      return data == null ? null : data.summary;
    }
        
    private var _color:uint = 0;
    private var _colorSet:Boolean = false;    
    
    /**
     * The color of this calendar.
     */  
    public function get color():uint {
      if (data == null) {
        return null;
      }
      if (!_colorSet) {
        _colorSet = true;
        _color = GUtil.parseColor(data.color.@value);
        _color = ColorUtil.adjustBrightness(_color, 52);  
      }
      
      return _color;
    }    
               
    /**
     * @private
     */                    
    public function set events(value:Array):void {
      _events = value;
    }
    
    /**
     * The events of this calendar.
     */  
    public function get events():Array {
      return _events;
    }
    
    /**
     * Remove the specified event from the internal event list.
     * This method does not synchronize with the server but at contrary should be used
     * after the removal on the server.
     */ 
    public function removeEvent(event:GEvent):void {
      _events.splice(_events.indexOf(event));
    }
    
    /**
     * @private
     */ 
    public function toString():String {
      return data == null ? "null" : title;
    }    
          

  }
}