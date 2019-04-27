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
		private static var currentUserLanguageInfo:Object;
		
//		private static var isReadFromDB:Boolean = false;
		/**
		 * 
		 * Returns the current user's
		 * 
		 * @return Current user's language code and language
		 * 
		 */
		public static function getLanguageInfo():Object {
			if (currentUserLanguageInfo != null) {
				return currentUserLanguageInfo;
			}
			currentUserLanguageInfo = new Object();
			// Default value for Language, LanguageCode and Locale are empty
			var languageCode:String = "ENU";
			var currencyCode:String = "USD";
			var language:String = "English-American";
			var local:String = "English - United Kingdom";
			
			if (Database.userDao) {
				var user:Object = Database.userDao.read();
				if (user != null && user.user_sign_in_id != null) {
					var userInfos:ArrayCollection = Database.allUsersDao.findAll(
						new ArrayCollection([{element_name:"LanguageCode"}, {element_name:"Language"}, {element_name:"Locale"}]), 
						"userSignInId = '" + user.user_sign_in_id + "'",null,1,null,false);
					if (userInfos.length > 0) {
						if(!StringUtils.isEmpty(userInfos[0].LanguageCode))
							languageCode = userInfos[0].LanguageCode;
						
						if(!StringUtils.isEmpty(userInfos[0].CurrencyCode))
							currencyCode = userInfos[0].CurrencyCode;
						
						if(!StringUtils.isEmpty(userInfos[0].Language))
							language = userInfos[0].Language;
						
						if(!StringUtils.isEmpty(userInfos[0].Locale))
							local = userInfos[0].Locale;						
					
					}
				}
			}
			currentUserLanguageInfo.Language = language;
			currentUserLanguageInfo.LanguageCode = languageCode;
			currentUserLanguageInfo.CurrencyCode = currencyCode;
			currentUserLanguageInfo.Locale = local;
			return currentUserLanguageInfo;
		}
		
		public static function getLanguageCode():String{
			return getLanguageInfo().LanguageCode;
		}
		
		public static function updateLanguageInfo(userInfos:Object):void{
			if(currentUserLanguageInfo==null){
				currentUserLanguageInfo= new Object();
			}
			currentUserLanguageInfo.Language = userInfos.Language;
			currentUserLanguageInfo.LanguageCode = userInfos.LanguageCode;;
			currentUserLanguageInfo.Locale = userInfos.Locale;
		}
		
		/**
		 * Resets the cache. 
		 */
		public static function reset():void {
			currentUserLanguageInfo = null;
		}
	}
}