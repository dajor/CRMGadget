package gadget.control
{
	import gadget.i18n.i18n;
	import gadget.util.StringUtils;
	
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	public class MultiPickListValidator extends Validator
	{
		public function MultiPickListValidator()
		{
			super();
		}
		override protected function doValidation(value:Object):Array
		{
			var selectedValue:String = value as String;
			var results:Array = new Array();
			
			if(!StringUtils.isEmpty(selectedValue)){
				var selectedItems:Array = selectedValue.split(';');
				if(selectedItems.length>10){
					results.push(new ValidationResult(true,null,"tooLong" , i18n._("MULTI_SELECT_EXCEED@You can only select up to 10 values for this field.")));
				}
				
			}
			
			return results;			
		}
	}
}