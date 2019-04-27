package gadget.sync.group
{
	import flash.events.Event;
	
	import gadget.dao.Database;
	import gadget.dao.IncomingSyncDAO;
	import gadget.dao.PreferencesDAO;
	import gadget.i18n.i18n;
	import gadget.sync.LogEvent;
	import gadget.sync.SyncProcess;
	import gadget.sync.WSProps;
	import gadget.sync.incoming.GetFields;
	import gadget.sync.incoming.GetTime;
	import gadget.sync.incoming.PicklistService;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;
	import gadget.util.DateUtils;
	import gadget.util.ObjectUtils;
	import gadget.util.ServerTime;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.soap.WebService;
	
	public class TaskGroupBase {
		
		// Global runtime parameters, from inited
		private var _syncProcess:SyncProcess;
		private var _tasks:Array;
		private var _full:Boolean;
		private var _metaSyn:Boolean;
		private var _isTransaction:Boolean;

		// Bound function
		private var bound:Object = {}
		
		// Global runtime parameters, from extern
		private var _preferences:Object;

		// State variables
		private var _progress:int;
		private var _isStopped:Boolean;

		// Session variables
		private var _startTime:Date;
		
		// Current runtime parameters
		private var _currentTask:int;
		private var finished_tasks:int;

		public function TaskGroupBase(syncProcess:SyncProcess, tasks:Array, full:Boolean,metaSyn:Boolean) {
			_syncProcess = syncProcess;
			_tasks = tasks;
			_full = full;	
			_metaSyn = metaSyn;
			_progress = 0;
			_currentTask = -2;
		}

		public function bindFunctions(logInfo:Function, logProgress:Function, logCount:Function, eventHandler:Function, end:Function):void {
			bound.info		= logInfo;
			bound.progress	= logProgress;
			bound.count		= logCount;
			bound.eventCB	= eventHandler;
			bound.end 		= end;
		}

		//VAHI this must be an AS bug: setters must be public?!?
		public function set progress(p:int):void {
			_progress	= p;
			doProgress();
		}

		public function get progress():int {
			return _progress;
		}
		
		public function get startTime():Date {
			return _startTime;
		}
		// BEGIN External interface
		
		public function start():void {
			_preferences = Database.preferencesDao.read();

			_currentTask	= 0;	// Yes, we're started!  Call end() in stop()
			progress		= 0;
			finished_tasks	= 0;

			
			if (_tasks.length==0) {
				progress = 100;
				end();
				return;
			}

			doStart();
			progress += 1;
			
			for each (var task:WebServiceBase in _tasks) {
				
				var p:TaskParameterObject = new TaskParameterObject(task);
				
				p.setCountHandler	= myCountHandler;
				p.setErrorHandler	= myTaskError;
				p.setEventHandler	= myTaskEventHandler;
				p.full				= _full;
				p.metaSyn 				= _metaSyn;
				p.fullCompare = _syncProcess.fullCompar;
				p.preferences		= _preferences;
				p.setSuccessHandler	= myTaskSuccess;
				p.setWarningHandler	= myTaskWarning;
				p.setInfoHandler = myTaskInfo;
				p.syncProcess=_syncProcess;
				p.waiting			= true;
				p.finished			= false;
				p.running			= false;
				
				initTaskParameters(task,p);
				
				//VAHI let the task have a chance to fix the parameters using a setter.
				task.param			= p;
			}
			
			var time:GetTime = new GetTime();
			time.call(false, _preferences, gotTime, warn, logErrorAndEnd, taskEventHandler, countHandler,_syncProcess);
		}

		public function stop():void {
			_isStopped = true;
			doStop();
		}
		
		// END External interface

		private function doProgress():void {
			if (bound.progress!=null) {
				bound.progress();
			} else {
				trace("!logProgress",_progress);
			}
		}
		
		protected function doStop():void {
			if (_currentTask<0)
				return;

			for each (var task:WebServiceBase in _tasks) {
				if (task.param && !task.param.waiting && !task.param.finished) {
					task.stop();
				}					
			}
			end();
		}
		
		// CLASS interface
		
		protected function currentTask():WebServiceBase {
			return _tasks[_currentTask];
		}
		
		// Increments task list (round robin) and
		// return false if we are starting another round
		// if returning false and _currentTask<0 we are ready,
		// in this case doLogout(end) was already called
		protected function incTask():Boolean {
			var again:Boolean=true;
			var active:Boolean=false;
			if (_currentTask<0)
				return false;
			do {
				//VAHI find the next task to run
				if (++_currentTask>=_tasks.length) {
					_currentTask = 0;
					if (!again) {
						if (active)
							break;
						_currentTask = -1;
						end();
//						_isStopped	= true;	//VAHI hack to terminate properly
						break;
					}
					again	= false;
				}
				active = active || currentTask().param.running;
			} while (currentTask().param.finished);
			return again;
		}
		
		protected function isFull():Boolean {
			return _full;
		}
		
		protected function isMetaSyn():Boolean {
			return _metaSyn;
		}
		
		protected function allTasks():Array {
			return _tasks;
		}

		protected function doStart():void {
			// Override to implement something running on this.start()
		}

		protected function doEvent(remote:Boolean, type:String, name:String, action:String):void {
			// event handler can be changed dymamically in TaskGroup, so we have to setup a hook here
			if (bound.eventCB!=null) {
				bound.eventCB(remote, type, name, action);
				//			} else {
				//				trace("!eventHandler",remote,type,name,action);
			}
		}
		
		private function doEnd():void {
			if (bound.end!=null) {
				bound.end(this);
			} else {
				trace("!end");
			}
		}

		private function doInfo(ev:int,s:String, e:Event = null,recorde_error:Object=null):void {
			if (bound.info!=null) {
				bound.info(new LogEvent(ev,s, e,recorde_error));
			} else {
				trace("!info "+ev+" "+s);
			}
		}

		protected function countHandler(nbItems:int, entityName:String):void {
			if (bound.count!=null) {
				bound.count(nbItems,entityName);
			} else {
				trace("!logCount",nbItems,entityName);
			}
		}
		protected function myCountHandler(task:WebServiceBase, nbItems:int):void {
			countHandler(nbItems,task.getEntityName());
		}

		protected function end():void {
			_isStopped = true;
			doEnd();
			_currentTask = -2;
		}

		protected function info(s:String):void {
			doInfo(LogEvent.INFO, s);
		}
		
		protected function err(s:String, e:Event,record_error:Object=null):void {
			doInfo(LogEvent.ERROR, s, e,record_error);
		}
		
		protected function warn(s:String, e:Event,record_error:Object=null):void {
			doInfo(LogEvent.WARNING, s, e,record_error);
		}

		protected function logErrorAndEnd(error:String, event:Event):void {
			err(error, event);
			end();
		}


		protected function initTaskParameters(task:WebServiceBase, p:TaskParameterObject):void {
			// Override to do something nonstandard
		}
		
		protected function hello(task:WebServiceBase):void {
			info(i18n._("{1}", task.getName()));
		}


		protected function myTaskWarning(task:WebServiceBase, warning:String, event:Event,record_error:Object):void {
			warn(warning, event,record_error);
		}
		
		protected function myTaskInfo(message:String){
			info(message);
		}

		protected function taskEventHandler(remote:Boolean, type:String, name:String, action:String):void {
			doEvent(remote,type,name,action);
		}
		protected function myTaskEventHandler(task:WebServiceBase, remote:Boolean, type:String, name:String, action:String):void {
			taskEventHandler(remote,type,name,action);
		}

		// We have a login, thus a session
		// We have the date when the sync happened
		protected function gotTime(startTime:String):void {
			_startTime	= ServerTime.parseSodDate(startTime);
			doSessionStart(currentTask());
		}
		
		protected function doSessionStart(task:WebServiceBase):void {
			// Override to initialize the session with time etc.
			doTask(task);
		}

		protected function doNextTask():void {
			if (incTask() || _currentTask>=0)	//VAHI ugly workaround for bugfix
				doTask(currentTask());
		}

		protected function doTask(task:WebServiceBase):void {
			if (_isStopped) {
				return;
			}
			if (task.param.waiting==true) {
				hello(task);
				task.param.waiting	= false;
			}
			task.param.running	= true;
			task.param.server_time =startTime;
			doTaskImpl(task);
		}

		protected function myTaskSuccess(task:WebServiceBase, result:String):void {
			task.param.running = false;
			if (_isStopped) {
				return;
			}
			doTaskSuccess(task);
		}
		
		protected function myTaskError(task:WebServiceBase, error:String, event:Event,recorde_error:Object):void {
			task.param.running = false;
			err(error, event,recorde_error);
			if (_isStopped) {
				return;
			}
			trace("fail",task.getEntityName());
			doTaskError(task);
		}
		
		protected function taskFinished(task:WebServiceBase):void {
			_syncProcess.setIsFieldChange(task.isFieldChange());
			task.param.running = false;
			if (task.param.finished) {
				trace("already finished",task.getEntityName());
				return;
			}
			finished_tasks++;
			progress = finished_tasks * 100 / _tasks.length;
			task.param.finished	= true;
			trace("finished",task.getEntityName());
			if (task.getFailed()) {
				info(i18n._('Not successful: {1}', task.getName()));
			} else {
				task.done();//done for only task no error
				var count:String = task.getRecordCount();
				if (count!=null) {
					info(i18n._("Successful, {1} records: {2}", count, task.getName()));
				} else {
					info(i18n._('Successful: {1}', task.getName()));
				}
				// this should be done inside the task
				if (!(task is GetFields) && !(task is PicklistService)) {
					Database.lastsyncDao.replace({ task_name:task.getMyClassName(), start_row:0, start_id:"", sync_date:DateUtils.toSodDate(_startTime) });
				}
			}
		}

		protected function finishAndNext(task:WebServiceBase):void {
			taskFinished(task);
			doNextTask();
		}
		
		protected function doTaskImpl(task:WebServiceBase):void {
			trace("running",task.getEntityName());
			task.requestCall();
		}

		protected function doTaskSuccess(task:WebServiceBase):void {
			finishAndNext(task);
		}
		
		protected function doTaskError(task:WebServiceBase):void {
			trace("failed",task.getEntityName());
			warn(i18n._("sync of {1} interrupted with error", task.getEntityName()), null);  //VAHI event already reported
			finishAndNext(task);
		}
	}
}
