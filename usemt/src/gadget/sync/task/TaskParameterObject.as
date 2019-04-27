//VAHI I hate to have too many parameters to functions, like WebServiceCall.call()
package gadget.sync.task {

	
	import flash.events.Event;
	
	import gadget.sync.SyncProcess;

	public class TaskParameterObject {
		
		private var _task:WebServiceBase;

		public function TaskParameterObject(task:WebServiceBase) {
			_task	= task;
		}

		public final function countHandler(nbItems:int):void { setCountHandler(_task,nbItems) }
		public final function errorHandler(error:String, event:Event,recorde_error:Object=null):void { setErrorHandler(_task,error,event,recorde_error) }
		public final function eventHandler(remote:Boolean, type:String, name:String, action:String):void { setEventHandler(_task,remote,type,name,action) }
		public final function successHandler(result:String):void { setSuccessHandler(_task,result) }
		public final function warningHandler(warning:String, event:Event,recorde_error:Object=null):void { setWarningHandler(_task,warning,event,recorde_error) }
		public final function infoHandler(message:String):void{
			setInfoHandler(message);
		}

		public var setCountHandler:Function;
		public var setErrorHandler:Function;
		public var setEventHandler:Function;
		public var setSuccessHandler:Function;
		public var setWarningHandler:Function;
		public var setInfoHandler:Function;

		// session state
		public var preferences:Object;
		public var finished:Boolean = false;

		// runtime input
		public var full:Boolean = false;
		public var metaSyn:Boolean = false;
		public var fullCompare:Boolean=false;

		//VAHI additional parameters for sync.incoming,
		// perhaps move this into some child class in future
		public var force:Boolean = false;			// Do not interrupt range in case too much workload
		public var range:Object = null;
		public var maximumTime:Date;
		public var minRec:Date, maxRec:Date;

		//VAHI for IncomingParallelTaskGroup
		public var running:Boolean = false;
		public var waiting:Boolean = false;			//VAHI task is waiting until it can run the first time
		public var syncProcess:SyncProcess;
	}
}
