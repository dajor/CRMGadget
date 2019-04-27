package gadget.sync.incoming
{
	import avmplus.getQualifiedClassName;
	
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	
	import flexunit.utils.ArrayList;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.IncomingSyncDAO;
	import gadget.dao.SubobjectTable;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.dao.TransactionDAO;
	import gadget.sync.WSProps;
	import gadget.sync.task.TaskParameterObject;
	import gadget.util.DateUtils;
	import gadget.util.ServerTime;
	import gadget.util.SodUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.charts.chartClasses.DataTip;
	import mx.collections.ArrayCollection;

	public class IncomingSubBase extends WebServiceIncoming
	{
		protected var _subpage:int;

		protected var subIDour:String;
		protected var subIDsod:String;
		protected var subIDns:String;
		protected var subList:String;
		protected var subIDId:String;
		protected var parentLastSynch:Date = null;
		protected var pid:String = null;
		protected var isUsedLastModified:Boolean = true;
		protected const SUBROW_PLACEHOLDER:String = "___HERE__THE__SUBROW__NUMBER___";
		protected const PARENT_SEARCH_SPEC:String="parent_search_spec";
		protected var SUB_PAGE_SIZE:int=25;	
	//	protected var parentSearchSpec:String;
		
		protected var _listParents:ArrayCollection;
		private var _currentRequestIds:ArrayCollection;
		
		public function IncomingSubBase(ID:String, subId:String, _dao:String=null) {
			subIDour	= subId;
			subIDsod	= SodUtils.transactionProperty(subId).sod_name;
			if(ID == Database.opportunityDao.entity && subId == Database.productDao.entity){
				subIDsod = subIDsod + "Revenue";
				
			}else if((ID == Database.contactDao.entity||ID == Database.accountDao.entity  )&& subId == "Related"){
				subIDsod = subIDsod + ID;
			}else if(ID == Database.contactDao.entity && "Custom Object 2" == subIDsod){
				subIDsod = "CustomObject2";
			}
			
			
			subIDns		= subIDsod.replace(/ /g,"");
			
			subList		= "ListOf"+subIDns;
			
			subIDId		= "Id";
			super(ID, _dao);
			//subobject ignore field
			ignoreQueryFields.push("IsPrivateEvent");
			ignoreQueryFields.push("GUID");
			ignoreQueryFields.push("GDATA");
			ignoreQueryFields.push("ms_id");
			ignoreQueryFields.push("ms_change_key");	
			ignoreQueryFields.push("ms_local_change");	
			noPreSplit = true;
			linearTask = true;
			var lastSyncObject:Object = Database.lastsyncDao.find(getQualifiedClassName(IncomingObject)+entityIDour);
			if(lastSyncObject==null){
				lastSyncObject = Database.lastsyncDao.find(getQualifiedClassName(IncomingRelationObject)+entityIDour);
			}
			var lastSubSync:Object = Database.lastsyncDao.find(getQualifiedClassName(this)+entityIDour+subId);			
			//parentSearchSpec = ServerTime.toSodIsoDate(Utils.getStartDateByType(TransactionDAO.ONE_MONTH_TYPE));
			if(lastSyncObject!=null && lastSubSync!=null){
				ServerTime.setSodTZ(DateUtils.getCurrentTimeZone(new Date())*3600,lastSyncObject.sync_date,Database.allUsersDao.ownerUser().TimeZoneName);
				parentLastSynch = ServerTime.parseSodDate(lastSyncObject.sync_date);
				
			}
			//TODO
			startTime		= Utils.calculateStartTime(Database.subSyncDao.getAdvancedFilterType(ID,subId)); 		
			
		}

		override public function getMyClassName():String{
			return getQualifiedClassName(this)+entityIDour+subIDour;
		}
		
		override protected function tweak_vars():void {
			
			if(this is IncomingAttachment){
				pageSize = Math.max(1, Math.min(100, Database.preferencesDao.getIntValue(getEntityName()+"_page",50)));
				SUB_PAGE_SIZE = Math.max(1, Math.min(100, Database.preferencesDao.getIntValue(getEntityName()+"_subpage",4)));
			}else{
				pageSize = Math.max(1, Math.min(100, Database.preferencesDao.getIntValue(getEntityName()+"_page",50)));
				SUB_PAGE_SIZE = Math.max(1, Math.min(100, Database.preferencesDao.getIntValue(getEntityName()+"_subpage",50)));
			}
			
//			SUCCESSFULLY_FAIL_UNFORCED_PAGES	= Math.max(3, Math.min(100, Database.preferencesDao.getIntValue(getEntityName()+"_pages",3)));
			isUnboundedTask = true;
			
			//VAHI yes, call it here, even that it seems redundant.
			// but this way you cannot forget to hook it using super.tweak_vars() 
			tweak_vars2();
		}
		
		protected function tweak_vars2():void {}

		override protected function initXML(baseXML:XML):void {
			// VAHI Don't ask.  It took me (more than) 4hrs to find QName .. Bullshit documentation
			var qlist:QName=new QName(ns1.uri,listID), qent:QName=new QName(ns1.uri,entityIDns);

			//initXMLsub(baseXML, addFilters(entityIDour, entityIDsod, baseXML.child(qlist)[0].child(qent)[0]));
			initXMLsub(baseXML, baseXML.child(qlist)[0].child(qent)[0]);
		}

		protected function initXMLsub(baseXML:XML, subXML:XML):void {}

		override protected function initEach():void {
			_subpage = 0;
			_lastItems = _nbItems;
			super.initEach();
		}

		protected function nextSubPage(lastPage:Boolean, lastSubPage:Boolean):void {
			
			if (!lastSubPage) {
				showCount();
				_listParents.addAllAt(_currentRequestIds,0);
				_subpage++;		//VAHI yes, this might overcount
				doRequest();
				return;
			}
			_subpage=0;
			nextPage(lastPage);
		}
		
		
		protected override function nextPage(lastPage:Boolean):void {			
				showCount();
				if(lastPage){
					if(_listParents.length<=0){						
						super.nextPage(true);
					}else{						
						_subpage=0;
						_page=0;
						doRequest();
					}
				}else{
					_listParents.addAllAt(_currentRequestIds,0);
					_subpage=0;
					_page++;
					doRequest();
				}
				
			
		}
		
		

		override protected function handleZeroFault(soapAction:String, request:XML, event:IOErrorEvent):Boolean {
			if (param.force || linearTask)
				return false;
			doSplit();
			return true;
		}

		protected function doGetParents():ArrayCollection{
			if(dao!=null){
				return dao.findAllIds();
			}
			
			return new ArrayCollection();
		}
		
		
		protected function getSubSerachSpec():String{
			var dateSpec:String = "";
			var startDate:Date = null;
			if(startTime!=-1){
				if(parentLastSynch!=null && parentLastSynch.getTime()>=startTime){
					startDate = parentLastSynch;
				}else{
					startDate = new Date(startTime);
				}
			}else{
				if(isUsedLastModified){
					startDate = parentLastSynch;
				}
			}
			
			if( !param.full || startTime!=-1){			
				if(startDate!=null){
					dateSpec = "["+MODIFIED_DATE+"] &gt;= '"+ServerTime.toSodIsoDate(startDate)+"'"
				}
				
			}
			return dateSpec;
		}
		
		override protected function doRequest():void {
			
			
			
			
			var pagenow:int = _page;
			var subpagenow:int = _subpage;
			var parentcriteria:String = "";
			isLastPage = false;
			
			if(_listParents==null){
				_listParents = doGetParents();
			}
			
			if(_listParents.length<=0){
				super.nextPage(true);
				return;
			}
			
			var filterSearch:String = getSearchFilterCriteria(entityIDour);
			if(!StringUtils.isEmpty(filterSearch)){			
				parentcriteria+=filterSearch;
			}
			var searchByParentCriteria:String = generateSearchByParentId();
			//parent ids cannot empty
			if(parentcriteria!='' && searchByParentCriteria!=''){
				parentcriteria+=' AND ';
				parentcriteria+=("("+searchByParentCriteria+")");			
			}else{
				parentcriteria = searchByParentCriteria;
			}
			var subCirteria:String = getSubSerachSpec();
			
//			if (param.range) {
//				dateSpec	= "( &gt;= '"+DateUtils.toSodDate(param.range.start)+"' ) AND ( &lt;= '"+DateUtils.toSodDate(param.range.end)+"' )";
//			}			
			trace("::::::: SUBREQUEST20 ::::::::",getEntityName(),param.force,_page,_subpage,pagenow,subpagenow,isLastPage,haveLastPage,subCirteria);
//			Database.errorLoggingDao.add(null,{trace:[getEntityName(),param.force,_page,_subpage,pagenow,subpagenow,isLastPage,haveLastPage,dateSpec]});

			sendRequest("\""+getURN()+"\"", new XML(
				getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, pagenow*pageSize)
				.replace(SUBROW_PLACEHOLDER, subpagenow*SUB_PAGE_SIZE)
				.replace(PARENT_SEARCH_SPEC,parentcriteria)
				.replace(SEARCHSPEC_PLACEHOLDER,subCirteria)
			));
		}
		
		
		protected  function generateSearchByParentId():String{
			if(_listParents.length>0){
				var criteria:String="";
				var maxIndex:int = Math.min(pageSize,_listParents.length);
				var first:Boolean = true;
				_currentRequestIds=new ArrayCollection();
				for(var currentMinIndex:int=maxIndex;currentMinIndex>=1;currentMinIndex--){
					
					if(!first){
						criteria+=" OR ";
					}
					var pid:String = _listParents.removeItemAt(0) as String;
					_currentRequestIds.addItem(pid);
					first = false;
					criteria+=("[Id]=\'"+pid+"\'");
				}
				return criteria;
			}
			
			return "";
		}
		
		
		override protected function handleResponse(request:XML, response:XML):int {
			var listObject:XML = response.child(new QName(ns2.uri,listID))[0];
			var lastPage:Boolean = listObject.attribute("lastpage")[0].toString() == 'true';
			var lastSubPage:Boolean = true;
			var qsublist:QName = new QName(ns2.uri,subList);
			var cnt:int=0;
			
			Database.begin();
			try{
			for each (var parentRec:XML in listObject.child(new QName(ns2.uri,entityIDns))) {
				var subObject:XML = parentRec.child(qsublist)[0];
				if(!(this is IncomingAttachment)){
					this.pid =  parentRec.child(new QName(ns2.uri,"Id"))[0].toString();					
				}
				
				lastSubPage = lastSubPage && ( subObject.attribute("lastpage")[0].toString() == 'true' );
				var nr:int = importRecords(subIDsod, subObject.child(new QName(ns2.uri,subIDns)));
				if (nr<0) {
					//Database.commit();
					return cnt;
				}
				cnt += nr;
			}
				
			}finally{
				Database.commit();
			}
			nextSubPage(lastPage,lastSubPage);
			return cnt;
			
		}

		override public function getEntityName():String { return entityIDsod+subIDsod; }
		override public function getTransactionName():String { return subIDour; }
		override public function getParentTransactionName():String { return entityIDour; }

	}
}