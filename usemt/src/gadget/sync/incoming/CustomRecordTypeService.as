package gadget.sync.incoming {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.lists.List;
	import gadget.sync.task.SyncTask;
	import gadget.util.FieldUtils;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	public class CustomRecordTypeService extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/customrecordtype/query");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/customrecordtype/data");
		private var currentTransaction:int = 0;
		private var allTransactions:ArrayCollection = null;	
		override protected function doRequest():void {
 			if (getLastSync() != NO_LAST_SYNC_DATE){
				successHandler(null);
				return;
			}
			if (allTransactions == null) {
				var tmpTransaction:ArrayCollection = Database.transactionDao.listTransaction();
				allTransactions = new ArrayCollection() ;
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
						
					}
				}
				
			}
			var xmlCustomRecordType:XML = <CustomRecordTypeRead_Input xmlns="urn:crmondemand/ws/odesabs/customrecordtype/"><CustomRecordType xmlns="urn:/crmondemand/xml/customrecordtype/query">
								<Name>{allTransactions[currentTransaction]}</Name>              
							</CustomRecordType></CustomRecordTypeRead_Input>;
			sendRequest("\"document/urn:crmondemand/ws/odesabs/CustomRecordType/:CustomRecordTypeRead\"",
				xmlCustomRecordType,
				"admin",
				"Services/cte/CustomRecordTypeService"
			);

		}
		
		private function getDataStr(field:XML, col:String):String {
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

			var cnt:int = 0;
			
			Database.begin();
			if(isClearData){
				Database.customRecordTypeServiceDao.delete_all();
				isClearData=false;
			}
			for each (var rec:XML in result.ns2::ListOfCustomRecordType[0].ns2::CustomRecordType) {

				var fieldRec:Object = populate(rec, Database.customRecordTypeServiceDao.getColumns());
				Database.customRecordTypeServiceDao.replace(fieldRec);

				for each (var trans:XML in rec.ns2::ListOfCustomRecordTypeTranslations[0].ns2::CustomRecordTypeTranslation) {
					var transRec:Object = populate(trans, Database.customRecordTypeTranslationsDao.getColumns());
					transRec.CustomRecordTypeServiceName = fieldRec.Name;
					Database.customRecordTypeTranslationsDao.replace(transRec);
				}
				cnt++;
			}
			Database.commit();
			
			// nextPage(true);
			currentTransaction++;
			nextPage(currentTransaction == allTransactions.length);
			return cnt;
		}

		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			//VAHI we do not have an error code here.
			// So all we can do is to check for the exact string.
			// I honestly vomit.
			
			if (xml_list.length()<1 || xml_list[0].faultstring.length()!=1)
				return false;
			//VAHI perhaps it would be better to check for error type SOAP:Server????
			var str:String = xml_list[0].faultstring[0].toString();
			if (str=="")
				return false;
			trace("no CustomRecordTypeService in this login");
//			nextPage(true);
			currentTransaction++;
			nextPage(currentTransaction == allTransactions.length);
			return true;
		}
		
		override public function getName():String {
			return "Getting translations from custom record type service..."; 
		}
		
		override public function getEntityName():String {
			return "CustomRecordTypeService"; 
		}
	}
}
