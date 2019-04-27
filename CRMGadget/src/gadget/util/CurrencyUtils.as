package gadget.util
{
	
	import gadget.service.LocaleService;
	
	import mx.formatters.CurrencyFormatter;

	public class CurrencyUtils
	{
		
		private static const ENGLISH:Array = ["ENU", "ENG"];
		
		public function CurrencyUtils()
		{
		}
		
		public static function format(value:Object, currencyCode:String=null,right:Boolean=false):String {
			var languageInfo:Object = LocaleService.getLanguageInfo();
			if(currencyCode) languageInfo.CurrencyCode = currencyCode;
			var decimalSeparatorTo:String = "", thousandsSeparatorTo:String = "";
			if(ENGLISH.indexOf(languageInfo.LanguageCode) > -1) {
				decimalSeparatorTo = ".";
				thousandsSeparatorTo = ",";
			}else {
				decimalSeparatorTo = ",";
				thousandsSeparatorTo = ".";
			}
			var currency:CurrencyFormatter = new CurrencyFormatter();
			if(right){
				currency.alignSymbol = "right";
			}else{
				currency.alignSymbol = "left";
			}
			
			currency.precision = 2;
			currency.currencySymbol = languageInfo.CurrencyCode + " ";
			currency.decimalSeparatorTo = decimalSeparatorTo;
			currency.thousandsSeparatorTo = thousandsSeparatorTo;
			currency.useThousandsSeparator = true;
			return currency.format(value);
		}
		
	}
}