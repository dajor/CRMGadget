package gadget.util
{
	
	import flash.utils.setTimeout;
	
	import gadget.dao.Database;
	import gadget.window.WindowManager;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class NetbreezeService
	{
		
		private var httpService: HTTPService;
		private var dashboardUrl: String;
		private var netbreezeAccount: Object; 
		// indicate if the account allready exists at Netbreeze and not exists on the new DB
		private var createNeuAccont:Boolean;
		 
		public function NetbreezeService(netbreezeAccount: Object)
		{
			if(netbreezeAccount)
				this.netbreezeAccount = netbreezeAccount;
			this.createNeuAccont = false;
		}
		
		public function createMonitoringJob(): void
		{
			
			var url: String = "http://api.netbreeze.ch:8080/crm-manager/monitoringjobs/create.xml?crmId="+netbreezeAccount.Netbreeze_id+"&entityId="+netbreezeAccount.account_name+netbreezeAccount.Netbreeze_id+"&entityName="+netbreezeAccount.account_name+"&entityQuery="+netbreezeAccount.account_name;
			httpService = new HTTPService();
			httpService.url = url;
			httpService.addEventListener(ResultEvent.RESULT, function CreateResult_Handler(event:ResultEvent):void {
				
				var result: Object = event.result;
				try{
					var status: String = result.monitoringJobResponse.statusCode;
				}catch (e: TypeError){
					createNeuAccont = true;
					deleteMonitoringJob();
					return;
				}
			 	
				createDashboard();
			});
			httpService.addEventListener(FaultEvent.FAULT, function CreateFault_Handler(event: FaultEvent): void {
				var faultstring:String = event.fault.faultString;
				Alert.show(faultstring, "HTTP - Error", Alert.OK);
			});
			httpService.send();
		}
		 
		public function createDashboard(): void
		{
			var url: String = "http://api.netbreeze.ch:8080/crm-manager/monitoringjobs/dashboardUrl.xml?crmId="+netbreezeAccount.Netbreeze_id+"&entityId="+netbreezeAccount.account_name+netbreezeAccount.Netbreeze_id;
			httpService = new HTTPService();
			httpService.url = url;
			httpService.addEventListener(ResultEvent.RESULT, function result_Handler(event:ResultEvent):void {
				var result: Object = event.result;
				this.dashboardUrl = result.monitoringJobResponse.dashboardUrl;
				var netbreeze: Object = {account_id: netbreezeAccount.account_id, account_name: netbreezeAccount.account_name, dashboard_url: this.dashboardUrl, user_id: netbreezeAccount.user_id };
				//att
				Database.netbreezeAccountDao.insert(netbreeze);
				var netbreezeWindow: NetbreezeDashboard = new NetbreezeDashboard();
				netbreezeWindow.dashboardUrl = this.dashboardUrl;
				WindowManager.openModal(netbreezeWindow); 
			});
			httpService.addEventListener(FaultEvent.FAULT, function fault_Handler(event: FaultEvent): void {
				var faultstring:String = event.fault.faultString;
			});
			httpService.send();
			
		}
		
		public function deleteMonitoringJob(): void
		{
			var url: String = "http://api.netbreeze.ch:8080/crm-manager/monitoringjobs/delete.xml?crmId="+netbreezeAccount.Netbreeze_id+"&entityId="+netbreezeAccount.account_name+netbreezeAccount.Netbreeze_id;
			httpService = new HTTPService();
			httpService.url = url;
			httpService.addEventListener(ResultEvent.RESULT, function result_Handler(event:ResultEvent):void {
				var result: Object = event.result;
				var status: String = result.monitoringJobResponse.statusCode;
				if(parseInt(status) == 200 && createNeuAccont)
				{
					createNeuAccont = false;
					createMonitoringJob();
				}
				if(parseInt(status) == 200 && Database.netbreezeAccountDao.findByAccountID({account_id: netbreezeAccount.accountId}))
					Database.netbreezeAccountDao.deleteByAccountId({account_id: netbreezeAccount.accountId});
				
			});
			httpService.addEventListener(FaultEvent.FAULT, function fault_Handler(event: FaultEvent): void {
				var faultstring:String = event.fault.faultString;
			});
			httpService.send();
		}
	}
}