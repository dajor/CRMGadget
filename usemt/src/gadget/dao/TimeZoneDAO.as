package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class TimeZoneDAO extends SimpleTable
	{
		private var stmtCountTimeZone:SQLStatement;
		private var stmtFind:SQLStatement;
		private var stmtFindAll:SQLStatement;
		private static var timeZoneData:Array=[
			{ Code:"0-1OBMV", Name:"(GMT) Casablanca, Monrovia"},
			{ Code:"0-1OBMR", Name:"(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London"},
			{ Code:"0-1OBOZ", Name:"(GMT+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna"},
			{ Code:"0-1OBLX", Name:"(GMT+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague"},
			{ Code:"0-1OBNX", Name:"(GMT+01:00) Brussels, Copenhagen, Madrid, Paris"},
			{ Code:"0-1OBLZ", Name:"(GMT+01:00) Sarajevo, Skopje, Sofija, Vilnius, Warsaw, Zagreb"},
			{ Code:"0-1OBOX", Name:"(GMT+01:00) West Central Africa"},
			{ Code:"0-1OBMX", Name:"(GMT+02:00) Athens, Istanbul, Minsk"},
			{ Code:"0-1OBMD", Name:"(GMT+02:00) Bucharest"},
			{ Code:"0-1OBMJ", Name:"(GMT+02:00) Cairo"},
			{ Code:"0-1OBOD", Name:"(GMT+02:00) Harare, Pretoria"},
			{ Code:"0-1OBMP", Name:"(GMT+02:00) Helsinki, Riga, Tallinn"},
			{ Code:"0-1OBN5", Name:"(GMT+02:00) Jerusalem"},
			{ Code:"0-1OBLB", Name:"(GMT+03:00) Baghdad"},
			{ Code:"0-1OBL7", Name:"(GMT+03:00) Kuwait, Riyadh"},
			{ Code:"0-1OBNZ", Name:"(GMT+03:00) Moscow, St. Petersburg, Volgograd"},
			{ Code:"0-1OBM9", Name:"(GMT+03:00) Nairobi"},
			{ Code:"0-1OBN3", Name:"(GMT+03:30) Tehran"},
			{ Code:"0-1OBL9", Name:"(GMT+04:00) Abu Dhabi, Muscat"},
			{ Code:"0-1OBLP", Name:"(GMT+04:00) Baku, Tbilisi, Yerevan"},
			{ Code:"0-1OBL3", Name:"(GMT+04:30) Kabul"},
			{ Code:"0-1OBML", Name:"(GMT+05:00) Ekaterinburg"},
			{ Code:"0-1OBP1", Name:"(GMT+05:00) Islamabad, Karachi"},
			{ Code:"0-1OBMU", Name:"(GMT+05:00) Tashkent"},
			{ Code:"0-1OBN1", Name:"(GMT+05:30) Calcutta, Chennai, Mumbai, New Delhi"},
			{ Code:"0-1OBOF", Name:"(GMT+05:30) Sri Jayawardenepura"},
			{ Code:"0-1OBNJ", Name:"(GMT+05:45) Kathmandu"},
			{ Code:"0-1OBNH", Name:"(GMT+06:00) Almaty, Novosibirsk"},
			{ Code:"0-1OBLV", Name:"(GMT+06:00) Astana, Dhaka"},
			{ Code:"0-1OBNF", Name:"(GMT+06:30) Rangoon"},
			{ Code:"0-1OBO9", Name:"(GMT+07:00) Bangkok, Hanoi, Jakarta"},
			{ Code:"0-1OBNR", Name:"(GMT+07:00) Krasnoyarsk"},
			{ Code:"0-1OBM5", Name:"(GMT+08:00) Beijing, Chongqing, Hong Kong, Urumqi"},
			{ Code:"0-1OBNP", Name:"(GMT+08:00) Irkutsk, Ulaan Bataar"},
			{ Code:"0-1OBOB", Name:"(GMT+08:00) Kuala Lumpur, Singapore"},
			{ Code:"0-1OBOV", Name:"(GMT+08:00) Perth"},
			{ Code:"0-1OBOH", Name:"(GMT+08:00) Taipei"},
			{ Code:"0-1OBOL", Name:"(GMT+09:00) Osaka, Sapporo, Tokyo"},
			{ Code:"0-1OBN7", Name:"(GMT+09:00) Seoul"},
			{ Code:"0-1OBP5", Name:"(GMT+09:00) Yakutsk"},
			{ Code:"0-1OBLR", Name:"(GMT+09:30) Adelaide"},
			{ Code:"0-1OBLF", Name:"(GMT+09:30) Darwin"},
			{ Code:"0-1OBMB", Name:"(GMT+10:00) Brisbane"},
			{ Code:"0-1OBLH", Name:"(GMT+10:00) Canberra, Melbourne, Sydney"},
			{ Code:"0-1OBP3", Name:"(GMT+10:00) Guam, Port Moresby"},
			{ Code:"0-1OBOJ", Name:"(GMT+10:00) Hobart"},
			{ Code:"0-1OBOT", Name:"(GMT+10:00) Vladivostok"},
			{ Code:"0-1OBM1", Name:"(GMT+11:00) Magadan, Solomon Is., New Caledonia"},
			{ Code:"0-1OBNL", Name:"(GMT+12:00) Auckland, Wellington"},
			{ Code:"0-1OBMN", Name:"(GMT+12:00) Fiji, Kamchatka, Marshall Is."},
			{ Code:"0-1OBON", Name:"(GMT+13:00) Nuku'alofa"},
			{ Code:"0-1OBLJ", Name:"(GMT-01:00) Azores"},
			{ Code:"0-1OBLN", Name:"(GMT-01:00) Cape Verde Is."},
			{ Code:"0-1OBNB", Name:"(GMT-02:00) Mid-Atlantic"},
			{ Code:"0-1OBMF", Name:"(GMT-03:00) Brasilia"},
			{ Code:"0-1OBO1", Name:"(GMT-03:00) Buenos Aires, Georgetown"},
			{ Code:"0-1OBMT", Name:"(GMT-03:00) Greenland"},
			{ Code:"0-1OBMQ", Name:"(GMT-03:00) Salta"},
			{ Code:"0-1OBNN", Name:"(GMT-03:30) Newfoundland"},
			{ Code:"0-1OBLD", Name:"(GMT-04:00) Atlantic Time (Canada)"},
			{ Code:"0-1OBOY", Name:"(GMT-04:00) La Paz"},
			{ Code:"0-1OBMO", Name:"(GMT-04:00) Manaus"},
			{ Code:"0-1OBNT", Name:"(GMT-04:00) Santiago"},
			{ Code:"0-1OBO5", Name:"(GMT-04:30) Caracas"},
			{ Code:"0-1OBO3", Name:"(GMT-05:00) Bogota, Lima, Quito"},
			{ Code:"0-1OBMH", Name:"(GMT-05:00) Eastern Time (US & Canada)"},
			{ Code:"0-1OBOP", Name:"(GMT-05:00) Indiana (East)"},
			{ Code:"0-1OBLT", Name:"(GMT-06:00) Central America"},
			{ Code:"0-1OBM3", Name:"(GMT-06:00) Central Time (US & Canada)"},
			{ Code:"0-1OBN9", Name:"(GMT-06:00) Mexico City"},
			{ Code:"0-1OBLL", Name:"(GMT-06:00) Saskatchewan"},
			{ Code:"0-1OBMS", Name:"(GMT-06:00) Tegucigalpa"},
			{ Code:"0-1OBOR", Name:"(GMT-07:00) Arizona"},
			{ Code:"04-J4927", Name:"(GMT-07:00) Chihuahua, La Paz, Mazatlan"},
			{ Code:"0-1OBND", Name:"(GMT-07:00) Mountain Time (US & Canada)"},
			{ Code:"0-1OBNV", Name:"(GMT-08:00) Pacific Time (US & Canada); Tijuana"},
			{ Code:"0-1OBL5", Name:"(GMT-09:00) Alaska"},
			{ Code:"0-1OBMZ", Name:"(GMT-10:00) Hawaii"},
			{ Code:"0-1OBO7", Name:"(GMT-11:00) Midway Island, Samoa"},
			{ Code:"0-1OBM7", Name:"(GMT-12:00) Eniwetok, Kwajalein"}
			
		];
		public function TimeZoneDAO(conn:SQLConnection, work:Function)
		{
		
			super(conn, work, {
				table:"timezone",
				//VAHI fix Issue #13, see comment at end
				unique: [ 'Code' ],
				index: [ 'Code' ],
				columns: { 'TEXT' : ['Code','TimeZoneName'],'INTEGER':['Ordering']}
			});
			
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = conn;
			stmtFind.text = "SELECT * FROM timezone WHERE TimeZoneName = :timezonename";
			
			stmtFindAll = new SQLStatement();
			stmtFindAll.sqlConnection = conn;
			stmtFindAll.text = "SELECT * FROM timezone ORDER BY Ordering";
			
			stmtCountTimeZone = new SQLStatement();
			stmtCountTimeZone.sqlConnection = conn;
			stmtCountTimeZone.text = "SELECT COUNT(*) AS total FROM timezone";
		}
		
		public function find(currency:Object):Object
		{
			stmtFind.parameters[":TimeZoneName"] = currency.name;
			stmtFind.parameters[":code"] = currency.code;
			exec(stmtFind);
			
			var result:SQLResult = stmtFind.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		public function findAll():Array{
			exec(stmtFindAll);			
			var result:SQLResult = stmtFindAll.getResult();
			if (result.data == null || result.data.length == 0) {
				return new Array() ;
			}
			return result.data;
		}
		
		public function initData():void{
			var currencyDAO:TimeZoneDAO = Database.timeZoneDao;
			var index:int =0;
			if(currencyDAO != null){
				Database.begin();
				for each(var value:Object in timeZoneData) {
					var currencyObj:Object = new Object();
					currencyObj.code = value.Code;
					currencyObj.TimeZoneName = value.Name;
					currencyObj.Ordering = index;
					currencyDAO.insert(currencyObj);
			        index ++;
				}
				Database.commit();
			}
		}
		
		public function count():int{
			exec(stmtCountTimeZone);			
			var result:SQLResult = stmtCountTimeZone.getResult();
			return result.data[0].total;
		}
	}
}