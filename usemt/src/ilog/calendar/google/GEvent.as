package ilog.calendar.google
{
  use namespace atom;
  use namespace gCal;
  use namespace gd;
  
  /**
   * The GEvent is the ActionScript representation of a Google Calendar event.
   * The XML data used during server transactions is wrapped by this object.
   * This base implementation only exposes the minimal set of properties but can be 
   * easily improved. 
   */   
  public class GEvent extends GObject
  {
    
    private var _calendar:GCalendar;
    
    /**
     * Constructor
     * 
     * @param data The XML (entry tag) that represents an Google event.
     *             If this parameter is null, a default XML data will be created. 
     *             This data is valid if and only if it has been committed to the server.  
     */  
    public function GEvent(data:XML=null)
    {     
      super(data);    
      
      if (data != null) {
        allDayEvent = GUtil.isDate(data.when.@startTime) && GUtil.isDate(data.when.@endTime);
        var org:XMLList = data.originalEvent;
        _recurrenceInstance = org.length() != 0;
      }
       
    }
    
    private var _recurrenceInstance:Boolean = false;
    
    /**
     * Creates the base event XML data (new event).
     */  
    override protected function createDefaultData():XML {
      return <entry xmlns='http://www.w3.org/2005/Atom'
                    xmlns:gd='http://schemas.google.com/g/2005'>
               <category scheme='http://schemas.google.com/g/2005#kind'
                         term='http://schemas.google.com/g/2005#event'>
               </category>
               <title type='text'></title>
	  		   <visibility type='text'></visibility>
	  		   <uid type='text'></uid>
	  	       <where type='text'></where>
               <content type='text'></content>
               <gd:transparency
                 value='http://schemas.google.com/g/2005#event.opaque'>
               </gd:transparency>
               <gd:eventStatus
                 value='http://schemas.google.com/g/2005#event.confirmed'>
               </gd:eventStatus>              
               <gd:when startTime='2008-01-8T00:00:00.000Z'
                        endTime='2008-01-18T00:00:00.000Z'></gd:when>
             </entry>;
    }
	
	public function get visibility():String {
//		return data == null ? null : data.visibility == "" ? "" : data.visibility;
		if(data == null){
			return "";
		}else if(data.visibility.@value == ""){
			return "";
		}else{
			var value:String = data.visibility.@value;
			value = value.substr(value.lastIndexOf(".")+1);
			return value;
		}
	}
    
	public function set visibility(value:String):void {
		data.visibility = value;
	}
	
	public function get uid():String {
		if(data == null) return "";
		return data.uid.@value;
	}
	
	public function set uid(value:String):void {
		data.uid.@value = value;	
	}
	
	public function get where():String {
		if(data == null) return "";
		return data.where.@valueString;
	}
	
	public function set where(value:String):void {
		data.where.@valueString = value;	
	}
	
    /**
     * Title of the event.
     */  
    public function get title():String {
      return data == null ? null : data.title == "" ? "(No Subject)" : data.title;
    }
    
    /**
     * @private
     */  
    public function set title(value:String):void {
      data.title = value;
    }
    
    /**
     * Content of the event.
     */  
    public function get content():String {
      return data == null ? null : data.content == "" ? "" : data.content;
    }
    
    /**
     * @private
     */
    public function set content(value:String):void {
      data.content = value;
    }    
          
    private var _allDayEvent:Boolean; 
    
    /**
     * Whether this event is all day event or not. 
     */  
    public function get allDayEvent():Boolean {
      return _allDayEvent; 
    }
    
    /**
     * @private
     */
    public function set allDayEvent(value:Boolean):void {
      _allDayEvent = value; 
    }
    
    /**
     * The start time of the event.
     */
    public function get startTime():Date {
      if (data == null) {
        return null;
      }
      return GUtil.decodeDate(data.when.@startTime); 
    }
    
    /**
     * @private
     */
    public function set startTime(value:Date):void {    
      data.when.@startTime = GUtil.encodeDate(value, allDayEvent);
    }
    
    /**
     * The end time of the event.
     */   
    public function get endTime():Date {
      return GUtil.decodeDate(data.when.@endTime);
    }
    
    /**
     * @private
     */
    public function set endTime(value:Date):void {      
      data.when.@endTime = GUtil.encodeDate(value, allDayEvent);
    }
    
    /**
     * @private
     */
    public function set calendar(value:GCalendar):void {
      _calendar = value;
    }
    
    /**
     * The calendar of this event.
     */  
    public function get calendar():GCalendar {
      return _calendar;
    }
    
    /**
     * @private
     */ 
    public function toString():String {
      return data == null ? "null" : title + ":" + startTime + " -> " + endTime;
    }
    
    /**
     * The google identifier of the calendar of this event.
     */  
    public function get calendarId():String {      
      return GUtil.parseId(linkSelf);               
    }    
    
    /**
     * Whether this event is a regular event or a instance of a recurring event.
     */  
    public function isRecurrenceInstance():Boolean {      
      return _recurrenceInstance;
    }
    
  }
}