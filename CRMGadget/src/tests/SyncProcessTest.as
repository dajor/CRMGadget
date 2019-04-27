package tests
{
	import com.adobe.utils.DateUtil;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.LogEvent;
	import gadget.sync.SyncProcess;
	import gadget.util.DateUtils;
	import gadget.util.HackOpenAnotherDatabase;
	import gadget.util.Startup;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	public class SyncProcessTest{
		private var xml:XML=null;
		private var worklist:Array=new Array();
//		private var logFilePath:String;
		private var _endFunction:Function;		
		public function SyncProcessTest(xmlPath:String,endFunction:Function=null)
		{
			_endFunction=endFunction;
//			logFilePath=logFilePath;
			addWork("Open database...", function(params:Object):void {
				HackOpenAnotherDatabase(Database.dbinit(addWork, "testsync.db", ""));
			});
			
			
			var fileConfig:File=new File(xmlPath);
			
			if(!fileConfig.exists){
				throw new Error("XML file not found.");
			}
			if(fileConfig.extension!="xml"){
				throw new Error("Invalid extension.");
			}
		
			var stream:FileStream = new FileStream();
			stream.open(fileConfig, FileMode.READ);
			var fileData:String = stream.readUTFBytes(stream.bytesAvailable);			
			xml=new XML(fileData);
//			addWork("",Utils.importConfig,xml);
//			Utils.importConfig(xml);
			
			
		}
		
		
		private function addWork(display:String, fn:Function, params:Object = null):Object {
			var wob:Object = { fn:fn, text:display, params:params }; 
			worklist.push(wob);
			return wob;
		}
		
		private function doWork(final:Function):void {
			var ob:Object = worklist.shift();
			
			if (ob!=null) {				
				setTimeout(function():void{
					if (ob.fn!=null) {
						//DEBUG ob.fn(ob.params);
						try {
							ob.fn(ob.params);							
							
						} catch (e:Error) {
							trace(e.getStackTrace());
							//throw e;
							
						}
					
					doWork(final);
				}
				},20);		
			} else if (final!=null) {
				Utils.importConfig(xml);
				var synProject:SyncProcess=new SyncProcess(false,false);
				var functions:Array=new Array();
				if(_endFunction!=null){
					functions.push(_endFunction);					
				}
//			    functions.push(logResult);
				synProject.bindFunctions(logInfo,logProgress,logCount,syncEvent,functions,fieldComplete);
				synProject.start();
			}
		}
		
		
		public function dostart():void {		
			
			doWork(Startup.running);
		}
		
		
		private function logInfo(log:LogEvent):void {
			//nothing to do
		}
		private function logProgress():void {
			//nothing to do
		}
		
		private function logCount(nbItems:int, entityName:String):void {
			//nothing to do
		}
		
		private function syncEvent(remote:Boolean, type:String, name:String, action:String):void {
			//nothing to do
		}
		public function fieldComplete():void {
			//nothing to do
		}
		
		
	}
}