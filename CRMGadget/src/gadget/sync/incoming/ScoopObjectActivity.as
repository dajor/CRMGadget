package gadget.sync.incoming
{
	import gadget.dao.BaseDAO;
	import gadget.dao.Database;

	public class ScoopObjectActivity extends IncomingScoopSubobject {
		
		public function ScoopObjectActivity(entity:String) {
			linearTask = true;
			super(entity, "Activity");
		}

		override protected function getInfo(xml:XML, ob:Object):Object {
			
			
			return { rowid:ob.ActivityId, name:ob.Subject }
			
		}
	}
}
