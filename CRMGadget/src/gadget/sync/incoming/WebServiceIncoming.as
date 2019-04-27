
package gadget.sync.incoming {
	import com.google.analytics.utils.UserAgent;
	
	import flash.errors.SQLError;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	
	import gadget.dao.ActivityDAO;
	import gadget.dao.AllUsersDAO;
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.FilterDAO;
	import gadget.dao.IncomingSyncDAO;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.dao.TransactionDAO;
	import gadget.i18n.i18n;
	import gadget.service.LocaleService;
	import gadget.service.PicklistService;
	import gadget.service.UserService;
	import gadget.sync.WSProps;
	import gadget.sync.outgoing.CPOutgoingUpdateRelation;
	import gadget.sync.task.TaskParameterObject;
	import gadget.sync.task.WebServiceBase;
	import gadget.util.FieldUtils;
	import gadget.util.OOPS;
	import gadget.util.OOPSthrow;
	import gadget.util.ObjectUtils;
	import gadget.util.ServerTime;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;

	
	public class WebServiceIncoming extends WebServiceBase {

		protected var isFormulaError:Boolean = false;
		protected const SEARCHSPEC_PLACEHOLDER:String = "___HERE__THE__SEARCH__SPEC___";
		protected const ROW_PLACEHOLDER:String = "___HERE__THE__ROW__NUMBER___";
		protected const SUCCESSFULLY_FAIL_UNFORCED_PAGES:int = 3;
		protected const MODIFIED_DATE:String = "ModifiedDate"; // ModifiedDate or ModifiedByDate
		protected const CREATED_DATE:String ="CreatedDate";
		
		protected var _page:int;
		protected var haveLastPage:Boolean, isLastPage:Boolean;
		//protected var _nbItems:int=0;
		//protected var _lastItems:int;
		
		protected var dicCount:SyncRecordCount = new SyncRecordCount();
		
		// Following are precalculated from initialization
		private var _entityIDour:String;	// Account, Contact, AllUsers, ...
		protected var entityIDsod:String;	// Account, Contact, User, ...
		protected var entityIDns:String;	// CustomObject1, ...
		protected var sodID:String;		// account, contact, ...
		protected var listID:String;	// ListOfAccount, ...
		protected var wsID:String;		// AccountWS_AccountQueryPage_Input,  ...
		protected var entityIDId:String;	//AccountId
		protected var urn:String;		// document/urn:crmondemand/ws/account/:AccountQueryPage, ...
		
		protected var ns1:Namespace;	// new Namespace("urn:crmondemand/ws/account/")
		protected var ns2:Namespace;	// new Namespace("urn:/crmondemand/xml/account")
		
		protected var withFilters:Boolean;
		protected var viewType:Number;
		// Some defaults
		protected var viewMode:String;
		protected var stdXML:XML;
		protected var pageSize:int = 50;
		protected var isUnboundedTask:Boolean = false;

		protected var startTime:Number=-1;
		// Likely to be changed after initialization
		protected var ignoreFields:Array = [ "ModifiedBy" ];
		//SEEALSO[1] Keep this in sync (field ModifiedDate)
		protected var ignoreQueryFields:Array = [ ];
		protected var oldIds:Dictionary = null;
		protected var _checkinrange:Boolean = false;
		protected var _ListNotInFilters:ArrayCollection = new ArrayCollection();
		// METHODS not to change
		//first sync we should use created date because we have some pb with modifieddate look like bug#11384 or #10703
		protected var useCreatedDate:Boolean = false;
		protected var checkOwner:Boolean = true;
		private var _dao:BaseDAO;
		private var rebuildRequest:Boolean = true;
		private var useCountRec:Boolean = true;
		public function WebServiceIncoming(ID:String, daoName:String=null) {
			isUnboundedTask = false;

			entityIDour	= ID;
			entityIDsod	=getSodName();
			entityIDns	= entityIDsod.replace(/ /g,"");
			sodID		= entityIDns.toLowerCase();
			listID		= "ListOf"+entityIDns;
			entityIDId	= entityIDns+"Id";
			
			withFilters	= true;
			
			wsID		= entityIDns+"QueryPage_Input";
			urn			= getSoapAction();
			ns1			= getNS1();
			ns2			= getNS2();
			
			if (daoName==null){
				var sod:SodUtilsTAO=SodUtils.transactionProperty(ID);
				if(sod!=null){
					daoName	= sod.dao;
				}else{
					daoName	= entityIDsod;
				}
			}
				
			dao = Database[daoName] as BaseDAO;
			if(dao==null){
				dao = Database.getDao(ID);
			}
			if (!dao)
				notImpl(i18n._("DAO {1} for {2}", daoName, ID));


			//In WSDL2.0 this is ModifiedDate, even for Products
			stdXML			= null;
			startTime		= Utils.calculateStartTime(Database.transactionDao.getAdvancedFilterType(entityIDour)); 
			viewMode		= getViewmode();
			viewType  		= Database.transactionDao.getTransactionViewType(entityIDour);
//			tweak_vars();

			//SEEALSO[1] Keep this in sync (field ModifiedDate)
			//<{ModifiedDate}>{DatePlaceholder}</{ModifiedDate}>
			trace(wsID);
//			if (stdXML==null) {
//				stdXML = buildStdXML();					
//				
//			}
			
			

		}
		
		private function finishReadDeltaChange(ids:ArrayCollection):void{
			if(ids!=null&& ids.length>0){
				this.oldIds = new Dictionary();
				for each(var id:String in ids){
					this.oldIds[id]=id;
				}
			}			
			doRequest();
		}
		
		override protected function doRequest():void {			
			if(checkOwner && checkinrange){
				//checkowner for first time only
				checkOwner = false;
				
				if(param.range!=null && !(param.fullCompare||param.full) && !(this is IncomingObjectPerId) && !(this is IncomingSubBase)  ){
					var minD:String = ServerTime.toSodIsoDate(param.range.start);		
					//waiting getting records change form server
					new GetDeltaRecordChange("["+MODIFIED_DATE+"] &gt;= '"+minD+"'",entityIDour,finishReadDeltaChange).start();
					return;
				}
				
				
			}
			
			buildAndSendRequest();	
			if(rebuildRequest){
				rebuildRequest = false;//we need cound for only first time
				//rebuild response
				initOnce();
			}
		}
		
		override public function getStartDate():Date{
			if(startTime!=-1){
				return new Date(startTime);
			}
			return null;
		}
		
		protected function buildAndSendRequest():void{
			if(startTime!=-1){
				if(param.range){
					var start:Date = param.range.start;
					var end:Date = param.range.end;	
					if(start.getTime()<startTime && end.getTime()<startTime){
						successHandler(null);
						return;
					}else{
						if(start.getTime()<startTime){
							param.range.start = new Date(startTime);
						}
						
					}					
				}
			}
			
			var searchSpec:String = generateSearchSpec();
			
			//Bug fixing 588 CRO
			if(isFormulaError){
				setFailed();
				param.errorHandler(i18n._("CANNOT_EVALUATE_YOUR_FILER",entityIDour), null);
				successHandler(null);
				return;
			}
			//			if (param.range) {
			//				searchSpec = "["+MODIFIED_DATE+"] &gt;= '"+ServerTime.toSodIsoDate(param.range.start)+"'"
			//					+ " AND ["+MODIFIED_DATE+"] &lt;= '"+ServerTime.toSodIsoDate(param.range.end)+"'";
			//			}
			//			
			//			
			//			if(entityIDour==Database.customObject3Dao.entity && UserService.getCustomerId()==UserService.JD){
			//				if(searchSpec==''){
			//					searchSpec = "[Name]= \'"+Utils.getGPlantLocation() + "\'";
			//				}else{
			//					searchSpec = "[Name]= \'"+Utils.getGPlantLocation() + "\' AND "+searchSpec;
			//				}
			//				
			//			}
			
			var pagenow:int = _page;
			
			isLastPage=false;
			if (isTestData()) {
				isLastPage = true;
				pagenow	= SUCCESSFULLY_FAIL_UNFORCED_PAGES;
			}
			
			
			
			trace("::::::: REQUEST20 ::::::::", getEntityName(), _page, pagenow, isLastPage, haveLastPage, searchSpec);
			//CRO 15-06-2011 release table size
			//Database.errorLoggingDao.add(null, {trace:[getEntityName(), _page, pagenow, isLastPage, haveLastPage, searchSpec]});
			
			//VAHI another poor man's workaround for missing late binding in XML templates
			sendRequest("\""+getURN()+"\"", new XML(getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, pagenow*pageSize)
				.replace(SEARCHSPEC_PLACEHOLDER, searchSpec)
			));
		}
		
		override public function nextRange():void{
			//re-init parent-id
			//param.force = false;
			
		}
		
		protected function isTestData():Boolean{
			return _page==0 && haveLastPage==false && param.force==false && isUnboundedTask==false;
		}
		
		protected function getSodName():String{
			return  SodUtils.transactionProperty(entityIDour).sod_name;
		}
		protected function getSoapAction():String{
			return "document/urn:crmondemand/ws/ecbs/"+sodID+"/:"+entityIDns+"QueryPage";
		}
		protected function getNS1():Namespace{
			return new Namespace("urn:crmondemand/ws/ecbs/"+sodID+"/");
		}
		
		protected function getNS2():Namespace{
			return new Namespace("urn:/crmondemand/xml/"+entityIDns+"/Data");
		}
		private function buildStdXML():XML{
			if(useCountRec){
				//we need count record at the first time only
				useCountRec = false;
				return <{wsID} xmlns={ns1.uri}>						
										<ViewMode>{viewMode}</ViewMode>						
										<{listID} recordcountneeded="1"  pagesize={pageSize} startrownum={ROW_PLACEHOLDER}>
											<{entityIDns} searchspec={SEARCHSPEC_PLACEHOLDER}>
											</{entityIDns}>
										</{listID}>
									</{wsID}>;
			}
			return <{wsID} xmlns={ns1.uri}>						
						<ViewMode>{viewMode}</ViewMode>						
						<{listID}  pagesize={pageSize} startrownum={ROW_PLACEHOLDER}>
							<{entityIDns} searchspec={SEARCHSPEC_PLACEHOLDER}>
							</{entityIDns}>
						</{listID}>
					</{wsID}>;
		}
		
		override public function set param(p:TaskParameterObject):void
		{			
			super.param = p;
			//bug#11731--remove hard code for opportunity
			//bug#8928--resync if full compare=true and viewtype=defaultbook
			//bug#10624---full sync. do the same full compare
			if(oldIds==null && (p.fullCompare||p.full) && !(this is CheckConflictObject) && !(this is IncomingObjectPerId) && !(this is IncomingSubBase)  ){
				if(viewType == TransactionDAO.DEFAULT_BOOK_TYPE || checkinrange ||entityIDour == Database.accountDao.entity){
					oldIds = dao.findAllIdsAsDictionary();				
					Database.incomingSyncDao.unsync_one(getEntityName(),getMyClassName());
					useCreatedDate = true;
				}else{
					useCreatedDate = param.full||Database.incomingSyncDao.is_unsynced(getEntityName());
				}
			}else{
				useCreatedDate = param.full||Database.incomingSyncDao.is_unsynced(getEntityName());
			}
			
			
			
			
		}
		
		
		public function get entityIDour():String
		{
			return _entityIDour;
		}

		public function set entityIDour(value:String):void
		{
			_entityIDour = value;
		}

		public function get dao():BaseDAO
		{
			return _dao;
		}

		public function set dao(value:BaseDAO):void
		{
			_dao = value;
		}

		protected function getViewmode():String{
			
			return Database.transactionDao.getTransactionViewMode(entityIDour);
		}
		protected function initXML(baseXML:XML):void {
			
			// append childs
			var qlist:QName=new QName(ns1.uri,listID), qent:QName=new QName(ns1.uri,entityIDns);
			
			
//			if(UserService.getCustomerId()==UserService.JD && entityIDour==Database.customObject3Dao.entity){
//				for each(var f:String in Database.customObject3Dao.queryFields){
//					var ws20name:String = WSProps.ws10to20(getEntityName(), f);
//					var xml:XML = baseXML.child(qlist)[0].child(qent)[0];					
//					xml.appendChild(new XML("<" + ws20name + "/>"));
//				}
//				return;
//			}
			
			if(viewType == TransactionDAO.DEFAULT_BOOK_TYPE){
				var bookid:String = Database.bookDao.getDefaultBookId();
				if(!StringUtils.isEmpty(bookid)){
					stdXML.appendChild(<BookId>{bookid}</BookId>);
				}
			}
			// Hack in all the ListOf... subobject thingies.
			for each (var sub:String in SupportRegistry.getSubObjects(entityIDour)) {
				if (entityIDour=="Activity" && sub=="Product") {
					//continue;
					if (Database.preferencesDao.getIntValue("pharma.disabled") == 1) {
						continue;
					}
				} 
				
				
				
				var subDao:SupportDAO = SupportRegistry.getSupportDao(entityIDour,sub);
				
				if(!subDao.isSyncWithParent){
					continue;
				}
				
				
				var subName:String = subDao.getSodSubName();
				
				var tmp:XML = <{subName} xmlns={ns1}/>;
				
				for each (var col:String in subDao.getCols()) {
					if (col!="DummySiebelRowId")
						tmp.appendChild(<{col}/>);
				}
				
				subName = "ListOf"+subName;
				stdXML.child(qlist)[0].child(qent)[0].appendChild(<{subName} xmlns={ns1}>{tmp}</{subName}>);
			}			
			
			
			
			// FieldUtils.allFields(entityIDsod, true), we pass true to force select from DB
			// indeed for some virtual field like owner it is pushed into the DB during app starting
			// this create caching issue
			var xml:XML = baseXML.child(qlist)[0].child(qent)[0];
			var hasActivityParent:Boolean = false;
			var ignoreFields:Dictionary = dao.incomingIgnoreFields;
			for each (var field:Object in getFields(true)) {
				// Filter out the column given in the standard XML above
				//SEEALSO[1] Keep this in sync 
//				if (field.element_name == "IsPrivateEvent" || field.element_name == "GUID" || field.element_name == "GDATA"){
//					continue;
//				} 
//				if(entityIDour==Database.serviceDao.entity && "GroupReport" ==field.element_name){
//					continue;
//				}
				if(ignoreFields.hasOwnProperty(field.element_name)){
					continue;
				}
				// dont take parentActivityId 
				if(field !=null && (field.element_name == ActivityDAO.PARENTSURVEYID || entityIDour!=Database.activityDao.entity)){
					hasActivityParent = true;
				}
				if (ignoreQueryFields.indexOf(field.element_name)<0) {
					var ws20name:String = WSProps.ws10to20(entityIDsod, field.element_name);					
					
					xml.appendChild(new XML("<" + ws20name + "/>"));
					//VAHI XXX TODO HACK87
					// Do we need to add this to the SearchSpec instead?
					//
					//applyFilters(xml, field.element_name, ws20name, criterials);
				}
			}
			if(dao.entity==Database.allUsersDao.entity){
				xml.appendChild(new XML("<FullName/>"));
			}
			if(!hasActivityParent && entityIDour==Database.activityDao.entity){
			    xml.appendChild(new XML("<" + ActivityDAO.PARENTSURVEYID + "/>"));
			}
			
			
		}
		
		protected function getFields(alwaysRead:Boolean=false):ArrayCollection{
			return FieldUtils.allFields(entityIDsod,alwaysRead);
		}
		
		//VAHI We need late initalization (just before the run) to be able to access all the fields etc.
		override protected function initOnce():void {
			stdXML = buildStdXML();	
			initXML(stdXML);
		}


		// We have two types of inits:
		// those only needed once and those needed every time on each request start.
		// This here is on each request:
		override protected function initEach():void {
			_page	= 0;
			haveLastPage = false;
			isLastPage = false;
		}
		
		protected function doSplit():void {
			//reset page when we do split
			_page	= 0;
			setFailed();				// failed success, do a split
			successHandler(null);
		}

		override protected function handleZeroFault(soapAction:String, request:XML, event:IOErrorEvent):Boolean {
			//VAHI isLastPage includes that param.force==false
			if (!isLastPage || linearTask)
				return false;

			// Request overwhelmed SoD, try a split
			doSplit();
			return true;
		}
		
		override public function done():void{
			if(oldIds!=null){
				try{
					Database.begin();				
					for(var oraId:String in oldIds){
						dao.deleteByOracleId(oraId);
					}
					Database.commit();
				}catch(e:SQLError){
					Database.rollback();
					//nothing todo
				}
			}
		}

		protected function nextPage(lastPage:Boolean):void {
			// As we finished a page, restore all hacks
			if (isLastPage) {
				isLastPage		= false;
				if (lastPage==false) {
					doSplit();
					return;
				}
				_page =0;//start do from page=0
				showCount();
				haveLastPage	= true;
				doRequest();	// Now fetch _page=0
				return;
			}
			showCount();
			if (lastPage == false) {
				_page ++;
				if (_page<SUCCESSFULLY_FAIL_UNFORCED_PAGES || param.force || isUnboundedTask) {
					doRequest();
					return;
				}
				if (!haveLastPage) {
					//VAHI This code should no more be reached, but be sure
					setFailed();		// failed success
				}
			}			
			successHandler(null);
		}

		

		protected function getSearchFilterCriteria(currentEntity:String):String{
			var criterials:ArrayCollection = getFilterCriterials(currentEntity);
			var searchSpec:String ="";
			for each (var objCriterial:Object in criterials) {
				//order by cannot send
				if(objCriterial.num=="5"){
					continue;
				}
				if (objCriterial.column_name!=null) {
					var oodField:String = WSProps.ws10to20(currentEntity,objCriterial.column_name);
					var operator:String =Utils.getOODOperation(objCriterial.operator);			
					if(objCriterial.operator=='is null'||objCriterial.operator=='is not null'){
						if(searchSpec !=''){
							searchSpec+=' AND ';
						}
						searchSpec+="["+oodField+"] "+ operator;
					}else{
						var val:String= Utils.doEvaluateForFilter(objCriterial,currentEntity);
						if(val != "<ERROR>"){
							if(val=='') continue;
							var childValue:String = "";
							
							if(operator.toLocaleUpperCase() == 'LIKE'){
								childValue = "LIKE " + StringUtils.xmlEscape(StringUtils.sqlStrArg("*"+val+"*"));
							}else if(operator.toLocaleUpperCase() == 'LIKE%'){
								childValue = "LIKE " + StringUtils.xmlEscape(StringUtils.sqlStrArg(val+"*"));
							}else{
								childValue = operator + " " + StringUtils.xmlEscape(StringUtils.sqlStrArg(val))
							}					
							if(searchSpec !=''){
								searchSpec+=' AND ';
							}
							if(operator=="&lt;>"){
								//ood cannot handle null with different criteria
								searchSpec+="(["+oodField+"] "+ childValue +" OR ["+oodField+"] IS NULL)";
							}else{
								searchSpec+="["+oodField+"] "+ childValue;
							}
							
						}else{
							isFormulaError=true;						
						}
					}
				}
			}
			return searchSpec;
		}
		
		protected function generateSearchSpec(byModiDate:Boolean=true):String{
			var searchSpec:String ="";
			if (param.range && byModiDate) {
				var minD:String = ServerTime.toSodIsoDate(param.range.start);
				var maxD:String = ServerTime.toSodIsoDate(param.range.end);
				if(!useCreatedDate || startTime!=-1){
					searchSpec = "(["+MODIFIED_DATE+"] &gt;= '"+minD+"'"
						+ " AND ["+MODIFIED_DATE+"] &lt;= '"+maxD+"')";
				}else{
					//bug#11384---sometime modfieddate is null so we can check with created Date
					searchSpec = "(["+CREATED_DATE+"] &gt;= '"+minD+"'"
						+ " AND ["+CREATED_DATE+"] &lt;= '"+maxD+"')";
				}
				
				
			}
			
			
			if(entityIDour==Database.customObject3Dao.entity && UserService.getCustomerId()==UserService.DIVERSEY){
				if(searchSpec==''){
					searchSpec = "[Name]= \'"+Utils.getGPlantLocation() + "\'";
				}else{
					searchSpec = "[Name]= \'"+Utils.getGPlantLocation() + "\' AND "+searchSpec;
				}
				
			}
			//#7656
			if(entityIDour=="User"){
				if(! StringUtils.isEmpty(searchSpec)){
					searchSpec += " AND ";
				}
				
				searchSpec += "[Status]= \'Active\'";
			}
			var searchFilter:String = getSearchFilterCriteria(entityIDour);
			if(!StringUtils.isEmpty(searchFilter)){
			
				if(searchSpec!=''){
					searchSpec=searchFilter + ' AND (' + searchSpec+")";
				}else{
				
					searchSpec =searchFilter;
				}
			}			
			
			return searchSpec;
			
		}
		
		protected function getResponseNamespace():Namespace{
			return ns2;
		}
		protected function doProcessResponse(recordCount:int,lastPage:Boolean,listObject:XML):int{
			var ns:Namespace = getResponseNamespace();
			var googleListUpdate:ArrayCollection;
			if(getEntityName() == "Activity"){
				googleListUpdate = new ArrayCollection();
				//trace(request);
				//trace(response);
			}
			
			/*if(getEntityName() == "BusinessPlan"){
			trace(request);
			trace(response);
			}*/
			var cnt:int = 0;
			if(this is CPIncomingCheckRelationById){
				//don't need open transaction
				cnt = importRecords(entityIDsod, listObject.child(new QName(ns.uri,entityIDns)),googleListUpdate);
			}else{
				Database.begin();
				cnt = importRecords(entityIDsod, listObject.child(new QName(ns.uri,entityIDns)),googleListUpdate);
				Database.commit();
			}
			
			
			//do update to google calendar
			if(googleListUpdate != null){
				if(getEntityName() == "Activity" && googleListUpdate.length>0){
					var calUpdateService:GoogleCalendarUpdateService = new GoogleCalendarUpdateService(googleListUpdate);
					calUpdateService.start();
				}
			}
			
			nextPage(lastPage);
			return cnt;
		}
		override protected function handleResponse(request:XML, response:XML):int {
			var ns:Namespace = getResponseNamespace();
			var listObject:XML = response.child(new QName(ns.uri,listID))[0];
			var lastPage:Boolean = listObject.attribute("lastpage")[0].toString() == 'true';
			var recordcount:int =-1; 
				try{
					recordcount = parseInt(listObject.attribute("recordcount")[0].toString());
				}catch(e:Error){
					//noting todo
				}
			
			return doProcessResponse(recordcount,lastPage,listObject);
		}
		
		protected function importRecords(entitySod:String, list:XMLList, googleListUpdate:ArrayCollection=null):int {
			var cnt:int = 0;
			for each (var data:XML in list) {
				cnt += importRecord(entitySod, data, googleListUpdate);
			}
			return cnt;
		}

		protected function isChangeOwner(localeRec:Object,serverRec:Object):Boolean{
			return false;
		}
		
		protected function getValue(entitySod:String,data:XML,oodField:String):String{
			var xmllist:XMLList = data.child(new QName(getResponseNamespace().uri,oodField));
			if (xmllist.length()>1)
				trace(oodField,xmllist.length());
			if (xmllist.length() > 0) {
				return xmllist[0].toString();
			} else {
				return  null;
			}
		}
		
		protected function canSave(incomingObject:Object,localRec:Object=null):Boolean{
			return true;
		}
		//hard code for Activity
		protected function isCanGoToDetail(localRec:Object, incomObj:Object):Boolean{
			if(this is IncomingSubActivity && Database.allUsersDao.ownerUser()['Id']!=incomObj['OwnerId']){
				//bug#14090------Activity - Detail Access for records i cannot access in OOD
				if(localRec==null){
					return false;
				}else{
					//return old right for sub
					return localRec.right_goto_detail?localRec.right_goto_detail:false;
				}
			}
			//default is true
			return true;
		}
		
		protected function importRecord(entitySod:String, data:XML, googleListUpdate:ArrayCollection=null):int {
			var tmpOb:Object={};
			var hasActivityParent:Boolean = false;
			for each (var field:Object in getFields()) {
				tmpOb[field.element_name] = getValue(entitySod,data,WSProps.ws10to20(entitySod,field.element_name));
				if(field.element_name == ActivityDAO.PARENTSURVEYID || entityIDour!=Database.activityDao.entity){
					hasActivityParent = true;
				}
			}
			
			if(entityIDour==Database.allUsersDao.entity){
				tmpOb["FullName"] = getValue(entitySod,data,WSProps.ws10to20(entitySod,"FullName"));
			}
			
			if(!hasActivityParent||entitySod==Database.activityDao.entity){
				tmpOb[ActivityDAO.PARENTSURVEYID]=getValue(entitySod,data,ActivityDAO.PARENTSURVEYID);
			}
			
			
			
			var info:Object = getInfo(data,tmpOb);
			var localRecord:Object = dao.findByOracleId(info.rowid);
			if(oldIds!=null){
				delete oldIds[info.rowid];//romove the visibal one
			}
			if(isChangeOwner(localRecord,tmpOb) && UserService.DIVERSEY==UserService.getCustomerId()){				
				dao.deleteByOracleId(info.rowid);
				dicCount.count(info.rowid);
				return 1;
			}
			if(this is JDIncomingObject){
				return 0;
			}
			if(!canSave(tmpOb,localRecord)){
				return 0;
			}
			tmpOb.right_goto_detail = isCanGoToDetail(localRecord,tmpOb);
			//only jd user		
			if(entityIDour== Database.serviceDao.entity 
				&& UserService.DIVERSEY==UserService.getCustomerId()){
				
				if(tmpOb["Status"] == 'Cancelled'){
					if(localRecord!=null){
						dao.deleteByOracleId(info.rowid);
					}
					return 0;//
				}
				
				var pickId:String='';
				if(tmpOb['CustomPickList9']==null||tmpOb['CustomPickList9']==''){
					pickId = gadget.service.PicklistService.getId(entityIDour,"CustomPickList9",tmpOb["CustomText39"],LocaleService.getLanguageInfo().LanguageCode);
					tmpOb['CustomPickList9']= pickId;
				}
				
				if(tmpOb['CustomPickList8']==null||tmpOb['CustomPickList8']==''){
					pickId = gadget.service.PicklistService.getId(entityIDour,"CustomPickList8",tmpOb["CustomText39"],LocaleService.getLanguageInfo().LanguageCode);
					tmpOb['CustomPickList8']= pickId;
				}
				
				
			}
			
			
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
			
			
			
			
			if(entityIDour==Database.productDao.entity){
				tmpOb.ood_lastmodified=tmpOb.ModifiedByDate;
			}else{
				tmpOb.ood_lastmodified=tmpOb.ModifiedDate;
			}
			if (info.rowid == null || info.rowid == "") {
				//VAHI actually this is an internal programming error if it occurs
				//Database.errorLoggingDao.add(null,{entitySod:entitySod,task:getEntityName(),ob:ObjectUtils.DUMPOBJECT(tmpOb),data:data.toXMLString()});
				trace("missing rowid in",getEntityName(),ObjectUtils.DUMPOBJECT(tmpOb));
				optWarn(i18n._("empty rowid in {1}, ignoring record", getEntityName()));
			} else if (localRecord == null) {
				//-- VM -- bug 331
				tmpOb.sync_number = Database.syncNumberDao.getSyncNumber();
				
				trace('ADD',getTransactionName(), info.rowid,tmpOb[modName],info.name);
				updateTracking(entitySod, info.rowid);
				dao.insert(tmpOb,false);
				notifyCreation(false, info.name);
				
			} else {
				var doGoogleSynce:Boolean = false;
				var changed:Boolean = false;
				if (this is IncomingObjectPerId) {
					changed = true;
				} else {
					for each (var field2:Object in FieldUtils.allFields(entitySod)) {
						
						if(field2.element_name == "GDATA" || field2.element_name == "IsPrivateEvent" || field2.element_name == "GUID") continue;
						
						if (tmpOb[field2.element_name] != localRecord[field2.element_name]) {
							
							if (StringUtils.isEmpty(tmpOb[field2.element_name]) && StringUtils.isEmpty(localRecord[field2.element_name])) {
								continue;
							}
							
							// VAHI: XXX
							// The ignoreFields are probably not used.
							// These fields may be present on the SoD side, but they are not on the fieldDao side.
							// As the iteration goes over fieldDao, these fields cannot be present.
							// So perhaps following is redundant code?
							if (field2.element_name.indexOf("CI_") == 0 || ignoreFields.indexOf(field2.element_name)>=0) {
								continue;
							}
							
							if(getEntityName() == "Activity"){
								if( field2.element_name == "Subject" || field2.element_name == "Description" || field2.element_name == "Location" ||
									field2.element_name == "StartTime" || field2.element_name == "EndTime" || field2.element_name == "DueDate")
								{ 
									doGoogleSynce = true; 
								}
							}
							
							changed = true;
							break;
						}
					}
				}
				
				if (changed) {
					
					if(Database.preferencesDao.getValue("enable_google_calendar", 0) != 0){
						if(doGoogleSynce && getEntityName()=="Activity" && !StringUtils.isEmpty(localRecord.GUID) && googleListUpdate!=null){
							tmpOb.IsPrivateEvent = localRecord.IsPrivateEvent;
							tmpOb.GDATA 		 = localRecord.GDATA;
							tmpOb.GUID 			 = localRecord.GUID;
							googleListUpdate.addItem(tmpOb);
						}
					}
					if(UserService.getCustomerId()==UserService.COLOPLAST && localRecord.checkRelation==true){
						var lostRelation:Boolean = false;
						if(entityIDour==Database.customObject11Dao.entity){
							if(StringUtils.isEmpty(tmpOb.ContactId)){
								lostRelation=true;
							}
						}else if(entityIDour==Database.customObject12Dao.entity){
							if(StringUtils.isEmpty(tmpOb.CustomObject14Id)){
								lostRelation=true;
							}
						}
						if(lostRelation){
							createCPOutgoingUpdateRelation(localRecord).start();
							return 0;
						}
					}
					trace('UPD',getTransactionName(), info.rowid,tmpOb[modName],info.name);
					updateTracking(entitySod, info.rowid);
					dao.updateByOracleId(tmpOb);
					notifyUpdate(false, info.name);
				} else {
					trace('HAV',getTransactionName(), info.rowid,tmpOb[modName],info.name);
				}
			}
			}catch(e:SQLError){
				OOPS("=Error while saveing data....", e.details);
				Database.errorLoggingDao.add(e, null);
			}
			
			//update formular field		
			Utils.updateCustomFormulaField(dao,dao.findByOracleId(tmpOb[DAOUtils.getOracleId(dao.entity)]));
//			var customFormularFields:ArrayCollection = Database.customFieldDao.selectCustomFormularFields(dao.entity);
//			if(customFormularFields!=null && customFormularFields.length>0){
//				var updateFields:Array = new Array();
//				var curentSave:Object = dao.findByOracleId(tmpOb[DAOUtils.getOracleId(dao.entity)]);
//				for each(var customField:Object in customFormularFields){
//					updateFields.push(customField.fieldName);
//					var result:String = Utils.doEvaluate(customField.value,Database.allUsersDao.ownerUser(), customField.entity, customField.fieldName, curentSave,null);
//					curentSave[customField.fieldName] = result;
//				}
//				try{
//					dao.updateByField(updateFields,curentSave,DAOUtils.getOracleId(dao.entity));
//				}catch(e:SQLError){
//					OOPS(e.getStackTrace());
//				}
//			
//			}
			//update language info
			if(this is IncomingCurrentUserData){				
				Database.allUsersDao.setOwnerUser(tmpOb);
			}
			
			handleInlineData(data, tmpOb, info);
			dicCount.count(info.rowid);
			
			return 1;
		}
		
		protected function createCPOutgoingUpdateRelation(rec:Object):CPOutgoingUpdateRelation{
			return new CPOutgoingUpdateRelation(entityIDour,rec);
		}
		
		
		/**
		 * Cleanup modification tracking handled rows so they are not processed twice.
		 * @param entity Current entity.
		 * @param id Identifier.
		 */
		protected function updateTracking(entity:String, id:String):void {
			if (!(this is ModificationTracking)) {
				Database.modificationTrackingDao.process(entity, id);
			}			
		}

		protected function getRequestXML():XML { return stdXML; }

		// Most likely methods to override
		
		/**
		 * Override to tweak variables in constructor
		 */
		//protected function tweak_vars():void {}

		protected function handleInlineData(data:XML, tmpOb:Object, info:Object):void {

			for each (var sub:String in SupportRegistry.getSubObjects(entityIDour)) {

				var subDao:SupportDAO = SupportRegistry.getSupportDao(entityIDour, sub);
				var subId:String = DAOUtils.getOracleId(subDao.entity);	
				var subName:String = subDao.getSodSubName();
				var listName:String = "ListOf"+subName;
				
				var xmllist:XMLList = data.child(new QName(ns2.uri,listName));
				if (xmllist.length()==0)
					continue;
				if (xmllist[0].attribute("lastpage")[0].toString() != 'true')
					OOPS("=missing","Cannot handle additional sub-object-pages yet", entityIDour, sub);
				
				for each (var subrec:XML in xmllist[0].child(new QName(ns2.uri,subName))) {
					// XXX TODO MISSING: Delete records which are missing now?
					// Or can this be handled by deleted-Objects? (Hopefully, later)

					//VAHI the following is highly redundant to the above,
					// but no time yet to do proper common code, sorry.

					var rec:Object = {};
					var objTemp:Object = new Object();
					for each (var col:String in subDao.getCols()) {
						var xmldata:XMLList = subrec.child(new QName(ns2.uri,col));
						if (xmldata.length()>1)
							trace(col,xmldata.length());
						rec[col] = xmldata.length()>0 ? xmldata[0].toString() : null;
						objTemp[col] = rec[col];
					}

					var allOk:Boolean = subDao.fix_sync_incoming(rec, tmpOb);
					
					if("ListOfAddress"==listName){
						try{
							var objAddr:Object = Database.addressDao.findByOracleId(tmpOb["Id"]);
							if(objAddr==null){
								objTemp['ParentId'] = tmpOb[entityIDour + "Id"];
								objTemp['Full_Address'] = rec.Address + ", "+ rec.City + ", "+ rec.ZipCode + ", "+ rec.Country;
								objTemp['Entity'] = entityIDour;
								Database.addressDao._insert(objTemp);
							}
						}catch(e:Error){
							trace(e.message);
						}
						continue;
					}
					rec.deleted = false;
					rec.local_update = null;

					if (!allOk && StringUtils.isEmpty(rec[subId])) {

						//Database.errorLoggingDao.add(null,{entitySod:subDao.entity, task:getEntityName(), ob:ObjectUtils.DUMPOBJECT(rec), data:subrec.toXMLString()});
						trace("missing rowid in", getEntityName(), ObjectUtils.DUMPOBJECT(rec));
						optWarn(i18n._("empty rowid in {1}, ignoring record", subDao.entity));

					} else if (rec[subId]==null || subDao.findByOracleId(rec[subId])==null) {
							
						trace('ADD', subDao.entity, rec[subId]);
						subDao.insert(rec);
						
						if (rec[subId]==null)
							subDao.fix_sync_add(rec, tmpOb);
						
					} else {
						trace('UPD', subDao.entity, rec[subId]);
						subDao.updateByOracleId(rec);
						
					}
				}
			}
		}
		
		private var once:Boolean = true;
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
			if (mess==null || errors==null) {
				return false;
			}
			if (errors.length()>0 && errors[0].faultstring.length()>0) {
				mess = errors[0].faultstring[0].toString();
			}
			mess = mess.replace(/[[:space:]][[:space:]]*/g," ");
			//if (mess==i18n._("Method 'Execute' of business component '{1}' (integration component '{1}') returned the following error: \"Access denied.(SBL-DAT-00553)\"(SBL-EAI-04376)", entityIDsod)) {
			if(mess.indexOf("SBL-DAT-00553")!=-1){//|| mess.indexOf("SBL-EAI-04376")!=-1---timeout should be retry
				//not display
//				if (once)
//					warn(i18n._("Object {1} not supported in this environment", entityIDour));
				once = false;
				nextPage(true);
				return true;
			}else if(mess.indexOf("SBL-DAT-00407")!=-1 ||
				mess.indexOf("SBL-EAI-04376")!=-1){
				/**
				 * Method 'Count Records' Business Component 'Action' (Integration Component 'Activity') returned number:
						"This operation is not allowed for SQL objects in the 'Forward only mode.
					Ask your system administrator to check your application configuration if the problem persists. (SBL-DAT 00407) "(SBL-EAI-04 376)
				 * */
				rebuildRequest = false;
				//rebuild request without count
				initOnce();
				
			}
			OOPS("=unhandled(in)", soapAction, mess);
			return false;
		}


		//
		// Abstract Methods
		//

		// Return Object: { rowid:"Siebel ROWID", name:"User readable object name" }
		// Probably must be extended for future dynamic things (which are not like Account/Contact).
		protected function getInfo(response:XML, ob:Object):Object { notImpl("doResponse"); return null }
		
		

		
		override public function getRecordCount():String {
			return dicCount.getRecCount().toString();
		}


		
		
		
		override public function getTransactionName():String { return entityIDour; }
		override public function getEntityName():String { return entityIDsod; }
		protected function getURN():String { return urn; }
		
		//VAHI this is bullshit bingo if we sync horizontally ..
		override  public function getName() : String {
			return i18n._('Reading "{1}" data from server', getEntityName());
		}
		
		protected function showCount():void {
				//always show count
				countHandler(dicCount.getRecCount());
			//_lastItems = _nbItems;
		}
		
		// Copied from SyncTask
		
		protected function notifyCreation(remote:Boolean, name:String):void {
			if (eventHandler != null) 
				eventHandler(remote, getTransactionName(), name, "Created");
		}
		
		protected function notifyUpdate(remote:Boolean, name:String):void {
			if (eventHandler != null)
				eventHandler(remote, getTransactionName(), name, "Updated");	
		}
		
		/*
		protected function notifyDelete(remote:Boolean, name:String, entity:String = null):void {
		if (eventHandler != null)
		eventHandler(remote, entity == null ? getEntityName() : entity, name, "Deleted");
		}
		*/
		
		// Change following into a class,
		// such that member functions can be called!
		
		//VAHI as seen in the original Sync
		protected function getFilterCriterials(entityOur:String):ArrayCollection {
			
			var criterials:ArrayCollection = new ArrayCollection();
			
			if (!withFilters)
				return criterials;
			
			// XXX TODO
			// This should not go here, it should go into filterDao or transactionDao
			
			var transaction:Object = Database.transactionDao.find(entityOur);
			if (transaction==null)
				return criterials;
			
			var filters:Object = Database.filterDao.getObjectFilter(entityOur,transaction.filter_id);
			if (transaction.filter_id>0)
				return Database.criteriaDao.findCriterialWithConjunctionAnd(filters.id);
			
			return criterials;
		}

		public function get checkinrange():Boolean
		{
			return _checkinrange;
		}

		public function set checkinrange(value:Boolean):void
		{
			_checkinrange = value;
		}
		
	
		// change it into a function returning the complete field, such that it can be added directly.
		// Also looking up the field in the criterials this way is clumsy.
		// Even that criterials only have very few fields.
//		protected function applyFilters(xml:XML, fieldInternal:String, fieldSod:String, criterials:ArrayCollection):void {
//			//VAHI generic variant of what was found in original Sync:
//			// apply some criterials (filter specs)
//			if (!withFilters)
//				return;
//			
//			// XXX TODO
//			// This should not go here, it should go into filterDao or transactionDao
//			for each (var objCriterial:Object in criterials) {
//			    //order by cannot send
//				if(objCriterial.num=="5"){
//					continue;
//				}
//				//Bug fixing 588 CRO
//				if (fieldInternal == objCriterial.column_name) {
//					var operator:String =Utils.getOODOperation(objCriterial.operator);
//					if(objCriterial.operator=='is null'||objCriterial.operator=='is not null'){
//						xml.elements(fieldSod).appendChild(operator);
//					}else{
//						var val:String= Utils.doEvaluateForFilter(objCriterial,entityIDour);
//						if(val != "<ERROR>"){
//							if(val=='') continue;
//							var childValue:String = "";
//							
//							if(operator.toLocaleUpperCase() == 'LIKE'){
//								childValue = "LIKE " + StringUtils.xmlEscape(StringUtils.sqlStrArg("*"+val+"*"));
//							}else if(operator.toLocaleUpperCase() == 'LIKE%'){
//								childValue = "LIKE " + StringUtils.xmlEscape(StringUtils.sqlStrArg(val+"*"));
//							}else{
//								childValue = operator + " " + StringUtils.xmlEscape(StringUtils.sqlStrArg(val))
//							}
//							trace("filter",getEntityName(),"column",fieldSod,"with",childValue);
//							xml.elements(fieldSod).appendChild(childValue);
//						}else{
//							isFormulaError=true;						
//						}
//					}
//				}
//			}
//		}
		//use search spec.
//		protected function addFilters(entityOur:String, entitySod:String, xml:XML):XML {
//			if (!withFilters)
//				return xml;
//			
//
//			for each (var objCriterial:Object in getFilterCriterials(entityOur)) {
//				var col:String = objCriterial.column_name;
//				col = WSProps.ws10to20(entitySod, col);
//				
//				var chi:XML = new XML("<" + col + "/>");
//				var childValue:String = objCriterial.operator + " " + StringUtils.xmlEscape(StringUtils.sqlStrArg(objCriterial.param));
//				
//				trace("filter",getEntityName(),"column",col,"with",childValue);
//				chi.appendChild(childValue);
//				xml.appendChild(chi);
//			}
//			return xml;
//		}
	}
}
