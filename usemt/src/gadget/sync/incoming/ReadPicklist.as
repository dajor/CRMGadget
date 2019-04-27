package gadget.sync.incoming
{
	import flash.utils.Dictionary;
	
	import gadget.dao.Database;
	import gadget.dao.PicklistDAO;
	import gadget.dao.SupportDAO;
	import gadget.sync.task.SyncTask;
	import gadget.util.CacheUtils;
	
	import mx.collections.ArrayCollection;
	
	public class ReadPicklist extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/picklist/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/picklist");
		
		
		private var allPicklists:ArrayCollection = null;
		
		private var currentPicklist:int = 0;
		private var currentSynEntity:String = '';
		
		
		override protected function doRequest():void {
			if (getLastSync() != NO_LAST_SYNC_DATE){
				updateLastSync();
				return;
			}
			if (allPicklists == null) {
				var cache:CacheUtils = new CacheUtils("picklist",null);
				var tmpPickList:ArrayCollection = Database.fieldDao.listPicklists();
				allPicklists = new ArrayCollection() ;
				for each(var picklist:Object in tmpPickList) {
					if (checkEntitySynchronize(picklist.entity)) {
						cache.del(picklist.entity + "/" + picklist.element_name);
						allPicklists.addItem(picklist);
					}
				}
				
				Database.lastsyncDao.unsync("gadget.sync.task::PicklistService");
			}
			//VAHI bugfix: If there are no fields, there are no Picklists
			if (allPicklists.length<=currentPicklist) {
				updateLastSync();
				return;
			}

					
			trace("Picklist",allPicklists[currentPicklist].entity,":",allPicklists[currentPicklist].element_name);
			var picklistObj:Object = allPicklists[currentPicklist];
			var entity:String = picklistObj.entity;
			if(entity==Database.opportunityProductRevenueDao.entity){
				entity = "Revenue";
			}else if(entity==Database.businessPlanDao.entity){
				entity = "CRMODLS_BusinessPlan";
			}else if(entity==Database.objectivesDao.entity){
				entity = "CRMODLS_OBJECTIVE";
				
			}
			// we have to create a new WebService object each time
			//if(checkEntitySynchronize(allPicklists[currentPicklist].entity)){
				var request:XML =
					<PicklistWS_GetPicklistValues_Input xmlns='urn:crmondemand/ws/picklist/'>
						<FieldName>{picklistObj.element_name}</FieldName>
						<RecordType>{entity}</RecordType>
					</PicklistWS_GetPicklistValues_Input>;
				sendRequest("\"document/urn:crmondemand/ws/picklist/:GetPicklistValues\"", request);
			//}
		}
		
		private function checkEntitySynchronize(entity:String):Boolean{
			if(currentSynEntity==entity) return true;
			var objEntity:Object = Database.transactionDao.find(entity);
			if(objEntity!=null && objEntity.enabled){
				currentSynEntity = entity;
				return objEntity.enabled;
			}
//			if (entity.indexOf(".")>0) {
				var subDao:SupportDAO = Database.getDao(entity,false) as SupportDAO;
				if(subDao!=null){
					var pEntity:String= subDao.getSubEntity(0);
					var pObject:Object = Database.transactionDao.find(pEntity);
					if(pObject!=null && pObject.enabled){
						return true;
						
					}
				}
				
//			}
			currentSynEntity = '';
			return false;
		}

		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
			if (!mess)
				return false;
			if (mess.indexOf("(SBL-ODS-50720)")>0
				|| mess.indexOf("(SBL-ODS-50085)")>0
				|| mess.indexOf("(SBL-SBL-00000)")>0
				|| mess.indexOf("(SBL-ODS-50731)")>0 
				|| mess.indexOf("(SBL-ODS-50735)")>0//field requested is not a valid picklist.
				//|| (mess.indexOf("(SBL-SBL-00000)")>0 && allPicklists[currentPicklist].element_name=='Sub_Class') 
			) {
				trace("pick",allPicklists[currentPicklist].entity,"list",allPicklists[currentPicklist].element_name,"err:",errors.toXMLString());				
				_nbItems++;
				
			}
			currentPicklist++;
			nextPage(currentPicklist == allPicklists.length);
			return true;
		}

		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}
			if(isClearData){
				//clear picklist from cache
				new CacheUtils("picklist").clear();
				Database.picklistDao.delete_all();
				isClearData=false;
			}
			var cnt:int = 0;
			var recordType:String = request.ns1::RecordType[0].toString();
			var fieldName:String = request.ns1::FieldName[0].toString();
			trace(recordType, fieldName);
			if(recordType==="Revenue"){
				recordType = Database.opportunityProductRevenueDao.entity;//nestle--need only oppt-revenue
			}else if(recordType == "CRMODLS_BusinessPlan"){
				recordType = Database.businessPlanDao.entity;
			}else if(recordType=="CRMODLS_OBJECTIVE"){
				recordType = Database.objectivesDao.entity;
				
			}
			var picklistDao:PicklistDAO = Database.picklistDao;
			Database.begin();
			var existCode:Dictionary = new Dictionary();
			for each(var pvalue:XML in result.ns2::ListOfParentPicklistValue[0].ns2::ParentPicklistValue) {
				for each(var value:XML in pvalue.ns2::ListOfPicklistValue[0].ns2::PicklistValue) {
					var code:String = value.ns2::Code[0].toString();
					if(!existCode.hasOwnProperty(code)){
						var picklistObj:Object = new Object();			
						existCode[code]=code;
						picklistObj.record_type = recordType;
						picklistObj.field_name = fieldName;
						picklistObj.code = code;
						picklistObj.value = value.ns2::DisplayValue[0].toString();
						picklistObj.disabled = value.ns2::Disabled[0].toString();
						picklistObj.Order_ = cnt+1;
						var currentValue:Object = picklistDao.find(picklistObj);
						if(currentValue!=null) picklistDao.delete_(picklistObj);	
						
						/*if (currentValue==null && value.ns2::Disabled[0].toString() == 'Y') continue;			
		 				if (currentValue != null && value.ns2::Disabled[0].toString() == 'N') {
							picklistDao.update(picklistObj);	
						} else if (currentValue != null && value.ns2::Disabled[0].toString() == 'Y'){
							picklistDao.delete_(picklistObj);					
					    } else {
							picklistDao.insert(picklistObj);
						}*/
						
						picklistDao.insert(picklistObj);
						
							
						cnt++;
						_nbItems++;
					}
				}
			}
			Database.commit();
			notifyCreation(false, recordType+"/"+fieldName);
			currentPicklist++;
			nextPage(currentPicklist == allPicklists.length);
			return cnt;
 		}


		override public function getName():String {
			return "Reading picklists from server..."; 
		}
		override public function getEntityName():String {
			return "Picklist records";
		}
		
	}
}
