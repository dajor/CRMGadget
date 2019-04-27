package gadget.control
{
	import com.adobe.utils.StringUtil;
	
	import gadget.util.NumberLocaleUtils;

	public class ProbabilityColNumRenderer extends ImpactColNumRenderer
	{
		public function ProbabilityColNumRenderer()
		{
			super();
		}
		
		override  public function set text(value:String):void
		{
			if(value!=null && column){
				value = NumberLocaleUtils.format(super.data[column.dataField],0);
			}
			super.text = value;
		}
	}
}