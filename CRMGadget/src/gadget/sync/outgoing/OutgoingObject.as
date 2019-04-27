//VAHI will become more generic in future
//
// This is a rough and dirty implementation for Activity today.
// It still is heavily based on the WS1.0 outgoing sync.
package gadget.sync.outgoing
{	
	import com.hurlant.crypto.symmetric.ECBMode;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import gadget.dao.ActivityContactDAO;
	import gadget.dao.ActivityDAO;
	import gadget.dao.AttachmentDAO;
	import gadget.dao.BaseDAO;
	import gadget.dao.CustomObject12DAO;
	import gadget.dao.CustomObject7DAO;
	import gadget.dao.DAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.i18n.i18n;
	import gadget.service.UserService;
	import gadget.sync.WSProps;
	import gadget.sync.task.ReferenceUpdater;
	import gadget.sync.task.WebServiceBase;
	import gadget.util.DateUtils;
	import gadget.util.OOPS;
	import gadget.util.ObjectUtils;
	import gadget.util.Relation;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	import gadget.util.XmlUtils;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	public class OutgoingObject extends WebServiceBase {
		
		protected const PAGE_SIZE:int = 1;	//VAHI currently must be 1

		protected var dao:BaseDAO;
		protected var entity:String;

		protected var SodID:String;
		protected var NameCols:Array;
		protected var URNexe:String;
		/*
		protected var URNins:String;
		protected var URNupd:String;
		protected var WSTagIns:String;
		protected var WSTagUpd:String;
		*/
		
		protected var WSTagExe:String;
		protected var ListOfTag:String;
		protected var EntityTag:String;

		protected var Q1ListOf:QName;
		protected var Q2ListOf:QName;
		protected var Q2Entity:QName;

		protected var do_attachments:Boolean;
		protected var do_user:Boolean;

		protected var updated:Boolean;
		protected var _co7FindWithoutCo11:Boolean = false;
		protected var faulted:int;
		protected var _nbItems:int;

		protected var field_list:ArrayCollection;		
		protected var records:ArrayCollection;
		protected var subObjects:Object;	// Subobject:Array_or_ArrayCollection

		protected var ns1:Namespace;
		protected var ns2:Namespace;

		override public function getRecordCount():String {
			return _nbItems.toString();
		}
		
		public function OutgoingObject(entity:String) {
			this.entity = entity;
			
			var prop:SodUtilsTAO = SodUtils.transactionProperty(entity);
			var trans:Object = Database.transactionDao.find(entity);

			dao				= Database[prop.dao];
			do_attachments	= trans ? trans.sync_attachments : prop.ws20att;

			field_list		= Database.fieldDao.listFields(entity);

			SodID			= DAOUtils.getOracleId(entity);
			NameCols		= DAOUtils.getNameColumns(entity);
			
			if(entity == Database.businessPlanDao.entity){
				trace("OutgoingObject : " + entity);
			}
			
			var entityNS:String	= SodUtils.transactionProperty(entity).sod_name.replace(/ /g,"");
			var entityLC:String	= entityNS.toLocaleLowerCase();
			
			ns1 = new Namespace('urn:crmondemand/ws/ecbs/'+entityLC+'/');
			ns2 = new Namespace('urn:/crmondemand/xml/'+entityNS+'/Data');
			URNexe = '"document/urn:crmondemand/ws/ecbs/'+entityLC+'/:'+entityNS+'Execute"';
/*
			URNins = '"document/urn:crmondemand/ws/ecbs/'+entityLC+'/:'+entityNS+'Insert"';
			URNupd = '"document/urn:crmondemand/ws/ecbs/'+entityLC+'/:'+entityNS+'Update"';
			WSTagIns = entityNS+'Insert_Input';
			WSTagUpd = entityNS+'Update_Input';
*/
			WSTagExe = entityNS+'Execute_Input';
			ListOfTag = 'ListOf'+entityNS;
			EntityTag = entityNS;

			Q1ListOf = new QName(ns1.uri,ListOfTag);
			Q2ListOf = new QName(ns2.uri,ListOfTag);
			Q2Entity = new QName(ns2.uri, entityNS);			
			updated = false;
			faulted = 0;
		}
		
		protected function notify(name:String, what:String):void {
			if (eventHandler != null) 
				eventHandler(true, entity, name, what);
		}
//		protected function findIgnoreFields(record:Object):Array{
//		  var ignoreFields:Array=new Array();
//		  var refs:ArrayCollection=Relation.getReferenced(entity);
//		  for each (var r:Object in refs){
//			  var keyVal:String=record[r.keySrc];
//			  if(keyVal!=null&&keyVal.indexOf('#')==0 && r.supportTable==null){
//				 ignoreFields.push(r.keySrc);
//				 if(!r.keepOutLabelSrc){
//					 for each(var f:String in r.labelSrc){
//						 ignoreFields.push(f);
//					 } 
//				 }
//				 
//			  }
//		  } 
//		  return ignoreFields;
//		}
		
		//jd only--check sr before upload
		protected function checkSRRequire(srObj:Object):Boolean{
			if(Utils.isSRHasPdfAtt(srObj,entity)){
				return false;
			}
			var currentRecords:Object = getCurrentRecordError();
			warn(i18n._("SERVICE_JD_REQUIRE_PDF_ATT"));
			notify(ObjectUtils.joinFields(currentRecords, NameCols), i18n._("Missing"));
			faulted++;
			setFailed();
			dao.setErrorGid(currentRecords.gadget_id, true);					
			doRequest();
			return true;
			
			
		}
		
		//replace ' to empty only for ('Y' and 'N')
		protected function ensureData(str:String,dataType:String='Text (short)'):String{
			if(!StringUtils.isEmpty(str)){
				if(dataType=="Date"){
					var dateObj:Date = DateUtils.guessAndParse(str);
					if(dateObj!=null){
						str = DateUtils.format(dateObj,DateUtils.DATABASE_DATE_FORMAT);
					}else{
						str = null;
					}
				}else if(dataType=="Number"||
					dataType=="Integer"||
					dataType=="Checkbox"){
					str = str.replace(/\'/gi, '').replace(/\’/gi, '').replace(/\‘/gi, '');//remove ' ,’ and ‘ to empty
				
				}else{
					if(dataType=="Multi-Select Picklist"||
						dataType=="Picklist"){
						//remove ' ,’ and ‘ at first char and end char
						var firstChar:String = str.charAt(0);
						if(Utils.QOUTE_CHAR.indexOf(firstChar)!=-1){
							str = str.substr(1);
						}
						var endChar:String = str.charAt(str.length-1);
						if(Utils.QOUTE_CHAR.indexOf(endChar)!=-1){
							str = str.substr(0,str.length-1);
						}
					}else{
						if(str=="'Y'" ||str=="‘Y’"){
							return 'true';
						}else if(str=="'N'" || str=="‘N’"){
							return 'false';
						}
					}
				}
			}else{
				str='';//value cannot be null
			}
		
			return str;
		}
		
		
		protected function readRecords():Boolean{
			records = new ArrayCollection();//clear records
			if (updated) {
				if(!_co7FindWithoutCo11){
					records = dao.findUpdated(faulted, PAGE_SIZE);
				}
				if(records.length==0 && UserService.getCustomerId()==UserService.COLOPLAST && dao is CustomObject7DAO){
					if(!_co7FindWithoutCo11){
						faulted = 0;
						_co7FindWithoutCo11=true;
					}
					records = (dao as CustomObject7DAO).findUpdateWithoutCo11(faulted,PAGE_SIZE);
				}
			} else {
				if(!_co7FindWithoutCo11){
					records = dao.findCreated(faulted, PAGE_SIZE);
				}
				if(records.length==0 && UserService.getCustomerId()==UserService.COLOPLAST && dao is CustomObject7DAO){
					if(!_co7FindWithoutCo11){
						faulted = 0;
						_co7FindWithoutCo11=true;
					}
					records = (dao as CustomObject7DAO).findCreateWithoutCo11(faulted,PAGE_SIZE);
				}
			}
			if (records.length == 0) {
				if (updated) {
					successHandler(null);
					return false;
				}
				updated = true;
				faulted = 0;
				_co7FindWithoutCo11=false;
				doRequest();
				return false;
			}
			
			return true;
		}
		
		override protected function doRequest():void {
			subObjects = {};
			
			if(!readRecords()){
				return;
			}
			
			
			var WSTag:String = WSTagExe;
			var request:XML =
				<{WSTag} xmlns={ns1}>
					<{ListOfTag}/>
				</{WSTag}>;
			if(entity == Database.businessPlanDao.entity){
				trace("OutgoingObject : " + entity);
			}
			for (var i:int = 0; i < records.length; i++) {
				var oracleId:String =records[i][SodID];
				if(updated &&( oracleId.indexOf("#")!=-1||StringUtils.isEmpty(oracleId))){
					faulted++;
					doRequest();
					return;
				}
				
				//var ignoreFields:Array=findIgnoreFields(records[i]);
				var tmp:XML;
				var oper:String = updated ? 'update' : 'insert';
				var xml:XML = <{EntityTag} xmlns={ns1} operation={oper}/>;
				var hasActivityParent:Boolean = false;
				var outgoingIgnoreFields:Dictionary = dao.outgoingIgnoreFields;
//				if(UserService.getCustomerId()==UserService.COLOPLAST){
//					//bug#11533 try to sent item name(e1 sample item) to ood
//					if(entity==Database.customObject12Dao.entity){
//						delete outgoingIgnoreFields['CustomObject14Name'];
//					}
//				}
				if(entity==Database.opportunityDao.entity && UserService.getCustomerId()==UserService.COLOPLAST && Database.preferencesDao.isEnableImpactCalendar()){
					//we check only update record
					if(records[i].OpportunityType=='Forecast' && updated){
						//checking opportunity for ic total before send to ood
						Database.opportunityDao.checkOpportunityTotalByOppId(records[i].OpportunityId);
						//re-read opportunity from db
						records[i] = Database.opportunityDao.findByOracleId(records[i].OpportunityId);
					}
				}
				var hasOracleId:Boolean = false;
				
				for each (var field:Object in field_list) {
					var fieldData:String = records[i][field.element_name];
					if(fieldData==null ||((field.element_name == SodID || StringUtils.isEmpty(fieldData)) && !updated)){
						//bug#13893--hard code when IndexedPick4 is empty need to sent it on createMode
						if(UserService.getCustomerId()!=UserService.COLOPLAST || field.element_name != 'IndexedPick4' || entity!=Database.customObject11Dao.entity){
							continue;//when not updating, the ID need not be sent with WS2.0
						}
						
					}
					if (fieldData != "No Match Row Id") {
						
						if(outgoingIgnoreFields.hasOwnProperty(field.element_name)){
							continue;
						}
						
					
						
						if(field.element_name == ActivityDAO.PARENTSURVEYID || entity!=Database.activityDao.entity){
							hasActivityParent = true;
						}
						var ws20field:String = WSProps.ws10to20(entity,field.element_name);
						//var fieldData:String = records[i][field.element_name];
						if (field.element_name == SodID) {
							hasOracleId = true;
							if (!updated) {
								fieldData="";
							} else if (fieldData=="") {
								warn(i18n._("trying to fix NULL value in {1} record", entity));
								fieldData="#dummy";
							}
						}
						
						xml.appendChild(<{ws20field}>{ensureData(fieldData,field.data_type)}</{ws20field}>);
					}
					
				}
				if(!hasOracleId && updated){
					var realId:String = WSProps.ws10to20(entity,SodID);
					var dataId:String = records[i][SodID];
					xml.appendChild(<{realId}>{dataId}</{realId}>);
				}
				if(!hasActivityParent && records[i][ActivityDAO.PARENTSURVEYID] != null){
					xml.appendChild(
						<{ActivityDAO.PARENTSURVEYID}>{records[i][ActivityDAO.PARENTSURVEYID]}</{ActivityDAO.PARENTSURVEYID}>
					);
				}

	
				
				// Map subobjects like User, Product, Contact, etc.
				for each (var sub:String in SupportRegistry.getSubObjects(entity)) {
					have = false;
					var subDao:SupportDAO = SupportRegistry.getSupportDao(entity, sub);
					var baseDao:BaseDAO = subDao;
					var subName:String = subDao.getSodSubName();
					var subId:String = DAOUtils.getOracleId(baseDao.entity);	// This is complete bullshit
					
					if(!subDao.isSyncWithParent){
						continue;
					}
					tmp = <{"ListOf"+subName} xmlns={ns1}/>;

					var rec:Object = {};
					rec[subDao.getSubOracleId(0)] = records[i][SodID];

					var subList:Array = subDao.getRecordsBySubId(rec);
					subObjects[sub] = subList;

					for each (var obj:Object in subList) {
						
					
						
						var have:Boolean = true;
						

						//VAHI this is bullshit.  We should not sync unchanged objects
						//VAHI this is bullshit.  We should delete deleted objects
						// As we do not have any correct markers for this, we cannot do it here.
						oper = 'update';
						if (StringUtils.isEmpty(obj[subId]) || obj[subId].substr(0,1)=='#') {
							oper = 'insert';
						}else if(obj.deleted){
							oper= 'delete';
						}
						
						var contId:String = records[i].PrimaryContactId;
						if(oper =='insert'&&entity==Database.activityDao.entity && subDao is ActivityContactDAO){
							
							if(obj.Id==contId){					
							
								
								//primary contact auto create activitycontact on ood
								continue;
							}
						}
						

						var tmp2:XML = <{subName} operation={oper}/>;

						for each (var name:String in subDao.getColsOutgoing()) {
							if (name=="DummySiebelRowId" || subDao.outgoingIgnoreFields.hasOwnProperty(name)){
								continue;
							}
							//if (obj[name] == null) continue;
							var val:String = StringUtils.unNull(obj[name]);

							if (oper=='insert') {
								if (name==subId || val=='')
									continue;
								//warningHandler(_("trying to fix NULL value in {1} subrecord {2}", entity, sub), null);
							}
							val = ensureData(val);
							tmp2.appendChild(<{name}>{ val}</{name}>);
						}
						tmp.appendChild(tmp2);
					}
					if (have)
						xml.appendChild(tmp);
				}

				request.child(Q1ListOf)[0].appendChild(xml);
			} 
			sendRequest(URNexe, request);
		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			var i:int = 0;			
			for each (var data:XML in result.child(Q2ListOf)[0].child(Q2Entity)) {

				notify(ObjectUtils.joinFields(records[i], NameCols),
					i18n._(
						(records[i][SodID] && !StringUtils.startsWith(records[i][SodID], "#"))
						? "Updated"
						: "Created"
					));

				for each (var field:Object in field_list) {
					var ws20field:QName = new QName(ns2.uri, WSProps.ws10to20(entity,field.element_name));

					if (data.child(ws20field).length() > 0) {

						if (field.element_name == SodID) {
							ReferenceUpdater.updateReferences(
								entity,
								records[i][field.element_name],
								data.child(ws20field)[0].toString()
								
							);
							if(entity==Database.activityDao.entity){
								//update parentid for ICA
								Database.activityDao.updadteParentSurveyId(data.child(ws20field)[0].toString(),"#" + records[i].gadget_id);
								//update activity user
								Database.activityUserDao.updateReference('ActivityId',records[i]['ActivityId'],data.child(ws20field)[0].toString());
							}
						}
						
						records[i][field.element_name] = data.child(ws20field)[0].toString();
					}
				}
				if(entity==Database.productDao.entity){
					records[i].ood_lastmodified=records[i].ModifiedByDate;
				}else{
					records[i].ood_lastmodified=records[i].ModifiedDate;
				}
				
				records[i].deleted = false;
				records[i].local_update = null;
				records[i].error = false;
				if(UserService.COLOPLAST==UserService.getCustomerId()){
					if(entity==Database.customObject11Dao.entity||entity==Database.customObject12Dao.entity){
						records[i].checkRelation = true;
					}
				}
				
				dao.update(records[i]);				
				if(entity==Database.activityDao.entity){
					var contId:String = records[i].PrimaryContactId;
					var actCont:Object = Database.activityContactDao.getByParentId({'ActivityId':records[i][SodID], 'Id':contId});
					if(actCont!=null){
						Database.activityContactDao.fix_sync_incoming(actCont,records[i]);
						actCont.deleted = false;
						actCont.local_update = null;
						actCont.error = false;
						Database.activityContactDao.fix_sync_outgoing(actCont);
						Database.activityContactDao.update(actCont);
					}
				}else if(entity==Database.accountDao.entity||entity==Database.contactDao.entity){
					var accoundId:String = records[i].AccountId;
					var contactId:String = records[i].ContactId;					
					if(StringUtils.isEmpty(contactId)){
						contactId = records[i].PrimaryContactId;//entity=account						
					}
					if(!StringUtils.isEmpty(accoundId)&& !StringUtils.isEmpty(contactId)){
						var accCont:Object = Database.contactAccountDao.getByParentId({'AccountId':accoundId, 'ContactId':contactId});
						if(actCont!=null){							
							accCont.deleted = false;
							accCont.local_update = null;
							accCont.error = false;
							accCont.Id = accoundId;//no need sent it out to ood, cause it auto create on ood
							Database.contactAccountDao.update(actCont);
						}
					}
				}

				// Send Attachment
				if (do_attachments){
//					var atts:ArrayCollection = new ArrayCollection();
//					for each(var o:Object in subObjects.Attachments){
//						if(o.deleted){
//							Database.attachmentDao.delete_(o);
//						}else{
//							atts.addItem(o);
//						}
//					}
//					Utils.outgoingAttachment(data, entity, atts);
					//send attachment to server
//					new OutgoingAttachment(entity,param.preferences,records[i]).start();
				}
					

				for each (var sub:String in SupportRegistry.getSubObjects(entity)) {
					handleSub(data, sub);
				}

				i++;
			}

			_nbItems += i;
			countHandler(_nbItems);
			doRequest();
			return i;
		}

		//VAHI this is huge duplicated code
		// It should be possible to do this more generic
		protected function handleSub(data:XML, sub:String):void {

			var subDao:SupportDAO = SupportRegistry.getSupportDao(entity, sub);
			var baseDao:BaseDAO = subDao;
			var subId:String = DAOUtils.getOracleId(baseDao.entity);	// This is bullshit, but we do not have a direct function yet
			var subName:String = subDao.getSodSubName();
			var listName:String = "ListOf"+subName;
			
			var xmllist:XMLList = data.child(new QName(ns2.uri,listName));
			if (xmllist.length()==0)
				return;

			for each (var subrec:XML in xmllist[0].child(new QName(ns2.uri,subName))) {

				var changed:Boolean = false;
				// subrec and subObjects do not have the same order, we must match them on Id
				// seems that Id is always present in subobjects and it is a valid unique key for identifying them
				// so this is hardcoded here. We don't use subId.
				var rec:Object;
				for each (rec in subObjects[sub]) {
					if (rec['Id'] == subrec.child(new QName(ns2.uri, 'Id'))[0].toString()) {
						break;
					}
				}
				//var rec:Object = subObjects[sub][i];
				
				changed = baseDao.fix_sync_outgoing(rec);

				if(rec.deleted==1){
					var oraceleId:String=rec[DAOUtils.getOracleId(baseDao.entity)];
					baseDao.deleteByOracleId(oraceleId);
					
				}else{
					for each (var col:String in subDao.getCols()) {
						
						var field:XMLList = subrec.child(new QName(ns2.uri,col));
						if (field.length()>0) {
							
							var upd:String = field[0].toString();
							var old:String = rec[col];
							
							if (upd==old) continue;
							
							changed = true;
							if (col==subId) {
								ReferenceUpdater.updateReferences(baseDao.entity, old, upd);
							}
							rec[col] = upd;
						}
					}
					
					if (changed) {
						rec.deleted = false;
						rec.local_update = null;
						rec.error = false;
						baseDao.update(rec);
					}
				}
				
			}

		}

		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			var oops:String, short:String;
			//VAHI SBL-EAI-04403 must come last as this is NOT "no record", it is "no data returned"
			// the latter can happen due to other bugs.
			if (faultString.indexOf("(SBL-DAT-00498)")>=0
				|| faultString.indexOf("(SBL-DAT-00510)")>=0
				|| faultString.indexOf("(SBL-EAI-04186)")>=0
				|| faultString.indexOf("(SBL-ODS-50736)")>=0
				|| faultString.indexOf("(SBL-DAT-00421)")>=0
				|| faultString.indexOf("(SBL-EAI-04421)")>=0
				|| faultString.indexOf("(SBL-DAT-00225)")>=0
				|| faultString.indexOf("(SBL-DAT-00521)")>=0
				|| faultString.indexOf("(SBL-DAT-00476)")>=0
				|| faultString.indexOf("(SBL-EAI-13011)")>=0
				|| faultString.indexOf("(SBL-DAT-00235)")>=0
				|| faultString.indexOf("(SBL-EAI-04375)")>=0
				|| faultString.indexOf("(SBL-DAT-00412)")>=0
				|| faultString.indexOf("(SBL-ODS-50751)")>=0
				|| faultString.indexOf("(SBL-DAT-56810)")>=0
				|| faultString.indexOf("(SBL-EAI-04376)")>=0
				|| faultString.indexOf("(SBL-EAI-04397)")>=0
				|| faultString.indexOf("(SBL-DAT-00565)")>=0
			) {
				oops ="cannot {4} {1} with Id {2}: data error in '{3}': {6}";
				short = "Invalid";
			} else if (faultString.indexOf("(SBL-EAI-04401)")>=0 
				|| faultString.indexOf("(SBL-DAT-00523)")>=0) {
				oops ="cannot {4} {1} with Id {2}: outdated data in '{3}': {6}";
				short = "Outdated";
			} else if (faultString.indexOf("(SBL-DAT-00542)")>=0 || 
						faultString.indexOf("(SBL-ODS-00446)")>=0 ||			
						faultString.indexOf("(SBL-DAT-00553)")>=0 ||
						faultString.indexOf("(SBL-DAT-00278)")>=0||
						faultString.indexOf("SBL-DAT-00279")>=0||
						faultString.indexOf("(SBL-DAT-00284)")>=0){
				oops ="cannot {4} {1} with Id {2}: access denied to '{3}': {6}";
				short = "Forbidden";
			} else if (faultString.indexOf("(SBL-DAT-00382)")>=0 ||
					   faultString.indexOf("SBL-DAT-00381")>=0) {
				oops ="cannot {4} {1} with Id {2}: existing similar record of '{3}': {6}";
				short = "Nonunique";
			} else if (faultString.indexOf("(SBL-EAI-04403)")>=0 
						|| faultString.indexOf("(SBL-EAI-04378)")>=0) {
//				oops ="cannot {4} {1} with Id {2}: missing server record '{3}': {6}";
				short = "Missing";
				//delete record 
				//current recorderor cannot null				
				var deletedObj:Object = getCurrentRecordError();
				if(this is OutgoingAttachment){
					if(deletedObj.AttachmentId!=null){
						Database.attachmentDao.deleteAttachment(deletedObj);
						doRequest();
						return true;
					}
				}else{
					//Bug #6755
					var currentDao:BaseDAO = getDao();
					var item:Object;
					//sub we should be delete when missing some relation
					if(UserService.getCustomerId().toUpperCase() != UserService.COLOPLAST || this is OutgoingSubBase){						
						var fOraId:String = DAOUtils.getOracleId(currentDao.entity);
						var oracId:String =deletedObj[fOraId]; 
						//sub record we don't care about id
						if(oracId!=null && oracId.indexOf("#")==-1 || this is OutgoingSubBase ){
							item= getCurrentRecordError();
							currentDao.delete_(item);
							if(!(currentDao is SupportDAO)){
								//delete child obj
								Utils.deleteChild(item,currentDao.entity);
								Utils.removeRelation(item,currentDao.entity,false);
							}
						}
					}
					else{
						item = getCurrentRecordError();
						if(item != null){
							item.deleted = false;
							item.local_update = null;
							item.error = false;
							//update only modified field
							currentDao.clearErrorAndLocalChange(item);
						}	
					}
					doRequest();
					return true;
				}												
				oops ="cannot {4} {1} with Id {2}: missing server record '{3}': {6}";
				

			} else if ((faultString.indexOf("(SBL-EAI-04383)")>0 ||
						faultString.indexOf("(SBL-DAT-00357)")>0)&& faultString.indexOf("'Activity_Contact'")>0) {
				// This is a very special case for Activity.Contact
				var huntId:String = faultString.replace(/^.*'\[Id\] = "/,'').replace(/".*$/,'');
				oops = "cannot {4} {1} with Id {2}: duplicate record '{3}': {6}";
				faultString = huntId;
				short = "Duplicate";
				if (huntId!="" && huntId.length<20) {
					//'[Id] = "AHKA-RGTW2"'
					// Hopefully we have a RowId here now.
					// Locate it in Activity.Contact and mark it as present
					// XXX TODO
					var sup:BaseDAO = SupportRegistry.getSupportDao(entity, "Contact");
					var rec:Object = dao.findByOracleId(huntId);
					if (sup.fix_sync_outgoing(rec))
						sup.update(rec);
					oops = "cannot {4} {1} with Id {2}: handled in next sync '{3}': {6}";
				}
			}else if(faultString.indexOf("SBL-ODU-01008")>0){
				oops ="cannot {4} {1} with Id {2}: data error in '{3}': {6}";
				short = "Invalid Character";
			}
			
			else {
				OOPS("=unhandled(out)",faultString.toString());
//				failErrorHandler("BUG CHECK",event);
				return false;
			}
			//specific for activity_contact
			if ((faultString.indexOf("(SBL-EAI-04383)")>0 ||
				faultString.indexOf("(SBL-DAT-00357)")>0)&& faultString.indexOf("'Activity_Contact'")>0) {
				short = "Duplicate";
			}
			
			var showWarning:Boolean = true;
			var error:Boolean = true;
			var currentRecords:Object = getCurrentRecordError();
			if((short=="Nonunique"|| short=="Duplicate") && this is OutgoingSubBase){
				if(getOperation()=='create' || getOperation()=='Created'){
					showWarning = false;
					faulted++;
					if(currentRecords!=null){
						//not need to retry later if has duplicate child
						currentRecords[getOracleIdField()] = currentRecords.gadget_id;						
						currentRecords.local_update=null;
						currentRecords.error = false;
						getDao().update(currentRecords);
					}
				}
			}else if(faultString.indexOf("SBL-DAT-00278")!=-1){
				error=false;
			}
			if(showWarning){
				warn(i18n._(oops, getDao().entity, currentRecords[SodID], ObjectUtils.joinFields(currentRecords, getNameCols()), getOperation(), short, XmlUtils.XMLcleanString(faultString)));
				notify(ObjectUtils.joinFields(currentRecords, getNameCols()), i18n._(short));
				if(error){
					faulted++;
					getDao().setErrorGid(currentRecords.gadget_id, true);
				}else{
					currentRecords.local_update=null;
					currentRecords.error = false;
					currentRecords.deleted=false;
					getDao().update(currentRecords);
				}
				trace(faultString.toString());
			}
			doRequest();
			return true;
		}
		
		protected function getOperation():String{
			return updated ? "update" : "create";
		}
		
		
		
		protected function getNameCols():Array{
			return this.NameCols;
		}
		
		protected function getDao():BaseDAO{
			return this.dao;
		}
		
		
		override protected function getCurrentRecordError():Object{
			if(records==null) return null;
			if(this is OutgoingAttachment){
				var att:Object = records[0];
				return getDao().findByGadgetId(att.gadget_id);
			}
			if(this is OutgoingSubObject){
				var rec:Object = getDao().findByGadgetId(records[0].gadget_id);
				
				if(rec==null){
					var orcleId:String = records[0][getOracleIdField()];
					rec = getDao().findByOracleId(orcleId);
				}
				
				return rec;
			}
			
			return records[0];
		}
		
		protected function getOracleIdField():String{
			return SodID;
		}
		
		override public function getEntityName():String {
			return entity;
		}
		
		override public function getName():String {
			return i18n._("Sending {1} data to server...", getEntityName()); 
		}
		
		override public function getMyClassName():String {
			return getQualifiedClassName(this) + getEntityName();
		}		
	}
}
