package gadget.dao
{
	import gadget.util.ObjectUtils;

	public class SupportRegistry
	{
		public function SupportRegistry()
		{
		}
		
		///////////////////////////////////////////////////////////////
		// Static interface
		///////////////////////////////////////////////////////////////
		
		private static var register:Object = {};
		private static var subRegister:Object = {};
		
		/** Get a SupportDAO from it's name a.b
		 */
		public static function getDao(entity:String):SupportDAO {
			return register[entity];
		}
		
		public static function getSupportDao(...args):SupportDAO {
			return getDao(args.join("."));
		}		
		
		
		public static function getSubObjects(...args):Array {
			return getSub(args.join("."));
		}
		
		
		/** Get all sub-objects as list of strings.
		 * For 'Activity' this is ['Product', 'User', 'Contact']
		 * Might become more in future.
		 */
		private static function getSub(entity:String):Array {
			//			if (entity=="Activity") return ['Product'];		OLD TESTS
			return subRegister[entity];
		}
		
		public static function allEntities():Array {
			return ObjectUtils.keys(register);
		}
		
		/**
		 * Returns all of the entity's fields. Used for finding display names. 
		 * @param entity Entity to consider.
		 * @return All the entity fields.
		 * 
		 */
		public static function allFields(entity:String):Object {
			return register[entity].all;
		}
		
		// fakes Relation.getFieldRelation()
		public static function getRelation(entity:String, field:String):Object {
			return register[entity].relation[field];
		}
		

		
		public static function init_registry(entity:String, dao:SupportDAO):void {
			register[entity] = dao; 
			
			// Populate list of subobjects
			// This already is prepared for future,
			// when we might have more a.b.c relations:
			// registers a=b.c and a.b=c
			var ent:Array = dao.rel.entity;
			for (var i:int = ent.length; --i>0; ) {
				var sub:String = ent.slice(0,i).join(".");
				if (!( sub in subRegister ))
					subRegister[sub] = [];
				subRegister[sub].push(ent.slice(i).join("."));
			}
		}
	}
}