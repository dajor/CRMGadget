package gadget.sync.incoming
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import gadget.dao.Database;
	import gadget.sync.task.SyncTask;
	import gadget.util.ImportFileOODUtils;
	
	public class GetContentCustomTab
	{
		private var onError:Function = null;
		private var callback:Function = null;
		public function GetContentCustomTab(callback:Function,onError:Function)
		{
			this.onError = onError;
			this.callback = callback;
		}
		public function doRequest():void {
			ImportFileOODUtils.execute(readPrefs(),onLoginSuccess, onError);
		}
		protected  function onLoginSuccess(sessionId:String):void{
			getContentCustomTab(sessionId);
		}
		
		protected function getURI():String {
			
			var reportUrl:String = Database.preferencesDao.getSegment_Targeting_URL();
			if(reportUrl.indexOf('OnDemand/user/')!=-1){
				reportUrl = reportUrl.split('OnDemand/user/')[1];//may they use old url
			}
			reportUrl = reportUrl.charAt(0)=='/'?reportUrl.substr(1):reportUrl;
			var sodhost:String = Database.preferencesDao.getStrValue("sodhost");		
			var strForwardSlash:String = sodhost.charAt(sodhost.length-1) == "/" ? "" : "/";
			var str:String = sodhost + strForwardSlash+"OnDemand/user/" + reportUrl;
			return str;
		}
		
		private function getContentCustomTab(sessionId:String):void{
			
	
			var pref:Object = readPrefs();
			
			var request:URLRequest = new URLRequest();
			// url from preference
//			var url:String = "https://secure-vmsomxkfa.crmondemand.com/OnDemand/user/analytics/saw.dll?Dashboard&PortalPath=%2fshared%2fCompany_AJTA-D6W9M_Shared_Folder%2f_portal%2fSegmentation%20%26%20Targeting";		
			request.url = getURI(); 
			request.method = URLRequestMethod.GET;
			request.contentType = "text/xml; charset=utf-8";
			request.idleTimeout =100000;
			request.useCache = true;
			request.requestHeaders.push(new URLRequestHeader("Cookie", sessionId));
			
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				
				try{
					var data:String = (e.target as URLLoader).data;
					
					if(data != null){
						callback(request);
					}
				}catch(e:Error){
					//nothing to do
				}
			});
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				onError(e.text);
			});
			
			loader.load(request);
			
			
		}
		
		
		private function readPrefs():Object{
			
			var tmpPreferences:Object = new Object()
			var username:String = '';
			var passwornd:String ='';
			
			if(Database.preferencesDao.getBooleanValue("use_sso")){
				username = Database.preferencesDao.getValue("tech_username") +"";
				passwornd = Database.preferencesDao.getValue("tech_password") +"";
			}else{
				username = Database.preferencesDao.getValue("sodlogin")+"";
				passwornd = Database.preferencesDao.getValue("sodpass")+"";
			}
			tmpPreferences.sodhost =Database.preferencesDao.getValue("sodhost");
			tmpPreferences.sodlogin = username;
			tmpPreferences.sodpass = passwornd;
			return tmpPreferences;
			
		}
	}
}