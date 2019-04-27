package gadget.util
{
	import com.adobe.utils.StringUtil;
	
	import gadget.service.LocaleService;

	public class LocaleUtils
	{
		private static const LOCALES:Object = {
			'0D-CCOZE':'zh_CN',
			'0-118':'zh_CN',
			'0D-CCOZD':'zh_CN',
			'0-205':'zh_CN',
			'0-202':'fr_FR',
			'0-108':'de_DE',
			'0-BAA65':'nl_NL',
			'0-109':'nl_NL',
			'0-BAA5D':'en_US',
			'0-BAA5G':'en_US',
			'0-208':'en_US',
			'0-BAA5I':'en_US',
			'0-206':'en_US',
			'0-204':'en_US',
			'0-203':'en_US',
			'0-111':'en_US',
			'0-101':'en_US',
			'0-110':'fr_FR',
			'0-112':'fr_FR',
			'0-BAA5K':'fr_FR',
			'0-103':'fr_FR',
			'0-BAA5P':'fr_FR',
			'0-BAA5R':'fr_FR',
			'0-BAA5T':'de_DE',
			'0-106':'de_DE',
			'0-BAA5Z':'de_DE',
			'0-BAA5V':'de_DE',
			'0R-BAA67':'de_DE',
			'0-201':'fr_FR',
			'0-210':'de_DE',
			'0-104':'it_IT',
			'0-102':'ja_JP',
			'0-113':'en_US',
			'0-207':'de_DE',
			'0-BAA63':'de_DE',
			'0-212':'de_DE',
			'0-LCBRA':'pt_BR',
			'0-114':'pt_BR',
			'0-211':'ru_RU',
			'0P-BAA66':'es_ES',
			'0-BAA61':'es_ES',
			'0-116':'es_ES',
			'0-107':'sv_SE',
			'0-209':'en_US',
			'0-213':'de_DE'
			
		};
		public static const LANGCODE_TO_LOCALS:Object = {
			DEU:'de_DE',
			ENU:'en_US',
			ESN:'es_ES',
			FRA:'fr_FR',
			PTG:'pt_BR',
			PTB:'pt_BR',
			NLD:'nl_NL',
			JPN:'ja_JP',
			CHS:'zh_CN',
			SVE:'sv_SE',			
			RUS:'ru_RU',
			ITA:'it_IT'
			
		};
		public function LocaleUtils()
		{
		}
		public static function getLocaleCodeByLanguage(langCode:String):String{
			if(langCode == null || langCode == ""){
				return 'en_US';
			}else{
				return LANGCODE_TO_LOCALS[langCode]==null?'en_US':StringUtil.trim(LANGCODE_TO_LOCALS[langCode]);
			}
			
		}
		public static function getLocaleCode():String{
			//0_1OBMR = en_US
			var languageInfo:Object = LocaleService.getLanguageInfo();
			var localeCode:String = languageInfo.LocaleCode;
			
			if(localeCode == null || localeCode == ""){
				return 'en_US';
			}else{
				return LOCALES[localeCode]==null?'en_US':StringUtil.trim(LOCALES[localeCode]);
			}
			
		}
		
	}
}