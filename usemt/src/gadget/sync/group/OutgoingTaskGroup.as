package gadget.sync.group
{
	import gadget.sync.SyncProcess;
	import gadget.sync.group.TaskGroupBase;
	import gadget.sync.task.WebServiceBase;
	
	public class OutgoingTaskGroup extends TaskGroupBase {
		
		public function OutgoingTaskGroup(syncProcess:SyncProcess, tasks:Array, full:Boolean, isTransaction:Boolean) {
			super(syncProcess, tasks, full, isTransaction);
		}
		
		override protected function hello(task:WebServiceBase):void {
			info(_("{1} (in parallel)", task.getName()));
		}
		
		override protected function doSessionStart(taskIgnore:WebServiceBase):void {
			for each (var task:WebServiceBase in allTasks()) {
				try {
					doTask(task);	// Run all the tasks in parallel
				} catch (e:Error) {
					trace(e);
					trace(e.getStackTrace());
					err(_("cannot start task for {1}: {2}", task.getEntityName(), e.message), null);
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
