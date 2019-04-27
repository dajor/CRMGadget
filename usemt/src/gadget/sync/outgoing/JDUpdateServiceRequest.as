package gadget.sync.outgoing
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.ServiceDAO;
	import gadget.i18n.i18n;
	import gadget.sync.WSProps;
	import gadget.sync.task.ReferenceUpdater;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;
	import gadget.util.ObjectUtils;
	import gadget.util.StringUtils;

	public class JDUpdateServiceRequest extends OutgoingObject
	{
		private var record:Object;		
		private var index:Number;
		private var listRecords:Array;
		private var isIncreaseIndex:Boolean=false;
		public function JDUpdateServiceRequest(records:Array)
		{
			super(Database.serviceDao.entity);
			this.listRecords=records;
			if(listRecords==null){
				var service:ServiceDAO=ServiceDAO(dao);
				listRecords=service.selectUserStatusUpdate();
			}
			updated = true;
			index=0;
		}
		
		override protected function doRequest():void {
			if(isIncreaseIndex){
				index=index+1;
				isIncreaseIndex=false;
			}
			if(listRecords==null || index>=listRecords.length){
				successHandler(null);
				return ;
			}
			record=listRecords[index];
			//bug#1969
			var check:Object = dao.findByOracleId(record[SodID]);
			if(check==null){
				index++;
				doRequest();
				return;
			}
			
			var WSTag:String = WSTagExe;
			var request:XML =
				<{WSTag} xmlns={ns1}>
					<{ListOfTag}/>
				</{WSTag}>;
			
			
				var tmp:XML;
				var oper:String = updated ? 'update' : 'insert';
				var xml:XML = <{EntityTag} xmlns={ns1} operation={oper}/>;
				var ignoreFields:Dictionary = dao.outgoingIgnoreFields;
				for each (var field:Object in field_list) {
					if (field.element_name == SodID
						? updated	
						: record[field.element_name]) {
						if (record[field.element_name] != "No Match Row Id") {
							
							
							if(ignoreFields.hasOwnProperty(field.element_name)){
								continue;
							}
							
							var ws20field:String = WSProps.ws10to20(entity,field.element_name);
							var fieldData:String = record[field.element_name];
							if (field.element_name == SodID) {
								if (!updated) {
									fieldData="";
								} else if (fieldData=="") {
									warn(i18n._("trying to fix NULL value in {1} record", entity));
									fieldData="#dummy";
								}
							}
							xml.appendChild(
								<{ws20field}>{fieldData}</{ws20field}>
							);
						}
					}
				}
				
				
				
				
				request.child(Q1ListOf)[0].appendChild(xml);
			 
			sendRequest(URNexe, request);
		}
		

		
		override protected function getCurrentRecordError():Object{
			var recordError:Object = listRecords[index];
				isIncreaseIndex=true;
			return recordError;
		}
		
		
		
		override protected function handleResponse(request:XML, result:XML):int {			
			
			
			for each (var data:XML in result.child(Q2ListOf)[0].child(Q2Entity)) {
				
				notify(ObjectUtils.joinFields(record, NameCols),
					i18n._(
						(record[SodID] && !StringUtils.startsWith(record[SodID], "#"))
						? "Updated"
						: "Created"
					));
				
				for each (var field:Object in field_list) {
					var ws20field:QName = new QName(ns2.uri, WSProps.ws10to20(entity,field.element_name));
					
					if (data.child(ws20field).length() > 0) {
						
						if (field.element_name == SodID) {
							ReferenceUpdater.updateReferences(
								entity,
								record[field.element_name],
								data.child(ws20field)[0].toString()
							);
						}
						
						record[field.element_name] = data.child(ws20field)[0].toString();
					}
				}
				record.StatusModified=false;
				record.deleted = false;
				record.local_update = null;
				record.error = false;
				dao.update(record);
			}
			
			
			index+=1;
			_nbItems += 1;
			countHandler(_nbItems);		
			doRequest();
			
			return 1;
		}
		
		
		
		
		
//		protected function doCountHandler(task:WebServiceBase, nbItems:int):void {
//			//todo later			
//		}
//		protected function doTaskEventHandler(task:WebServiceBase, remote:Boolean, type:String, name:String, action:String):void {
//			//todo later
//		}
//		
//		protected function doTaskSuccess(task:WebServiceBase, result:String):void {
//			trace(result);
//			
//		}
//		protected function errorHandler(task:WebServiceBase, error:String, event:Event):void {
//			trace(error);
//		}
//		
//		public function start():void{
//			
//			var p:TaskParameterObject = new TaskParameterObject(this);
//			
//			
//			p.preferences		= Database.preferencesDao.read();
//			p.setErrorHandler =errorHandler;	
//			p.setCountHandler=doCountHandler;
//			p.setSuccessHandler=doTaskSuccess;
//			p.setEventHandler=doTaskEventHandler;
//			
//			p.waiting			= true;
//			p.finished			= true;
//			p.running			= false;
//			this.param			= p;
//			
//			doRequest();
//		}
		
		
	}
}