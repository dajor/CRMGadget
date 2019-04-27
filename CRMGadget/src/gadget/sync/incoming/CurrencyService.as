package gadget.sync.incoming {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import gadget.dao.CurrencyServiceDAO;
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
	
	public class CurrencyService extends SyncTask {
		
		private static var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/currency/");
		private static var ns2:Namespace = new Namespace("urn:/crmondemand/xml/currency/data");
		
		private var allCurrencyServices:ArrayCollection = null;		
		private var currentCurrency:int = 0;	
		override protected function doRequest():void {
			/*if (getLastSync(PICKLISTSERVICE_VERSION) != NO_LAST_SYNC_DATE){
			updateLastSync(PICKLISTSERVICE_VERSION);
			return;
			}*/
			if (getLastSync() != NO_LAST_SYNC_DATE){
				updateLastSync();
				return;
			}
			var request:XML =
				<CurrencyReadAll_Input xmlns="urn:crmondemand/ws/odesabs/currency/"/>;
			sendRequest("\"document/urn:crmondemand/ws/odesabs/Currency/:CurrencyReadAll\"", request,"admin","Services/cte/CurrencyService");
		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}
			if(isClearData){
				//clear picklist from cache
				new CacheUtils("currency").clear();
				Database.currencyServiceDao.delete_all();
				isClearData=false;
			}
			var cnt:int = 0;
			var currencyDAO:CurrencyServiceDAO = Database.currencyServiceDao;
			Database.begin();
			
			for each(var value:XML in result.ns2::ListOfCurrency[0].ns2::Currency) {
				
				var currencyObj:Object = new Object();
				
				currencyObj.name = value.ns2::Name[0].toString();;
				currencyObj.code = value.ns2::Code[0].toString();
				currencyObj.symbol = value.ns2::Symbol[0].toString();
				currencyObj.issuingCountry = value.ns2::IssuingCountry[0].toString();
				currencyObj.active = value.ns2::Active[0].toString();
				var currentValue:Object = currencyDAO.find(currencyObj);
				if(currentValue!=null) currencyDAO.delete_(currencyObj);
				
				currencyDAO.insert(currencyObj);
				cnt++;
				_nbItems++;
			}
			Database.commit();
			//notifyCreation(false, recordType+"/"+fieldName);
			currentCurrency++;
			//nextPage(currentCurrency == allCurrencyServices.length);
			nextPage(true);
			return cnt;
		}
		
		override protected function handleZeroFault(soapAction:String, request:XML, event:IOErrorEvent):Boolean {
			//warn(i18n._("Remote too slow, cannot perform this task now.  Postponed to next sync."));
			Hack("'Unsync + successful fail' instead of proper 'postponed error' handling");
			
			return true;
		}
		
		
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
			if (!mess)
				return false;
			nextPage(true);
			return true;
		}

		
		override public function getName():String {
			return "Getting currency from currency service..."; 
		}
		
		override public function getEntityName():String {
			return "CurrencyService"; 
		}
	}
}
