package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.sync.incoming.GetDeletedItem;
	import gadget.sync.outgoing.OutgoingDelete;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;

	public function DeletionTasks():Array {

		function transactionFilter(t:SodUtilsTAO, index:int, arr:Array):Boolean {
			var transaction:Object = Database.transactionDao.find(t.sod_name);
			return transaction!=null && transaction.enabled == 1;
		}

		
		return [].concat(
			SodUtils.transactionsTAOif("top_level")
			.filter(transactionFilter)
			.map(function (t:SodUtilsTAO, i:int,a:Array):OutgoingDelete {
				return new OutgoingDelete(t.our_name);
			}),
			[
				new GetDeletedItem()
			]
		);
	}
}
