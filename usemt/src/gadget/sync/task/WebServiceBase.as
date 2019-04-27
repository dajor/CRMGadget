
package gadget.sync.task {

	import com.probertson.utils.GZIPEncoder;
	import com.probertson.utils.GZIPFile;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.sync.incoming.GetTime;
	import gadget.util.Debug;
	import gadget.util.OOPStrace;
	import gadget.util.SSOUtils;
	import gadget.util.Utils;
	import gadget.util.XmlUtils;
	
	import mx.rpc.soap.WebService;
	import mx.utils.StringUtil;

	public class WebServiceBase {
		
		protected const NS0:Namespace = new Namespace("http://schemas.xmlsoap.org/soap/envelope/");
		protected const NSERR:Namespace = new Namespace("http://www.siebel.com/ws/fault");

		private const MAX_RETRIES:int = 50;	//VAHI the maximum number of retries
		private const HARD_ERROR_RETRY_ADD:int=4;  //VAHI additional retry costs on hard errors
		protected static var SOD_RATE_LIMIT:Number = 1000/20+0;	// ms, the +XXX is a workaround to slow down a little more
		protected static var nextRequest:Number, nextAdjust:int = 0;
		protected var retries:int;		
		protected var requestStarted:Number;
		private var isInited:Boolean = false;		
		private var prefFault:Array=[{'<ErrorMessage>':'</ErrorMessage>'},{'<siebelf:errormsg>':'</siebelf:errormsg>'},
			{'<faultstring>':'</faultstring>'}];//MONY key is start prefix and value is end prefix	
		private const RETRY_WAIT_BACKOFF:int = 2000;	//VAHI ms, wait retry* this when retrying

		//VAHI timeout values.  100000 is 1.66 minutes.
		// The first retry has MAX_TIMEOUT+TIMEOUT_BACKOFF timeout
		// The Nth   retry has MAX_TIMEOUT+TIMEOUT_BACKOFF*Nth timeout
		protected const MAX_TIMEOUT:int = 600000;		//VAHI ms, timeout value (600s is 10 minutes)
		protected const TIMEOUT_BACKOFF:int = 300000;	//VAHI ms, additional timeout value when retrying (300s is 5 minutes)
		private var _param:TaskParameterObject;
		protected var _failed:Boolean;			//VAHI yes, keep this private!
		private var _iscompress:Boolean=true;
		protected var timer:Timer;
		protected var isFielChange:Boolean = false;
		protected var isuseSSO:Boolean = Database.preferencesDao.getBooleanValue("use_sso");

		//VAHI Parameter Set Array, to reduce the numbers of paramaters to requestCall.
		// The TaskParameterObject is linked to a private variable.
		// However the parameters can be publicly changed.
		// (Perhaps we have to refactor this again, but this was the best I can do in the short time)
		public function set param(p:TaskParameterObject):void {
			_param	= p;
		}
		public function get param():TaskParameterObject {
			return _param;
		}
		public function isFieldChange():Boolean{
			return isFielChange;
		}
		
		protected var linearTask:Boolean = false;	//VAHI the task is linear (no splitting)
		public function get isLinearTask():Boolean {
			return linearTask;
		}

		protected var noPreSplit:Boolean = false;	//VAHI do not do the default splits.
		public function get noPresplit():Boolean {
			return noPreSplit;
		}
		
		
		public function requestCall():void {

			
			if (!(this is GetTime)) {
				createLastSync();
			}
			
			_failed = false;
			retries	= 0;

			trace("WebServiceCall for "+getEntityName());
			if (!isInited) {
				initOnce();
				isInited=true;
			}
			initEach();
			
			doRequest();
		}
		
		
		protected function createLastSync():void {
			var task_name:String = getMyClassName();
			var syncObject:Object = Database.lastsyncDao.find(task_name); 
			if(syncObject == null){
				syncObject = new Object();
				syncObject.task_name = task_name;
				syncObject.sync_date = NO_LAST_SYNC_DATE;
				syncObject.start_row = 0;
				syncObject.start_id = '';
				Database.lastsyncDao.insert(syncObject);
			}			
		}
		
		
		protected const NO_LAST_SYNC_DATE:String = "01/01/1970 00:00:00";
		
		
		
		//VAHI using the "start_row" and "start_id" fields as selectors
		// for automatic FullSync support.
		// I KNOW THIS IS UNCLEAN!  No time to do it properly now.
		//
		// Use as follows:
		// Call this as getLastSync(0).
		// Increment this number to make syncs from older clients invalid.
		// Example: Some feature is added and requires a full sync -> inc number.
		// Call this as getLastSync(0,value) to compare if the last sync was done
		// with the same value.  For example if the transaction changes -> Full Sync.
		protected function getLastSync(minRow:int=0, mustBeSame:String=null):String {
			if (param.full) {
				return NO_LAST_SYNC_DATE;
			}
			var lastSyncObject:Object = Database.lastsyncDao.find(getMyClassName());
			if (lastSyncObject == null
				|| lastSyncObject.start_row < minRow
				|| (mustBeSame!=null && lastSyncObject.start_id!=mustBeSame)
			) {
				return NO_LAST_SYNC_DATE;
			}
			return lastSyncObject.sync_date;
		}
		
		public function getMyClassName():String {
			return getQualifiedClassName(this);
		}
		
		
		
		
		protected function updateLastSync(minRow:int=0, mustBeSame:String=''):void {
			var task_name:String = getMyClassName();
			var syncObject:Object = new Object();
			syncObject.task_name = task_name;
			syncObject.sync_date = NO_LAST_SYNC_DATE;
			syncObject.start_row = minRow;
			syncObject.start_id = mustBeSame;
			//VAHI note that this is wrong - traditionally.
			// It is OK for all tasks which only need to be run once,
			// but for all others it MUST be the START time,
			// not the END time.
			// However this code currently shall only be used
			// by old code now, hopefully none which really depends
			// on a correct date.
			// One exception, though (will be fixed in future):
			// Get deleted objects.
			// (Perhaps I will forget to take out this comment when
			// deleted objects is fixed.)
			var time:GetTime = new GetTime(); 
			time.call(false, _param.preferences, 
				function (date:String):void {
					try {
						syncObject.sync_date = date;
						Database.lastsyncDao.update(syncObject);
						successHandler(null);
					} catch (e:Error) {
						failErrorHandler_err2(null, e);
					}	
				}, 
				_param.warningHandler,
				_param.errorHandler, null, null);
		}
		
		protected function optWarn(mess:String, event:Event=null):void {
			OOPStrace("=optwarn",mess);
			if (Debug.isVerbose())
				_param.warningHandler(mess, event,getCurrentRecordError());
		}

		protected function warn(mess:String):void {
			OOPStrace("=warn",mess);
			_param.warningHandler(mess, null,getCurrentRecordError());
		}
		
		protected function info(mess:String){
			_param.infoHandler(mess);
		}

		protected function initEach():void {}
		protected function initOnce():void {}
		public function getRecordCount():String { return null; }	//VAHI Number cannot be NULL
		
		protected function getURI(service:String=null):String {
			var sodhost:String = _param.preferences.sodhost;
			var strForwardSlash:String = sodhost.charAt(sodhost.length-1) == "/" ? "" : "/";
			var str:String = sodhost + strForwardSlash + (service ? service : "Services/Integration");
			return str;
		}

		protected function notImpl(s:String):void {
			_failed = true;
			s = i18n._("{1} not implemented", s);
			if (_param!=null && _param.errorHandler!=null) {
				_param.errorHandler(s+" not implemented", null);
			} else {
				throw s;
			}
		}

		protected function doRequest():void {
			notImpl("doRequest");
		}

		protected function handleResponse(request:XML, response:XML):int {
			notImpl("handleResponse");
			return 0;
		}
		
		protected function now():Number {
			return (new Date()).getTime();
		}

		//VAHI This routine is only for the simple retry case,
		// where a request must be sent UNCHANGED again.
		protected function retry(soapAction:String, request:XML, ms:int, speed:Boolean=false):void {
			if (!speed) {
				//VAHI hack to improve pipelining in the desparate case
				if (nextAdjust<ms)
					nextAdjust = ms;
			}
			if (retries>MAX_RETRIES)
				failErrorHandler(i18n._("too many retries ({1.retries}) for {1.entity}", { entity:getEntityName(), retries:retries }));
			else
				setTimeout(function(self:WebServiceBase):void {sendRequest.call(self,soapAction,request)}, ms, this);
		}
		
		protected function sendRequest(soapAction:String, xml:XML, type:String=null, service:String=null):void {		
			if(isuseSSO){
				SSOUtils.execute(param.preferences,
					function(sessionid:String):void{
					doSendRequest(soapAction, xml, type, service,sessionid);
				},function(e:IOErrorEvent):void{
					requestFaultHandler.call(this, soapAction, xml, null, e);
				}	);
			}else{
				doSendRequest(soapAction, xml, type, service);
			}
		

		}

		protected function doSendRequest(soapAction:String, xml:XML, type:String=null, service:String=null,sessionId:String=null ):void{
			
			var self:WebServiceBase = this;	//VAHI make "this" available for closure
			
			retries++;
			
			if (nextRequest) {				
				var delta:Number = (nextRequest-now())+nextAdjust;
				if (delta>0) {
					//VAHI self session rate limiting
					trace("slowing down", delta,"---------------------------------------------------------------------------");
					retry(soapAction,xml,delta,true);
					return;
				}
			}
			var request:URLRequest = new URLRequest();
			request.url = getURI(service);
			//Test
//			if(type =="admin"){
//				request.url="https://secure-ausomxbfa.crmondemand.com/"+service;
//			}
			request.method = URLRequestMethod.POST;
			request.contentType = "text/xml; charset=utf-8";
			request.requestHeaders.push(new URLRequestHeader("SOAPAction", soapAction));
			
			if(Database.preferencesDao.getBooleanValue("usegzip") && _iscompress){
				request.requestHeaders.push(new URLRequestHeader("Accept-Encoding", "gzip"));
			}
			
			/*
			if (wantGzip) {
			request.requestHeaders.push(new URLRequestHeader("Accept-Encoding", "gzip"));
			} else {
			trace(">>>>>>>>>>>>> GZIP switched off <<<<<<<<<<<<<<<<<<");
			}
			*/
			request.data = 
				<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
						xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
						xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
						xmlns:xsd="http://www.w3.org/2001/XMLSchema"
						>
					<soap:Body/>
				</soap:Envelope>;			
			if (type=="admin") {
				//VAHI really awful hack
				// for unknown reason this does not use the session.
				// Documentation says, Password must look like follows, but this does not work.
				//<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wssusername-token-profile-1.0#PasswordText">{_param.preferences.sodpass}</wsse:Password>
				// Reading SOAP doc shows, that you can leave Type away to use a default of #PasswordText
				// Luckily this works.
				
				request.data =
					<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
							xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
							xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
							xmlns:xsd="http://www.w3.org/2001/XMLSchema"
							>
						<soap:Header>
							<wsse:Security>
							<wsse:UsernameToken>
								<wsse:Username>{isuseSSO?_param.preferences.tech_username:_param.preferences.sodlogin}</wsse:Username>
								<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">{isuseSSO?_param.preferences.tech_password:_param.preferences.sodpass}</wsse:Password>
							</wsse:UsernameToken>
						</wsse:Security>
						<ClientName xmlns="urn:crmondemand/ws">Fellow Consulting AG, CRM Gadget</ClientName>
						<!-- <FlushCache xmlns="urn:crmondemand/ws">true</FlushCache> -->
						</soap:Header>
						<soap:Body/>
					</soap:Envelope>;
				request.manageCookies=!isuseSSO;
			}else if(sessionId!=null && sessionId.length>0){
				request.requestHeaders.push(new URLRequestHeader("Cookie", sessionId));
			}else{				
					request.data = 
						<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
								xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								xmlns:xsd="http://www.w3.org/2001/XMLSchema"
								>
								<soap:Header>
									<wsse:Security>
									<wsse:UsernameToken>
										<wsse:Username>{_param.preferences.sodlogin}</wsse:Username>
										<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">{_param.preferences.sodpass}</wsse:Password>
									</wsse:UsernameToken>
								</wsse:Security>
								<ClientName xmlns="urn:crmondemand/ws">Fellow Consulting AG, CRM Gadget</ClientName>
								<!-- <FlushCache xmlns="urn:crmondemand/ws">true</FlushCache> -->
								</soap:Header>
							<soap:Body/>
						</soap:Envelope>;
				
				
				
			}
			(request.data.NS0::Body[0] as XML).appendChild(xml);
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			/*
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(e:HTTPStatusEvent):void {
			requestStatus.call(self, soapAction, xml, e);
			});
			*/
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				requestHandler.call(self, soapAction, xml, loader, e)		
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				requestFaultHandler.call(self, soapAction, xml, loader, e);
			});
			/*
			_isGzip = false;
			*/
			loader.load(request);
			
			requestStarted = now();
			nextRequest = requestStarted+SOD_RATE_LIMIT;
			
			timer = new Timer(MAX_TIMEOUT+TIMEOUT_BACKOFF*retries,1);
			timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				requestTimeout.call(self, loader, soapAction, xml, e);
			});
			timer.start();
			
			if (Database.preferencesDao.getStrValue("request_log").indexOf("("+getEntityName()+")")>=0 ||
				Database.preferencesDao.getStrValue("request_log").indexOf("(*)")>=0) {
				Database.errorLoggingDao.add(null,{
					entity:getEntityName(),
					method:request.method,
					url:request.url,
					SOAPAction:soapAction,
					contentType:request.contentType,
					request:request.data.toString()
				});
			}
		}
		
		
		protected function stopTimer(loader:URLLoader):void {
			if(loader==null){
				return;
			}
			if (timer!=null) {
				timer.stop();
			}
			timer=null;
			loader.close();
		}

		protected function requestTimeout(loader:URLLoader, soapAction:String, request:XML, event:TimerEvent):void {
			if (timer==null) {
				return;	//VAHI delayed timeout, race condition, ignore
			}
			Database.errorLoggingDao.add(null, {entity:getEntityName(), timeout:event.toString(), soapAction:soapAction, request:request, pos:loader.bytesLoaded, total:loader.bytesTotal});
			loader.close();
			optWarn(i18n._("{1} request timeout", getEntityName()));
			retry(soapAction,request,retries*RETRY_WAIT_BACKOFF);
		}


		//VAHI if it is GZIP encoding, decompress.
		//VAHI this now is expected to throw if uncompression fails
		private function uncompress(target:Object):String {	
			if(Utils.osIsMac() || (!(Database.preferencesDao.getBooleanValue("usegzip")&& _iscompress))){
				return URLLoader(target).data;	
			}
			try{
			var rawData:ByteArray = URLLoader(target).data as ByteArray;
			var encoder:GZIPEncoder = new GZIPEncoder();
			var gzipData:GZIPFile = encoder.parseGZIPData(rawData);
			var uncompressedData:ByteArray = gzipData.getCompressedData();
			uncompressedData.uncompress(CompressionAlgorithm.DEFLATE);			
			return uncompressedData.toString();
			}catch(e:Error){
				return URLLoader(target).data;
			}
			return URLLoader(target).data;
		}

		protected function requestHandler(soapAction:String, request:XML, loader:URLLoader, event:Event):void {
			var str:String = null;
			var xml:XML = null;
			var step:String;
			var duration:Number = now()-requestStarted;

			stopTimer(loader);
			if (_failed) {
				return;
			}
			//VAHI on successful answers, reduce the adjustment a bit
			// changed to half the duration to make it faster adopt to a better situation
			if (nextAdjust>0)
				nextAdjust = int(nextAdjust/2);
			try {
				step = "uncompress";
//				trace("responselen",event.target.bytesTotal,"gzip",_isGzip);
				trace("response",getEntityName(),"len",event.target.bytesTotal,"took",duration);
				str	= uncompress(event.target);
				xml = new XML(str);
				
				//session expired
				if(str.indexOf("SBL-ODU-01006")!=-1 && isuseSSO){
					SSOUtils.resetSession();
					doRequest();
					return;
				}		
				//var response:XML = (new XML(URLLoader(event.target).data).ns0::Body[0] as XML).children()[0];

				
				/*
				if (request.toXMLString().indexOf("ListOfAttachment")>0) {
					xml	=
						<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
						  <soap:Body>
							<soap:Fault>
							  <detail>
								<siebdetail xmlns="http://www.siebel.com/ws/fault">
								  <errorstack>
									<error>
									  <errorcode>SBL-DAT-00553</errorcode>
									  <errormsg>
										Method 'Execute' of business component 'XXX Attachment' (integration component 'XXX Attachment') returned an artificial test error
									  </errormsg>
									</error>
								  </errorstack>
								</siebdetail>
							  </detail>
							</soap:Fault>
						  </soap:Body>
						</soap:Envelope>;
				}
				/**/
				/*
				xml	=
					<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
					  <soap:Body>
						<soap:Fault>
						  <faultcode>soap:Server</faultcode>
						  <faultstring>Server</faultstring>
						  <detail>
							<ErrorCode>SBL-ODU-01005</ErrorCode>
							<ErrorMessage>The maximum rate of requests was exceeded.  Please try again in 5 ms.</ErrorMessage>
							<RequestWait>5</RequestWait>
						  </detail>
						</soap:Fault>
					  </soap:Body>
					</soap:Envelope>;
				/**/
				/*
				xml	= 
					<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
					 <soap:Body>
					   <soap:Fault>
						 <faultcode>soap:Server</faultcode>
						 <faultstring>Server</faultstring>
						 <detail>
						   <ErrorCode>SBL-ODU-01006</ErrorCode>
						   <ErrorMessage>RIP_WAIT_ERROR_TIMEOUT</ErrorMessage>
						 </detail>
					   </soap:Fault>
					 </soap:Body>
					</soap:Envelope>;
				/**/
				/*
				xml	= 
					<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
					 <soap:Body>
					   <soap:Fault>
						 <faultcode>soap:Server</faultcode>
						 <faultstring>Server</faultstring>
						 <detail>
						   <ErrorCode>SBL-ODU-01006</ErrorCode>
						   <ErrorMessage>RIP_WAIT_ERROR_TIMEOUT</ErrorMessage>
						 </detail>
					   </soap:Fault>
					 </soap:Body>
					</soap:Envelope>;
				/**/

				if (request==null) {
					request=new XML();
				}
				step = "0";
				var fault:XMLList = xml.NS0::Body[0].NS0::Fault;
//				throw Error("meep");
				//VAHI New siebel Fault message handler
				// Generic Siebel Faults are received as reqular (successful) XML message
				if (fault.length()>0) {
					_iscompress=false;
					Database.errorLoggingDao.add(null, {
						URI:		getURI(),
						entity:		getEntityName(),
						event:		event.toString(),
						rateLimit:	SOD_RATE_LIMIT,
						retries:	retries,
//						gzip:		_isGzip,
						soapAction:	soapAction,
						request:	request.toXMLString(),
						response:	xml.toXMLString(),
						bytes:		event.target.bytesTotal,
						duration:	duration,
						state:		"requestHandler, fault"
					});
					var detail:XMLList = fault[0].detail;
					step = "1";
					var sodErr:XMLList = detail;
					var RequestWait:XMLList = detail;
					var ErrorMessage:XMLList = detail;
					if (detail.length()>0) {
						//If not, both have zero length
						sodErr = detail[0].NSERR::siebdetail;
						RequestWait = detail[0].RequestWait;
						ErrorMessage = detail[0].ErrorMessage;
					}
					if (sodErr.length()>0) {
						step = "1a";
						sodErr	= sodErr[0].NSERR::errorstack[0].NSERR::error;
						step = "1b";
						handleSodFault(soapAction, request, xml, sodErr, sodErr[0].NSERR::errorcode[0], sodErr[0].NSERR::errormsg[0]);
					} else if (RequestWait.length()>0) {
						step = "2";
						slowdown(soapAction, request, detail);
					} else if (ErrorMessage.length()>0 && ErrorMessage[0].toString() == "RIP_WAIT_ERROR_TIMEOUT") {
						step = "3";
						rip_retry(soapAction, request);
					} else {
						step = "9";
						handleSoapFault(soapAction, request, xml, fault, fault[0].faultcode, fault[0].faultstring);
					}
					return;
				}
				step = "do";
				var cnt:int = handleResponse(request, xml.NS0::Body[0].children()[0]);
				if (Database.preferencesDao.getStrValue("response_log").indexOf("("+getEntityName()+")")>=0 ||
					Database.preferencesDao.getStrValue("response_log").indexOf("(*)")>=0) {
					Database.errorLoggingDao.add(null,{entity:getEntityName(), cnt:cnt, request:request, response:xml});
				}
				retries	= 0;
			} catch (e:Error) {				
				_iscompress=false;
				try {
					Database.rollback();					
				} catch (e:Error) {}
				if (xml==null) {
					retryFailErrorHandler2(soapAction, request, e, i18n._("in {1.entity} request handler ({1.step}): while decoding XML: received {1.bytes} bytes: {1.message}", { entity:getEntityName(), step:step, bytes:event.target.bytesTotal, message:e.message} ));
//					Database.errorLoggingDao.add(e, {
//						URI:		getURI(),
//						entity:		getEntityName(),
//						event:		event.toString(),
//						rateLimit:	SOD_RATE_LIMIT,
//						retries:	retries,
////						gzip:		_isGzip,
//						soapAction:	soapAction,
//						request:	request.toXMLString(),
//						response:	str,
//						bytes:		event.target.bytesTotal,
//						duration:	duration,
//						step:		step,
//						state:		"requestHandler, noXML"
//					});
				} else {
					retryFailErrorHandler2(soapAction, request, e, i18n._("in {1.entity} request handler ({1.step}): received bytes: {1.bytes}: {1.message}, response was '{1.response}', request was '{1.request}'", { entity:getEntityName(), step:step, bytes:event.target.bytesTotal, message:e.message, response:XmlUtils.XMLcleanString(xml).substr(0,1000), request:XmlUtils.XMLcleanString(request).substr(0,1000) }));
					optWarn(i18n._("dump of XML: {1}", xml.toXMLString().replace(/&/g,"&amp;").replace(/</g,"&lt;").substr(0,5000)));
//					Database.errorLoggingDao.add(e, {
//						URI:		getURI(),
//						entity:		getEntityName(),
//						event:		event.toString(),
//						rateLimit:	SOD_RATE_LIMIT,
//						retries:	retries,
////						gzip:		_isGzip,
//						soapAction:	soapAction,
//						request:	request.toXMLString(),
//						response:	str,
//						bytes:		event.target.bytesTotal,
//						duration:	duration,
//						step:		step,
//						state:		"requestHandler, fault"
//					});
				}
			}
		}

		protected function rip_retry(soapAction:String, request:XML):void {
			trace("RIP RETRY","---------------------------------------------------------------------------");
			optWarn(i18n._("backend timeout, retrying in {1}s" ,retries*RETRY_WAIT_BACKOFF/1000));
			retry(soapAction,request,retries*RETRY_WAIT_BACKOFF);
		}
		
		protected function slowdown(soapAction:String, request:XML, detail:XMLList):void {
			// slowdown = 15 sec
			var waitMs:int = 5000;//int(detail[0].RequestWait[0].toString());
//			trace("slowing down (remote)",waitMs,"---------------------------------------------------------------------------");
//			if (waitMs<1)
//				waitMs = 5;
//			
//			SOD_RATE_LIMIT += waitMs>5000 ? 5000 : waitMs;
//			if (SOD_RATE_LIMIT>5000)
//				SOD_RATE_LIMIT=5000;
//			optWarn(i18n._("sending too fast, waiting {1}ms, adjusting limit to {2}ms", waitMs, SOD_RATE_LIMIT));
			retry(soapAction,request,waitMs);
		}

		protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
/* Example use:
			if (!mess)
				return false;
			if (mess.indexOf("(...)")>=0) {
				if (!once)
					optWarn("Advanced Sync not supported");
				once = true;
				nextPage(true);
				return true;
			}
*/
			return false;
		}

		protected function handleSodFault(soapAction:String, request:XML, response:XML, errors:XMLList, siebelError:String, siebelMessage:String):void {
			if (handleErrorGeneric(soapAction, request, response, siebelMessage, errors))
				return;
			retryFailErrorHandler2(soapAction, request, null, i18n._("Siebel (remote) error {1}: {2}", siebelError, siebelMessage));
			trace(siebelError, siebelMessage, errors.toXMLString());
			optWarn(i18n._("dump of XML: {1}", response.toXMLString().replace(/&/g,"&amp;").replace(/</g,"&lt;").substr(0,5000)));
		}
		
		protected function handleSoapFault(soapAction:String, request:XML, response:XML, errors:XMLList, soapError:String, soapMessage:String):void {
			if (handleErrorGeneric(soapAction, request, response, soapMessage, errors))
				return;
			retryFailErrorHandler2(soapAction, request, null, i18n._("SOAP (remote) error {1}: {2}", soapError, soapMessage));
			trace(soapError, soapMessage, errors.toXMLString());
			optWarn(i18n._("dump of XML: {1}", response.toXMLString().replace(/&/g,"&amp;").replace(/</g,"&lt;").substr(0,5000)));
		}

		//VAHI return true if fault is handled here,
		// else it falls through to the standard error processing
		protected function handleZeroFault(soapAction:String, request:XML, event:IOErrorEvent):Boolean {
			return handleErrorGeneric(soapAction, request, null, null, null);
		}

		//VAHI this should be handled by some generic error handler here
		// which can be overwritten more easily.
		protected function requestFaultHandler(soapAction:String, request:XML, loader:URLLoader, event:IOErrorEvent):void {
			var str:String = null;
			var xml_list:XMLList = null;
			var xml:XML = null;
			var step:String;
			var duration:Number = now()-requestStarted;

			stopTimer(loader);
			if (_failed) {
				return;
			}
			//var xml:XML = new XML(URLLoader(event.target).data).ns0::Body[0].ns0::Fault[0];
			try {
				step="uncompress";
				trace("response(fault)",getEntityName(),"len",event.target.bytesTotal,"took",duration);
				str	= uncompress(event.target);
				//session expired
				if(str.indexOf("SBL-ODU-01006")!=-1 && isuseSSO){
					SSOUtils.resetSession();
					doRequest();
					return;
				}		
				_iscompress=false;
				step="log";
				Database.begin();
				Database.errorLoggingDao.add(null, {
					//URI:		getURI(),
					entity:		getEntityName(),
					event:		event.toString(),
					//rateLimit:	SOD_RATE_LIMIT,
					//retries:	retries,
//					gzip:		_isGzip,
					//soapAction:	soapAction,
					//request:	request.toXMLString(),
					//response:	str,
					bytes:		event.target.bytesTotal,
					//duration:	duration,
					state:		"faultHandler, info"
				});
				Database.commit();				
				
				step="-1";

				if (
//					!_isGzip && 
					str.length==0 && event.errorID==2032) {
					trace("zero length #2032 - hard coded header timeout");
					if (handleZeroFault(soapAction, request, event))
						return;
					//VAHI fall through if not handled
				}
			
				step="0";
				try {
					var response:XML = new XML(str);
				} catch (e:Error) {
					if (handleErrorGeneric(soapAction, request, null, str, null))
						return;
					throw e;
				}
				xml_list = response.NS0::Body;
				if (xml_list.length()>0)
					xml_list = xml_list[0].NS0::Fault;
				xml = xml_list.length()>0 ? xml_list[0] : new XML();
				var xmlS:String = xml.toString();
				if (xmlS=="")
					xmlS = str;
				step="1";
				
				if (xml.detail.length() > 0 && xml.detail[0].RequestWait.length() > 0) {
					step="1a";
					slowdown(soapAction, request, xml.detail);
					return;
				}
				step="2";
				if (xml.detail.length() > 0 && xml.detail[0].ErrorMessage.length() > 0 && xml.detail[0].ErrorMessage[0].toString() == "RIP_WAIT_ERROR_TIMEOUT") {
					step="2a";
					rip_retry(soapAction, request);
					return;
				}
/* VAHI found that skipping creates more problems than it solves
				step="3";
				if (xmlS.indexOf("SBL-ODS-50085") != -1 || xmlS.indexOf("SBL-DAT-00553") != -1 || xmlS.indexOf("SBL-ODU-01007") != -1) {
					step="3a";
					skip();
					return;
				}
*/
/*VAHI I disable this, because I think it does not belong here.
  It belongs into handleRequestFault() of the appropriate method.
				step="4";
				if (xmlS.indexOf("SBL-DAT-00542") != -1 || xmlS.indexOf("SBL-DAT-00235") != -1) {
					step="4a";
					var id:String = xmlS.substring(xmlS.indexOf('[Id] = "') + 8, xmlS.indexOf('"\'')); 
					ignoreError(id);
					return;
				}
*/
				step="5";
				if (handleRequestFault(soapAction, request, response, xmlS, xml_list, event))
					return;
				step="6";
				retryFailErrorHandler2(soapAction, request, null, xmlS, event);
//				_failed = true;
//				_param.errorHandler(xmlS, event);
			} catch (e:Error) {
				_iscompress=false;
				retryFailErrorHandler2(soapAction, request, e, i18n._("{1} IO error {2} after receiving {3} bytes, error type {4}: {5}", getEntityName(), event.errorID, event.target.bytesTotal, event.type, event.text));
				Database.errorLoggingDao.add(e, {
					URI:		getURI(),
					entity:		getEntityName(),
					event:		event.toString(),
					rateLimit:	SOD_RATE_LIMIT,
					retries:	retries,
//					gzip:		_isGzip,
					soapAction:	soapAction,
					request:	request.toXMLString(),
					response:	str,
					bytes:		event.target.bytesTotal,
					duration:	duration,
					step:		step,
					state:		"faultHandler, error"
				});
			}
		}

		//VAHI override if needed to ignore some types of faults
		// return true to suppress error
		protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			//if (faultString.indexOf("()")>=0) { ... }
			return handleErrorGeneric(soapAction, request, response, faultString, xml_list);
		}

		//VAHI stop() can be called before params are initialized
		public function stop():void {
			failErrorHandler(i18n._('Sync process for "{1}" aborted by user, last request at {2}', getEntityName(), (new Date(nextRequest)).toUTCString()));
        }
		
		public function done():void{
			//nothing to do, implement in the subclass
		}

		
		/**
		 * Return the task name. 
		 * @return Task name.
		 * 
		 */
		public function getName() : String {
			return "(getName not implemented)";
		}
		
		//VAHI Returns the SoD object name like
		// Account, Contact, ..
		//
		// actually should this throw?
		public function getEntityName():String {
			return "(getEntityName not implemented)";
		}

		//VAHI return the INTERNAL transaction name (so our name for the object)
		public function getTransactionName():String { return getEntityName(); }
		public function getParentTransactionName():String { return getEntityName(); }
		
		public function getFailed():Boolean {
			return _failed;
		}

		// We cannot unset the _failed state.
		public function setFailed():void {
			_failed	= true;
		}

		//VAHI renamed this from errorHandler to catch all calls
		// ever seen the second parameter non-null?
		protected function failErrorHandler(mess:String, event:Event=null):void {
			
			//bug#319			
			mess=extractErrorMessage(mess);
			_failed	= true;		//VAHI hopefully get rid of setFailed()
			if (_param!=null && _param.errorHandler!=null) {
				_param.errorHandler(mess, event,getCurrentRecordError());
			} else {
				trace("ERROR without handler:",mess);
			}
		}

		//bug#319---extract error message if it's soap fault
		protected function extractErrorMessage(mess:String):String{
			if(mess == null){
				return "";
			}
			for each(var obj:Object in prefFault){
				for(var prefStart:String in obj){
					
					var prefEnd:String=obj[prefStart];
					var indStart:int=mess.indexOf(prefStart);
					if(indStart>0){
						indStart+=prefStart.length;
						var indEnd:int=mess.indexOf(prefEnd,indStart);
						mess=mess.substring(indStart,indEnd);
						break;
					}
				}
			}
			
			return mess;
		}
		
		

		protected function failErrorHandler_err2(mess:String, err:Error, event:Event=null):void {
			Database.errorLoggingDao.add(err,{FailErrorHandler:mess, err:err, event:event});
			failErrorHandler(mess, event);
		}


		protected function retryFailErrorHandler2(soapAction:String, request:XML, err:Error, mess:String, event:Event=null):void {
			
			retries += HARD_ERROR_RETRY_ADD;
			if (retries>MAX_RETRIES){
				Database.errorLoggingDao.add(err,{RetryFailErrorHandler:mess, soapAction:soapAction, request:request, err:err, event:event});
				failErrorHandler(mess, event);
			}else {
				if(mess!=null && StringUtil.trim(mess).length>0){
					optWarn(mess, event);
				}
				
				//VAHI to enable extended error processing, this must call doRequest(), not sendRequest()
				// Is this the right fix?  Can we call doRequest() without trouble all the time?  Is it always retryable this way?
				// Note that the fix makes soapAction and request unused - if this fix is OK, remove them
				//				setTimeout(function(self:WebServiceBase):void {sendRequest.call(self,soapAction,request)}, retries*RETRY_WAIT_BACKOFF, this);
				trace("delay",getEntityName(),retries*RETRY_WAIT_BACKOFF);
				setTimeout(function(self:WebServiceBase):void {doRequest.call(self)}, retries*RETRY_WAIT_BACKOFF, this);
			}
		}


		protected function getCurrentRecordError():Object{
			//for out going only
			return null;
		}

		protected function get eventHandler():Function {
			return _param.eventHandler;
		}

		public function get successHandler():Function {
			return _param.successHandler;
		}

		protected function get countHandler():Function {
			return _param.countHandler;
		}
	}
}
