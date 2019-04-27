package gadget.sync.incoming {

	import flash.errors.SQLError;
	import flash.events.IOErrorEvent;
	
	import gadget.dao.AccountPartnerDAO;
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.ITeam;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.i18n.i18n;
	import gadget.sync.WSProps;
	import gadget.util.OOPS;
	import gadget.util.ServerTime;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	public class ModificationTracking extends WebServiceIncoming {
		
		private var readMt:Boolean = false;
		
		private var ood2LocalEntity:Object={
			Account:Database.accountDao.entity,
			Activity:Database.activityDao.entity,
			Asset:Database.assetDao.entity,
			Book:Database.bookDao.entity,
			BusinessPlan:Database.businessPlanDao.entity,
			Campaign:Database.campaignDao.entity,
			Contact:Database.contactDao.entity,
			CustomObject1:Database.customObject1Dao.entity,
			CustomObject2:Database.customObject2Dao.entity,
			CustomObject3:Database.customObject3Dao.entity,
			CustomObject4:Database.customObject4Dao.entity,
			CustomObject5:Database.customObject5Dao.entity,
			CustomObject6:Database.customObject6Dao.entity,
			CustomObject7:Database.customObject7Dao.entity,
			CustomObject8:Database.customObject8Dao.entity,
			CustomObject9:Database.customObject9Dao.entity,
			CustomObject10:Database.customObject10Dao.entity,
			CustomObject11:Database.customObject11Dao.entity,
			CustomObject12:Database.customObject12Dao.entity,
			CustomObject13:Database.customObject13Dao.entity,
			CustomObject14:Database.customObject14Dao.entity,
			CustomObject15:Database.customObject15Dao.entity,
			Lead:Database.leadDao.entity,
			Objective:Database.objectivesDao.entity,
			Opportunity:Database.opportunityDao.entity,
			Product:Database.productDao.entity,
			ServiceRequest:Database.serviceDao.entity,
			User:Database.allUsersDao.entity			
			
			
		}
			
		private var oodChild2LocalChildEntity:Object={
			AccountCompetitor:Database.accountCompetitorDao.entity,
			AccountContact:Database.contactAccountDao.entity,
			AccountNote:Database.accountNoteDao.entity,
			AccountPartner:Database.accountPartnerDao.entity,
			RelatedAccount:Database.accountRelatedDao.entity,
			AccountTeam:Database.accountTeamDao.entity,
			Attachment:Database.attachmentDao.entity,
			ProductsDetailed:Database.activityProductDao.entity,
			SampleDropped:Database.activitySampleDroppedDao.entity,
			ContactNote:Database.contactNoteDao.entity,
			RelatedContact:Database.relatedContactDao.entity,
			ContactTeam:Database.contactTeamDao.entity,
			OpportunityCompetitor:Database.opportunityCompetitorDao.entity,
			OpportunityContactRole:Database.opportunityContactDao.entity,
			OpportunityNote:Database.opportunityNoteDao.entity,
			OpportunityPartner:Database.opportunityPartnerDao.entity,
			OpportunityTeam:Database.opportunityTeamDao.entity
			
		}
		
		
		public function ModificationTracking() {
			super("ModificationTracking");
			this.pageSize = 100;
			Database.modificationTrackingDao.deleteAll();
			dao = Database.modificationTrackingDao;
			readMt = (Database.lastsyncDao.find(getMyClassName())!=null);
		}
		
		
		override protected function doRequest():void{
			if(param.full || param.fullCompare || !readMt){
				nextPage(true);
				return;
			}
			
			super.doRequest();
		}
		
	
		
		override protected function getInfo(xml:XML, ob:Object):Object {
			
			
			return { rowid:ob.Id, name:ob.Id }
			
		}

		private var once:Boolean=true;
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, xml_list:XMLList):Boolean {
			if (!mess)
				return false;
			if (mess.indexOf("(SBL-DAT-00553)")>=0) {
				if (once)
					optWarn(i18n._("Advanced Sync not supported in this environment"));
				once = false;
				nextPage(true);
				return true;
			}
			return false;
		}
		
		protected function fixName(obj:Object):Boolean{
			var oodEntity:String = obj['ObjectName'];
			var localEntity:String = ood2LocalEntity[oodEntity];
			if(localEntity!=null){
				obj['ObjectName']=localEntity;
				var oodChild:String = obj['ChildName'];
				var localChild:String = oodChild2LocalChildEntity[oodChild];
				if(localChild==null){
					oodChild = oodEntity+oodChild;
					localChild = oodChild2LocalChildEntity[oodChild];
					if(localChild==null){
						var supportDao:SupportDAO = 	SupportRegistry.getSupportDao(localEntity, obj['ChildName']);	
						if(supportDao!=null){
							localChild = supportDao.entity;
						}
						if(localChild!=null){
							obj['ChildName']=localChild;
						}
					}else{
						obj['ChildName']=localChild;
					}
					
				}else{
					obj['ChildName']=localChild;
				}
				return true;
			}
			
			return false;
		}
		
		override protected function importRecord(entitySod:String, data:XML, googleListUpdate:ArrayCollection=null):int {
			var tmpOb:Object={};			
			for each (var field:Object in getFields()) {
				tmpOb[field.element_name] = getValue(entitySod,data,WSProps.ws10to20(entitySod,field.element_name));	
			}
			if(!fixName(tmpOb)){
				return 0;
			}
			var info:Object = getInfo(data,tmpOb);
			tmpOb.deleted = false;
			tmpOb.local_update = null;
			if(entityIDour == Database.activityDao.entity){
				tmpOb.ms_local_change = new Date().getTime();
			}
			
			var modName:String = WSProps.ws20to10(entitySod, MODIFIED_DATE);
			var modDate:Date = ServerTime.parseSodDate(tmpOb[modName]);
			if (modDate==null) {
				optWarn(i18n._("{1} record with Id {2} has NULL modification date", entitySod, info.rowid));   
			} else {
				if (param.minRec>modDate)		// this works for > but not for ==
					param.minRec	= modDate;
				if (param.maxRec<modDate)
					param.maxRec	= modDate;
			}
			
			
			
			try{
				
				
				tmpOb.ood_lastmodified=tmpOb.ModifiedDate;				
				if (info.rowid == null || info.rowid == "") {
					//VAHI actually this is an internal programming error if it occurs
					//Database.errorLoggingDao.add(null,{entitySod:entitySod,task:getEntityName(),ob:ObjectUtils.DUMPOBJECT(tmpOb),data:data.toXMLString()});
					//trace("missing rowid in",getEntityName(),ObjectUtils.DUMPOBJECT(tmpOb));
					optWarn(i18n._("empty rowid in {1}, ignoring record", getEntityName()));
				} else {
					var childEntityName:String = tmpOb['ChildName'];
					if(tmpOb['EventName']=='PreDeleteRecord' || tmpOb['EventName']=='Dissociate'){
						var tmpdao:BaseDAO = null;
						 if(tmpOb['EventName']=='Dissociate'){
							 tmpdao = Database.getDao(childEntityName,false);
								
								if(tmpdao!=null){
									if(tmpdao is SupportDAO){
										SupportDAO(tmpdao).deleteByChildId(tmpOb['ObjectId'],tmpOb['ChildId']);
									}else{
										tmpdao.deleteByOracleId(tmpOb['ChildId']);
									}
								}
								return 0;
						 }else{
							 if(StringUtils.isEmpty(tmpOb['ChildName'])){
								 tmpdao = Database.getDao(tmpOb['ObjectName'],false);
								 if(tmpdao!=null){
									 tmpdao.deleteByOracleId(tmpOb['ObjectId']);
								 } 
								 return 0;
							 }else{								
								 tmpdao = Database.getDao(childEntityName,false);
								 if(tmpdao!=null){
									 if(tmpdao is SupportDAO){
										 SupportDAO(tmpdao).deleteByChildId(tmpOb['ObjectId'],tmpOb['ChildId']);
									 }else{
										 tmpdao.deleteByOracleId(tmpOb['ChildId']);
									 }
								 } 
								 if(!(tmpdao is ITeam)){
									 return 0;//we need to save only team object for test user has right to see the db
								 }
								 
							 }
						 }						
					}
					//-- VM -- bug 331
					tmpOb.sync_number = Database.syncNumberDao.getSyncNumber();						
					dao.insert(tmpOb,false);
					notifyCreation(false, info.name);
				} 
				
				
				
			}catch(e:SQLError){
				OOPS("=Error while saveing data....", e.details);
				Database.errorLoggingDao.add(e, null);
			}
			_nbItems ++;	
			return 1;
		}
		
		
	}
}
