package gadget.sync.incoming {
	import flash.events.IOErrorEvent;
	import flash.net.DatagramSocket;
	
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.sync.task.SyncTask;

//	import gadget.util.FieldUtils;
	
	public class AccessProfileService extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/accessprofile/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/AccessProfile/Data");
		
		protected function getMapObject():Object{
			return {
			"Contact_Note":Database.contactNoteDao.entity,
			"Acct_Address":Database.accountAddressDao.entity,
			"Acct_Note":Database.accountNoteDao.entity,
			"Acct_Competitor":Database.accountCompetitorDao.entity,			
			"Activity_Team":Database.activityUserDao.entity,			
			"Oppty_Revenue":Database.opportunityProductRevenueDao.entity,
			"Contact_Team":Database.contactTeamDao.entity,
			"Acct_Partner":Database.accountPartnerDao.entity,
			"Oppty_Partner":Database.opportunityPartnerDao.entity,
			"CRMODLS_BusinessPlan":Database.businessPlanDao.entity,
			"CRMODLS_PlanOpportunities":Database.planOpportunityDao.entity,	
			"CRMODLS_BPL_ACNT":Database.planAccountDao.entity,
			"CRMODLS_BPL_CNTCT":Database.planContactDao.entity,
			"Acct_Team":Database.accountTeamDao.entity,
			"Activity_Contact":Database.activityContactDao.entity,
			"Oppty_Team":Database.opportunityTeamDao.entity,
			"Oppty_Note":Database.opportunityNoteDao.entity,
			"Activity_Samp_Drop":Database.activitySampleDroppedDao.entity,
			"Activity_Prod_Detail":Database.activityProductDao.entity,
			"Contact_Rel":Database.relatedContactDao.entity,
			"Oppty_Competitor":Database.opportunityCompetitorDao.entity,
//			"Oppty_Note":Database.opportunityNoteDao.entity,
			"CRMODLS_OBJECTIVE":Database.objectivesDao.entity,
			"Acct_Rel":Database.accountRelatedDao.entity,
			"Acct_Book":Database.accountDao.entity+" Book",
			"Oppty_Book":Database.opportunityDao.entity+" Book",
			"SR_Book":Database.serviceDao.entity+" Book",
			"CustomObject15/CustomObject15_Book":Database.customObject15Dao.entity+" Book",
			"Campaign/Campaign Book":Database.campaignDao.entity+" Book"
			
			};
		}
		

		override protected function doRequest():void {
 			if (getLastSync() != NO_LAST_SYNC_DATE){
				successHandler(null);
				return;
			} 
//			FieldUtils.reset();
			
			sendRequest("\"document/urn:crmondemand/ws/odesabs/accessprofile/:AccessProfileReadAll\"",
				<AccessProfileReadAll_Input xmlns={ns1}/>,
				"admin",
				"Services/cte/AccessProfileService"
			);

		}
		
		private function getDataStr(field:XML, col:String):String {
			var tmp:XMLList = field.child(new QName(ns2.uri,col));
			return tmp.length()==0 ? "" : tmp[0].toString();
		}
		
		private function populate(field:XML, cols:Array,mapVal:Object=null):Object {
			var tmpOb:Object = {};
			for each (var col:String in cols) {
				var val:String = getDataStr(field,col);
				if(col=='AccessObjectName'){
					var tempVal:String = val.replace(/ /gi,"_");
					if(mapVal!=null && mapVal.hasOwnProperty(tempVal)){
						val = mapVal[tempVal];
					}
				}
				tmpOb[col] = val;
			}
			return tmpOb;
		}

		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}

			var cnt:int = 0;

			Database.begin();
			Database.accessProfileServiceDao.delete_all();
			
			for each (var ap:XML in result.ns2::ListOfAccessProfile[0].ns2::AccessProfile) {

				var apRec:Object = populate(ap, Database.accessProfileServiceDao.getColumns());
				Database.accessProfileServiceDao.insert(apRec);
				
				for each (var trans:XML in ap.ns2::ListOfAccessProfileTranslation[0].ns2::AccessProfileTranslation) {
					var transRec:Object = populate(trans, Database.accessProfileServiceTransDao.getColumns());
					transRec.AccessProfileServiceName = apRec.Name;
					Database.accessProfileServiceTransDao.insert(transRec);
				}
				var mapEntity:Object = getMapObject();
				for each (var entry:XML in ap.ns2::ListOfAccessProfileEntry[0].ns2::AccessProfileEntry) {
					var entryRec:Object = populate(entry, Database.accessProfileServiceEntryDao.getColumns(),mapEntity);
					entryRec.AccessProfileServiceName = apRec.Name;
					Database.accessProfileServiceEntryDao.insert(entryRec);
				}

				cnt++;
			}
			Database.commit();
			
			nextPage(true);
			return cnt;
		}

		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {

			// SINCE Oracle dont return any error code
			// we return true each time there is a faultstring
			/*
			
			<faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns0="urn:crmondemand/ws/odesabs/accessprofile/" xmlns:ns1="urn:/crmondemand/xml/AccessProfile/Query" xmlns:ns2="urn:/crmondemand/xml/AccessProfile/Data">
			SOAP:Server
			</faultcode>
			*/
			if (xml_list.length()<1 || xml_list[0].faultstring.length()!=1)
				return false;
			var str:String = xml_list[0].faultstring[0].toString();
			if (str=="")				
				return false;
			
			optWarn("AccessProfileService unsupported: "+str);
			nextPage(true);
			return true;
		}
		
		override public function getName():String {
			return "Getting AccessProfileService..."; 
		}
		
		override public function getEntityName():String {
			return "AccessProfileService"; 
		}
	}
}
