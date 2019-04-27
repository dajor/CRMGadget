package gadget.sync.tasklists {
	import flexunit.utils.ArrayList;
	
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.service.UserService;
	import gadget.sync.incoming.AccessAssessmentScriptService;
	import gadget.sync.incoming.AccessProfileService;
	import gadget.sync.incoming.CurrencyService;
	import gadget.sync.incoming.CustomRecordTypeService;
	import gadget.sync.incoming.FieldManagementService;
	import gadget.sync.incoming.GetConfigXml;
	import gadget.sync.incoming.GetFields;
	import gadget.sync.incoming.IncomingCurrentUserData;
	import gadget.sync.incoming.IncomingObject;
	import gadget.sync.incoming.IncomingSalesProcess;
	import gadget.sync.incoming.IncomingUser;
	import gadget.sync.incoming.PicklistService;
	import gadget.sync.incoming.ReadCascadingPicklists;
	import gadget.sync.incoming.ReadPicklist;
	import gadget.sync.incoming.RoleService;
	import gadget.sync.task.MetadataChangeService;
	import gadget.sync.tests.TestCreateRight;
	import gadget.sync.tests.TestPharma;
	import gadget.sync.tests.TestUpdateRight;
	
	import mx.collections.ArrayCollection;
	
	public function InitializationTasks(metaSyn:Boolean=false):Array {
		
		function testUpdateRights():ArrayCollection {
			var a:ArrayCollection = new ArrayCollection();
			for each (var transaction:Object in Database.transactionDao.listTransaction()){
				if (transaction.enabled) {
					a.addItem(new TestUpdateRight(transaction.entity));
				}
			}
			return a;
		}
		
		function testCreateRights():ArrayCollection {
			var a:ArrayCollection = new ArrayCollection();
			for each (var transaction:Object in Database.transactionDao.listTransaction()){
				if (transaction.enabled) {
					a.addItem(new TestCreateRight(transaction.entity));
				}
			}
			return a;
		}
		
		
		
		var all:ArrayCollection =new ArrayCollection( [			
			
			new MetadataChangeService(),
					
			new CustomRecordTypeService(),
			// new IncomingSalesProcess(),			
			new GetFields(),
			

			// Picklists in this sequence, not different.
			new ReadPicklist(),
			
			new CurrencyService(),
					
			// capabilities testing
			new TestPharma()
		]);
		
		//if(Database.preferencesDao.isSync_assessmentscript()){
			all.addItemAt(new AccessAssessmentScriptService(),0);
		//}
		//if(Database.preferencesDao.isSync_field_managment()){
			all.addItemAt(new FieldManagementService(),4);
		//}
		
		//if(Database.preferencesDao.isSync_picklistservice()){
			all.addItem(new PicklistService());
		//}		
		//if(Database.preferencesDao.isSync_cascadingpicklist()){
			all.addItem(new ReadCascadingPicklists());
		//}	
		//if(Database.preferencesDao.isSync_accessprofile()){
			all.addItem(new AccessProfileService());
			
		//}
			
		//if(Database.preferencesDao.isSync_role()){
			all.addItem(new RoleService());
		//}
			//all.addAll(testUpdateRights());//we don't need test update anymore
			all.addAll(testCreateRights());	
		
		if (Database.transactionDao.find("Opportunity").enabled || Database.transactionDao.find("Lead").enabled) {
			all.addItem(new IncomingSalesProcess());
		}
		
		return all.source;
	}
	
	
	
}
