package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.sync.outgoing.OutgoingDelete;
	import gadget.sync.outgoing.OutgoingObject;
	import gadget.sync.outgoing.OutgoingSubObject;
	import gadget.sync.task.WebServiceBase;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	
	import mx.collections.ArrayCollection;

	public function OutgoingTasks():Array {

		
//		function transactionFilter(t:SodUtilsTAO, index:int, arr:Array):Boolean {
//			var transaction:Object = Database.transactionDao.find(t.sod_name);
//			return transaction!=null && transaction.enabled == 1;
//		}
//		
//		// activity must be after contact 
//		return [].concat(
//			SodUtils.transactionsTAOif("top_level")
//			.filter(transactionFilter)
//			.map(function (t:SodUtilsTAO, i:int,a:Array):OutgoingObject {
//				return new OutgoingObject(t.our_name);
//			})
//		);
		
		var enablesTrans:ArrayCollection=Database.transactionDao.listEnabledTransaction();
		var outs:Array =new Array();
		for each(var obj:Object in enablesTrans){
			outs.push(new OutgoingObject(obj.entity));
//			if(obj.entity==Database.contactDao.entity){
//				outs.push(new OutgoingTeam(obj.entity));
//			}
		}
		
		return outs;
		
		
	}
}
