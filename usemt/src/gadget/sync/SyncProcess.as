package gadget.sync
{
	import avmplus.getQualifiedClassName;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import gadget.dao.Database;
	import gadget.dao.ErrorLoggingDAO;
	import gadget.service.LocaleService;
	import gadget.service.UserService;
	import gadget.sync.group.IncomingParallelTaskGroup;
	import gadget.sync.group.TaskGroupBase;
	import gadget.sync.incoming.IncomingContactNotExistInAccCon;
	import gadget.sync.incoming.IncomingObject;
	import gadget.sync.incoming.JDIncomingObject;
	import gadget.sync.incoming.JDIncomingPlant;
	import gadget.sync.incoming.ModificationTracking;
	import gadget.sync.incoming.WebServiceIncoming;
	import gadget.sync.outgoing.JDUpdateServiceRequest;
	import gadget.sync.outgoing.OutgoingGCalendarDelete;
	import gadget.sync.outgoing.OutgoingGCalendarUpdate;
	import gadget.sync.task.MetadataChangeService;
	import gadget.sync.task.WebServiceBase;
	import gadget.sync.tasklists.DeletionTasks;
	import gadget.sync.tasklists.IncomingPerIdTasks;
	import gadget.sync.tasklists.IncomingStructure;
	import gadget.sync.tasklists.IncomingStructureByIds;
	import gadget.sync.tasklists.IncomingSubObjTasks;
	import gadget.sync.tasklists.IncomingSubObjTasksPerIds;
	import gadget.sync.tasklists.IncomingTasks;
	import gadget.sync.tasklists.InitializationTasks;
	import gadget.sync.tasklists.JDIncomingChangeOwnerTasks;
	import gadget.sync.tasklists.OutgoingSubTasks;
	import gadget.sync.tasklists.OutgoingTasks;
	import gadget.util.CacheUtils;
	import gadget.util.DateUtils;
	import gadget.util.SilentOOPS;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	public class SyncProcess {
		
		private var _full:Boolean;
		private var _metaSyn:Boolean;
		protected var _logInfo:Function;
		protected var _logProgress:Function;
		protected var _eventHandler:Function;
		protected var _fieldComplete:Function;
		
		protected var _hasErrors:Boolean;
		protected var _hasWarnings:Boolean;
		protected var _progress:int;
		protected var _finished:Boolean;
		protected var _showFinishMsg:Boolean=true;
		private var _logs:ArrayCollection;
		
		protected var _groups:ArrayCollection;		// WS1.0 firstrun
		protected var _end:Array;
		protected  var isFieldChange:Boolean;
		protected var _isStopped:Boolean;
	
		protected var _logCount:Function;
		
		protected var _syncNow:Boolean = false;
		protected var _fullCompar:Boolean=false;
		
		protected function buildTask(full:Boolean,fullCompare:Boolean=false,isSRSynNow:Boolean=false,records:Array=null,checkConflicts:Array=null):void{
			this._syncNow = isSRSynNow;
			if(!isSRSynNow){
				
				if(checkConflicts!=null){
					_showFinishMsg=false;
					_groups.addItem(new TaskGroupBase(
						this,
						checkConflicts,	
						_full
						,_metaSyn
					));
				}else{
					if(_metaSyn||fullCompare || _full){
						_groups.addItem(new TaskGroupBase(
							this,
							InitializationTasks(_metaSyn),
							_full // true,  // VAHI changed this to always do it, which is better but incorrect as well
							,_metaSyn
						));			
					}
					if(_metaSyn){  // Sync only Metadata. get only a full sync on the meta data(field management,Picklist,)
						return;
					}	
					
					//add check owner change
					addSeriaTask(JDIncomingChangeOwnerTasks(),TaskGroupBase);
					
					//Deleted items to google calendar
					if(Database.preferencesDao.getValue("enable_google_calendar", 0) != 0)
						_groups.addItem(new OutgoingGCalendarDelete());
					
					_groups.addItem(new TaskGroupBase(
						this,
						DeletionTasks(),
						_full
						,_metaSyn
					));
					
					
					
					//Update items to google calendar
					if(Database.preferencesDao.getValue("enable_google_calendar", 0) != 0){
						_groups.addItem(new OutgoingGCalendarUpdate());
					}
					
					
					_groups.addItem(new TaskGroupBase(	//VAHI Parallel with OutgoingTaskGroup, but it cannot run parallely
						this,
						OutgoingTasks(),
						_full
						,_metaSyn
					));
					
					var outAtts:Array = OutgoingSubTasks();
					if(outAtts.length>0){
						_groups.addItem(new TaskGroupBase(	
							this,
							outAtts,
							_full
							,_metaSyn
						));
					}
					
					_groups.addItem(new IncomingParallelTaskGroup( // Modification tracking
						this,
						[new ModificationTracking(),new IncomingObject(Database.bookDao.entity)],
						_full
						,_metaSyn,false
					));
					//for jd user only
					addProductAndPlantTask();
					
					
					var incommingStructure:IncomingStructure = IncomingTasks(_full);
					var incomingTasks:ArrayCollection = incommingStructure.getTaskAllLevel();
					
					
					
					//no parallel any more
					for each(var stasks:Array in incomingTasks){
						if(stasks!=null && stasks.length>0){
							addSeriaTask(stasks,IncomingParallelTaskGroup);	
						}
					}
					
					var incomingIds:IncomingStructureByIds = IncomingPerIdTasks();					
					for each(var idTasks:Array in incomingIds.getTaskAllLevel()){
						if(idTasks!=null && idTasks.length>0){
							addSeriaTask(idTasks,TaskGroupBase);	
						}
					}
					
					
					if(_full||fullCompare){
						addSeriaTask(IncomingSubObjTasks(fullCompare,_full),IncomingParallelTaskGroup);
						
					}else{
						addSeriaTask(IncomingSubObjTasksPerIds(),IncomingParallelTaskGroup);
					}
					//retrieve missing contact
					_groups.addItem(new TaskGroupBase(	
						this,
						[new IncomingContactNotExistInAccCon()],
						_full
						,_metaSyn
					));
				
					
					
				}
				
			}else{
				
				//bug#1969
				addSeriaTask([new JDIncomingObject(Database.serviceDao.entity,new ArrayCollection(records))],TaskGroupBase);
				_groups.addItem(new TaskGroupBase(
					this,
					[new JDUpdateServiceRequest(records)],	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
					_full
					,_metaSyn
				));
			}
		}
		
		public function SyncProcess(full:Boolean,metaSyn:Boolean,fullCompare:Boolean=false,isSRSynNow:Boolean=false,records:Array=null,checkConflicts:Array=null) {
			_full = full;	
			_metaSyn = metaSyn;
			_hasErrors = false;
			_hasWarnings = false;
			_isStopped = false;
			_progress = 0;
			_fullCompar = fullCompare;
			_logs = new ArrayCollection();
			_groups = new ArrayCollection();
			buildTask(full,fullCompare,isSRSynNow,records,checkConflicts);
			
		}
		
		private function addSeriaTask(listTask:Array, cls:Class):void{
			if(listTask==null || listTask.length<1){
				return;
			}
			for each(var incomingTask:WebServiceIncoming in listTask){
				if(cls == IncomingParallelTaskGroup){
					_groups.addItem(new cls(
						this,
						[incomingTask],	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
						_full
						,_metaSyn,false
					));
				}else{
					_groups.addItem(new cls(
						this,
						[incomingTask],	
						_full
						,_metaSyn
					));
				}
				
			}
		}
		
		private function addProductAndPlantTask():void{
			//add imcoming product task and plant
			if(UserService.DIVERSEY==UserService.getCustomerId()){
				var transaction:Object = Database.transactionDao.find(Database.productDao.entity);
				if(transaction.enabled == 1){
					_groups.addItem(new IncomingParallelTaskGroup(
						this,
						[new JDIncomingPlant(Database.customObject3Dao.entity)],	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
						_full
						,_metaSyn,true
					));					
				}
				
			}
		}
		private function addParallelTask(listTask:Array):void{
			
			if(listTask==null || listTask.length<1){
				return;
			}
			var i:int=1;
			var limitTask:Array=new Array();
			for each(var incomingTask:WebServiceIncoming in listTask){
				if(i==3){
					limitTask.push(incomingTask);
					_groups.addItem(new IncomingParallelTaskGroup(
						this,
						limitTask,	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
						_full
						,_metaSyn,true
					));
					limitTask=new Array();
					i=1;
					
				}else{
					limitTask.push(incomingTask);
					i++;
				}
				
			}
			if(listTask.length>0){
				_groups.addItem(new IncomingParallelTaskGroup(
					this,
					limitTask,	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
					_full
					,_metaSyn,true
				));
			}
		}
	
		
		public function bindFunctions(logInfo:Function, logProgress:Function, logCount:Function, eventHandler:Function, end:Array, fieldComplete:Function):void {
			_logInfo = logInfo;
			_logProgress = logProgress;
			_end = end;
			_fieldComplete = fieldComplete;
			_logCount = logCount;			
			_eventHandler = eventHandler;		

			for (var i:int = 0; i < _groups.length; i++) {
				_groups[i].bindFunctions(doLog, doLogProgress, logCount, eventHandler, nextGroup);
			}
		}

		public function start():void {
			Database.errorLoggingDao.delete_all();
			if(_metaSyn){
				Database.lastsyncDao.unsync("gadget.sync.incoming::AccessProfileService");
				Database.lastsyncDao.unsync("gadget.sync.incoming::FieldManagementService");
				Database.lastsyncDao.unsync("gadget.sync.incoming::CustomRecordTypeService");
				Database.lastsyncDao.unsync("gadget.sync.incoming::IncomingSalesProcess");
				Database.lastsyncDao.unsync("gadget.sync.incoming::RoleService");
				Database.lastsyncDao.unsync("gadget.sync.incoming::GetFields");
				Database.lastsyncDao.unsync("gadget.sync.incoming::ReadPicklist");
				Database.lastsyncDao.unsync("gadget.sync.incoming::PicklistService");
				Database.lastsyncDao.unsync("gadget.sync.incoming::ReadCascadingPicklists");
				Database.lastsyncDao.unsync("gadget.sync.incoming::AccessAssessmentScriptService");
			}else if (_full) {
				// Clear out old records which perhaps disturb the GUI
				Database.incomingSyncDao.unsync_all();
			}
			_groups[0].start();
 		}
 		
 		public function stop():void {
 			_isStopped = true;
			_hasErrors	= false;	//VAHI Will be set again within .stop()

			for each (var _group:Object in _groups) {
				//when user click stop ==> error for my task
				_group.stop();
			}

			if (!_hasErrors)	//VAHI always tell user about the abort
				doLog(new LogEvent(LogEvent.ERROR, "Sync aborted by user"));
			//_hasErrors always is true now
 		}
 		
		protected function nextGroup(finished:Object):void {
			var index:int = _groups.getItemIndex(finished);			
			if (index == 0) {
				_fieldComplete();
			}
			if(!_isStopped && index+1 < _groups.length) {
				_groups[index+1].start();
			} else {
				groupEnd();
			}
		}
 		protected function groupEnd():void {
			LocaleService.reset();
			if(Database.preferencesDao.getValue("log_files")=="1"){
				
				var fileName:String =Database.preferencesDao.getValue("log_fileName") as String;				
				if(fileName =="" || fileName==null){
					fileName = "log_" + DateUtils.getCurrentDateAsSerial();
				}
				//-- V M -- write log file to  db directory
				var byteArr:ByteArray = new ByteArray();
				byteArr.writeUTFBytes(unescape(Database.errorLoggingDao.dumpOnlyError().substr(0,5000)));
				var file:File = File.userDirectory.resolvePath(fileName +".txt");				
				var newFile:FileStream = new FileStream();
				newFile.open( file, FileMode.WRITE );
				newFile.writeBytes(byteArr);
				newFile.close();
				
			}
			if(_showFinishMsg){
				if (_isStopped || _hasErrors) {
					doLog(new LogEvent(LogEvent.ERROR, "There had been errors"));
				} else if (_hasWarnings) {
					doLog(new LogEvent(LogEvent.WARNING, "Synchronization was successful. There had been warnings"));
				} else {
					doLog(new LogEvent(LogEvent.SUCCESS, "Synchronization was successful"));
				}
				if(isFieldChange){
					CacheUtils.clear_all();//clear all cache data after synced.
					doLog(new LogEvent(LogEvent.INFO, "Translation changes will take effect when you restart the application"));
				}
				saveSyncLogs();
			}			
			if(!this._syncNow && !this._isStopped && this._groups.length>1){
				var susccess:Object = new Object();
				susccess["task_name"] = "successsync";
				susccess["sync_date"] = new Date().toUTCString();
				susccess["start_row"] = 0;
				susccess["start_id"] = "";
				Database.lastsyncDao.replace(susccess);
			}
			_finished = true;
			for each (var f:Function in _end) {
				f();
			}
		}
		//#563 CRO
 		private function saveSyncLogs():void{
			var strLogs:String="";
			
			for each(var l:Object in _logs){
				
				strLogs += DateUtils.format(l.date, "DD.MM.YYYY JJ:NN:SS") + " - [" +LogEvent.LOGTYPE[l.type] +"] - "+ l.text + "\n";
				
			}
  			Database.errorLoggingDao.add(null,{"Synchronize logs":strLogs});
		}
		private function doLog(log:LogEvent):void {
			SilentOOPS('=log',log.date.toUTCString(),log.type,log.text,StringUtils.toString(log.event));
			if (log.type == LogEvent.FATAL) {
				_hasErrors = true;
			} else if (log.type == LogEvent.ERROR) {
				_hasErrors = true;
			} else if (log.type == LogEvent.WARNING) {
				_hasWarnings = true;
			}
			_logs.addItem(log);
			if (_logInfo != null) {
				_logInfo(log);
			}
			if (log.type == LogEvent.FATAL) {
				stop();
			}
		}
		
		protected function getDefaultProcess():int{
			return 0;
		}
		
		protected function doLogProgress():void {
			_progress = getDefaultProcess();
			for each (var _group:Object in _groups) {
				if(_group is OutgoingGCalendarUpdate || _group is OutgoingGCalendarDelete)
					_progress += 100;
				else
					_progress += _group.progress;
			}
			_progress /= _groups.length;
			if (_logProgress != null) {
				_logProgress(_progress<1?1:_progress);
			}
		}
		
		
		public function setIsFieldChange(_isFieldChange:Boolean):void{
			if(!isFieldChange){
				this.isFieldChange = _isFieldChange;
			}			
		}
		public function get progress():int {
			return _progress;
		}
		
		public function get finished():Boolean {
			return _finished;
		}
		public function get isStopped():Boolean{
			return _isStopped;
		}
		public function get hasErrors():Boolean {
			return _hasErrors;
		}
		
		
		public function get logs():ArrayCollection {
			return _logs;
		}

		public function get full():Boolean
		{
			return _full;
		}

		public function set logs(value:ArrayCollection):void
		{
			_logs = value;
		}

		public function get fullCompar():Boolean
		{
			return _fullCompar;
		}

		public function get metaSyn():Boolean
		{
			return _metaSyn;
		}
		
	
	}

}
