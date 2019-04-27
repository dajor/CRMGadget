package gadget.sync.tasklists {
	import gadget.dao.BaseDAO;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.sync.outgoing.OutgoingAttachment;
	import gadget.sync.outgoing.OutgoingSubObject;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public function OutgoingSubTasks():Array {

		

		
		var enablesTrans:ArrayCollection=Database.transactionDao.listEnabledTransaction();
		var outs:Array =new Array();
		
		var isAddSub:Boolean = true;
		for each(var obj:Object in enablesTrans){
			
			var subList:Array = Database.subSyncDao.listSubEnabledTransaction(obj.entity);
			if(isAddSub && (obj.entity == "Contact" || obj.entity == "Account")){
				outs.push(new OutgoingSubObject("Contact","Account"));
				isAddSub = false;
			}
			if(obj.entity == "Contact"){
				outs.push(new OutgoingSubObject("Contact","Custom Object 2"));
			}
			for each(var subObj:Object in subList){
				var sodname:String = subObj.sodname;
				if(StringUtils.isEmpty(sodname)){
					sodname = subObj.sub;
				}
				
				switch (sodname){
					case  "Attachment": outs.push(new OutgoingAttachment(subObj.entity));
						break;
					case "Activity":
					case "Opportunity":
					case "CustomObject10":
					case "Custom Object 2":
					case "CustomObject2":
					case "Custom Object 3":
					case "CustomObject4":
					case "Account":
					case "Objectives":
					case "Lead":
					//case "Product":
					
					case "Address":
					case "Service Request":
					case "Asset":
						break;					
					case "Contact":
						if(obj.entity!=Database.activityDao.entity){
							break;
						}
					default:
						var supportDao:SupportDAO = Database.getDao(subObj.entity_name,false) as SupportDAO;
						if(supportDao!=null && !supportDao.isSyncWithParent){
							outs.push(new OutgoingSubObject(subObj.entity,sodname));
						}
						
				}
			}
			if(obj.entity == Database.activityDao.entity){
				outs.push(new OutgoingSubObject(obj.entity,Database.allUsersDao.entity));
			}
			
			
		}
		
		return outs;
		
		
	}
}
