package gadget.sync.group
{
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.sync.SyncProcess;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;
	
	public class IncomingParallelTaskGroup extends TaskGroupBase {
		
		private var oldCount:int;
		private var _isParallel:Boolean=false;
		
		override protected final function initTaskParameters(task:WebServiceBase, p:TaskParameterObject):void {
			p.force				= false;
			p.range				= null;
			p.maximumTime		= null;
		}
//		history sync clear in syncprocess class if full sync=true.
//		override protected function doStart():void {
//			if (isFull()) {
//				for each (var task2:WebServiceBase in allTasks()) {
//					Database.incomingSyncDao.unsync_one(task2.getEntityName());
//				}
//			}
//		}
		
		protected function standardSplits(task:WebServiceBase):void {
			Database.incomingSyncDao.repairSodRanges(task.getEntityName());
			if (task.isLinearTask || task.noPresplit)
				return;
			//VAHI Add some standard splits: 1 Day, 1 Month, 1 year
			for each (var a:Number in [ 1, 30, 365 ]) {
				var d:Date=new Date(startTime.getTime()-a*24*3600000);
				Database.incomingSyncDao.addRange(task.getEntityName(), { start:d, end:d });
			}
		}

		
		override protected function doTaskImpl(task:WebServiceBase):void {
			// Perform some action on the task
			
			if (task.isLinearTask) {
				trace("running",task.getEntityName(),"without range");
				task.requestCall();
				return;
			}
			
			// On failing tasks, try to fetch something older (task.param.maximumTime)
			var range:Object = { start:null, end:task.param.maximumTime ? task.param.maximumTime : startTime };
			var nextRange:Object = Database.incomingSyncDao.getDateRange(task.getEntityName(), range);
			
			if (!nextRange) {
				// No range left to process, task has finished
				finishAndNext(task);
				return;
			}
			
			oldCount = parseInt(task.getRecordCount());
			
			// Run the task
			task.param.range	= nextRange;
			task.param.minRec	= nextRange.end;	// preset minimum date to the maximum of the range
			task.param.maxRec	= nextRange.start;	// preset maximum to minimum, so it grows
			trace("running",task.getEntityName(),"with range",task.param.range.start,"to",task.param.range.end);
			task.requestCall();
		}
		
		override protected function doTaskSuccess(task:WebServiceBase):void {
			if (task.isLinearTask) {
				if (task.getFailed()) {
					//VAHI linear tasks may not fail successfully.
					doTaskError(task);
					return;
				}
				finishAndNext(task);
				return;
			}
			
			if (task.getFailed()) {
				// The task is successfully failing, this means: Split work
				trace("successfully fail",task.getEntityName());
				taskSplit(task);
				doTask(task);
				return;
			}
			trace("ok",task.getEntityName());
			//VAHI keep some sync history for the future
			Database.incomingSyncHistoryDao.replace({
				task:task.getEntityName(),
				start:task.param.range.start,
				end:task.param.range.end,
				count:parseInt(task.getRecordCount())-oldCount,
				timestamp:startTime.getTime()
			});
			Database.incomingSyncDao.addRange(task.getEntityName(), task.param.range);
			task.param.maximumTime	= null;
			task.param.force = false;
			doTask(task);
		}
		
		override protected final function doTaskError(task:WebServiceBase):void {
			// There was an error, perhaps too much work.  Try to split for the next try.  It cannot hurt.
			taskSplit(task);
			trace("failed",task.getEntityName());
			warn(i18n._("sync of {1} interrupted with error", task.getEntityName()), null);  //VAHI event already reported
			finishAndNext(task);
		}
		
		private final function taskSplit(task:WebServiceBase):void {
			if (task.isLinearTask) {
				return;
			}
			if (task.param.force) {
				warn(i18n._("sync of {1} skipped a date range, rerun sync again", task.getEntityName()), null);
				task.param.maximumTime	= task.param.range.start;
				task.param.force		= false;
			} else {
				var minRec:Date = task.param.minRec;
				var maxRec:Date = task.param.maxRec;
				
				if (minRec<=maxRec) {
					
					// When minRec==maxRec then move maxRec a bit down to improve splitting
					if (minRec>=maxRec) {
						maxRec	= new Date(maxRec.getTime()+200000);
					}
					//VAHI TODO XXX Else we should move it up 1s, not yet implemented
					
					// mark the found edges
					Database.incomingSyncDao.addRange(task.getEntityName(), { start:minRec, end:minRec });
					Database.incomingSyncDao.addRange(task.getEntityName(), { start:maxRec, end:maxRec });
					
					if (task.param.range.start<minRec)
						task.param.range.start	= minRec;
					if (task.param.range.start<maxRec)
						task.param.range.start	= maxRec;
				}
				
				trace("splitting",task.getEntityName(),"range",task.param.range.start,"to",task.param.range.end);
				task.param.force		= Database.incomingSyncDao.splitRange(task.getEntityName(), task.param.range);
				if (!task.param.force)
					task.param.maximumTime	= null;
				else trace(task.getEntityName()+" >>>>>>>>>>>> Splits too small, forcing this range <<<<<<<<<<<<");
			}
		}
		
		public function IncomingParallelTaskGroup(syncProcess:SyncProcess, tasks:Array, full:Boolean,metaSyn:Boolean,isParallel:Boolean) {
			super(syncProcess, tasks, full,metaSyn);
			this._isParallel=isParallel;
		}
		
		override protected function hello(task:WebServiceBase):void {
			if(_isParallel){
				info(i18n._("{1} (in parallel)", task.getName()));
			}else{
				super.hello(task);
			}
			
		}

		override protected final function doSessionStart(taskIgnore:WebServiceBase):void {
			for each (var task:WebServiceBase in allTasks()) {
				standardSplits(task);
				try {
					doTask(task);	// Run all the tasks in parallel
				} catch (e:Error) {
					trace(e);
					trace(e.getStackTrace());
					err(i18n._("cannot start task for {1}: {2}", task.getEntityName(), e.message), null);
					taskFinished(task);
				}
			}
			incTask();	// calls doLogout(end) if we are finished
		}

		override protected function finishAndNext(task:WebServiceBase):void {
			taskFinished(task);
			incTask();	// calls doLogout(end) if we are finished
			//no nextTask() because we are parallel
		}
	}
}
