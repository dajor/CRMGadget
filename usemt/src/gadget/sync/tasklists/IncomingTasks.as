package gadget.sync.tasklists {
	import flexunit.utils.ArrayList;
	
	import gadget.dao.Database;
	import gadget.service.UserService;
	import gadget.sync.WSProps;
	import gadget.sync.incoming.IncomingObject;
	import gadget.sync.incoming.MSExchangeService;
	import gadget.sync.incoming.ModificationTracking;
	import gadget.sync.incoming.WebServiceIncoming;
	import gadget.util.Relation;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public function IncomingTasks(dependOn:Boolean):IncomingStructure {


		
		var enablesTrans:ArrayCollection=Database.transactionDao.listEnabledTransaction();
		
		
		
		var incomings:IncomingStructure =new IncomingStructure();
				
		incomings.buildStructure(enablesTrans,dependOn);
		return incomings;
		
	}
}
