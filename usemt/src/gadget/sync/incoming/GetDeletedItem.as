package gadget.sync.incoming {
	
	import flash.events.Event;
	
	import gadget.dao.DAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.i18n.i18n;
	import gadget.sync.task.SyncTask;
	import gadget.util.OOPS;
	import gadget.util.ObjectUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	import mx.utils.StringUtil;

	
	public class GetDeletedItem extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/deleteditem/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/deleteditem");

		private var row:int;
		private var lastSync:String;
		public function GetDeletedItem() {
			row = 0;
			
			var lastSyncObject:Object = Database.lastsyncDao.find(getMyClassName());
			if(lastSyncObject!=null){
				lastSync =  lastSyncObject.sync_date;
			}else{
				lastSync = NO_LAST_SYNC_DATE;
			}
			
			
			
		}
		
		override protected function doRequest():void {

//			var lastSync:String = getLastSync(); 
			if (lastSync == NO_LAST_SYNC_DATE) {
				nextPage(true);
				return;
			}
			
			var request:XML =
	          	<DeletedItemWS_DeletedItemQueryPage_Input xmlns="urn:crmondemand/ws/deleteditem/">
	          		<StartRowNum>{row}</StartRowNum>
				    <PageSize>50</PageSize>
				    <ListOfDeletedItem>
				        <DeletedItem>
				            <DeletedItemId/>
				            <DeletedDate>&gt; '{lastSync}'</DeletedDate>
				            <Name/>
				            <ObjectId/>
				            <Type/>
				            <ExternalSystemId/>
				        </DeletedItem>
				    </ListOfDeletedItem>
				</DeletedItemWS_DeletedItemQueryPage_Input>


			request.ns1::StartRowNum[0] = startRow;
			sendRequest("\"document/urn:crmondemand/ws/deleteditem/:DeletedItemQueryPage\"", request);
		}
		
		
		private function fixName(s:String):String {
			if (s == "Action***Task" || s=="Action***Appointment") {
				return "Activity";
			}else if(s =="Revenue"){
				return Database.opportunityProductRevenueDao.entity;
			}
			
			s= s.replace("OnDemand ", "");
			
			if(s.indexOf(Database.serviceDao.entity)!=-1){
				
			   s=s.replace(Database.serviceDao.entity,"");
			   s=s.replace(/\s+/g,"");
			   if(s==""){
				   return Database.serviceDao.entity;
			   }else{
				   return Database.serviceDao.entity +"."+s;
			   }
				
			}
			
			var dao:DAO = Database.getDao(s,false);
			if(dao==null){
				if(s.indexOf("Custom")!=-1){
					s=s.replace(/\s+/g, '');
				}else{
					s=s.replace(/\s+/g,".");
				}
			}
			
			
			return s; 
		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			
			var googleListDelete:ArrayCollection = new ArrayCollection();
			
			var cnt:int = 0;
			var lastPage:Boolean = result.ns1::LastPage[0].toString() == 'true';
			Database.begin();
			for each(var deleteItem:XML in result.ns2::ListOfDeletedItem[0].ns2::DeletedItem) {
				var objName:String = deleteItem.ns2::Type[0].toString();
				 
				var deleteItemObj:Object = new Object();
				deleteItemObj.id = deleteItem.ns2::ObjectId[0].toString();
				deleteItemObj.type = fixName(objName);
				if (objName.indexOf("Attachment")!=-1){
					var indexAtt:Number=objName.indexOf("Attachment");
					var entity:String=StringUtil.trim(objName.substring(0,indexAtt));
					Database.attachmentDao.deleteAttachmentByAttId(deleteItemObj.id,entity);
					//notifyDelete(false, name, deleteItemObj.type);
					continue; 
				}
				
				var dao:DAO = Database.getDao(deleteItemObj.type,false);
				if (dao == null) {
					OOPS(i18n._("unsupported delete: id={1.id} type={1.type}", deleteItemObj));
				} else {
					var item:Object = dao.findByOracleId(deleteItemObj.id);
					if (item != null) {
						
						if(Database.preferencesDao.getValue("enable_google_calendar", 0) != 0){
							if(!StringUtils.isEmpty(item.GUID)){
								googleListDelete.addItem(item);	
							}
						}
						var name:String ="";
						if(dao is SupportDAO){
							name = ObjectUtils.joinFields(item,DAOUtils.getNameColumns(SupportDAO(dao).entity));							
						}else{
							name = Utils.getName(item);
							//delete child obj
							Utils.deleteChild(item,deleteItemObj.type);
							Utils.removeRelation(item,deleteItemObj.type,false);
							
						}

						dao.deleteByOracleId(deleteItemObj.id);
						notifyDelete(false, name, deleteItemObj.type);
					}
				}
				cnt++;
			}
			Database.commit();
			
			//do delete to google calendar
			if(googleListDelete.length>0){
				var calDeleteService:GoogleCalendarDeleteService = new GoogleCalendarDeleteService(googleListDelete);
				calDeleteService.start();
			}
			
			row += cnt;
			nextPage(lastPage);
			return cnt;
 		}
 		
		override public function getEntityName():String {
			return "Deleted item";
		}
		
		override public function getName():String {
			return "Receiving item deletions from server..."; 
		}
		
	}
}