package gadget.sync.outgoing
{
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import gadget.dao.Database;
	import gadget.sync.incoming.CPIncomingCheckRelationById;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;
	
	import mx.collections.ArrayCollection;

	public class CPOutgoingUpdateRelation extends OutgoingObject
	{
		protected  const MAX_RETRY:int =5;
		protected var rec:Object;
		protected var countRetry:int=0;
		public function CPOutgoingUpdateRelation(entity:String,rec:Object,retry:int=0)
		{
				
			super(entity);			
			this.countRetry = retry;
			this.rec = rec;
		}
		
		
		protected override function readRecords():Boolean{
			updated = true;
			if(this.rec!=null){
				records = new ArrayCollection();
				records.addItem(this.rec);
				return true;
			}else{
				records = new ArrayCollection();
			}
			return false;
		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			//no need update record
			new CPIncomingCheckRelationById(entity,rec[SodID],countRetry).start();
			return 0;
		}
		
		protected function doCountHandler(task:WebServiceBase, nbItems:int):void {
			//todo later			
		}
		protected function doTaskEventHandler(task:WebServiceBase, remote:Boolean, type:String, name:String, action:String):void {
			//todo later
		}
		
		protected function doTaskSuccess(task:WebServiceBase, result:String):void {
			trace(result);
			
		}
		protected function errorHandler(task:WebServiceBase, error:String, event:Event,recode_err:Object=null):void {
			trace(error);
		}
		
		protected function warningHandler(warning:String, event:Event,recorde_error:Object=null):void{
			trace(warning);
		}
		
		public function start():void{
			if(countRetry<MAX_RETRY){
				
				var p:TaskParameterObject = new TaskParameterObject(this);
				
				
				p.preferences		= Database.preferencesDao.read();
				p.setErrorHandler =errorHandler;	
				p.setCountHandler=doCountHandler;
				p.setSuccessHandler=doTaskSuccess;
				p.setEventHandler=doTaskEventHandler;	
				p.setWarningHandler = warningHandler; 
				p.waiting			= true;
				p.finished			= true;
				p.running			= false;
				this.param			= p;
				doRequest();
			}
		}
	}
}