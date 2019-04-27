package gadget.sync.incoming {
	import com.adobe.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	
	import gadget.dao.AllUsersDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.lists.List;
	import gadget.service.LocaleService;
	import gadget.service.UserService;
	import gadget.sync.task.SyncTask;
	import gadget.util.FieldUtils;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	
	
	public class FieldManagementService extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/fieldmanagement/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/fieldmanagement/data");
		
		private var allTransactions:ArrayCollection = null;		
		private var currentTransaction:int = 0;

		override protected function doRequest():void {
 			if (getLastSync() != NO_LAST_SYNC_DATE){
				successHandler(null);
				return;
			} 
			FieldUtils.reset();
			
			if (allTransactions == null) {
				var tmpTransaction:ArrayCollection = Database.transactionDao.listTransaction();
				allTransactions = new ArrayCollection() ;
				allTransactions.addItem(Database.allUsersDao.entity);
				for each(var transaction:Object in tmpTransaction) {
					if (transaction.enabled) {
						var entityTran:String = transaction.entity;
						if(entityTran==Database.medEdDao.entity){
							entityTran = "MedEdEvent";
						}else if(entityTran==Database.businessPlanDao.entity){
							entityTran = "CRMODLS_BusinessPlan";
						}else if(entityTran==Database.objectivesDao.entity){
							entityTran = "CRMODLS_OBJECTIVE";
						}
						allTransactions.addItem(entityTran);						
						for each (var sub:String in SupportRegistry.getSubObjects(transaction.entity)) {
							var subDao:SupportDAO = SupportRegistry.getSupportDao(transaction.entity, sub)
							var subentity:String=DAOUtils.getRecordType(subDao.entity);
							if(subDao.isGetField){								
								allTransactions.addItem(subentity);
							}
							
						}
					}
				}
				
			}
			
			var request:XML =	
				<FieldManagementRead_Input xmlns="urn:crmondemand/ws/odesabs/fieldmanagement/">
					<FieldSet xmlns="urn:/crmondemand/xml/fieldmanagement/query">
						<ObjectName>{allTransactions[currentTransaction]}</ObjectName>              
					</FieldSet>
				</FieldManagementRead_Input>
				
			sendRequest("\"document/urn:crmondemand/ws/odesabs/FieldManagement/:FieldManagementRead\"", request,
				"admin",
				"Services/cte/FieldManagementService");
			
			
			/*sendRequest("\"document/urn:crmondemand/ws/odesabs/FieldManagement/:FieldManagementReadAll\"",
				<FieldManagementReadAll_Input xmlns="urn:crmondemand/ws/odesabs/fieldmanagement/"/>,
				"admin",
				"Services/cte/FieldManagementService"
			);*/

		}
		
		private function getDataStr(field:XML, col:String):String {
			if(col=='Name'){
				col = 'GenericIntegrationTag';
			}
			var tmp:XMLList = field.child(new QName(ns2.uri,col));
			return tmp.length()==0 ? "" : tmp[0].toString();
		}
		
		private function populate(field:XML, cols:Array):Object {
			var tmpOb:Object = {};
			for each (var col:String in cols) {
				tmpOb[col] = getDataStr(field,col);
			}
			return tmpOb;
		}

		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}
			if(isClearData){
				Database.fieldManagementServiceDao.delete_all();
				isClearData=false;
			}
			
			var cnt:int = 0;
			var fields:ArrayCollection = new ArrayCollection();

			Database.begin();
			// Database.fieldManagementServiceDao.delete_all();
			
			for each (var objects:XML in result.ns2::ListOfFieldSet[0].ns2::FieldSet) {

				var entity:String = getDataStr(objects, "ObjectName");
				try{
					if(entity==="Revenue"){
						entity = Database.opportunityProductRevenueDao.entity;//nestle--need only oppt-revenue
					}
					else if(entity=="CRMODLS_OBJECTIVE"){
						entity = Database.objectivesDao.entity;
					}
					for each (var field:XML in objects.ns2::ListOfFields[0].ns2::Field) {
	
						var fieldRec:Object = populate(field, Database.fieldManagementServiceDao.getColumns());
						fieldRec.entity = entity;
						if(entity==Database.activityDao.entity && fieldRec.Name=='Alias'){
							fieldRec.Name = 'Owner';//change alias to owner
						}
						if(StringUtils.isEmpty(fieldRec.Name)){
							var name:String= getDataStr(field,"Name");
							//hard code for coloplast
							if(name=='Role Name - Translation' && entity=='Account Team'){
								fieldRec.Name='RoleName';
							}
						}
						
						
						Database.fieldManagementServiceDao.replace(fieldRec);
						try{
							var mapTranslate:Dictionary = new Dictionary();
							for each (var trans:XML in field.ns2::ListOfFieldTranslations[0].ns2::FieldTranslation) {
								var transRec:Object = populate(trans, Database.fieldTranslationDataDao.getColumns());
								transRec.entity = entity;
								transRec.Name = fieldRec.Name;
								mapTranslate[transRec.LanguageCode] = transRec.DisplayName;
								Database.fieldTranslationDataDao.replace(transRec);
							}
							if(Database.checkField(DAOUtils.getEntityByRecordType(entity),fieldRec.Name) && Database.fieldDao.findFieldByNameIgnoreCase(entity,fieldRec.Name)==null){
								var fieldObj:Object ={
									'entity': entity,
									'element_name': fieldRec.Name,
										'display_name': getDisplayName(fieldRec,mapTranslate),
										'data_type':   getFieldType(fieldRec)
								};
								Database.fieldDao.insert(fieldObj);
							}
							
						}catch(e:TypeError){
							//no FieldTranslation
							//nothing to do
						}
					}
					cnt++;
				}catch(e:TypeError){
					//no field name
					//nothing to do					
				}
				
			}
			
			
			Database.commit();
			isFielChange = true;
			// nextPage(true);
			currentTransaction++;
			nextPage(currentTransaction == allTransactions.length);
			return cnt;
		}
		protected function getDisplayName(fieldRec:Object,mapTrans:Dictionary):String{
			var lang:String = LocaleService.getLanguageInfo().LanguageCode;
			if(mapTrans.hasOwnProperty(lang)){
			  var text:String=	mapTrans[lang];
			  if(!StringUtils.isEmpty(text)){
				  return text;
			  }
			}
			return fieldRec.DisplayName;
		}

		protected function getFieldType(fieldRec:Object):String{
			if(StringUtil.beginsWith(fieldRec.FieldType,'Picklist')){
				return 'Picklist'
			}
			
			return fieldRec.FieldType;
		}
		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			//VAHI we do not have an error code here.
			// So all we can do is to check for the exact string.
			// I honestly vomit.
			if (xml_list.length()<1 || xml_list[0].faultstring.length()!=1)
				return false;
			//VAHI perhaps it would be better to check for error type SOAP:Server????
			var str:String = xml_list[0].faultstring[0].toString();
			if (str=='')
				return false;
			optWarn("management service unsupported: "+str);
			currentTransaction++;
			nextPage(currentTransaction == allTransactions.length);
			return true;
		}
		
		override public function getName():String {
			return "Getting fields from management service..."; 
		}
		
		override public function getEntityName():String {
			return "FieldManagementService"; 
		}
	}
}
