package tests
{
	
	import gadget.util.StringUtils;
	
	import org.flexunit.Assert;
	
	public class StringUtilsTest {
	
		[Test(description="Length is greater than string")]
		public function reduceTextLength1():void{
		    var s:String = StringUtils.reduceTextLength("hello", 10);
		    Assert.assertEquals("hello", s);
		}

		[Test(description="Length is smaller than string")]
		public function reduceTextLength2():void{
		    var s:String = StringUtils.reduceTextLength("hello world", 5);
		    Assert.assertEquals("hello...", s);
		}

		[Test(description="StartsWith test #1")]
		public function startsWith1():void {
			var result:Boolean = StringUtils.startsWith("hello world", "hello");
			Assert.assertTrue(result);
		}

		[Test(description="StartsWith test #2")]
		public function startsWith2():void {
			var result:Boolean = StringUtils.startsWith("hello world", "good bye");
			Assert.assertFalse(result);
		}
		[Test(description="String '' IsEmpty return true.")]
		public function isEmpty1():void {
			var result:Boolean = StringUtils.isEmpty("");
			Assert.assertTrue(result);
		}
		
		[Test(description="String null IsEmpty return true.")]
		public function isEmpty3():void {
			var result:Boolean = StringUtils.isEmpty(null);
			Assert.assertTrue(result);
		}
		
		[Test(description="String 'hello' IsEmpty return false.")]
		public function isEmpty2():void {
			var result:Boolean = StringUtils.isEmpty("hello");
			Assert.assertFalse(result);
		}
		
		[Test(description="XML Escaping test.")]
		public function testXmlEscape():void {
			Assert.assertEquals("&lt;>", StringUtils.xmlEscape("<>"));
		}
		
		
		[Test(description="String 'hello world' EndsWith 'world' return true.")]
		public function endsWith1():void {
			var result:Boolean = StringUtils.endsWith("hello world", "world");
			Assert.assertTrue(result);
		}
		
		[Test(description="String 'hello world!' EndsWith 'world' return false.")]
		public function endsWith2():void {
			var result:Boolean = StringUtils.endsWith("hello world!", "world");
			Assert.assertFalse(result);
		}
		
		[Test(description="Extention of toto.doc is doc")]
		public function getExtention():void{
			var result:String = StringUtils.getExtension("toto.doc");
			Assert.assertEquals("doc", result);
		}
	}
}