package gadget.sync.incoming
{
	
	
	import flash.errors.SQLError;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.task.TaskParameterObject;
	import gadget.util.ObjectUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	public class IncomingRelationObject extends IncomingObject
	{
		
		protected var _parentTask:IncomingObject;
		protected var _parentRelationField:Object;
		protected var _dependOnParent:Boolean = false;
		
		protected var _currentRequestIds:ArrayCollection;
		protected var _readParentIds:Boolean = true;
		protected var _existRetrieved:Dictionary = null;
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
		}
		
		override public function set param(p:TaskParameterObject):void
		{			
			super.param = p;
			//bug#8990
			if(p.fullCompare && entityIDour==Database.accountDao.entity){
				_readParentIds = true;
				_dependOnParent = true;
			}
			
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
		
		
		
		protected override function canSave(incomingObject:Object):Boolean{
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
		
		
		override protected function doRequest():void {		
			//if(!dependOnParent){
				var count:int = Database.getDao(entityIDour).count();					
				if(_readParentIds &&(count<=0 ||dependOnParent)){
					_readParentIds= false;
					_dependOnParent = true;
					
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
				}
				
			//}
			if( dependOnParent && (parentTask.listRetrieveId.length<=0)){
				super.nextPage(true);
			}else{
				
				super.doRequest();
			}
		}
		
		override public function stop():void
		{
			if(_dependOnParent){
				//keep the dependon as true when user cancel while syncing
				Database.incomingSyncDao.unsync_one(getEntityName(),getMyClassName());
			}
			super.stop();
		}
		
		
		protected override function generateSearchSpec(byModiDate:Boolean=true):String{		
			
			this.isUnboundedTask = true;
			if(!dependOnParent){
				return super.generateSearchSpec();
			}else{				
				var first:Boolean = true;
				var searchProductSpec:String = "";
				var maxIndex:int = Math.min(pageSize,(parentTask.listRetrieveId.length));
				_currentRequestIds=new ArrayCollection();
				for(var i:int=1;i<=maxIndex;i++){
					
					var parentObj:Object = parentTask.listRetrieveId.removeItemAt(0);
					if(parentObj==null){
						continue;
					}
					_currentRequestIds.addItem(parentObj);
					if(!first){
						searchProductSpec=searchProductSpec+" OR ";
					}
					searchProductSpec=searchProductSpec+"["+parentRelationField.ParentRelationId+"] = \'"+parentObj[DAOUtils.getOracleId(parentTask.entityIDour)]+'\'';
					if(!StringUtils.isEmpty(parentRelationField.ChildRelationId) && parentObj.hasOwnProperty(parentRelationField.ChildRelationId)){
						var thisId:String = parentObj[parentRelationField.ChildRelationId];	
						if(!StringUtils.isEmpty(thisId) && !_existRetrieved.hasOwnProperty(thisId)){							
							searchProductSpec=searchProductSpec+" OR ";
							searchProductSpec=searchProductSpec+"[Id]=\'"+thisId+"\'";
							this._existRetrieved[thisId] = thisId;
							
						}
					}
									
					first = false;
				}			
				
				var superCriteria:String = super.generateSearchSpec(startTime!=-1);
				if(StringUtils.isEmpty(superCriteria)){
					superCriteria=searchProductSpec;
				}else{
					superCriteria+=' AND ('+searchProductSpec+')';
				}
				
				return superCriteria;
			}
		}
		
		protected function restoreRequest():void{
			if(dependOnParent){
				parentTask.listRetrieveId.addAllAt(_currentRequestIds,0);
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
			if(!notRretry || mess.indexOf("SBL-DBC-00112")!=-1){
				notRretry = false;
				restoreRequest();
			}
			return notRretry;
		}
		
		
		
		protected override function nextPage(lastPage:Boolean):void {
			if(!dependOnParent){
				super.nextPage(lastPage);
			}else{
				showCount();
				if(lastPage){
					if(parentTask.listRetrieveId.length<=0){						
						super.nextPage(true);
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