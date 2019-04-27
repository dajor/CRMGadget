package gadget.sync.incoming
{
	
	
	import com.google.analytics.utils.UserAgent;
	
	import flash.errors.SQLError;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.TransactionDAO;
	import gadget.service.UserService;
	import gadget.sync.task.TaskParameterObject;
	import gadget.util.DateUtils;
	import gadget.util.ObjectUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	public class IncomingRelationObject extends IncomingObject
	{
		
		protected var _parentTask:IncomingObject;
		protected var _parentRelationField:Object;
		protected var _dependOnParent:Boolean = false;
		protected var DATE_RANGE:int=30;
		protected var _currentRequestIds:ArrayCollection;
		protected var _readParentIds:Boolean = true;
		protected var _existRetrieved:Dictionary = null;
		protected var _switchToDependOnParent:Boolean = true;
		protected var _usemodfiedDateAscriteria:Boolean = false;
		protected var _maxParentIdCriteria:int=50;
		protected var _parentIds:ArrayCollection=new ArrayCollection();
		protected var _test_data:Boolean = true;
		protected var MIN_PARENT_IDS:int =10;
		protected var _startDate:Date;
		
		
		/**
		 * parentFieldIds has properties ChildRelationId,ParentRelationId
		 * */
		public function IncomingRelationObject(entity:String, parentTask:IncomingObject=null, parentFieldIds:Object=null, dependOnParent:Boolean=false)
		{
			super(entity);
			this._parentTask = parentTask;
			this._dependOnParent = dependOnParent;
			this._parentRelationField = parentFieldIds;
			_existRetrieved = new Dictionary();
			_readParentIds = Database.incomingSyncDao.is_unsynced(getEntityName());
			if(_readParentIds){
				_test_data = false;
			}
			this._startDate = Utils.getStartDateByType(Database.transactionDao.getAdvancedFilterType(entityIDour));
		}
		
		override public function set param(p:TaskParameterObject):void
		{			
			super.param = p;
			//bug#8990
			if((p.fullCompare||p.full) && (viewType == TransactionDAO.DEFAULT_BOOK_TYPE||checkinrange ||entityIDour==Database.accountDao.entity)){
				_readParentIds = true;
				_dependOnParent = true;
			}
			//bug#11731--remove hardcode for opportunity
//			if(UserService.getCustomerId()==UserService.COLOPLAST && entityIDour ==Database.opportunityDao.entity){
//				_readParentIds = true;
//				_dependOnParent = true;
//			}
			
			
		}
	
	
		public function get dependOnParent():Boolean
		{
			return _dependOnParent;
		}
		
		public function get parentRelationField():Object
		{
			return _parentRelationField;
		}
		
		public function set parentRelationField(value:Object):void
		{
			_parentRelationField = value;
		}
		
		public function get parentTask():IncomingObject
		{
			return _parentTask;
		}
		
		public function set parentTask(value:IncomingObject):void
		{
			_parentTask = value;
		}
		
		
		
		protected override function canSave(incomingObject:Object,localRec:Object=null):Boolean{
			if(parentTask!=null && parentRelationField!=null){
				var parentId:String=incomingObject[parentRelationField.ParentRelationId];
				var issave:Boolean = false;
				if(StringUtils.isEmpty(parentId) || parentId=='No Match Row Id'){
					if(parentRelationField.hasOwnProperty('ChildRelationId')){
						var criteria:Object = new Object();
						criteria[parentRelationField.ChildRelationId] = incomingObject[DAOUtils.getOracleId(entityIDour)];
						var parentObject:Object = parentTask.dao.getByParentId(criteria);				
						issave = parentObject!=null;
					}
				}else{
					var parentObject1:Object = parentTask.dao.findByOracleId(parentId);
					issave = parentObject1!=null;			
				}
				if(issave){
					listRetrieveId.addItem(incomingObject);
				}else{
					var item:Object = dao.findByOracleId(incomingObject[DAOUtils.getOracleId(entityIDour)]);
					if(item!=null){
						//delete child obj
						Utils.deleteChild(item,entityIDour);
						Utils.removeRelation(item,entityIDour,false);
						dao.deleteByOracleId(item[DAOUtils.getOracleId(entityIDour)]);
					}
					
				}
				
				return issave;
			}
			
			return super.canSave(incomingObject);
		}
		
		
		protected function  initParentIds():void{
			var fields:ArrayCollection = new ArrayCollection([{"element_name":DAOUtils.getOracleId(parentTask.entityIDour)}]);
			try{						
				if(!StringUtils.isEmpty(parentRelationField.ChildRelationId)){
					fields.addItem({"element_name":parentRelationField.ChildRelationId});
				}
				parentTask.listRetrieveId = Database.getDao(parentTask.entityIDour).findAll(fields,null,null,0);
			}catch(e:SQLError){
				fields.removeItemAt(fields.length-1);//remove last column
				parentTask.listRetrieveId = Database.getDao(parentTask.entityIDour).findAll(fields,null,null,0);
			}
			
			copyParentIds();
		}
		
		protected function copyParentIds():void{
			_maxParentIdCriteria = 50;
			this._parentIds = new ArrayCollection();
			if(parentTask.listRetrieveId!=null && dependOnParent){
				for each(var o:Object in parentTask.listRetrieveId){
					this._parentIds.addItem(o);
				}
			}
		}
		
		override public function nextRange():void{
			//re-init parent-id			
//			if(startTime!=-1){
//				_test_data = !param.force;
//				_maxParentIdCriteria =25;
//				copyParentIds();
//			}
		}
		
		
		override protected function doRequest():void {		
			//if(!dependOnParent){
			var count:int = Database.getDao(entityIDour).count();					
			if(_readParentIds &&(count<=0 ||dependOnParent)){
				_readParentIds= false;
				_dependOnParent = true;
				
				initParentIds();
			}
				
			//}
			if( dependOnParent && (this._parentIds.length<=0)){
				super.nextPage(true);
			}else{
				if(_startDate!=null){
					if(param.range){
						
						var start:Date = ensureStartDate(param.range,_startDate);;						
						var end:Date = Utils.calculateDate(DATE_RANGE,start,"date");	
						if(end.getTime()>param.server_time.getTime()){
							end = param.range.end;							
						}
						if(start.getTime()>end.getTime()){
							start = end;
							super.nextPage(true);
							return;
						}
						
						param.range.start = start;
						param.range.end = end;
								
					}
				}
				super.doRequest();
			}
		}
		
		protected function ensureStartDate(range:Object,minStartDate:Date):Date{
			var currentStartDate:Date = range.start;
			if(currentStartDate.getTime()>minStartDate.getTime()){
				return currentStartDate;
			}
			return minStartDate;
		}
		
		override public function stop():void
		{
			if(_dependOnParent){
				//keep the dependon as true when user cancel while syncing
				Database.incomingSyncDao.unsync_one(getEntityName(),getMyClassName());
			}
			super.stop();
		}
		
		
		override public function get checkinrange():Boolean
		{
			return _checkinrange && !dependOnParent;
		}

		
		protected override function generateSearchSpec(byModiDate:Boolean=true):String{		
			
			
			if(!dependOnParent){
				return super.generateSearchSpec();
			}else{				
				var first:Boolean = true;
				var searchspec:String = "";
				var maxIndex:int = Math.min(_maxParentIdCriteria,(this._parentIds.length));
				_maxParentIdCriteria = maxIndex;
				_currentRequestIds=new ArrayCollection();
				var oracleId:String = DAOUtils.getOracleId(entityIDour);
				for(var i:int=1;i<=maxIndex;i++){
					
					var parentObj:Object = this._parentIds.removeItemAt(0);
					if(parentObj==null){
						continue;
					}
					_currentRequestIds.addItem(parentObj);
					if(!first){
						searchspec=searchspec+" OR ";
					}
					searchspec=searchspec+"["+parentRelationField.ParentRelationId+"] = \'"+parentObj[DAOUtils.getOracleId(parentTask.entityIDour)]+'\'';
					if(!StringUtils.isEmpty(parentRelationField.ChildRelationId) && oracleId==parentRelationField.ChildRelationId && parentObj.hasOwnProperty(oracleId)){
						var thisId:String = parentObj[parentRelationField.ChildRelationId];	
						if(!StringUtils.isEmpty(thisId) && !_existRetrieved.hasOwnProperty(thisId)){							
							searchspec=searchspec+" OR ";
							searchspec=searchspec+"[Id]=\'"+thisId+"\'";
							this._existRetrieved[thisId] = thisId;
							
						}
					}
									
					first = false;
				}			
				
				var superCriteria:String = super.generateSearchSpec((startTime!=-1 || _usemodfiedDateAscriteria));
				if(StringUtils.isEmpty(superCriteria)){
					superCriteria=searchspec;
				}else{
					superCriteria+=' AND ('+searchspec+')';
				}
				
				return superCriteria;
			}
		}
		protected override function doProcessResponse(recordCount:int,lastPage:Boolean,listObject:XML):int{
			
			if(_switchToDependOnParent && !dependOnParent){
				_switchToDependOnParent = false;
				var localCount:int = dao.count();
				if(recordCount>=localCount){
					_page =0;//reset page
					_dependOnParent = true;					
					_readParentIds = true;
					_usemodfiedDateAscriteria=true;//use modifidate
					//start sync depend parent
					doRequest();
					return 0;
				}
			}
			
			
			return super.doProcessResponse(recordCount,lastPage,listObject);;
		}
		protected function restoreRequest():void{
			if(dependOnParent){
				this._parentIds.addAllAt(_currentRequestIds,0);
				for each(var parentObj:Object in _currentRequestIds){
					if(!StringUtils.isEmpty(parentRelationField.ChildRelationId) && parentObj.hasOwnProperty(parentRelationField.ChildRelationId)){
						var thisId:String = parentObj[parentRelationField.ChildRelationId];	
						if(!StringUtils.isEmpty(thisId)){		
							delete this._existRetrieved[thisId];
							
						}
					}
				}
			}
		}
		
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
			var notRretry:Boolean = super.handleErrorGeneric(soapAction,request,response,mess,errors);
			
			if(!notRretry || mess.indexOf("SBL-DBC-00112")!=-1||mess.indexOf("SBL-DAT-00407")!=-1 ||
				mess.indexOf("SBL-EAI-04376")!=-1){
				if(startTime!=-1 && !param.force){					
					doSplit();
					return true;
				}else{
					notRretry = false;
					restoreRequest();
				}
				
			}
			return notRretry;
		}
		
		override protected function isTestData():Boolean{
			if(dependOnParent){
				return this._test_data;
			}
			
			return super.isTestData();
		}
		
		override protected function doSplit():void {
			_page=0;
			if(dependOnParent){
				restoreRequest();
				if(_maxParentIdCriteria>MIN_PARENT_IDS){
					_maxParentIdCriteria =Math.max(MIN_PARENT_IDS, _maxParentIdCriteria/2);					
					this._test_data=true;					
				}else{
					this._test_data=false
				}
				
				doRequest();
			}else{
				
				super.doSplit();
			}
		}
		
		protected override function nextPage(lastPage:Boolean):void {
			if(!dependOnParent){
				this._test_data=false;
				super.nextPage(lastPage);
			}else{
				showCount();
				if (this._test_data) {
					this._test_data=false;
					if (lastPage==false) {
						doSplit();
						return;
					}
					restoreRequest();
					_page=0;					
					haveLastPage	= true;
					doRequest();	// Now fetch _page=0
					return;
				}
				
				if(lastPage){
					if(this._parentIds.length<=0){	
						if(_startDate==null ||_startDate.getTime()>=_parentTask.param.server_time.getTime() ){
							super.nextPage(true);
						}else{
							//increase 15day for next request
							_startDate = Utils.calculateDate(DATE_RANGE,_startDate,"date");
							copyParentIds();
							_page=0;
							doRequest();
						}
					}else{				
						
						_page=0;
						doRequest();
					}
				}else{
				
					//parentTask.listRetrieveId.addAllAt(_currentRequestIds,0);				
					restoreRequest();
					_page++;
					doRequest();
				}
				
			}
		}
	}
}