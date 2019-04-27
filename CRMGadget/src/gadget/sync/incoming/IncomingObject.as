package gadget.sync.incoming {
	import flash.utils.getQualifiedClassName;
	
	import gadget.dao.DAOUtils;
	import gadget.util.ObjectUtils;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class IncomingObject extends WebServiceIncoming {
		private var _listRetrieveId:ArrayCollection = new ArrayCollection();
		
		
		public function IncomingObject(entity:String) {
			super(entity);
			if (entity == "Contact") {
				ignoreFields.push("CurrencyCode", "ContactFullName");
			}
			
			
//			if (entity == "Activity") {
//				ignoreQueryFields.push("Owner");
//			}			
		}
		
		
		
		

		
		
		public function get listRetrieveId():ArrayCollection
		{
			return _listRetrieveId;
		}

		public function set listRetrieveId(listObj:ArrayCollection):void
		{
			this._listRetrieveId = listObj;
		}

		protected override function canSave(incomingObject:Object,localRec:Object=null):Boolean{
			
			listRetrieveId.addItem(incomingObject);
			
			
			return true;
		}

		override protected function getInfo(xml:XML, ob:Object):Object {
			if (entityIDour == "Contact") {
				ob.picture = null;
			}
			return {
				rowid:ob[DAOUtils.getOracleId(entityIDour)],
				name:ObjectUtils.joinFields(ob, DAOUtils.getNameColumns(entityIDour))
			};
		}
		
		override protected function initOnce():void {
			if (entityIDour == "User") {
				withFilters	= false;
			}
			super.initOnce();
		}
		
		override public function getMyClassName():String {
			return getQualifiedClassName(this) + entityIDour;
		}
		
		
		
		
	}
}
