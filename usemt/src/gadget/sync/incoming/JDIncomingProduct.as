package gadget.sync.incoming
{
	import flash.events.Event;
	
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;

	public class JDIncomingProduct extends IncomingObject
	{
		private var searchSpec:String='';
		public function JDIncomingProduct(searchSpec:String)
		{			
			super(Database.productDao.entity);
			this.searchSpec=searchSpec;
		}
		
		override protected function doRequest():void {		
			var pagenow:int = _page;
			_lastItems = _nbItems;
			isLastPage=false;	
//			Database.errorLoggingDao.add(null, {trace:[getEntityName(), _page, pagenow, isLastPage, haveLastPage, searchSpec]});
			//VAHI another poor man's workaround for missing late binding in XML templates			
			sendRequest("\""+getURN()+"\"", new XML(getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, pagenow*pageSize)
				.replace(SEARCHSPEC_PLACEHOLDER, searchSpec)
			));
		}
//		override protected function initXML(baseXML:XML):void {
//			
//			// append childs
//			var qlist:QName=new QName(ns1.uri,listID), qent:QName=new QName(ns1.uri,entityIDns);
//			
//			
//			
//			for each(var f:String in Database.productDao.queryFields){
//				var ws20name:String = WSProps.ws10to20(getEntityName(), f);
//				var xml:XML = baseXML.child(qlist)[0].child(qent)[0];					
//				xml.appendChild(new XML("<" + ws20name + "/>"));
//			
//			}
//			
//			
//		}
	
	
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
	}
}