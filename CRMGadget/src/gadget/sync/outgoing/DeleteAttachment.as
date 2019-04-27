package gadget.sync.outgoing
{
	import flash.events.Event;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.sync.outgoing.OutgoingAttachment;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;
	
	public class DeleteAttachment extends OutgoingAttachment
	{
		
		private var pId:String;
		private var attId:String;
		public function DeleteAttachment(ID:String,pId:String,attId:String)
		{
			super(ID);
			this.pId = pId;
			this.attId = attId;
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
			initOnce();
			doRequest();
		}
		
		override protected function handleResponse(request:XML, result:XML):int{
			//nothing to do;
			return 0;
		}
		override protected function doRequest():void{
			
			
			
			var WSTag:String = WSTagExe;
			var request:XML =
				<{WSTag} xmlns={ns1}>
					<{ListOfTag}/>
				</{WSTag}>;
			
			var xml:XML = <{EntityTag} xmlns={ns1} operation='skipnode'/>;
			var subXML:XML = <{subList} xmlns={ns1}>
								<Attachment operation='delete'>
									<Id>{this.attId}</Id>
								</Attachment>	
							 </{subList}>;
			
			var sodid:String  = DAOUtils.getOracleId(entity);
			var ws20field:String = WSProps.ws10to20(entity,sodid);
			xml.appendChild(
				<{ws20field}>{this.pId}</{ws20field}>
			);
			xml.appendChild(subXML);
			request.child(Q1ListOf)[0].appendChild(xml);
			sendRequest(URNexe,request);
		}
		
		
	}
}