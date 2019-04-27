package gadget.sync.task
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import gadget.dao.Database;
	import gadget.util.DateUtils;
	
	import mx.utils.Base64Encoder;

	public class MetadataChangeService extends SyncTask
	{
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/fieldmanagement/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/metadatachangesummary/Data");

		public function MetadataChangeService()
		{
			super();
		}
		
		override protected function doRequest():void{
			var request:XML = <MetadataChangeSummaryQueryPage_Input xmlns="urn:crmondemand/ws/metadatachangesummary/">
				<ListOfMetadataChangeSummary>
					<MetadataChangeSummary>
						<LOVLastUpdated></quer:LOVLastUpdated>
						<FieldManagementLastUpdated></FieldManagementLastUpdated>
						<CascPicklistsLastUpdated></CascPicklistsLastUpdated>
						<AccessProfileLastUpdated></AccessProfileLastUpdated>
					</MetadataChangeSummary>
				</ListOfMetadataChangeSummary>
			</MetadataChangeSummaryQueryPage_Input>;
			sendRequest("\"document/urn:crmondemand/ws/metadatachangesummary/:MetadataChangeSummaryQueryPage\"",request);
			
		}
		
		override protected function handleResponse(xml:XML, response:XML):int{
			var listObject:XML = response.children()[0];
			var par:XML = listObject==null ? new XML() : listObject.children()[0];
			if(par == null){
				nextPage(true);
				return 0;
			}
			for each (var objects:XML in par.children()) {
					var syndate:String = objects == null ? '' : objects.toString();
					
					var task_name:String = '';
					if(objects.localName().toString() == 'FieldManagementLastUpdated'){
						task_name = "gadget.sync.incoming::FieldManagementService";
						
					}else if(objects.localName().toString() == 'AccessProfileLastUpdated'){
						task_name = "gadget.sync.incoming::AccessProfileService";
						
					}else if(objects.localName().toString() == 'LOVLastUpdated'){
						task_name = "gadget.sync.incoming::PicklistService";
					}else if(objects.localName().toString() == 'CascPicklistsLastUpdated'){
						task_name = "gadget.sync.incoming::ReadCascadingPicklists"
					}
					
					var lastSyncObject:Object = Database.lastsyncDao.find(task_name);
					if(lastSyncObject==null || lastSyncObject.sync_date == null || syndate==null){
						continue;
					}
					var loctime:Number = DateUtils.guessAndParse(lastSyncObject.sync_date).getTime();
					var serverTime:Number = DateUtils.guessAndParse(syndate).getTime();
					if(serverTime>loctime){
						Database.lastsyncDao.unsync(task_name);
					}
			}
			nextPage(true);
			return 0;
		}
		
		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			nextPage(true);
			return true;
		}
		
		override public function getName():String {
			return "Checking Metadata Change Summary QueryPage ..."; 
		}
		
		override public function getEntityName():String {
			return "MetadataChangeService"; 
		}
	}
}