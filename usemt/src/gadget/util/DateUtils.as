package gadget.util {
	import gadget.i18n.i18n;
	import gadget.service.LocaleService;
	
	public class DateUtils {

		import gadget.dao.Database;
		
		import mx.collections.ArrayCollection;
		import mx.formatters.DateFormatter;
		private static var user_gtm:Number=-99;
		public static const SUNDAY:int = 0;
		
		
		public static const MAR:int = 2;
		public static const OCT:int = 9;
		public static const NOV:int = 10;
		
		private static const DATE_PATTERNS:Array =[ 
			{locale: null, dateFormat: "MM/DD/YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0D-CCOZD", dateFormat: "DD/M/YYYY", timeFormat: "KK:NN:SS A"}, 
			{locale: '0-118', dateFormat: "YYYY-M-DD", timeFormat: "KK:NN:SS A"},
			{locale: "0D-CCOZE", dateFormat: "DD/M/YYYY", timeFormat: "KK:NN:SS A"}, 
			{locale: "0-205", dateFormat: "YYYY/M/DD", timeFormat: "KK:NN:SS A"},
			{locale: "0-202", dateFormat: "DD.M.YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-108", dateFormat: "DD-MM-YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-BAA65", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-109", dateFormat: "DD-MM-YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-BAA5D", dateFormat: "DD/MM/YYYY", timeFormat: "KK:NN:SS A"}, 
			{locale: "0-BAA5G", dateFormat: "DD/MM/YYYY", timeFormat: "KK:NN:SS A"},
			{locale: "0-208", dateFormat: "DD-MM-YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-BAA5I", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-206", dateFormat: "DD/MM/YYYY", timeFormat: "KK:NN:SS A"}, 
			{locale:"0-204", dateFormat: "M/DD/YYYY", timeFormat: "KK:NN:SS A"},
			{locale: "0-203", dateFormat: "YYYY/MM/DD", timeFormat: "KK:NN:SS A"}, 
			{locale: "0-111", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-101", dateFormat: "MM/DD/YYYY", timeFormat: "KK:NN:SS A"}, 
			{locale: "0-110", dateFormat: "DD.M.YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-112", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-BAA5K", dateFormat: "YYYY-MM-DD", timeFormat: "JJ:NN:SS"},
			{locale: "0-103", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-BAA5P", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-BAA5R", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-BAA5T", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-106", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-BAA5Z", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"},
			{locale:"0-BAA5V", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-201", dateFormat: "YYYY.MM.DD.", timeFormat: "J:NN:SS"},
			{locale: "0-210", dateFormat: "DD/MM/YYYY", timeFormat: "J:NN:SS"}, 
			{locale: "0-104", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-102", dateFormat: "YYYY/MM/DD", timeFormat: "LL:NN:SS A"}, 
			{locale: "0-113", dateFormat: "YYYY-MM-DD", timeFormat: "LL:NN:SS A"},
			{locale: "0-207", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-BAA63", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-212", dateFormat: "YYYY-MM-DD", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-LCBRA", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-114", dateFormat: "DD-MM-YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-211", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-BAA61", dateFormat: "DD/MM/YYYY", timeFormat: "LL:NN:SS A"}, 
			{locale: "0-116", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "0-107", dateFormat: "YYYY-MM-DD", timeFormat: "JJ:NN:SS"}, 
			{locale: "0-209", dateFormat: "DD/M/YYYY", timeFormat: "J:NN:SS"},
			{locale: "0-213", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"}];
		
		
		
		private static const EUROPE:Array = ['0-1OBMR','0-1OBOZ','0-1OBMV','0-1OBNX','0-1OBMP','0-1OBMD','0-1OBMX'];
		private static const AMERICAN:Array =['0-1OBMH','0-1OBLT','0-1OBM3','0-1OBN9','0-1OBLL','0-1OBMS','0-1OBOR','04-J4927','0-1OBND','0-1OBNV','0-1OBL5','0-1OBMZ'];
		private static const AFFRIC:Array = ['0-1OBOX','0-1OBOD','0-1OBMJ'];
//		private static const ASIA:Array = ['','','','','','','','','','','','','','','',''];
//		private static const NO_DST:Array=['','','','','','','',''];
		
		
		
		
		/*private static const DATE_PATTERNS:Array =[ 
			{locale: null, dateFormat: "MM/DD/YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "Chinese - Singapore", dateFormat: "DD/M/YYYY", timeFormat: "KK:NN:SS A"}, 
			{locale: "Chinese - PRC", dateFormat: "YYYY-M-DD", timeFormat: "KK:NN:SS A"},
			{locale: "Chinese - Hong Kong SAR", dateFormat: "DD/M/YYYY", timeFormat: "KK:NN:SS A"}, 
			{locale: "Chinese - Taiwan", dateFormat: "YYYY/M/DD", timeFormat: "KK:NN:SS A"},
			{locale: "Czeck - Czeck Republic", dateFormat: "DD.M.YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "Danish - Denemark", dateFormat: "DD-MM-YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "Dutch - Belgium", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "Dutch - Netherlands", dateFormat: "DD-MM-YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "English - Australia", dateFormat: "DD/MM/YYYY", timeFormat: "KK:NN:SS A"}, 
			{locale: "English - Canada", dateFormat: "DD/MM/YYYY", timeFormat: "KK:NN:SS A"},
			{locale: "English - India", dateFormat: "DD-MM-YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "English - Irland", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "English - New Zealand", dateFormat: "DD/MM/YYYY", timeFormat: "KK:NN:SS A"}, 
			{locale: "English - Philippines", dateFormat: "M/DD/YYYY", timeFormat: "KK:NN:SS A"},
			{locale: "English - South Africa", dateFormat: "YYYY/MM/DD", timeFormat: "KK:NN:SS A"}, 
			{locale: "English - United Kingdom", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "English - United States", dateFormat: "MM/DD/YYYY", timeFormat: "KK:NN:SS A"}, 
			{locale: "Finnish - Finland", dateFormat: "DD.M.YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "French - Belgium", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "French - Canada", dateFormat: "YYYY-MM-DD", timeFormat: "JJ:NN:SS"},
			{locale: "French - France", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "Fench - Luxembourg", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "French - Switzerland", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "German - Austria", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "German - Germany", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "German - Luxembourg", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "German - Switzerland", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "Hungarian - Hungary", dateFormat: "YYYY.MM.DD.", timeFormat: "J:NN:SS"},
			{locale: "Indonesian - Indonesia", dateFormat: "DD/MM/YYYY", timeFormat: "J:NN:SS"}, 
			{locale: "Italia - Italy", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "Japanese - Japan", dateFormat: "YYYY/MM/DD", timeFormat: "LL:NN:SS A"}, 
			{locale: "Korean - Korea", dateFormat: "YYYY-MM-DD", timeFormat: "LL:NN:SS A"},
			{locale: "Malay - Malaysia", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "Norwegian - Bokmal", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "Polish - Poland", dateFormat: "YYYY-MM-DD", timeFormat: "JJ:NN:SS"}, 
			{locale: "Portuguese - Brasil", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "Portuguese - Portugal", dateFormat: "DD-MM-YYYY", timeFormat: "JJ:NN:SS"}, 
			{locale: "Russian - Russia", dateFormat: "DD.MM.YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "Spanish - Mexico", dateFormat: "DD/MM/YYYY", timeFormat: "LL:NN:SS A"}, 
			{locale: "Spanish - Spain (International Sort)", dateFormat: "DD/MM/YYYY", timeFormat: "JJ:NN:SS"},
			{locale: "Swedish - Sweden", dateFormat: "YYYY-MM-DD", timeFormat: "JJ:NN:SS"}, 
			{locale: "Thai - Thailand", dateFormat: "DD/M/YYYY", timeFormat: "J:NN:SS"}];*/
		
		/**
		 * Date time format to use for database. All dates in database must conform to that format. 
		 */
		public static const DATABASE_DATETIME_FORMAT:String = "YYYY-MM-DDTJJ:NN:SSZ";	

		/**
		 * Date format to use for database. All dates in database must conform to that format. 
		 */
		public static const DATABASE_DATE_FORMAT:String = "YYYY-MM-DD";	

		
		/**
		 * Converts a date to a string according to a format. 
		 * @param date Date to convert.
		 * @param format Date format.
		 * @return Formatted date.
		 */
		public static function format(date:Date, format:String):String {
			var df:DateFormatter = new DateFormatter();
			df.formatString = format;
			return df.format(date);
		}
		
		

		/**
		 * Try to guess the date format of a string. 
		 * @param s String to guess.
		 * @return Guessed date format.
		 * 
		 */
		public static function guessDateFormat(s:String):String {
			if (s != null) {
				var delim:String = s.replace(/\d/g, "");
				if (delim == '// ::') {
					return "MM/DD/YYYY JJ:NN:SS";
				}else if( delim == '//'){
					return "MM/DD/YYYY";
				}
			}
			return "YYYY-MM-DDTJJ:NN:SSZ";
		}
		
		
		public static function isDate(date:String ):Boolean{
			if(date.length<8){
				return false;
			}
			//CRO for dynamic time zone
			var notDate:String =new Date(0, 0, 0, 0, 0, 0).toString(); 
			var guseDate:String =guessAndParse(date).toString();
			return notDate!=guseDate;
		}
		
		
		/**
		 * Try to guess a string's date format and returns the corresponding date. 
		 * @param s String to analyse.
		 * @return Corresponding date.
		 */
		public static function guessAndParse(s:String):Date {
			return parse(s, guessDateFormat(s));
		}
		
		/**
		 * Converts a string to a date according to a format. 
		 * @param date String to convert.
		 * @param format Date format.
		 * @return Parsed date.
		 */		
		public static function parse(s:String, format:String):Date {
			if (StringUtils.isEmpty(s)) return null;
			format = format.toLowerCase();
			s = s.toLowerCase();
			// we keep only the delimiters and get rid of the format code letters
			var delim:String = format.replace(/[ymdjklnsa]/g, "");
			// gets an array of format codes
			var codes:Array = cut(format, delim);
			// gets an array of the year, month, date, hour, minute, second values
			var parts:Array = cut(s, delim);
			var year:int, month:int, day:int, hours:int, minutes:int, seconds:int;
			for (var i:int; i<codes.length && i<parts.length; i++) {
				switch (codes[i].charAt(0)) {
					case 'y':
						year = parts[i]; break;
					case 'm':
						month = parts[i] - 1; break;
					case 'd':
						day = parts[i]; break;
					case 'j':
					case 'k':
					case 'l':
						hours = parts[i]; break;
					case 'n':
						minutes = parts[i]; break;
					case 's':
						seconds = parts[i]; break;						
					case 'a':
						// this works because the 'a' code is after the hours
						hours += (parts[i] == 'pm' ? 12 : 0); break;
				}
			}
			return new Date(year, month, day, hours, minutes, seconds);
		}
		
		
		
		/**
		 * Determines if the TimeZone should be observing DST for the provided date.
		 * 
		 * @return True if DST should be observed by this TimeZone at the provided date.
		 */
		private static function isDst(d:Date,tzId:String):Boolean {
			var starthour:int;
			var endhour:int;
			var startoccurrences:int;
			var endoccurrences:int;
			var startMonth:int;
			var endMonth:int;
			if(AMERICAN.indexOf(tzId)!=-1){
				startoccurrences = 2;
				starthour =2;
				endhour = 2;
				endoccurrences = 1;
				startMonth = MAR;
				endMonth = NOV;
			}else if(EUROPE.indexOf(tzId)!=-1){
				startoccurrences = 5;
				endoccurrences = 5;
				starthour = 0;
				endhour = 24;
				startMonth = MAR;
				endMonth = OCT;
			}else{
				return false;
			}
			
			
			var date:Date = new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes(), 0, 0);
			var dstStart:Date = dateByOccurence(d.getFullYear(), startMonth, starthour, 0, SUNDAY, startoccurrences);
			var dstEnd:Date = dateByOccurence(d.getFullYear(), endMonth, endhour, 0, SUNDAY, endoccurrences);
			
			return dstStart.time <= date.time && date.time < dstEnd.time;
		}
		
		/**
		 * Finds a Date by its occurence
		 * 
		 * @private
		 */
		private static function dateByOccurence(year:int, month:int, hour:int, minute:int, dayOfWeek:int, occurrences:int):Date {
			
			var occurrencesFound:int = 0;
			var date:Date;
			
			if(0 < occurrences) {				
				var currentDate:Date = new Date(year, month, 1, hour, minute, 0, 0);
				while(occurrencesFound < occurrences) {					
					if(month<currentDate.getMonth()){
						return date;
					}
					if(currentDate.day == dayOfWeek) {
						//last equal
						date = new Date(currentDate.getTime());
						occurrencesFound++;						
						
						if(occurrencesFound == occurrences)
							break; 
					}
					
					currentDate.date++;
				}
			}
			
			return date;
		}
		
		
		
		/**
		 * Cuts a string into an Array according a delimiter list. 
		 * @param s String to be cut.
		 * @param delim Delimiter list.
		 * @return Resulting array.
		 */
		private static function cut(s:String, delim:String):Array {
			var parts:Array = [];
			for (var i:int = 0; i < delim.length; i++) {
				var pos:int = s.indexOf(delim.charAt(i));
				if (pos == -1) {
					break;
				}
				parts = parts.concat(s.substr(0, pos));
				s = s.substr(pos + 1);
			}
			parts = parts.concat(s);
			return parts;
		}
		

		/*
		*	return {dateString, dateTimeString} with the datePattern Standard format MM/DD/YYYY JJ:NN:SS
		*/
		public static function toDateTimeStringStandard(date:Date):Object {
			var dateString:String = format(date, DATE_PATTERNS[0].dateFormat);
			var dateTimeString:String = dateString + " " + format(date, DATE_PATTERNS[0].timeFormat);
			return {'dateString':dateString, 'dateTimeString':dateTimeString};
		}
		
		/*
		*	return {local,dateFormat,timeFormat}  datePattern for the current user
		*/
		public static function getCurrentUserDatePattern():Object {
			var languageInfo:Object = Database.allUsersDao.ownerUser();
			if(languageInfo!=null){
				for each (var datePattern:Object in DATE_PATTERNS){
					if(languageInfo.LocaleCode == datePattern.locale){
						return datePattern;
					}
				}
			}
			return DATE_PATTERNS[0];
		}
		
		public static function getCurrentDateAsSerial():String {
			var d:Date = new Date();
			d.getTimezoneOffset()
			return format(new Date(), "YYYY.MM.DD.HH.NN.SS");
		}	
		
		
		private static function getDST(d:Date, tzId:String):int{
			if(isDst(d,tzId)){
				return 1;
			}
			
			return 0;
			
			
		}
		//return 1 like GMT+1, -1 like GMT-1...
		public static function getCurrentTimeZone(d:Date=null):Number{
			if(d==null){
				d = ServerTime.toSODDate(new Date());
			}
			if(user_gtm!=-99){
				return user_gtm;
			}
			var userDatas:Object = Database.allUsersDao.ownerUser();
			//var userDatas:ArrayCollection = Database.allUsersDao.findAll(new ArrayCollection([{element_name:"*"}]), "userSignInId = '" + currentUser.user_sign_in_id + "'");
			if(userDatas!=null && userDatas.hasOwnProperty("Id")){				
				var gmt:Number=0;
				var uData:Object=userDatas;
				var timeZone:String=uData['TimeZoneName'];
				var timeZoneId:String = uData['TimeZoneId'];
				var dst:int =getDST(d,timeZoneId); 
				if(timeZone!=null){
				  timeZone=timeZone.substring(4,timeZone.indexOf(")"))
				  if(timeZone.length>0){
					  
				  
				  var isNegative:Boolean=timeZone.substr(0,1)=="-";
				 // timeZone=timeZone.replace(/+|-/,'');
				  var hourSecond:Array =timeZone.split(":");
				  var hour:Number=parseInt(hourSecond[0]);
				  var second:Number=parseInt(hourSecond[1])/60;
				  if(isNegative){
					  gmt=hour-second;
				  }else{
					  gmt=hour+second;
				  }
				  }
				  
				  return gmt+dst;
				  
				}
				
			}
			
			return 0;
			
			
		}
		
		
		public static function fromIsoDate(s:String):Date {
			function i(a:int,n:int):int { return parseInt(s.substr(a,n)) }
			var d:Date=new Date(Date.UTC(i(0,4),i(5,2)-1,i(8,2),i(11,2),i(14,2),i(17,2)));
			return d;
		}
		public static function toIsoDate(d:Date):String {
			function t(i:int):String { return i<10?'0'+i:''+i }
			var s:String = "".concat(d.getUTCFullYear(),"-",t(d.getUTCMonth()+1),"-",t(d.getUTCDate()),
				'T',t(d.getUTCHours()),':',t(d.getUTCMinutes()),':',t(d.getUTCSeconds()));
			return s;
		}
		// This is MM/DD/YYYY HH:MM:SS
		public static function toSodDate(d:Date):String {
			function t(i:int):String { return i<10?'0'+i:''+i }
			var s:String = "".concat(t(d.getUTCMonth()+1),"/",t(d.getUTCDate()),"/",d.getUTCFullYear(),
				' ',t(d.getUTCHours()),':',t(d.getUTCMinutes()),':',t(d.getUTCSeconds()));
			return s;
		}		
	}
}