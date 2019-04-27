package gadget.sync.tests {
	import flash.events.Event;
	import flash.events.IOErrorEvent;

	import gadget.dao.Database;
	import gadget.util.FieldUtils;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.i18n.i18n;

	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	import gadget.sync.task.SyncTask;
	
	public class TestPharma extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/mapping/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/mappingservice");


		
		override protected function doRequest():void {

			if (getLastSync() != NO_LAST_SYNC_DATE){
				successHandler(null);
				return;
			} 
			
			// pagesize 2 is important, not 1
			sendRequest("\"document/urn:crmondemand/ws/ecbs/activity/:ActivityQueryPage\"",
				<ActivityQueryPage_Input xmlns='urn:crmondemand/ws/ecbs/activity/'>
				  <ListOfActivity pagesize="2" startrownum="0">
					<Activity>
					  <ListOfProductsDetailed>
						<ProductsDetailed/>
					  </ListOfProductsDetailed>
					</Activity>
				  </ListOfActivity>
				</ActivityQueryPage_Input>
			);

		}
		
		
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
			if (mess==null || errors==null) {
				return false;
			}
			if (errors.length()>0 && errors[0].faultstring.length()>0) {
				mess = errors[0].faultstring[0].toString();
			}
			mess = mess.replace(/[[:space:]][[:space:]]*/g," ");
			if (mess.indexOf("SBL-DAT-00553")!=-1 && mess.indexOf("SBL-EAI-04376") != -1) {
				Database.preferencesDao.setValue("pharma.disabled", 1);
				
			}
			successHandler(null);
			return true;
		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}
			Database.preferencesDao.setValue("pharma.disabled", 0);
			nextPage(true);
			return 1;
		}
		
		override public function getName():String {
			return "Testing Pharma capabilities..."; 
		}
		
		override public function getEntityName():String {
			return "Products detailed"; 
		}
	}
}
