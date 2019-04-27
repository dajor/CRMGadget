package gadget.sync.incoming {
	import flash.errors.SQLError;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.util.ObjectUtils;
	
	import mx.collections.ArrayCollection;

	public class IncomingObjectPerId extends IncomingRelationObject {
		
		private var _ids:Array;
		private var mapIds:Dictionary;
		
		public function IncomingObjectPerId(entity:String, parentTask:IncomingObject=null, parentFieldIds:Object=null) {
			super(entity,parentTask,parentFieldIds,false);
			if (entity == "Contact") {
				ignoreFields.push("CurrencyCode", "ContactFullName");
			}
			this._dependOnParent = false;

		}
		override protected function canSave(incomingObject:Object):Boolean{
			var save:Boolean = super.canSave(incomingObject);
			delete mapIds[incomingObject[DAOUtils.getOracleId(entityIDour)]];
			return save;
		}
//		override protected function getInfo(xml:XML, ob:Object):Object {
//			if (entityIDour == "Contact") {
//				ob.picture = null;
//			}
//			return {
//				rowid:ob[DAOUtils.getOracleId(entityIDour)],
//				name:ObjectUtils.joinFields(ob, DAOUtils.getNameColumns(entityIDour))
//			};
//		}
		
		override protected function tweak_vars():void {
			if (entityIDour == "User") {
				withFilters	= false;
			}
		}
		
		override public function getMyClassName():String {
			return getQualifiedClassName(this) + entityIDour;
		}
		
		override protected function doRequest():void {
			
			if (_page*pageSize>=_ids.length) {
				successHandler(null);
				return;
			}
			
			var subList:Array = _ids.slice(_page*pageSize, _page*pageSize+pageSize);			
			var searchSpec:String = "";
			for each (var id:String in subList) {
				if (searchSpec.length > 0) {
					searchSpec += " OR ";
				}
				searchSpec += "([Id] = '" + id + "')";
			}				
			
			trace("::::::: REQUEST_PER_ID ::::::::", getEntityName(), _page, isLastPage, haveLastPage, searchSpec);
//			Database.errorLoggingDao.add(null, {trace:[getEntityName(), _page, isLastPage, haveLastPage, searchSpec]});
			//VAHI another poor man's workaround for missing late binding in XML templates
			sendRequest("\""+getURN()+"\"", new XML(getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, 0)
				.replace(SEARCHSPEC_PLACEHOLDER, searchSpec)
			));
		}
		
		override protected function initOnce():void {
			initXML(stdXML);
			mapIds = Database.modificationTrackingDao.getTestIdsByEntity(entityIDour);
			_ids=[];
			for(var id:String in mapIds) {
				if (_ids.indexOf(id) == -1) {
					_ids = _ids.concat(id);
				}
			}
		}
		
		
		
		override public function done():void{
			if(mapIds!=null){
				try{
					Database.begin();				
					for(var oraId:String in mapIds){
						dao.deleteByOracleId(oraId);
						//delete record not exist in the g2g
						Database.modificationTrackingDao.deleteByParentId({'ObjectId':oraId,'ObjectName':entityIDour});
					}
					Database.commit();
				}catch(e:SQLError){
					Database.rollback();
					//nothing todo
				}
			}
		}
	}
}
