package gadget.util
{
	import mx.formatters.NumberFormatter;

	public class NumberUtils
	{
		public function NumberUtils()
		{
		}
		public static function format(value:Object):String {
			var numfomatter:NumberFormatter = new NumberFormatter();
			numfomatter.precision = 0;
			numfomatter.decimalSeparatorTo = ".";
			numfomatter.decimalSeparatorFrom = ".";
			numfomatter.thousandsSeparatorTo = ",";
			numfomatter.thousandsSeparatorFrom =",";
			
			return numfomatter.format(value);
		}
	}
}