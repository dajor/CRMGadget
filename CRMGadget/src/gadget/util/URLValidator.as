package gadget.util
{
	import mx.utils.StringUtil;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

	public class URLValidator extends Validator
	{
		private var _invalidURL:String = 'Invalid URL: the url must begin with https:// and end with crmondemand.com';
		private var _pattern:RegExp = /^(https):\/\/([\w-]+\.)+crmondemand.com(\/)?$/;
		
		public function URLValidator()
		{
			super();
		}
		
		override protected function doValidation(value:Object):Array
	    {
	        var results:Array = [];
	        
	        var result:ValidationResult = validateURL(value);
	        if (result)
	            results.push(result);
	            
	        return results;
	    }
	    
	    private function validateURL(value:Object):ValidationResult {
	    	var val:String = (value != null) ? String(value) : "";
            val = StringUtil.trim(val);
			 
			trace(val.search(_pattern)); 
            if (val.length == 0 || val.search(_pattern) == -1){
                return new ValidationResult(true, "", "invalidURL", invalidURLError);                 
            }
	        return null;
	    }	
	    
	    public function get invalidURLError():String {
	        return _invalidURL;
	    }
	
	    public function set invalidURLError(value:String):void {
	        _invalidURL = value != null ? value: "Invalid URL: the url must begin with https:// and end with crmondemand.com";
	    }
	    
        public function get pattern():RegExp{
			return _pattern;
		}
		
		public function set parttern(value:RegExp):void{
			_pattern = value != null ? value : new RegExp(/^(https):\/\/([\w-]+\.)+crmondemand.com(\/)?$/);
		}
	    
	}
}