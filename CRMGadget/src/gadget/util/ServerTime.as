package gadget.util
{
	public class ServerTime
	{
		public function ServerTime()
		{
		}
		
		//VAHI start bullshit
		// For traditional reasons, we do use Siebel native timestamps (Server time).
		// These have an offset to the real time according to a timezone which is/was missing(!).
		// Historically we do not calculate with the real time but with the biased value.
		// So the timestamp is stored in a date with the timestamp value being considered UTC.
		// To get the real UTC (zulu) time, we need to have the timezone set to substract it.
		//
		// This is done in sync getTime.  Without this we cannot know the timezone.
		// If it is needed ever, we have to keep a copy around (like in preferences).
		// However we are in deep shit then if this TZ ever changes (perhaps because
		// the server is relocated, who knows).
		private static var myTZ:int;
		private static var initedTZ:Boolean = false;
		public static function setSodTZ(sec:int, date:String, tzstring:String,reset:Boolean=false):void {
			sec *= 1000;
			if (initedTZ) {
				if (myTZ!=sec) {
					OOPS("=should_not_happen", "timezone jump from "+myTZ.toString()+" to "+sec.toString());
				}
				if(reset){
					myTZ = sec;
				}
				
				return;
			}
			initedTZ = true;
			myTZ = sec;
			if(date==null) return;
			// dt.UTC now is the date the SOD server expects for its timezone.
			var dt:Date = parseSodDate(date);
			var sod:Date = new Date(dt.getTime()-getSodTZ());
			OOPS("=fix time", "TIM "+date,"TZ  "+tzstring,"SEC "+(myTZ/1000),"SOD "+sod.toUTCString(), "NOW "+(new Date()).toUTCString());
		}
		private static function getSodTZ():int {
			if (!initedTZ) {
				//Mony
				//throw new Error("timezone not yet set");
				return 0;
			}
			return myTZ;
		}
		public static function toSodIsoDate(d:Date):String {
			return DateUtils.toIsoDate(toSODDate(d))+"Z";
		}
		
		public static function toSODDate(d:Date):Date{
			
			return new Date(d.getTime()-getSodTZ()); 
		}
		
		public static function toUserTime(s:String):Date{
			var d:Date = new Date(s+ " UTC");
			return new Date(d.getTime()+getSodTZ());
			
		}
		/*
		// Get the current date, ISO formatted
		public static function getIsoDate():String {
		var s:String = toIsoDate(new Date());
		//			trace("now",s);
		return s;
		}
		*/
		// Parse current date, ISO formatted
		// Thinking help:
		// (ts==(new Date(ts)).getTime())==true always
		// ts is UTC Milliseconds since Epoch (1970)
		// So (new Date(ts)).getUTCHours() returns the hour of the TS.
		// If the TS had another TZ, this is the hour of the same TZ.
		// For Siebel:
		// Siebel gives us some (unknown) timezone.
		// This is (later) assumed to be the TZ set by setSodTZ().
		// Now to convert a ZULU timestamp to SoD date, we have to add the TZ.
		// To convert it back to ZULU timestamp, we have to sub the TZ (see toSodIsoDate()).
		public static function parseSodDate(s:String):Date {
			var d:Date;
			if (s==null)
				return null;
			if (s.substr(-1,1)=="Z") {
				d = new Date(DateUtils.fromIsoDate(s).getTime()+getSodTZ());
			} else {
				d = new Date(s+ " UTC");	// They forget to add the TZ
			}
			//			trace("parse ISO: ",s,"GMT to",d);
			return d;
		}
		//VAHI end bullshit		
	}
}