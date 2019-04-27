package gadget.service
{
	import gadget.dao.BookDAO;
	import gadget.dao.Database;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class LocaleService
	{
		/**
		 * This is a cache !
		 */
	//	private static var currentUserLanguageInfo:Object;
		
//		private static var isReadFromDB:Boolean = false;
		/**
		 * 
		 * Returns the current user's
		 * 
		 * @return Current user's language code and language
		 * 
		 */
		public static function getLanguageInfo():Object {
//			if (currentUserLanguageInfo != null) {
//				return currentUserLanguageInfo;
//			}
			var currentUserLanguageInfo:Object = new Object();
			// Default value for Language, LanguageCode and Locale are empty
			var languageCode:String = "ENU";
			var currencyCode:String = "USD";
			var language:String = "English-American";
			var local:String = "English - United Kingdom";
			var localeCode:String = "0-111";
			if (Database.allUsersDao!=null) {
				var user:Object = Database.allUsersDao.ownerUser();
				if (user != null) {
					if(!StringUtils.isEmpty(user.LanguageCode))
						languageCode = user.LanguageCode;
					
					if(!StringUtils.isEmpty(user.CurrencyCode))
						currencyCode = user.CurrencyCode;
					
					if(!StringUtils.isEmpty(user.Language))
						language = user.Language;
					
					if(!StringUtils.isEmpty(user.Locale))
						local = user.Locale;		
					if(!StringUtils.isEmpty(user.LocaleCode))
						localeCode = user.LocaleCode;	
				}
			}
			currentUserLanguageInfo.Language = language;
			currentUserLanguageInfo.LanguageCode = languageCode;
			currentUserLanguageInfo.CurrencyCode = currencyCode;
			currentUserLanguageInfo.Locale = local;
			currentUserLanguageInfo.LocaleCode = localeCode;
			return currentUserLanguageInfo;
		}
		
		public static function getLanguageCode():String{
			return getLanguageInfo().LanguageCode;
		}
		
//		public static function updateLanguageInfo(userInfos:Object):void{
//			if(currentUserLanguageInfo==null){
//				currentUserLanguageInfo= new Object();
//			}
//			currentUserLanguageInfo.Language = userInfos.Language;
//			currentUserLanguageInfo.LanguageCode = userInfos.LanguageCode;;
//			currentUserLanguageInfo.Locale = userInfos.Locale;
//		}
		
		/**
		 * Resets the cache. 
		 */
		public static function reset():void {
			//currentUserLanguageInfo = null;
		}
	}
}