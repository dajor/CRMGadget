package gadget.sync.incoming
{
	import flash.utils.Dictionary;
	
	import gadget.dao.ActivityDAO;
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.sync.task.TaskParameterObject;
	import gadget.util.FieldUtils;
	import gadget.util.Hack;
	import gadget.util.ObjectUtils;
	import gadget.util.Relation;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class IncomingSubActivity extends IncomingSubobjects {
		
		public function IncomingSubActivity(entity:String,subid:String = "Activity") {
//			noPreSplit = true;
//			linearTask = true;
//			if (linearTask)	Hack("linearTask still true, perhaps make it false?");
			super(entity, subid);
			//ignoreQueryFields.push("Owner");
		}

		override protected function getInfo(xml:XML, ob:Object):Object {
			
			
			return { rowid:ob[DAOUtils.getOracleId(subIDour)], name:ObjectUtils.joinFields(ob, DAOUtils.getNameColumns(subIDour)) }
			
		}
		override public function set param(p:TaskParameterObject):void
		{			
			super.param = p;
			if( p.fullCompare){
				isUsedLastModified = false;
			}
			
		}
		
		override protected function getSubSerachSpec():String{
			var criteria:String = super.getSubSerachSpec();
			if(subIDour==Database.activityDao.entity){			
				var searchFilter:String =getSearchFilterCriteria(subIDour);
				if(!StringUtils.isEmpty(searchFilter)){
					if(StringUtils.isEmpty(criteria)){
						criteria = searchFilter;
					}else{
						criteria = searchFilter +" AND ("+criteria+")";
					}
				}
			}
			return criteria;
		}
		
		override protected function canSave(incomingObject:Object,local:Object=null):Boolean{
			var obj:Object = Database.transactionDao.find(subIDour);
			if(StringUtils.isEmpty(obj.parent_entity)){
				return true;
			}
			var relation:Object = Relation.getRelation(obj.parent_entity,subIDour);
			if(relation!=null){
				var parentId:String=incomingObject[relation.keySrc];
				if(!StringUtils.isEmpty(parentId)){
					var parentObject:Object = Database.getDao(obj.parent_entity).findByOracleId(parentId);
					
					return parentObject!=null;
				}
			}
			
			return false;
			
		}
		
		
		override protected function getFields(alwaysRead:Boolean=false):ArrayCollection{
			return FieldUtils.allFields(subIDsod,alwaysRead);
		}
		override protected function doGetParents():ArrayCollection{
			var parentDao:BaseDAO = Database.getDao(entityIDour,false);
			if(parentDao!=null){
				return parentDao.findAllIds();
			}
			return new ArrayCollection();
		}
		
		override protected function initXMLsub(baseXML:XML, qapp:XML):void {
			var qsublist:QName=new QName(ns1.uri,subList), qsub:QName=new QName(ns1.uri,subIDns);
			qapp = qapp.child(qsublist)[0].child(qsub)[0];			
			var ignoreFields:Dictionary = dao.incomingIgnoreFields;
			var hasActivityParent:Boolean = false;
			for each (var field:Object in Database.fieldDao.listFields(subIDsod)) {
				if (!ignoreFields.hasOwnProperty(field.element_name) && ignoreQueryFields.indexOf(field.element_name)<0) {
					if(field.element_name == ActivityDAO.PARENTSURVEYID){
						hasActivityParent = true;
					}
					qapp.appendChild(new XML("<" + WSProps.ws10to20(subIDsod, field.element_name) + "/>"));
				}
			}
			
			if(subIDour==Database.activityDao.entity && !hasActivityParent){
				qapp.appendChild(new XML("<" + WSProps.ws10to20(subIDsod, ActivityDAO.PARENTSURVEYID) + "/>"));
			}
		}
	}
}
