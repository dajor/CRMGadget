package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.sync.incoming.IncomingObjectPerId;
	import gadget.sync.incoming.ModificationTracking;
	import gadget.sync.incoming.WebServiceIncoming;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	
	import mx.collections.ArrayCollection;

	public function IncomingPerIdTasks():IncomingStructureByIds {

		var enablesTrans:ArrayCollection=Database.transactionDao.listEnabledTransaction();
		
		
		
		var incomings:IncomingStructureByIds =new IncomingStructureByIds();
		
		incomings.buildStructure(enablesTrans,false);
		return incomings;
	}
}
