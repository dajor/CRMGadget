package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.service.UserService;
	import gadget.sync.WSProps;
	import gadget.sync.incoming.JDIncomingObject;
	import gadget.sync.incoming.MSExchangeService;
	import gadget.sync.incoming.ModificationTracking;
	import gadget.sync.incoming.WebServiceIncoming;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;

	public function JDIncomingChangeOwnerTasks():Array {

		var tasks:Array = new Array();
		var transaction:Object = Database.transactionDao.find(Database.serviceDao.entity);
		var viewmode:String = Database.transactionDao.getTransactionViewMode(Database.serviceDao.entity);
		
		if(transaction!=null && transaction.enabled == 1 && viewmode!="Broadest"){
			tasks.push(new JDIncomingObject(Database.serviceDao.entity));
		}
		
		return tasks;
		
		
		
//		function transactionFilter(t:SodUtilsTAO, index:int, arr:Array):Boolean {
//			
//			if(UserService.JD!=UserService.getCustomerId() ||
//				t.sod_name != Database.serviceDao.entity ){
//				return false;
//				
//			}
//			
//			
//			
//			var transaction:Object = Database.transactionDao.find(t.sod_name);
//			var viewmode:String = Database.transactionDao.getTransactionViewMode(t.sod_name);
//			return transaction!=null && transaction.enabled == 1 && viewmode!="Broadest";
//		}
		
//		return [].concat(
//			SodUtils.transactionsTAOif("top_level")
//			.filter(transactionFilter)
//			.map(function (t:SodUtilsTAO, i:int,a:Array):WebServiceIncoming {
//				return new JDIncomingObject(t.our_name);
//			})
//		);
		
		
		
	}
}

