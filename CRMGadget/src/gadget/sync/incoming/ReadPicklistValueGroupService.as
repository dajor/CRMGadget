package gadget.sync.incoming {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.i18n.i18n;
	import gadget.lists.List;
	import gadget.service.SupportService;
	import gadget.sync.task.SyncTask;
	import gadget.util.CacheUtils;
	import gadget.util.FieldUtils;
	import gadget.util.Hack;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import org.flexunit.runner.Description;
	
	public class ReadPicklistValueGroupService extends SyncTask {
		
		private static var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/pickvaluegroup/");
		private static var ns2:Namespace = new Namespace("urn:/crmondemand/xml/pickvaluegroup/data");		
		override protected function doRequest():void {			
			//alway read picklist value group when user click full compare or sync-meta or full sync.
			var request:XML =
				<PickValueGroupReadAll_Input xmlns="urn:crmondemand/ws/odesabs/pickvaluegroup/">				
						<IncludeAll>true</IncludeAll> 
				</PickValueGroupReadAll_Input>;
			sendRequest("\"document/urn:crmondemand/ws/odesabs/pickvaluegroup/:PickValueGroupReadAll\"", request,"admin","Services/cte/PickValueGroupService");				
		}
		
		
		private function getDataStr(field:XML, col:String):String {
			var tmp:XMLList = field.child(new QName(ns2.uri,col));
			return tmp.length()==0 ? "" : tmp[0].toString();
		}
		
		
	
		
		
		override protected function handleResponse(request:XML, result:XML):int {
			
			if (getFailed()) {
				return 0;
			}
			
			var cnt:int = 0;
			if(isClearData){			
				Database.pvgDao.delete_all();
				Database.pvgObjectDao.deleteAll();
				isClearData=false;
			}
			Database.begin();		
			
			for each (var set:XML in result.ns2::ListOfPicklistValueGroupSet[0].ns2::PicklistValueGroupSet) {
				
				var data:Object = {}
				function put(rec:XML, field:String, repl:String=null):void {
					var value:String = getDataStr(rec, field);
					data[repl!=null ? repl : field] = value;
				}
				
				put(set, "PicklistValueGroupId");
				put(set, "PicklistValueGroupName");
				put(set, "Description");
				Database.pvgObjectDao.insert(Utils.cloneObject(data));
				//remove description
				delete data["Description"];
				for each (var picklist:XML in set.ns2::ListOfPicklistTypeSet[0].ns2::PicklistTypeSet) {
					put(picklist, "ObjectName");
					put(picklist, "FieldName");
					data.FieldName=SupportService.getPVGField(data.FieldName);
					for each (var lns:XML in picklist.ns2::ListOfLicNameSet[0].ns2::LicNameSet) {
						for each(var val:XML in lns.ns2::LicName){
							data['LicName'] = val.toString();						
							Database.pvgDao.insert(data);
							cnt++;
						}						
					}
					
				}
				
			}
			Database.commit();			
			nextPage(true);
			return cnt;
		}
		
		override protected function handleZeroFault(soapAction:String, request:XML, event:IOErrorEvent):Boolean {
			//warn(i18n._("Remote too slow, cannot perform this task now.  Postponed to next sync."));
			Hack("'Unsync + successful fail' instead of proper 'postponed error' handling");
			
			return true;
		}
		
		
		override protected function failErrorHandler(mess:String, event:Event=null):void {
			
			//bug#319			
			mess=extractErrorMessage(mess);
			if(mess==''){
				mess=i18n._("too many retries ({1.retries}) for {1.entity}", { entity:getEntityName(), retries:retries });
			}
			
			super.failErrorHandler(mess,event);
			
		}
		
		
		
		
		
		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			
			if (xml_list.length()<1 || xml_list[0].faultstring.length()!=1)
				return false;
			var str:String = xml_list[0].faultstring[0].toString();
			if (str=="")				
				return false;			
			
			return true;
		}
		
		override public function getName():String {
			return "Getting PicklistValueGroup from server..."; 
		}
		
		override public function getEntityName():String {
			return "PicklistValueGroupService"; 
		}
		
		
		
	}
}
