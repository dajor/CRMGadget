package gadget.sync.task
{
	import gadget.dao.DAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.service.SupportService;
	import gadget.util.Relation;
	
	import mx.collections.ArrayCollection;
	
	public class ReferenceUpdater
	{
		public function ReferenceUpdater()
		{
		}
		
		/**
		 * Function that update references to an entity after it has been successfully synced,
		 * and replace everywhere the #gadget_id identifier with the real CRMOD identifier.
		 * This works for main tables and m-n relationship tables. 
		 * @param entity Referenced entity.
		 * @param previousId Old identifier (#gadget_id).
		 * @param nextId New identifier (from CRMOD).
		 * 
		 */
		public static function updateReferences(entity:String, previousId:String, nextId:String):void {
			var relations:ArrayCollection = Relation.getReferencers(entity);
			var subRelation:ArrayCollection = Relation.getMNReferenced(entity);
			//relations.addAll(subRelation);
			
			var relation:Object;
			
			for each(relation in subRelation){
				
				if (relation.keySupport == DAOUtils.getOracleId(entity)) {
					var subDao:gadget.dao.SupportDAO = SupportRegistry.getDao(relation.supportTable) as gadget.dao.SupportDAO;
					subDao.updateReference(relation.keySupport, previousId, nextId);
				}
				
			}
			
			for each (relation in relations) {
				if (relation.keyDest == DAOUtils.getOracleId(entity)) {
					if (relation.supportTable) {
						var supportDAO:gadget.dao.SupportDAO = SupportRegistry.getDao(relation.supportTable) as gadget.dao.SupportDAO;
						supportDAO.updateReference(relation.keySupport, previousId, nextId);
					} else {
						var srcDAO:DAO = Database.getDao(relation.entitySrc);
						srcDAO.updateReference(relation.keySrc, previousId, nextId);
					}
				}
			}
		}

	}
}