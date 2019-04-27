package ilog.calendar.google
{
  import flash.net.URLRequestHeader;
  
  public class GUtil
  {
    public function GUtil()
    {
    }     
    
    public static function parseId(feedURL:String):String {     
      var i:int = feedURL.indexOf("feeds/");
      if (i == -1) {
        return null;
      }
      i += 6;
      var i2:int = feedURL.indexOf("/", i);      
      return feedURL.substring(i, i2);    
    } 
    
    public static function isDate(s:String):Boolean {
      return s.length == 10; 
    } 
    
    public static function decodeDate(s:String):Date {
      // example: 2008-05-13
      // example: 2008-05-13T06:56:40.000Z
      // example: 2008-04-11T12:00:00.000+02:00
            
      var year:int = int(s.substr(0, 4));
      var month:int = int(s.substr(5, 2)) - 1; // -1 because Date.month starts from 0
      var date:int = int(s.substr(8, 2));

      var isDate:Boolean = isDate(s);
      
      if (!isDate) { 
            
        var hours:int = int(s.substr(11, 2));
        var minutes:int = int(s.substr(14, 2));
        var seconds:int = int(s.substr(17, 2));
        var milliseconds:int = int(s.substr(20, 3));
      
        if (s.substr(23, 1) == "Z") {
          // UTC time
        } else {
          // offset to decode
          var sign:int = s.substr(23, 1) == "+" ? -1 : 1; //convert local to UTC time
          var offHours:int = int(s.substr(24, 2));
          var offMinutes:int = int(s.substr(27, 2));
        
          hours += sign * offHours;
          minutes += sign * offMinutes;
        
        }
      }
      
      if (isDate) {
        return new Date(year, month, date);
      } else {
        return new Date(Date.UTC(year, month, date, hours, minutes, seconds, milliseconds));
      }
      
    }
    
    public static function encodeDate(d:Date, allDayEvent:Boolean=false):String {
      // example: 2008-05-13T06:56:40.000Z
      var s:String =  (allDayEvent ? d.fullYear : d.fullYearUTC) + "-" +
                      intToString(allDayEvent ? d.month+1 : d.monthUTC+1) + "-" + 
                      intToString(allDayEvent ? d.date : d.dateUTC);
      if (!allDayEvent) {        
        s += "T" + 
             intToString(d.hoursUTC) + ":" +
             intToString(d.minutesUTC) + ":" +
             intToString(d.secondsUTC) + ".000Z";
      }
      
      return s;  
    }
    
    public static function intToString(i:int):String {
      var s:String = "";
      if (i < 10) {
        s += "0";
      }
      return s+i;
    }
    
    public static function parseColor(s:String):uint {
      return uint("0x"+s.substr(1, 6));
    }
    
    public static function getRedirectURL(headers:Array):String {
      var newURL:String;
       
      for each (var rh:URLRequestHeader in headers) {                  
        if (rh.name == "Location") {
          newURL = rh.value;
        }                           
      }
      return newURL;
    }

  }
}