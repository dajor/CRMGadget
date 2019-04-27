package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.dao.TransactionDAO;
	import gadget.sync.WSProps;
	import gadget.sync.incoming.IncomingAttachment;
	import gadget.sync.incoming.IncomingContactNotExistInAccCon;
	import gadget.sync.incoming.IncomingSubActivity;
	import gadget.sync.incoming.IncomingSubContact;
	import gadget.sync.incoming.IncomingSubobjects;
	import gadget.sync.incoming.ScoopObjectActivity;
	import gadget.sync.incoming.WebServiceIncoming;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	
	import mx.collections.ArrayCollection;

	public function IncomingSubObjTasks(fullCompare:Boolean,fullSync:Boolean):Array {
		
		var subSync:Array = new Array();
		var list:ArrayCollection = Database.transactionDao.listEnabledTransaction();
		
		var syncContactAccount:Boolean = false;
		var syncContactC02:Boolean = false;
		var syncActivityUser:Boolean = false;
		
		var accountContact:IncomingSubContact = new IncomingSubContact("Account","Contact");
		if(Database.subSyncDao.isSyncAble("Account","Contact")||Database.subSyncDao.isSyncAble("Contact","Account")){
			subSync.push(accountContact);
			subSync.push(new IncomingContactNotExistInAccCon());
		}
		
		var co2Contact:IncomingSubContact = new IncomingSubContact("Contact","Custom Object 2");
		if(Database.subSyncDao.isSyncAble("Contact","Custom Object 2")||Database.subSyncDao.isSyncAble("Custom Object 2","Contact")){
			subSync.push(co2Contact);
		}
		for each(var o:Object in list){			
			
			if(o.entity == Database.activityDao.entity){	
				syncActivityUser = true;
			}
			//sub
			var subList:Array = Database.subSyncDao.listSubEnabledTransaction(o.entity);
			
			for each(var subObj:Object in subList){
				switch (subObj.sodname){
					case  "Attachment": 
						if(subObj.syncable){							
							if(Database.subSyncDao.isSyncAble(subObj.entity,subObj.sodname)){
								subSync.push(new IncomingAttachment(subObj.entity));		
							}
						}
					
						break;
					case "Activity":
					case "Opportunity":
					case "CustomObject10":
					case "Custom Object 2":
					case "CustomObject2":
					case "Custom Object 3":
					case "CustomObject4":
					case "Account":
					case "Address":
					case "Objectives":
					case "Lead":
					//case "Product":
					//case "Contact":
					case "Service Request":
					case "Asset":	
						//var obj:Object = Database.transactionDao.find(subObj.entity);
						if(subObj.syncable){							
							if(Database.subSyncDao.isSyncAble(subObj.entity,subObj.sodname)){
								subSync.push(new IncomingSubActivity(subObj.entity,subObj.sodname));
							}
							
						}
						break;
					
//					case "Note": subSync.push(new IncomingNote(subObj.entity));	
					default:
						if(subObj.syncable){
							
							if(Database.subSyncDao.isSyncAble(subObj.entity,subObj.sodname)){
								subSync.push(new IncomingSubobjects(subObj.entity,subObj.sodname));
							}
						}
						
				}
			}
			
		}		
		
		
//		if(syncActivityUser){
//			subSync.push(new IncomingSubobjects(Database.activityDao.entity,Database.allUsersDao.entity));
//		}
		
		return subSync;
		
		
//		function attachmentFilter(t:SodUtilsTAO, index:int, arr:Array):Boolean {
//			var o:Object = Database.transactionDao.find(t.sod_name);
//			return o!=null && o.enabled && o.sync_attachments;
//		}
//		
//		function activityFilter(t:SodUtilsTAO, index:int, arr:Array):Boolean {
//			var o:Object = Database.transactionDao.find(t.sod_name);
//			return o!=null && o.enabled && o.sync_activities;
//		}
//		function transactionFilter(t:SodUtilsTAO,index:int,arr:Array):Boolean {
//			//teamp solution 
//			if(t.sod_name!="Contact"){
//				return false;}
//			var transaction:Object = Database.transactionDao.find(t.sod_name);
//			return transaction!=null && transaction.enabled == 1;
//		}
//		return [].concat(
//			
////			SodUtils.transactionsTAOif("ws20act")
////			.filter(transactionFilter)
////			.map(function (t:SodUtilsTAO, i:int,a:Array):WebServiceIncoming{
////				return new IncomingTeam(t.sod_name);
////			}),
//					
//			
//				SodUtils.transactionsTAOif("ws20att")
//					.filter(attachmentFilter)
//					.map(function (t:SodUtilsTAO, i:int,a:Array):WebServiceIncoming {
//						return new IncomingAttachment(t.sod_name);
//					}),
//					
//					
//				SodUtils.transactionsTAOif("ws20act")
//					.filter(activityFilter)
//					.map(function (t:SodUtilsTAO, i:int,a:Array):WebServiceIncoming {
//						return new IncomingSubActivity(t.sod_name);
//					})
//			);
	}
}
