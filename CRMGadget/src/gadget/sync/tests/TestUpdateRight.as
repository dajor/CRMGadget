package gadget.sync.tests
{
	import flash.utils.getQualifiedClassName;
	
	import gadget.dao.Database;
	import gadget.sync.task.SyncTask;
	import gadget.util.CacheUtils;
	import gadget.util.SodUtils;

	public class TestUpdateRight extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/mapping/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/mappingservice");
		
		private var entity:String;
		
		private var ns:Namespace;
		private var wsId:String;
		private var listId:String;
		private var entityIDsod:String;
		private var entityIDns:String
		private var sodID:String;
		
		public function TestUpdateRight(pEntity:String) {
			entity = pEntity;
			entityIDsod	= SodUtils.transactionProperty(entity).sod_name;
			entityIDns	= entityIDsod.replace(/ /g,"");
			sodID		= entityIDns.toLowerCase();
			wsId		= entityIDns + "Update_Input";
			listId		= "ListOf" + entityIDns;
			ns = new Namespace("urn:crmondemand/ws/ecbs/" + sodID + "/");
			
		}
		
		override protected function doRequest():void {
			//rights must be updated all the times-------bug#112
//			if (getLastSync() != NO_LAST_SYNC_DATE){
//				successHandler(null);
//				return;
//			} 
			sendRequest("\"document/urn:crmondemand/ws/ecbs/" + sodID +"/:" + entityIDns + "Update\"",
				<{wsId} xmlns={ns.uri}>
					<{listId}>
						<{entityIDns}>
							<Id>badid</Id>
						</{entityIDns}>
					</{listId}>
				</{wsId}>
			);
			
		}
		
		
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
			if (mess==null || errors==null) {
				return false;
			}
			if (errors.length()>0 && errors[0].faultstring.length()>0) {
				mess = errors[0].faultstring[0].toString();
			}
			mess = mess.replace(/[[:space:]][[:space:]]*/g," ");
			if (mess.indexOf("SBL-EAI-04403")!=-1 || mess.indexOf("SBL-DAT-00510")!=-1 || mess.indexOf("SBL-EAI-04376")!=-1) {
//				If you see the error SBL-EAI-04403 : set HasAccess to True in the table role_service_type for the current user and for the entity Account
				Database.roleServiceRecordTypeAccessDao.upsert({HasAccess:"true"},entity);
				updateHassAccessInCatch(true,entity);				
			}else if (mess.indexOf("SBL-EAI-04376")!=-1) {
//				if you see the error SBL-EAI-04376 : set HasAccess to False in the table role_service_type for the current user and for the entity Account
				Database.roleServiceRecordTypeAccessDao.upsert({HasAccess:"false"},entity);
				updateHassAccessInCatch(false,entity);
				
			}			
			successHandler(null);
			return true;
		}		
		//Mony bug-#112
		private function updateHassAccessInCatch(hassAccess:Boolean,entity:String):void{
			var cache:CacheUtils = new CacheUtils("right");
			var right:Object;
			right = cache.get(entity); 			
			if (right != null) {
				var entityTransaction:Object = Database.transactionDao.find(entity);
				var readOnly:Boolean = entityTransaction ? entityTransaction.read_only : false;
				var canUpdate:Boolean = !readOnly && hassAccess;
				right.canUpdate=canUpdate;
				cache.put(entity, right);
			}
			
		}
		
		
		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}
			nextPage(true);
			return 1;
		}
		
		override public function getMyClassName():String {
			return getQualifiedClassName(this) + entity;
		}
		
		
		override public function getName():String {
			return "Testing " + entity + " update right..."; 
		}
		
		override public function getEntityName():String {
			return entity; 
		}
	}
}