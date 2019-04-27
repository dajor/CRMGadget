package gadget.util
{
	import com.google.analytics.utils.URL;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import gadget.i18n.i18n;
	
	import mx.collections.ArrayCollection;
	import mx.events.Request;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.http.HTTPService;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.utils.HTTPLoader;

	public class SSOUtils
	{
		
		private static var sessionId:String; 
		private static var techSessionId:String;
		public function SSOUtils()
		{
		}
		
		public static function resetSession():void{
			sessionId =null;
			techSessionId=null;
		}
		
		private static  function technicallUserLogin(_preferences:Object,errorHandler:Function, successHandler:Function):void{
			var request:URLRequest = new URLRequest();			
			var strForwardSlash:String = _preferences.sodhost.charAt(_preferences.sodhost.length-1) == "/" ? "" : "/";			
			var stream:URLLoader = new URLLoader();
			
			stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(e:HTTPStatusEvent):void{
				var session:String = getHeaderValue(e.responseHeaders,'Set-Cookie');
				techSessionId =session.split(';')[0];
				successHandler(techSessionId);
			} );
			
			stream.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{				
				errorHandler(e);	
			});			
			request.url=_preferences.sodhost + strForwardSlash + "Services/Integration?command=login";			
			request.manageCookies=false;
			var username:String = _preferences.tech_username;
			var password:String = _preferences.tech_password;			
			
			request.requestHeaders.push(new URLRequestHeader("Username", username));
			request.requestHeaders.push(new URLRequestHeader("Password", password));		
						
			stream.load(request);		
		}
		
		
		/*
		 * 
		 */
		public static function execute(pref:Object, successHandler:Function,errorHandler:Function,isTestLogin:Boolean=false,isAddmin:Boolean=false):void{
			if(isTestLogin){
				resetSession();
			}
			if(isAddmin){
				if(techSessionId==null){
					technicallUserLogin(pref,errorHandler,successHandler);
				}else{
					successHandler(techSessionId);
				}
				return;
			}
			if(sessionId!=null && sessionId!=''){
				successHandler(sessionId);
				return;
			}
			var sodhost:String = pref.sodhost;
			var strForwardSlash:String = sodhost.charAt(sodhost.length-1) == "/" ? "" : "/";
			var url:String = sodhost + strForwardSlash +  "Services/Integration?command=ssoitsurl&ssoid="+pref.company_sso_id;			
			
			
			
			var req:URLRequest=new URLRequest(url);
			req.followRedirects=false;
			req.method=URLRequestMethod.GET;
			req.useCache=false;
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void {				
				errorHandler(e);
			});
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,function(e:HTTPStatusEvent):void {				
				doGetLocation(pref,successHandler,errorHandler,e,isTestLogin);
			});
			loader.load(req);
			
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
		
		private static function doGetLocation(pref:Object,successHandler:Function,errorHandler:Function,e:HTTPStatusEvent,isTestLogin:Boolean):void{
			if(e.status==200){
				var headers:Array=e.responseHeaders;
				
				
				
				var loginUrl:String=getHeaderValue(headers,'X-SsoItsUrl');							
				var targetURL:String = loginUrl.substr(loginUrl.indexOf("TARGET"),loginUrl.length);
				var req:URLRequest=new URLRequest(loginUrl);
				req.method=URLRequestMethod.GET;
				req.followRedirects=false;
				
				req.useCache=false;
				req.userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1";
				
				var loader:URLLoader=new URLLoader();
				loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void{
					errorHandler(e);
				});
				
				var isBreak:Boolean = false; 
				loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,function(e:HTTPStatusEvent):void {					
					var headers:Array=e.responseHeaders;
					var location:String = getHeaderValue(headers,"Location");
					if(location!=null && location.length>0){
						doGetSessionId(pref,successHandler,errorHandler,e,isTestLogin,targetURL);
						isBreak = true;
						return;
					}
					
				});			
				
				
				loader.addEventListener(Event.COMPLETE,	function(e:Event):void{
					if(isBreak){
						return;
					}
					var body:String = URLLoader(e.target).data;
					var actionUrl:String=getValue(body,"<form method=\"POST\"","\" AutoComplete");
					var refid:String=getValue(body,"NAME=\"refid\"","\">");
					
					req=new URLRequest(actionUrl);
					req.method=URLRequestMethod.POST;
					req.followRedirects=false;
					req.useCache=false;
					

					
					req.userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1";
					var params:URLVariables = new URLVariables();
					params["username"] = pref.sodlogin;//"VIPUSER2";
					params["password"] = pref.sodpass;//"welcome2";
					params["refid"] = refid;
					req.data=params;
					loader=new URLLoader();
				
					
					loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void {					
						errorHandler(e);
					});
					loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,function(e:HTTPStatusEvent):void {					
						doGetSessionId(pref,successHandler,errorHandler,e,isTestLogin,targetURL);
					
						//loader.close();
					});					
					
					
					loader.load(req);
				});
				loader.load(req);
				
				
							
				
				
			}else{
				//todo error
				var error:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,e.toString());				
				errorHandler(error);
			}
		}
		
		private static function doGetSessionId(pref:Object,successHandler:Function,errorHandler:Function,e:HTTPStatusEvent,isTestLogin:Boolean,targetUrl:String):void{
			var locationUrl:String = getHeaderValue(e.responseHeaders,"Location");
			
			if(locationUrl==''){
				errorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,i18n._("INVALID_USER_PASSWORD")));;
				return;
			}
			
			
			locationUrl = locationUrl.substr(0,locationUrl.indexOf("TARGET"));
			locationUrl = locationUrl + targetUrl;
			var req:URLRequest=new URLRequest(locationUrl);
			req.method=URLRequestMethod.GET;
			req.useCache=false;
			

			
			
			var loader:URLLoader=new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void{
				errorHandler(e);
			});
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,function(e:HTTPStatusEvent):void {					
				doExecute(successHandler,errorHandler,e,isTestLogin);	
				(e.currentTarget as URLLoader).close();
			});
			loader.load(req);
			
			
			

		}
		
		
		private static function getValue(body:String,startStr:String,endStr:String):String{
//			var startStr:String="NAME=\"refid\"";
			var startInd:int = body.indexOf(startStr);			
				startInd= startInd+ startStr.length;
			var endInd:int=body.indexOf(endStr,startInd);
			var tempRefid:String = body.substring(startInd,endInd);
				tempRefid=tempRefid.split("=")[1];
				tempRefid=tempRefid.replace(/"/gi,"");
			return tempRefid;
		}
		
		private static function doExecute(successHandler:Function,errorHandler:Function,e:HTTPStatusEvent,isTestLogin:Boolean=false ):void{
			if(e.status==200){				
				var headers:Array=e.responseHeaders;
				var loginUrl:String='';
				for each(var rHeader:URLRequestHeader in headers){
					if(rHeader.name=='Set-Cookie'){
						sessionId=rHeader.value.split(';')[0];
						break;
					}
				}
				if(sessionId!=null && sessionId!=''){
					successHandler(sessionId);
				}
				if(isTestLogin){
					resetSession();
				}
	//for Testing popose			
//				var request:URLRequest = new URLRequest("https://secure-ausomxaya.crmondemand.com/Services/Integration");
//				//request.url = getURI(service);
//				request.method = URLRequestMethod.POST;
//				request.contentType = "text/xml; charset=utf-8";
//				request.requestHeaders.push(new URLRequestHeader("SOAPAction", "\"document/urn:crmondemand/ws/account/:AccountQueryPage\""));
//				request.requestHeaders.push(new URLRequestHeader("Cookie",sessionId ));
//				request.data=<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/'>
//							<SOAP-ENV:Body>
//               						<AccountWS_AccountQueryPage_Input xmlns='urn:crmondemand/ws/account/'>
//    	           						<PageSize>50</PageSize> 
//	          							<ListOfAccount>
//        							       <Account>
//               									<AccountId sortorder='ASC' sortsequence='1'/>
//               									<AccountName/>
//											</Account>
//										</ListOfAccount>
//									<StartRowNum>0</StartRowNum>
//							</AccountWS_AccountQueryPage_Input>
//						</SOAP-ENV:Body>
//					</SOAP-ENV:Envelope>;
//				
//				var loader:URLLoader =new URLLoader();
//				
//				loader.addEventListener(Event.COMPLETE, function(e:Event):void {
//					trace("Success "+ e.target);		
//				});
//				loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
//					trace("error "+ e.target);
//				});
//				
//				
//				loader.load(request);
				
				
				
			}else{
				errorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,e.toString()));
			}
			
		}
		
		
		
		
		
		
		
	}
}