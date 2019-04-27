package tests
{
	import gadget.util.URLValidator;
	
	import mx.events.ValidationResultEvent;
	
	import org.flexunit.Assert;
	
	public class URLValidatorTest{
		
		[Test(description="URLValidator Test with url='secure-ausomxapa.crmondemand.com'")]
		public function testURLValidator1():void{
			var urlValidator:URLValidator = new URLValidator();
			var v: ValidationResultEvent = urlValidator.validate("secure-ausomxapa.crmondemand.com");
			Assert.assertEquals("invalid", v.type);
			Assert.assertEquals("Invalid URL: the url must begin with https:// and end with crmondemand.com",v.message);
		}
		
		[Test(description="URLValidator Test with url='https://secure-ausomxapa.crmondemand.com'")]
		public function testURLValidator2():void{
			var urlValidator:URLValidator = new URLValidator();
			var v: ValidationResultEvent = urlValidator.validate("https://secure-ausomxapa.crmondemand.com");
			Assert.assertEquals("valid", v.type);
		}
		
		[Test(description="URLValidator Test with url='https://secure-ausomxapa.crmondemand.com/'")]
		public function testURLValidator3():void{
			var urlValidator:URLValidator = new URLValidator();
			var v: ValidationResultEvent = urlValidator.validate("https://secure-ausomxapa.crmondemand.com/");
			Assert.assertEquals("valid", v.type);
		}		
	}
}