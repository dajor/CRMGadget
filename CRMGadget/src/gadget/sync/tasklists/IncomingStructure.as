package gadget.sync.tasklists
{
	import avmplus.getQualifiedClassName;
	
	import flash.utils.Dictionary;
	
	import gadget.dao.Database;
	import gadget.service.UserService;
	import gadget.sync.incoming.ColoplastIncomingWithoutMD;
	import gadget.sync.incoming.IncomingObject;
	import gadget.sync.incoming.IncomingRelationObject;
	import gadget.util.Relation;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class IncomingStructure
	{
		protected var levelTask:Dictionary = new Dictionary();
		//private var _listNotDependOn:Array=new Array();
		
		public function IncomingStructure(addUser:Boolean=true)
		{  
			if(addUser){
				//always read users
				addTask(createParentProcess(Database.allUsersDao.entity));
			}
		}

		
		public function addTask(incomingTask:IncomingObject,level:int=0):void{
			if(incomingTask!=null){
				var listLevel:Array = levelTask[level] as Array;
				if(listLevel==null){
					listLevel = new Array();
					levelTask[level]=listLevel;
				}
				
				listLevel.push(incomingTask);
			}
		}
		/**
		 * return list of list task
		 * */
		public function getTaskAllLevel():ArrayCollection{
			var result:ArrayCollection = new ArrayCollection();
			var lev:int =0;
			var listLevel:Array;
			for(lev=0;;lev++){
				listLevel = levelTask[lev] as Array;
				if(listLevel==null){
					break;
				}else{
					result.addItem(listLevel);
				}
				
			}
			
			//level of co11
			for(lev=99;;lev++){
				listLevel = levelTask[lev] as Array;
				if(listLevel==null){
					break;
				}else{
					result.addItem(listLevel);
				}
			}
			
			
			
			return result;
		}
		
//		public function addNotDependOn(incomingTask:IncomingObject):void{
//			if(incomingTask!=null){
//				_listNotDependOn.push(incomingTask);
//			}
//		}
		
		public function buildStructure(enablesTrans:ArrayCollection,dependOn:Boolean):void{
			var mapDependOn:Object = new Object();
			var listNotDepentOn:ArrayCollection = new ArrayCollection();
			for each(var obj:Object in enablesTrans){
				if(UserService.getCustomerId()==UserService.COLOPLAST  && obj.entity==Database.customObject7Dao.entity){
					//when we do full sync we sync co7 depend on activity,oppt and co11
					continue;
				}
				if(StringUtils.isEmpty(obj.parent_entity)){
					listNotDepentOn.addItem(obj);
				}else{
					var listDependOn:ArrayCollection = mapDependOn[obj.parent_entity];
					if(listDependOn==null){
						listDependOn = new ArrayCollection();
						mapDependOn[obj.parent_entity]=listDependOn;
					}
					listDependOn.addItem(obj);
				}
			}
			//colplast need to wait workflow executing
			var co11:Object = null;
			for each(var parent:Object in listNotDepentOn){
				if(parent.entity==Database.customObject11Dao.entity){
					co11 = parent;
				}else{
					var parentTask:IncomingObject = createParentProcess(parent.entity);
					parentTask.checkinrange = parent.checkinrange;
					this.addTask(parentTask);				
					buildChildObject(mapDependOn,parentTask,parent.entity,1,dependOn);
				}
			}
			if(co11!=null){
				var co11Task:IncomingObject = createParentProcess(co11.entity);
				co11Task.checkinrange = co11.checkinrange;
				this.addTask(co11Task,99);				
				buildChildObject(mapDependOn,co11Task,co11.entity,100,dependOn);
			}
			
		}
		
		protected function createParentProcess(entity:String):IncomingObject{
			if(UserService.getCustomerId()==UserService.COLOPLAST && entity==Database.customObject13Dao.entity){
				//bug#10703
				return new ColoplastIncomingWithoutMD(entity);
			}
			return new IncomingObject(entity);
		}
		protected function createProcess(entity:String,parentTask:IncomingObject,pFields:Object,dependOn:Boolean=true):IncomingRelationObject{
			return new IncomingRelationObject(entity,parentTask,pFields,dependOn)
		}
		
		protected function buildChildObject(mapDependOn:Object,parentTask:IncomingObject,parentEntity:String,level:int,dependOn:Boolean):void{
			var listChild:ArrayCollection = mapDependOn[parentEntity];
			if(listChild!=null && listChild.length>0){
				for each(var child:Object in listChild){
					var relation:Object = Relation.getRelation(child.entity,parentEntity);
					var childRelation:Object = Relation.getRelation(parentEntity,child.entity);
					var childTask:IncomingObject = null;
					var objParentField:Object = new Object();
					if(childRelation!=null){
						objParentField.ChildRelationId=childRelation.keySrc;
					}
					if(relation!=null){
						objParentField.ParentRelationId=relation.keySrc;
					}
					
					if(!dependOn){
						var lastSyncObj:Object = Database.lastsyncDao.find(getQualifiedClassName(IncomingRelationObject)+child.entity);
						if(lastSyncObj!=null && lastSyncObj.sync_date!='01/01/1970 00:00:00'){
							childTask = createProcess(child.entity,parentTask,objParentField,false);							
						}else{
							childTask = createProcess(child.entity,parentTask,objParentField,true);							
						}
					}else{
						childTask = createProcess(child.entity,parentTask,objParentField,true);
						
					}
					childTask.checkinrange = child.checkinrange;
					this.addTask(childTask,level);
					var list:ArrayCollection = mapDependOn[child.entity];
					if(list!=null && list.length>0){
						buildChildObject(mapDependOn,childTask,child.entity,(level+1),dependOn);
					}
				}
			}
		}

		
	}
}