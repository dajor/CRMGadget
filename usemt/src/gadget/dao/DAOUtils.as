package gadget.dao
{
	import gadget.service.UserService;
	import gadget.util.OOPS;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class DAOUtils
	{
		//VAHI added for future autolearning of structures
		private static var structures:Object = {};
		public static function register(entity:String, structure:Object):void {
			if (structure!=null)
				structures[entity]=structure;
		}
		
		public static function getStructure(entity:String):Object {
			return entity in structures ? structures[entity] : {};
		}

		/**
		 * Returns the CRMOD's entity name based on Gadget internal entity name.
		 * <code>Account</code> will return <code>Account</code>.
		 * <code>Activity.Product</code> will return <code>Call ProdDetail</code>.
		 * This uses the property <code>record_type</code> that is defined in DAOs. 
		 * @param entity Gadget's entity name.
		 * @return Entity name to use with CRMOD's services.
		 * 
		 */
		public static function getRecordType(entity:String):String {
			var rt:String = getStructure(entity).record_type;
			return rt ? rt : entity;
		}
		
		
		public static function getTable(entity:String):String {
			if (entity in structures) {
				return structures[entity].table;
			}
			return null;
		}
		
		public static function getEntityByRecordType(recordType:String){
			for(var e:String in structures){
				var s:Object = structures[e];					
				if(!StringUtils.isEmpty(s.record_type) && s.record_type==recordType){
					return e;
				}
			}
			
			return recordType;
			
		}
		
		public static function getEntity(table:String):String {
			for (var entity:String in structures) {
				if (structures[entity].table == table) {
					return entity;
				}
			}
			return null;
		}
		
		
		public static function getOracleId(entity:String):String {
			if (entity in structures){
				return structures[entity].oracle_id;
			}else{
				for(var e:String in structures){
					var s:Object = structures[e];					
					if(!StringUtils.isEmpty(s.record_type) && s.record_type==entity){
						return s.oracle_id;
					}
				}
			}
			
			
			return null;
		}
		

		
		
		public static function getNameColumns(entity:String):Array {
			if (entity in structures)
				return structures[entity].name_column;
			return null;
		}

		
		public static function getSearchColumns(entity:String):Array {
			var searchColumns:Array = [];			
			if (entity in structures && structures[entity].search_columns) {
				for (var i:int = 0; i < structures[entity].search_columns.length; i++) {
					searchColumns = searchColumns.concat(BaseDAO.getUppernameCol(i));
				}
			}
			return searchColumns;
		}
		
		public static function getUpperColumn(entity:String):String {
			var cols:Array = getNameColumns(entity);
			return cols[cols.length - 1];
		}
		
		public static function getNameColumn(entity:String, prefix:String = ""):String {
			var cols:Array = getNameColumns(entity);
			var s:String = "";
			for each (var col:String in cols) {
				if (s.length > 0) {
					s += "||' '||";
				}
				s += prefix + col;
			}
			return s;
		}
		
		public static function getNameForSearch(entity:String):String {
			var s:String = getNameColumn(entity);
			if ( entity == "Account") {
				// s += "|| CASE WHEN primaryShipToCity IS NOT NULL THEN ' (' || primaryShipToPostalCode || ' ' || primaryShipToCity || ')' WHEN primaryBillToCity IS NOT NULL THEN ' (' || primaryBillToPostalCode || ' ' || primaryBillToCity || ')' ELSE '' END";
				// Change Request #450
				s += "||  CASE WHEN Location IS NOT NULL THEN ' (' || Location || ')' ELSE '' END";
			}else if ( entity == "Contact") {
				// s += "|| CASE WHEN primaryShipToCity IS NOT NULL THEN ' (' || primaryShipToPostalCode || ' ' || primaryShipToCity || ')' WHEN primaryBillToCity IS NOT NULL THEN ' (' || primaryBillToPostalCode || ' ' || primaryBillToCity || ')' ELSE '' END";
				// Change Request #450
				s += "||  CASE WHEN ContactType IS NOT NULL THEN ' (' || ContactType || ')' ELSE '' END";
			}
			return s;
		}
		
		
		public static function getNameColumnFilter(entity:String, name:String):String {
			var cols:Array = getNameColumns(entity);
			var s:String = "(";
			for each (var col:String in cols) {
				if (s.length > 1) {
					s += " OR ";
				}
				s += col + " LIKE '" + name + "%'";
			}
			s += ")";
			return s;
		}

		public static function getAttachmentForObject(entity:String, object:Object):ArrayCollection{
//			var gadget_id:String = "";
//			var oracle_id:String = object[getOracleId(entity)];
//			if(StringUtils.startsWith(oracle_id, "#")){
//				gadget_id = oracle_id.substr(1);
//			}else{
//				gadget_id = object.gadget_id;
//			}			
			return Database.attachmentDao.findAttachments(entity, object.gadget_id);
		}



		
		/** This fakes a Relation.getFieldRelation() for SupportDAO types.
		 */
		public static function fakeGetFieldRelation(entity:String, field:String):Object {
			var rel:Object = SupportRegistry.getRelation(entity, field);
			if (rel==null)
				return null;
			if (rel.keyDest==null)
				rel.keyDest = getOracleId(rel.entityDest);
			if (rel.labelDest==null)
				rel.labelDest = rel.labelSrc;	//ContactFirstName -> ContactFirstName etc. 
			return rel;
		}


	}
}