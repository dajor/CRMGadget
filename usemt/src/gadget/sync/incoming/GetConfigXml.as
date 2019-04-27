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
	import gadget.util.StringUtils;
	import gadget.util.Utils;

	public class GetConfigXml extends SyncTask
	{
		public function GetConfigXml()
		{
		}
		
		protected override function doRequest():void {
			ImportFileOODUtils.execute(readPrefs(),onLoginSuccess, onError);
		}
		
		protected  function onLoginSuccess(sessionId:String):void{
			var ownerUser:Object = Database.allUsersDao.ownerUser();
			
			var role:String = ownerUser["Role"];
			var fileName:String = "gadget_" + getRoleNameUrl(role) + ".xml";
			loadXmlConfig(sessionId, fileName);
			
			
		}
		
		private function getRoleNameUrl(roleName:String):String{
			var specialCharacters:Array = [" ", "<", ">", "#", "%", "{", 
				"}", "|", "\\", "^", "~", "[", "]", "`", ";", "/", "?", ":", "@", "=", "&", "$"];
			for each(var spc:String in specialCharacters) {
				roleName = StringUtils.replaceAll_(roleName, spc, "");
			}
			if(roleName.length>19){
				roleName = roleName.substr(0, 19);
			}
			
			trace("Url RoleName : " + roleName);
			return roleName;
		}
		
		override public function getEntityName():String {
			return "Import xml";
		}
		
		override public function getName():String {
			return "Importing configuration file from server..."; 
		}
		
		private function loadXmlConfig(sessionId:String, fileName:String, retry:Boolean = true):void{
			var pref:Object = readPrefs();
			var strForwardSlash:String = pref.sodhost.charAt(pref.sodhost.length-1) == "/" ? "" : "/";			
			
			var request:URLRequest = new URLRequest();
			request.url = pref.sodhost + strForwardSlash +  "OnDemand/user/content/" + fileName; 
			request.method = URLRequestMethod.GET;
			request.contentType = "text/xml; charset=utf-8";
			request.idleTimeout =100000;
			request.useCache = false;
			request.requestHeaders.push(new URLRequestHeader("Cookie", sessionId));
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				info("Successfully imported configuration file " + fileName + ".");
				try{
					var data:String = (e.target as URLLoader).data;
					var xml:XML = new XML(data);
					handleResponse(null,xml);
				}catch(e:Error){
					//nothing to do
				}
			});
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				onError("Can not get configuration file with role name.", null);
				if(retry){
					info("Importing default xml");
					loadXmlConfig(sessionId,"gadget.xml",false);
				}else{					
					onError("Could not read configuration file from server.", null);
					setFailed();
					nextPage(true);//call next task
				}
				
			});
			
			loader.load(request);
		}
		
		
		
		protected function onError(errmessage:String,record:Object):void{
			warn(errmessage);
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
		
		override protected function handleResponse(request:XML, result:XML):int {
			var name:String = result.name();
			
			if("configuration" == name){
				// import preferrence 
				try{
					Utils.importConfig(result);				
				}catch(e:Error){
					//noting to do
				}
				nextPage(true);
			}else{
				onError('Invalide XML format',null);
			}
			
			return 0;
		}
		
		
	}
}