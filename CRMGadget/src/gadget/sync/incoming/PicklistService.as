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
	import gadget.sync.task.SyncTask;
	import gadget.util.CacheUtils;
	import gadget.util.FieldUtils;
	import gadget.util.Hack;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	public class PicklistService extends SyncTask {
		
		private static var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/picklist/");
		private static var ns2:Namespace = new Namespace("urn:/crmondemand/xml/picklist/data");
		
		private const PICKLISTSERVICE_VERSION:int = 2;	// Increment to force FULL SYNC on older clients
		private var sodname2ourname:Dictionary = new Dictionary();
		private var allPicklistServices:ArrayCollection = null;		
		private var currentPicklist:int = 0;	
		override protected function doRequest():void {
			/*if (getLastSync(PICKLISTSERVICE_VERSION) != NO_LAST_SYNC_DATE){
			updateLastSync(PICKLISTSERVICE_VERSION);
			return;
			}*/
			if (getLastSync() != NO_LAST_SYNC_DATE){
				updateLastSync();
				return;
			}
			if (allPicklistServices == null) {
				var tmpTransaction:ArrayCollection = Database.transactionDao.listTransaction();
				allPicklistServices = new ArrayCollection() ;
				for each(var transaction:Object in tmpTransaction) {
					if (transaction.enabled) {
						var dao:BaseDAO = Database.getDao(transaction.entity);
						allPicklistServices.addItem(dao.metaDataEntity);
						sodname2ourname[dao.metaDataEntity] = dao.entity;
						for each (var sub:String in SupportRegistry.getSubObjects(transaction.entity)) {
							var subDao:SupportDAO = SupportRegistry.getSupportDao(transaction.entity, sub)
//							var subentity:String=DAOUtils.getRecordType(subDao.entity);
//							//allPicklistServices.addItem(subentity);
//							
//							if(subentity == Database.businessPlanDao.entity){
//								subentity = "CRMODLS_BusinessPlan";
//							}else if(subentity == Database.objectivesDao.entity){
//								subentity = "CRMODLS_OBJECTIVE";
//							}
							sodname2ourname[subDao.metaDataEntity] = subDao.entity;
							allPicklistServices.addItem(subDao.metaDataEntity);
						}
					}
				}
				//clear picklist from cache
				
//				Database.picklistServiceDao.delete_all();
				Database.lastsyncDao.unsync("gadget.sync.task::ReadCascadingPicklists");
			}
			//			//VAHI bugfix: If there are no fields, there are no Picklists
			//			if (allPicklistServices.length<=currentPicklist) {
			//				updateLastSync();
			//				return;
			//			}
			//			
			var request:XML =
				<PicklistRead_Input xmlns="urn:crmondemand/ws/odesabs/picklist/">				
					<PicklistSet xmlns="urn:/crmondemand/xml/picklist/query">
						<ObjectName>{allPicklistServices[currentPicklist]}</ObjectName>
					</PicklistSet>
				</PicklistRead_Input>;
			sendRequest("\"document/urn:crmondemand/ws/odesabs/Picklist/:PicklistRead\"", request,"admin","Services/cte/PicklistService");
			
			//			sendRequest("\"document/urn:crmondemand/ws/odesabs/Picklist/:PicklistReadAll\"",
			//				<PicklistReadAll_Input xmlns="urn:crmondemand/ws/odesabs/picklist/"/>,
			//				"admin",
			//				"Services/cte/PicklistService"
			//			);
			
		}
		
		
		private function getDataStr(field:XML, col:String):String {
			var tmp:XMLList = field.child(new QName(ns2.uri,col));
			return tmp.length()==0 ? "" : tmp[0].toString();
		}
		
		
		private function mapPicklist(picklistName:String):String {
			return picklistName
			.replace(/\s/g, "")
				.replace(/PICK_000/g, "CustomPickList0")
				.replace(/PICK_0*/g, "CustomPickList")
				.replace(/M\/M/g, "MrMrs")
				.replace(/M\/F/g, "Gender")
			    .replace("PrimaryMarket","MarketSegment"); //Bug 5209
		}
		
		
		
		
		override protected function handleResponse(request:XML, result:XML):int {
			
			if (getFailed()) {
				return 0;
			}
			
			var cnt:int = 0;
			if(isClearData){
				new CacheUtils("picklist").clear();
				Database.picklistServiceDao.delete_all();
				isClearData=false;
			}
			
			
			Database.begin();
			//Database.picklistServiceDao.delete_all();
			//Database.lastsyncDao.unsync("gadget.sync.task::ReadCascadingPicklists");
			
			
			for each (var set:XML in result.ns2::ListOfPicklistSet[0].ns2::PicklistSet) {
				
				var data:Object = {}
				function put(rec:XML, field:String, repl:String=null):void {
					var value:String = getDataStr(rec, field);
					if(field=="ObjectName"){
//						if(value=="Revenue"){
//							value = Database.opportunityProductRevenueDao.entity;//nestle--need only oppt-revenue
//						}else if(value=="CRMODLS_BusinessPlan"){
//							value = Database.businessPlanDao.entity;
//						}else if(value=="CRMODLS_OBJECTIVE"){
//							value = Database.objectivesDao.entity;
//						}
						value = sodname2ourname[value];
					}
					data[repl!=null ? repl : field] = value;
				}
				
				put(set, "ObjectName");
				
				for each (var picklist:XML in set.ns2::ListOfPicklists[0].ns2::Picklist) {
					put(picklist, "Name");
					
					for each (var val:XML in picklist.ns2::ListOfPicklistValues[0].ns2::PicklistValue) {
						put(val, "ValueId");
						put(val, "Disabled");				
						
						for each (var trans:XML in val.ns2::ListOfValueTranslations[0].ns2::ValueTranslation) {
							put(trans, "LanguageCode");
							put(trans, "Value");
							put(trans, "Order", "Order3_");
							data.FieldName = mapPicklist(data.Name);
							
							try{
								var picklistObj:Object = ({
									record_type: data.ObjectName,
									field_name:  mapPicklist(data.Name),
									code:        data.ValueId,
									disabled:    'Y'
								});
								if (Database.picklistDao.find(picklistObj) != null) {
									data.Disabled= 'true';
								}
							}catch(e:Error){
								trace(e.message);
							}
							
							Database.picklistServiceDao.insert(data);
							
							
							
						}
					}
				}
				cnt++;
			}
			Database.commit();
			
			//nextPage(true, PICKLISTSERVICE_VERSION);
			currentPicklist++;
			nextPage(currentPicklist == allPicklistServices.length);
			return cnt;
		}
		
		override protected function handleZeroFault(soapAction:String, request:XML, event:IOErrorEvent):Boolean {
			//warn(i18n._("Remote too slow, cannot perform this task now.  Postponed to next sync."));
			Hack("'Unsync + successful fail' instead of proper 'postponed error' handling");
			//VAHI actually this is a very bad hack as Syncing does not allow to fail without error.
			//Database.lastsyncDao.unsync("gadget.sync.task::PicklistService");
			// We use "successfully fail" for this, which is abused(!) for splitting in another context.
			//setFailed();
			//successHandler(null);
			return false;
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
			
			//			trace("pick Service",allPicklistServices[currentPicklist].entity,"err:",xml_list.toXMLString());
			currentPicklist++;
			nextPage(currentPicklist == allPicklistServices.length);
			//			nextPage(true, PICKLISTSERVICE_VERSION);
			return true;
		}
		
		override public function getName():String {
			return "Getting picklists from picklist service..."; 
		}
		
		override public function getEntityName():String {
			return "PicklistService"; 
		}
		
		
		
		/*private function testReadLocalXMLfile():void{
		if(File.userDirectory.exists){
		for each(var file:File in File.userDirectory.getDirectoryListing()){
		if(file.name =="ReadPickList_ServiceLog.xml"){
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.READ);
		var fileData:String = stream.readUTFBytes(stream.bytesAvailable);
		//trace(fileData);
		try{
		var xml:XML = new XML(fileData);
		handleResponseTest(xml);
		}catch(e:Error){
		trace(e.message);
		}
		
		
		}
		}
		}
		}	
		
		protected function handleResponseTest(result:XML):int {
		if (getFailed()) {
		return 0;
		}
		
		var cnt:int = 0;
		
		Database.begin();
		Database.picklistServiceDao.delete_all();
		Database.lastsyncDao.unsync("gadget.sync.task::ReadCascadingPicklists");
		
		
		for each (var set:XML in result.ns2::ListOfPicklistSet[0].ns2::PicklistSet) {
		
		var data:Object = {}
		function put(rec:XML, field:String, repl:String=null):void {
		data[repl!=null ? repl : field] = getDataStr(rec, field);
		}
		
		put(set, "ObjectName");
		
		for each (var picklist:XML in set.ns2::ListOfPicklists[0].ns2::Picklist) {
		put(picklist, "Name");
		
		for each (var val:XML in picklist.ns2::ListOfPicklistValues[0].ns2::PicklistValue) {
		put(val, "ValueId");
		put(val, "Disabled");
		
		
		
		for each (var trans:XML in val.ns2::ListOfValueTranslations[0].ns2::ValueTranslation) {
		put(trans, "LanguageCode");
		put(trans, "Value");
		put(trans, "Order", "Order_");
		data.FieldName = mapPicklist(data.Name);
		
		
		var picklistObj:Object = ({
		record_type: data.ObjectName,
		field_name:  mapPicklist(data.Name),
		code:        data.ValueId,
		disabled:    'Y'
		});
		if (Database.picklistDao.find(picklistObj) != null) {
		data.Disabled= 'true';
		}
		
		/*	if (data.LanguageCode=="ENU") {
		var picklistObj:Object = ({
		record_type: data.ObjectName,
		field_name:  mapPicklist(data.Name),
		code:        data.ValueId,
		value:       data.Value
		});
		if (Database.picklistDao.find(picklistObj) == null) {
		Database.picklistDao.insert(picklistObj);
		}
		}//*
		
		Database.picklistServiceDao.insert(data);
		
		
		}
		}
		}
		cnt++;
		}
		Database.commit();
		
		nextPage(true, PICKLISTSERVICE_VERSION);
		return cnt;
		}*/
	}
}
