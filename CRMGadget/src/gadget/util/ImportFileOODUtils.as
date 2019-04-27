package gadget.util
{
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class ImportFileOODUtils
	{
		public function ImportFileOODUtils()
		{
		}
		private var uri:String;
		private var httpStatus:int;
		private static var sessionId:String; 
	
		/*
		* 
		*/
		public static function execute(pref:Object, successHandler:Function,errorHandler:Function):void{
			
			
			var sodhost:String = pref.sodhost;
			var strForwardSlash:String = sodhost.charAt(sodhost.length-1) == "/" ? "" : "/";		
			var url:String = pref.sodhost + strForwardSlash + "OnDemand/authenticate";
			var request:URLRequest = new URLRequest(url);			
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(e:HTTPStatusEvent):void{
				var session:String = getHeaderValue(e.responseHeaders,'Set-Cookie');
				sessionId =session.split(';')[0];
				successHandler(sessionId);
			} );
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{				
				errorHandler(e.text,null);	
			});			
	
			request.method = URLRequestMethod.POST;
			request.userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1";
			var username:String = pref.sodlogin;
			var password:String = pref.sodpass;			
			
			var variables:URLVariables = new URLVariables();
			variables.j_username = username;
			variables.j_password = password;
			request.followRedirects=false;
			request.useCache = false;
			request.data = variables;
			loader.load(request);		

			
		}

		private static function getHeaderValue(headers:Array ,key:String, isJSESSION:Boolean = false): String{
			for each(var rHeader:URLRequestHeader in headers){
				if(isJSESSION){
					if(rHeader.name==key && rHeader.value.indexOf("JSESSIONID") != -1){
						return rHeader.value;
					}
				}else{
					if(rHeader.name==key){
						return rHeader.value;
					}
				}
			}	
			return '';
		}

	}
}