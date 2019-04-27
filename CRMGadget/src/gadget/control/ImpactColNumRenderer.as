package gadget.control
{
	import com.adobe.utils.StringUtil;
	
	import gadget.util.NumberLocaleUtils;

	public class ImpactColNumRenderer extends ImpactText
	{
		public function ImpactColNumRenderer()
		{
			super();
		}
		
	
		
		override public function get text():String{
			return NumberLocaleUtils.parse( StringUtil.trim(super.text),decimal);
		}
	}
}