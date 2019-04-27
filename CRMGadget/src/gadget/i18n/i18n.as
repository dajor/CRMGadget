// XXX TODO XXX
// implement actual call to the used internationalization API

package gadget.i18n {

	import gadget.service.LocaleService;
	import gadget.util.CacheUtils;
	import gadget.util.PatternFormatter;
	import gadget.util.Utils;
	
	import mx.resources.IResourceBundle;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceBundle;
	import mx.resources.ResourceManager;
		
	public class i18n {

		private static const RESOURCE_FILE_NAME:String = "localization";
		
		
		
		private static var _cache:CacheUtils = new CacheUtils("i18n");

		public static function clearCache():void {
			_cache.clear();
		}


		private static function translateIntern(from:String):String {
			var languageCode:String = LocaleService.getLanguageInfo().LanguageCode;
			var splitInd:int = from.indexOf("@");
			var tempVal:String = null;
			if(splitInd!=-1){
				tempVal = from.substr(splitInd+1);
				from = from.substr(0,splitInd);
			}
			var val:String = getText(languageCode,from);
			if(tempVal!=null && (val==null || val=="")){
				val = tempVal;
			}
			if(val) return val;
			else return from;
		}

		private static function translate(from:String):String {
			// If translation is known, immediately return it
			if(_cache.get(from)==null){
				_cache.set(from, translateIntern(from));
			}
			return _cache.get(from).toString();
		}
		

		public static function _(s:String, ...args):String {
			if (!args.length)
				return translate(s);
			
			var formatter:PatternFormatter = new PatternFormatter();
			formatter.pattern = translate(s);
			return formatter.format(args);
		}
		
		[ResourceBundle("localization_ENU")]
		[ResourceBundle("localization_FRA")]
		[ResourceBundle("localization_DEU")]
		[ResourceBundle("localization_ESN")]
		[ResourceBundle("localization_PTG")]
		[ResourceBundle("localization_NLD")]
		[ResourceBundle("localization_DAN")]
		[ResourceBundle("localization_BGR")]
		[ResourceBundle("localization_JPN")]
		[ResourceBundle("localization_CHS")]
		[ResourceBundle("localization_SVE")]
		[ResourceBundle("localization_PLK")]
		[ResourceBundle("localization_RUS")]
		[ResourceBundle("localization_ITA")]
		//[ResourceBundle("localization_SWE")]
		//CRO 03.01.2010
		// AM 03.01.2010 to be done later, when properties files are OK
		/*[ResourceBundle("localization_ABW")]
		[ResourceBundle("localization_AUS")]
		[ResourceBundle("localization_BGR")]
		[ResourceBundle("localization_CAT")]
		[ResourceBundle("localization_CHN")]
		[ResourceBundle("localization_CSY")]
		[ResourceBundle("localization_DAN")]		
		[ResourceBundle("localization_FIN")]
		[ResourceBundle("localization_FRB")]
		[ResourceBundle("localization_GBR")]
		[ResourceBundle("localization_GRC")]
		[ResourceBundle("localization_HEB")]
		[ResourceBundle("localization_ITA")]
		[ResourceBundle("localization_JPN")]
		[ResourceBundle("localization_KRO")]
	
		[ResourceBundle("localization_NOR")]
		[ResourceBundle("localization_POL")]
		[ResourceBundle("localization_RUS")]
		[ResourceBundle("localization_SRB")]
		[ResourceBundle("localization_SWE")]
		[ResourceBundle("localization_THA")]
		[ResourceBundle("localization_TUR")]*/
	
		
		private static function getText(locale:String, key:String):String {
			var text:String = ResourceManager.getInstance().getString("localization_" + locale, key);
			return text ? text : ResourceManager.getInstance().getString("localization_ENU", key);
		}
		public static function getTextByLanguage(key:String,locale:String):String{
			var str:String = getText(locale,key);
			return  str == null ? key  : str;
		}
		
	}
}
