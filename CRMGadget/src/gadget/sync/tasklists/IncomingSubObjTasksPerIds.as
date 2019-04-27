package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.sync.incoming.IncomingAttachment;
	import gadget.sync.incoming.IncomingSubActivity;
	import gadget.sync.incoming.IncomingSubContact;
	import gadget.sync.incoming.IncomingSubobjects;
	import gadget.sync.incoming.IncomingSubobjectsByIds;
	import gadget.sync.incoming.ScoopObjectActivity;
	import gadget.sync.incoming.WebServiceIncoming;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	
	import mx.collections.ArrayCollection;

	public function IncomingSubObjTasksPerIds():Array {
		
		var subSync:Array = new Array();
		var list:ArrayCollection = Database.transactionDao.listEnabledTransaction();	
		var syncContactAccount:Boolean = false;
		var syncContactC02:Boolean = false;
		for each(var o:Object in list){			
			var subList:Array = Database.subSyncDao.listSubEnabledTransaction(o.entity);
			if(o.entity == "Account"){				
				syncContactAccount=true;	
			}
			if(o.entity == "Contact"){
				syncContactAccount=true;
				syncContactC02=true;
				
			}
			
			
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
					case "Contact":
					case "Service Request":
					case "Asset":						
						break;
					
					
					default:
						if(subObj.syncable){
							if(Database.subSyncDao.isSyncAble(subObj.entity,subObj.sodname)){
								subSync.push(new IncomingSubobjectsByIds(subObj.entity,subObj.sodname));
							}
							
						}
						
				}
				
			}
			
		}	
		
		if(syncContactAccount){
			
			subSync.push(new IncomingSubobjectsByIds(Database.accountDao.entity,Database.contactDao.entity));
		}
		if(syncContactC02){
			subSync.push(new IncomingSubobjectsByIds(Database.contactDao.entity,Database.customObject2Dao.entity));
		}
		
		return subSync;
		

	}
}
