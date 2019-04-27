package com.crmgadget.eval {

	
	public class DateUtils {

		
		
		import mx.collections.ArrayCollection;
		import mx.formatters.DateFormatter;
		private static var user_gtm:Number=-99;
		public static const millisecondsPerHour:int = 1000 * 60 * 60;
		private static const MONTHS:Array = [
			{str:"Jan",key:0},
			{str:"Feb",key:1},
			{str:"Mar",key:2},
			{str:"Apr",key:3},
			{str:"May",key:4},
			{str:"Jun",key:5},
			{str:"Jul",key:6},
			{str:"Aug",key:7},
			{str:"Sep",key:8},
			{str:"Oct",key:9},
			{str:"Nov",key:10},
			{str:"Dec",key:11},
			
		];
		
		public static const DATE_PATTERNS:Array =[ 
			{locale:null, dateFormat: "YYYYMMDD", timeFormat: "JJ:NN:SS"},
			{locale:null, dateFormat: "MM/DD/YYYY", timeFormat: "JJ:NN:SS"}, 
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
			{locale: "Thai - Thailand", dateFormat: "DD/M/YYYY", timeFormat: "J:NN:SS"}];
		
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
			if (s == null) return null;
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
		
		public static function isDate(date:String ):Boolean{
			if(date.length<8){
				return false;
			}
			var notDate:String =new Date(0, 0, 0, 0, 0, 0).toString(); 
			var guseDate:String =guessAndParse(date).toString();
			return notDate!=guseDate;
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
		
		public static function toDateTimeYMDHMS_PM(date:Date):String{
			return format(date,"YYYY/MM/DD") + " " + format(date,"L:MM:SS A");
		}
		public static function toDateTimeYMDHMS(date:Date):String{
			return format(date,"YYYY/MM/DD") + " " + format(date,"HH:MM:SS");
		}
		public static function toDateTimeYYYYMMDD(date:String,formatStr:String):String{
			var dateF:String="";
			if(date.length > 7){
				var y:String = date.substr(0,4);
				var m:String = date.substr(4,2);
				var d:String = date.substr(6,date.length-1);
				dateF = m+"/"+d+"/"+y;
			}
			var dat:Date = new Date(dateF);
			return format(dat,formatStr);
		}
		
		public static function getCurrentDateAsSerial():String {
			return format(new Date(), "YYYY.MM.DD.HH.NN.SS");
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
		
		/**
		 * 
		 * @param number
		 * @param date
		 * @param datepart = "fullYear", "month", "date", "startDayOfWeek", "endDayOfWeek"
		 * @return String
		 * 
		 */
		public static function dateAdd(number:Number, date:Date, datepart:String,format:String=DATABASE_DATETIME_FORMAT):String {
			if (date == null) {
				/* Default to current date. */
				date = new Date();
			}
			
			var returnDate:Date = new Date(date.time);;
			
			switch (datepart.toLowerCase()) {
				case "fullyear":
				case "month":
				case "date":				
					returnDate[datepart] += number;
					break;
				case "startdayofweek":
					returnDate["date"] -= date.day - 1;
					break;
				case "enddayofweek":
					returnDate["date"] += 7 - date.day;
					break;
				default:
					/* Unknown date part, do nothing. */
					break;
			}
			return DateUtils.format(returnDate, format);
		}
		/*
		*	return {local,dateFormat,timeFormat}  datePattern for the current user
		*/
		public static function getCurrentUserDatePattern(localUser:Object):Object {
			for each (var datePattern:Object in DATE_PATTERNS){
				if(localUser.Locale == datePattern.locale){
					return datePattern;
				}
			}
			return DATE_PATTERNS[0];
		}
		//retun 3 characters of the month ex: Jan,Feb,...
		public static function getStrMonth(d:Date):String{
			return MONTHS[d.getMonth()].str;
		}
		public static function today():String{
			return format(new Date,DATABASE_DATE_FORMAT) + "T00:00:01Z";
		}
		public static function getCurrentDateTime(userOwner:Object):String{
			var d:Date =new Date();
			d= new Date(d.getTime()-(getCurrentTimeZone(userOwner)*millisecondsPerHour));
			return format(d,DATABASE_DATETIME_FORMAT);
		} 
		//return 1 like GMT+1, -1 like GMT-1...
		public static function getCurrentTimeZone(userOwner:Object):Number{
			if(user_gtm!=-99){
				return user_gtm;
			}
			var userDatas:Object =userOwner;
			if(userDatas!=null){				
				var gmt:Number=0;
				var uData:Object=userDatas;
				var timeZone:String=uData['TimeZoneName'];
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
					
					return gmt+1;
					
				}
				
			}
			
			return 0;
			
			
		}
	}
}