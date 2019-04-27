package gadget.sync.task
{
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.util.CookieUtil;
	import gadget.util.SSOUtils;
	import gadget.util.XmlUtils;


	public class LoginCRM {
		
		private var _successHandler:Function;
		private var _errorHandler:Function;

		private var sessionId:String;
		private var httpStatus:int;
		
		private var uri:String;
		private var startTime:Number;
		private var _preferences:Object=null;
		protected function now():Number {
			return (new Date()).getTime();
		}
		
		public function LoginCRM(pSuccessHandler:Function, pErrorHandler:Function) {
			_successHandler = pSuccessHandler;
			_errorHandler = pErrorHandler;
		}
		
		public function loginCRM(_preferences:Object,isTestLogin:Boolean = true):void {
			if (_preferences.sodhost=="" || _preferences.sodlogin=="") {
				_errorHandler(i18n._("Missing 'Connection information' in 'Preferences'"), null);
				return;
			}
			this._preferences = _preferences;
	
			if(_preferences.use_sso==1){
				SSOUtils.execute(_preferences,technicallUserLogin,loginCRMErrorHandler,isTestLogin);
				
			}else{
				technicallUserLogin();
			}
	     
			

			
		}
		
		private function technicallUserLogin(tempsessionId:String =null):void{
			var request:URLRequest = new URLRequest();			
			var strForwardSlash:String = _preferences.sodhost.charAt(_preferences.sodhost.length-1) == "/" ? "" : "/";			
			var stream:URLStream = new URLStream();
			stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, loginCRMHttpHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{
				if(tempsessionId == null){
					loginCRMErrorHandler(e);
				}else{
					loginCRMErrorHandler(e,"false");
				}
				
			});
			stream.addEventListener(ProgressEvent.PROGRESS, function (e:ProgressEvent):void{
				if(tempsessionId == null){
					loginCRMDataHandler(e);
				}else{
					loginCRMDataHandler(e,"Tech. ");
				}
			});
			request.idleTimeout =10000;
			request.url=_preferences.sodhost + strForwardSlash + "Services/Integration?command=login&isEncoded=Y";
			if(Database.preferencesDao.getBooleanValue("use_sso")){
				request.manageCookies=false;
			}
			
			
			var username:String = _preferences.sodlogin;
			var password:String = _preferences.sodpass;
			
			if(tempsessionId!=null && tempsessionId.length>0){
				username = _preferences.tech_username;
				password = _preferences.tech_password;
			}
			request.requestHeaders.push(new URLRequestHeader("Username", encodeURI(username)));
			request.requestHeaders.push(new URLRequestHeader("Password",encodeURI(password)));
			sessionId = null;
			uri	= _preferences.sodhost;
			startTime = now();				
			stream.load(request);		
		}
		
		

		
		
		private function loginCRMErrorHandler(event:IOErrorEvent,isSSO:String = null):void {
			var byteAvailable:int = 0;
			if(event.target is URLStream){
				byteAvailable = URLStream(event.target).bytesAvailable;
			}else if(event.target is URLLoader){
				byteAvailable = URLLoader(event.target).bytesTotal;
			}
			if (event.target!=null && (byteAvailable==0) && event.errorID==2032) {
				_errorHandler(i18n._("Missing Internet connectivity? Login failed: {1}", event.text), null);
			} else {
				var msg:String = i18n._("Login failed due to IO error: {1}", event.text);
				if(isSSO=="true"){
					msg = "SSO "+ msg;
				}else if (isSSO=="false"){
					msg = "Tech. "+ msg;
				}
				_errorHandler( msg, null);
			}
			Database.errorLoggingDao.add(null, {
				URI:		uri,
				event:		event.toString(),
				duration:	now()-startTime,
				state:		"login error"
			});
		}

		private function loginCRMHttpHandler(event:HTTPStatusEvent):void {
			httpStatus = event.status;
			if (httpStatus == 200) {
	 			for (var i:int = 0; i < event.responseHeaders.length; i++) {
					if (event.responseHeaders[i].name == 'Set-Cookie' && event.responseHeaders[i].value.indexOf('JSESSIONID') == 0) {
						sessionId = event.responseHeaders[i].value.substring(11, event.responseHeaders[i].value.indexOf(';'));
						//VAHI XXX TODO add more checks?
						// Only succeed if we have a session cookie
						_successHandler(sessionId);
						return;
	   				}
	   			}
			} else {
//				_errorHandler(_("HTTP Error {1}", event.status), event);
				Database.errorLoggingDao.add(null, {
					URI:		uri,
					event:		event.toString(),
					httpCode:	event.status,
					duration:	now()-startTime,
					state:		"login http error"
				});
			}
		}

		private function loginCRMDataHandler(event:ProgressEvent,begintText:String = ""):void {
//			var data:String = URLLoader(event.target).data;

			event.target.removeEventListener(ProgressEvent.PROGRESS, loginCRMDataHandler, false);

			if (httpStatus==200 && sessionId!=null)
				return;

			var data:ByteArray = new ByteArray();
			event.target.readBytes(data,0,event.target.bytesAvailable);
			_errorHandler(begintText + i18n._("Login unsuccessful: {1}", XmlUtils.XMLcleanString(data)), null);

			Database.errorLoggingDao.add(null, {
				URI:		uri,
				event:		event.toString(),
				sessionId:	sessionId,
				data:		data,
				duration:	now()-startTime,
				state:		"login unsuccessful"
			});
		}
	}
}
