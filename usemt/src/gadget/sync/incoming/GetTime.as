package gadget.sync.incoming
{
	import gadget.dao.IncomingSyncDAO;
	import gadget.sync.SyncProcess;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;
	import gadget.util.ServerTime;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	public class GetTime extends WebServiceBase {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/time/");
		
		override protected function doRequest():void {
			
			sendRequest(
				"\"document/urn:crmondemand/ws/time/:GetServerTime\"",
				<TimeWS_GetServerTime_Input xmlns='urn:crmondemand/ws/time/'/>);
		}
		
		
		public function call(full:Boolean, pPreferences:Object, pSuccessHandler:Function, pWarningHandler:Function, 
							 pErrorHandler:Function, pEventHandler:Function, pCountHandler:Function,syncProcess:SyncProcess=null):void {
			
			var p:TaskParameterObject	= new TaskParameterObject(this);
			
			//VAHI XXX.apply(this,Array.prototype.slice.call(arguments,1)) is the ECMAscript standard to
			// call XXX() with the same parameters, except the first one (here: the task object passed to TaskParameterObject)
			// It's a workaround until gadget.sync.task is refactored to handle the new TaskParameterObject
			p.setErrorHandler = function(...arg):void { pErrorHandler.apply(this,arg.slice(1)) };
			p.setWarningHandler = function(...arg):void { pWarningHandler.apply(this,arg.slice(1)) };
			p.setSuccessHandler = function(...arg):void { pSuccessHandler.apply(this,arg.slice(1)) };
			p.setEventHandler = function(...arg):void { pEventHandler.apply(this,arg.slice(1)) };
			//VAHI I changed the (internal) interface for this
			p.setCountHandler = function(task:WebServiceBase, nbItems:int):void { pCountHandler(nbItems,task.getEntityName()) };
			
			p.preferences = pPreferences;
			p.syncProcess=syncProcess;
			p.full = full;
			
			param = p;

			
			requestCall();
		}		
		
		override protected function handleResponse(request:XML, result:XML):int {
			var date:String = result.ns1::CurrentServerTime.toString();
			//VAHI remember the last timezone seen to fix the sync offset to ZULU time. 
			var tz:String = result.ns1::TimeZone.toString();
			var sec:int = 0;
			if (tz.substr(0,5)!="(GMT)") { // London time = 0
				if (tz.substr(0,4)!="(GMT" || tz.substr(7,1)!=":" || tz.substr(10,2)!=') ')
					throw new Error("Timezone is not in format '(GMT?##:##) *': "+tz);
				sec = parseInt(tz.substr(5,2))*3600+parseInt(tz.substr(8,2))*60;
				if (tz.substr(4,1)=='-') {
					sec = -sec;
				}
			}
			ServerTime.setSodTZ(sec, date, tz);

			successHandler(date);
			return 1;
		}
		
		override public function getName():String {
			return "Getting server time..."; 
		}

		override public function getEntityName():String {
			return "server time"; 
		}
	}
}