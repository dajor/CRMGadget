package gadget.sync.incoming
{
	import com.adobe.rtc.util.Base64Encoder;
	import com.as3xls.xls.formula.Functions;
	import com.hurlant2.util.Base64;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.sync.LogEvent;
	import gadget.sync.WSProps;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;
	import gadget.util.DateUtils;
	import gadget.util.OOPS;
	
	import mx.collections.ArrayCollection;
	
	import org.hamcrest.SelfDescribing;
	
	public class MSExchangeService extends WebServiceBase
	{
		protected var entity:String;
		protected var _nbItems:int=0;
		protected var _logInfo:Function;		
		protected var listRecord:ArrayCollection = new ArrayCollection();
		public var fullSync:Boolean = false;
		private var syn_state:String ='';
		private var lastSyncState:String ;
		private var isStoped:Boolean;
		private var _end:Function;
		public function MSExchangeService(entiy:String)
		{
			super();
			this.entity=entiy;			
			
		}
		protected const mapEmail:Object = {
			ItemId :'ItemId',
			Subject: 'Subject',
			DateTimeCreated:'StartTime',
			DateTimeSent:'EndTime'
		};
		protected const mapCompleteName:Object = {
			FirstName : "ContactFirstName",
			MiddleName : "MiddleName",
			LastName : "ContactLastName",
			FullName : "ContactFullName"
		};
		protected const mapAddress:Object = {
			CountryOrRegion : "AlternateCountry",
			Street : "AlternateAddress1",
			City : "AlternateCity",
			PostalCode :"AlternateZipCode"
			//State : "AlternateCountry"
		};
		protected const  mapFields:Object = {
			ItemId : "ContactId",
			//mapFields.HasAttachments = false;
			//mapFields.Culture = en-US
			CompanyName : "PIMCompanyName",
			PhoneNumbers : "CellularPhone",
			BusinessPhone : "WorkPhone",
			HomePhone : "HomePhone",
			ImAddresses : "ContactEmail",
			JobTitle :"JobTitle",
			CompleteName : "CompleteName",
			PhysicalAddresses : "PhysicalAddresses"
		};
		protected const mapFieldTask:Object ={
			ItemId :'ItemId',
			Subject: 'Subject',
			//HasAttachments : '',
			StartDate:'StartTime',
			DueDate:'DueDate',
			Status:'Status'
		};
		protected const mapFieldApp:Object ={
			ItemId :'ItemId',
			Subject: 'Subject',
			//HasAttachments : '',
			Start:'StartTime',
			End:'EndTime',
			//LegacyFreeBusyStatus:'',
			//CalendarItemType:'',
			Location:'Location'
		};
		protected  function importObject(xml:XML,create:Boolean):int{
			notImpl("importObject");
			return 0;
		}
		protected  function getXMlRequest():XML{
			notImpl("importObject");
			return new XML();
		}
		protected function getLastSyncState():String{
			return lastSyncState;
		}
		override public function  stop():void{
			this.isStoped = true;
		}
//		override public function getEntityName():String { return 'MS Exchange'; }
		override  public function getName() : String {
			return i18n._('Reading "{1}" data from MS Exchange server', getEntityName());
		}
		override protected function sendRequest(soapAction:String, xml:XML, type:String=null, service:String=null):void{
			var self:WebServiceBase = this;	//VAHI make "this" available for closure
			
			retries++;
		
			if (nextRequest) {
				var delta:Number = nextRequest-(new Date()).getTime()+nextAdjust;
				if (delta>0) {
					//VAHI self session rate limiting
					trace("slowing down", delta,"---------------------------------------------------------------------------");
					//retry(soapAction,xml,delta,true);
					return;
				}
			}
			
			var username:String = param.preferences.ms_user;
			var pwd:String = param.preferences.ms_password;
			var aut:String = username + ':' + pwd;
			var encoder:Base64Encoder=new Base64Encoder();
			encoder.encode(aut);
			var authorizationHeader:String = "BASIC " +  encoder.toString();;
			
			var request:URLRequest = new URLRequest();
			request.url = getURI(service);
			request.method = URLRequestMethod.POST;
			request.contentType = "text/xml; charset=utf-8";
			request.requestHeaders.push(new URLRequestHeader("Authorization", authorizationHeader));
			
			
//			if(lastSyncState == NO_LAST_SYNC_DATE){
//				lastSyncState = '';
//			}else{
//				lastSyncState ='<SyncState>' +lastSyncState+'</SyncState>';
//			}
			request.data = xml;
				
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				requestHandler.call(self, soapAction, xml, loader, e)		
			});
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,function(e:HTTPStatusEvent):void{
				checkResponse(e);
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				requestFaultHandler.call(self, soapAction, xml, loader, e);
			});
			
			loader.load(request);
			
			requestStarted = now();
			
			
			
			
		}
		
		public function upldateLastSync(tak_name:String):void{
			this.task_name = tak_name;
			updateLastSync();
		}
		override protected function requestHandler(soapAction:String, request:XML, loader:URLLoader, event:Event):void {
			if(_failed){
				successHandler("Error: "+getName());
				return;
			}
			super.requestHandler(soapAction,request,loader,event);
		}	
		
		protected function checkResponse(e:HTTPStatusEvent):void{
			if(e.status==200){
				return;
			}
			setFailed();
			if(e.status===401){
				failErrorHandler(i18n._("Access denied."));
			}else if(e.status==500){
				failErrorHandler(i18n._("Internal Server Error"));
			}
			
		}
		
		override protected function requestFaultHandler(soapAction:String, request:XML, loader:URLLoader, event:IOErrorEvent):void {
			//ToDo later
			setFailed();
			failErrorHandler(event.text);
		}
		
		override protected function getURI(service:String=null):String{
			var sodhost:String = param.preferences.ms_url;
			var strForwardSlash:String = sodhost.charAt(sodhost.length-1) == "/" ? "" : "/";
			var str:String = sodhost + strForwardSlash + (service!=null ? service : "ews/Exchange.asmx");
			return str;
		}
		
		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean{
			setFailed();
			//todo later
			return true;;
		}
		
		
		override protected function doRequest():void{
			//todo later
			lastSyncState = syn_state==null?'':syn_state;
			sendRequest("",getXMlRequest());
		}
		override protected function createLastSync():void {
			var task_name:String = getMyClassName();
			var syncObject:Object = Database.lastsyncDao.find(task_name); 
			if(syncObject == null){
				syncObject = new Object();
				syncObject.task_name = task_name;
				syncObject.sync_date = "";
				syncObject.start_row = 0;
				syncObject.start_id = '';
				Database.lastsyncDao.insert(syncObject);
			}			
		}
		
		
		private var task_name:String = getMyClassName();
		override protected function updateLastSync(minRow:int=0, mustBeSame:String=''):void {
			var syncObject:Object = new Object();
			syncObject.task_name = task_name;
			syncObject.sync_date = syn_state;
			syncObject.start_row = minRow;
			syncObject.start_id = mustBeSame;
			Database.lastsyncDao.update(syncObject);
		}
		
		
		protected var ns:Namespace= new Namespace("http://schemas.microsoft.com/exchange/services/2006/messages");
		protected var nsChange:Namespace= new Namespace("http://schemas.microsoft.com/exchange/services/2006/types");
		
		override protected function handleResponse(request:XML, response:XML):int{

			var xmlResponse:XMLList = response.child(new QName(ns.uri,'ResponseMessages'));
			var listItem:XMLList = xmlResponse.child(new QName(ns.uri,'SyncFolderItemsResponseMessage'));
			
			var xmlStat:XMLList = listItem.child(new QName(ns.uri,'SyncState'));
			var parentObj:XMLList = listItem.child(new QName(ns.uri,'Changes'));
			var listObj:XMLList = parentObj.child(new QName(nsChange.uri,'Create'));
			var listObjUpdate:XMLList = parentObj.child(new QName(nsChange.uri,'Update'));
			syn_state = xmlStat[0] == null ? '' : xmlStat[0].toString();
			//updateLastSync();
			//lastSync = syn_state;
			var cnt:int = 0;
			for each (var data:XML in listObj) {	
				if(isStoped){
					_end();
					return cnt;
				}
				// create 
				cnt += importObject(data.children()[0],true);
			}
			for each (var update:XML in listObjUpdate) {		
				if(isStoped){
					_end();
					return cnt;
				}
				//upadate
				cnt += importObject(update.children()[0],false);				
			}
			_nbItems+=cnt;
			if(cnt==0){
				successHandler('Successful: '+getName() );
			}else{
				showCount();
				doRequest();
			}
			
			return cnt;
		}

		protected var _errorHandler:Function;
		protected var _doTaskSuccess:Function;
		public function start():void{
					
			var p:TaskParameterObject = new TaskParameterObject(this);
					
					
			p.preferences		= Database.preferencesDao.read();
			p.setErrorHandler =_errorHandler;	
			p.setCountHandler=doCountHandler;
			p.setSuccessHandler=_doTaskSuccess;
			p.setEventHandler=doTaskEventHandler;
					
			p.waiting			= true;
			p.finished			= true;
			p.running			= false;
			this.param			= p;
			_logInfo(getName());
			createLastSync();
			this.syn_state = getLastSync();
			if(this.syn_state == NO_LAST_SYNC_DATE || fullSync == true){
				this.syn_state='';
			}
			
			doRequest();
		}
		
		public function showCount():void{
			countHandler(_nbItems);
		}
		
		protected function doCountHandler(task:WebServiceBase, nbItems:int):void {
					//todo later			
		}
		protected function doTaskEventHandler(task:WebServiceBase, remote:Boolean, type:String, name:String, action:String):void {
					//todo later
		}
		public function bindFunctions(logInfo:Function,errorHandler:Function,successHandler:Function,end:Function):void {
			_logInfo = logInfo;
			_doTaskSuccess = successHandler;
			_errorHandler = errorHandler;
			_end = end;
			
		}
		
		public function getListRecord():ArrayCollection{
			return listRecord;
		}
		public function setListRecord(_listRecord:ArrayCollection):void{
			this.listRecord = _listRecord;
		}
	}
}