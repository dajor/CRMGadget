package gadget.util
{
	import flash.net.URLRequestDefaults;
	
	public class Startup
	{
		public static function init():void {
			URLRequestDefaults.idleTimeout = 20000000;	// 20000s or 5,55h max
		}

		public static function pre_db():void {
		}

		public static function post_db():void {
		}

		public static function running():void {
		}
	}
}