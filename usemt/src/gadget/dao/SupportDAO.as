

package gadget.dao
{
	import flash.data.SQLConnection;
	
	import gadget.util.OOPS;
	import gadget.util.ObjectUtils;
	import gadget.util.StringUtils;

	public class SupportDAO extends BaseDAO {

		///////////////////////////////////////////////////////////////
		// These are typo savers for COLUMN definitions.
		// The type names correspond with GUIUtils.
		///////////////////////////////////////////////////////////////

		// QUIRX: If a column must be hidden, because it is not in the WSDL,
		// start it with a dot (.).  The dot will be removed.
		//
		// AM Shouldn't the type be handled outside, in FieldUtils ?
		// I did not moved it because I don't know if the DB stuff uses it.
		//
		protected static function ID(id:String, disp:String=null):Object { return {name:id, type:"ID", disp:disp} };
		protected static function TEXT(field:String, disp:String=null):Object { return {name:field, type:"Text (Long)", disp:disp} };
		protected static function LIST(field:String, disp:String=null):Object { return {name:field, type:"Picklist", disp:disp} };
//		protected static function SHORT(field:String, disp:String=null):Object { return {name:field, type:"Text (Short)", disp:disp} };
		protected static function TIME(field:String, disp:String=null):Object { return {name:field, type:"Date/Time", disp:disp} };
		protected static function PHONE(field:String, disp:String=null):Object { return {name:field, type:"Phone", disp:disp} };
		protected static function NUMBER(field:String, disp:String=null):Object { return {name:field, type:"Number", disp:disp} };
		protected static function CURRENCY(field:String, disp:String=null):Object { return {name:field, type:"Currency", disp:disp} };
		protected static function INTEGER(field:String, disp:String=null):Object { return {name:field, type:"Integer", disp:disp} };
		protected static function CHECKBOX(field:String, disp:String=null):Object { return {name:field, type:"Checkbox", disp:disp} };
//		protected static function DATE(field:String):Object { return {name:field, type:"Date"} };
		protected static function xPICK(field:String, id:String, destName:String=null, disp:String=null, destEntity:String=null, destKey:String=null):Object {
			return field;	// This is a quickly switched off PICK
		}
		// field: Name of the field in THIS DAO
		// id: Id-Field in THIS DAO which relates to this field
		// destName: If different from field, name of the field in the DESTINATION DAO
		// disp: Display String (usually empty)
		// destEntity: DESTIONATION DAO, defaults to #th DAO of the #th id in the structure
		// destKey: DESTIONATION DAO Id Field name, defaults to OracleId of destEntity 
		protected static function PICK(field:String, id:String, destName:String=null, disp:String=null, destEntity:String=null, destKey:String=null):Object {
			// determined from the ID
			if (destEntity=='')
				destEntity = null;
			// these are autoguessed if missing
			if (disp=='')
				disp = null;
			if (destKey=='')
				destKey = null;
			if (destName=='')
				destName = null;
			return {name:field, type:"Picklist", id:id, disp:disp, dest:destEntity, key:destKey, field:destName};
		}


		protected override function getIndexColumns():Array{
			return ["deleted", "local_update" ];			
			
		}

		///////////////////////////////////////////////////////////////
		// Private data and initializers
		///////////////////////////////////////////////////////////////
		private var _all:Object;
		private var _rel:Object;
		private var _cols:Array, _hiddencols:Array;
		private var _relation:Object;
		private var _colsOut:Array;
		protected var _isSyncWithParent:Boolean = true;
		protected var _isGetField:Boolean = false;
		protected var _isSelectAll:Boolean = false;
		private static const GUESSMAP:Object = {
			Boolean:CHECKBOX,
			Integer:INTEGER,
			Currency:CURRENCY,
			Number:NUMBER,
			Phone:PHONE,
			Date:TIME
		};
		
		public function get isSelectAll():Boolean{
			return _isSelectAll;
		}
		public function get isGetField():Boolean{
			return _isGetField;
		}

		public function get isSyncWithParent():Boolean{
			return _isSyncWithParent;
		}
		public function get all():Object {
			return _all;
		}

		public function get rel():Object {
			return _rel;
		}
		
		public function get relation():Object {
			return _relation;
		}

		
		public function getPluralName():String{
			return entity;
		}

		// This routine is too long
		private function init_registry(rel:Object):void {
			var me:String = entity;		// entity is a getter, needs this.rel
			SupportRegistry.init_registry(me, this);

			// Create the column information
			// This also populates all the other column related things
			_cols = [];
			_colsOut = [];
			_hiddencols = [];
			_relation = {};
			
			_all = {};

			
			for each (var o:Object in rel.columns) {
				var ob:Object = o;
				if (ob is String) {
					var s:String = ob as String;
					
					// try to auto-guess
					for (var guess:String in GUESSMAP) {
						if (s.indexOf(guess)>0) {
							ob = GUESSMAP[guess](s);
							break;
						}
					}
					
					// Are we still ouf of clues?
					if (ob is String) {
						ob = TEXT(s);
					}
				}

				ob.hide = (ob.name.substr(0,1)=='.');
				if (ob.hide) {
					ob.name = ob.name.substr(1);
				}
			
				if (ob.name in _all)
					throw Error("duplicate columns in "+me+": "+ob.name)
				_all[ob.name] = ob;
			}
			// Populate the related columns which are given implicitely
			// if not already specified manually.
			for each (ob in rel.columns) {
				if ("id" in ob) {
					var id:String = ob.id.replace(/^\./,"");
					if (!(id in _all)) {
						_all[id] = ID(id);	// ID must be defined as hidden, else it is created!
					}
					if (ob.dest==null || ob.dest=='') {
						// Autoguess the entity.
						// The entity of ID field rel.id[i] can be found at rel.entity[i]
						ob.dest = rel.entity[rel.id.indexOf(id)];
						if (!ob.dest)
							ob.dest = id.substr(0,id.length-2);
						if (DAOUtils.getNameColumns(ob.dest)==null)
							throw Error("cannot guess relation "+ob.name+" using "+ob.id);
					}
					// Create a record suitable for gadget.util.Relation
					//	{entitySrc:"Activity.Product", keySrc:"ProductId", keyDest:"ProductId", labelSrc:"Product", labelDest:"Name", entityDest:"Product"},
					//VAHI ({ is a hack to get a proper indent.
					// Note that the NULL columns are automagically populated by DAOUtils
					_relation[ob.name] = ({
						entitySrc: me,			// Required
						keySrc: ob.id,			// Required
						keyDest: ob.key,		// if null autoguessed in DAOUtils from entityDest
						labelSrc: [ob.name],		// Required
						labelDest: [ob.field],	// if null autoguessed in DAOUtils from entityDest
						entityDest: ob.dest		// Required
					});
				}
			}
			// Now loop through the objects and build what we want
			for each (ob in _all) {
				if (ob.hide) {
					_hiddencols.push(ob.name);
				} else {
					_cols.push(ob.name);
					if (!("id" in ob))
						_colsOut.push(ob.name);
				}
			}
		}

		///////////////////////////////////////////////////////////////
		// Constructor
		///////////////////////////////////////////////////////////////

		public function SupportDAO(work:Function, conn:SQLConnection, rel:Object, struct:Object=null) {
			this._rel = rel;


			init_registry(rel);
			
			// Prepare the struct for BaseDAO,
			if (!struct)
				struct = {};
			if (!struct.columns)
				struct.columns = {};
			struct.columns.TEXT = _cols.concat(_hiddencols);
			
			// Fill in defaults if not already defined.
			if (!struct.table)
				struct.table = rel.entity.join("_").toLowerCase();
			if (!struct.display_name)
				struct.display_name = rel.entity.join(".");
			if (!struct.oracle_id)
				struct.oracle_id = "Id";
			if (!struct.name_column)
				struct.name_column = [ struct.oracle_id ];
			
			// Set the standard indexes 
			struct.index = rel.id.concat(struct.index ? struct.index : []);
			struct.unique = [].concat((struct.unique ? struct.unique : []), struct.oracle_id );

			super(work, conn, struct);
		}
		
		
		
		public function deleteByChildId(parentId:String,childId:String):void{
			deleteByOracleId(childId);
		}

		///////////////////////////////////////////////////////////////
		// BaseDAO overrides
		///////////////////////////////////////////////////////////////

		override public final function get entity():String {
			if (_rel==null)
				return null;
			return _rel.entity.join(".");
		}
		

		

		public function getCols():Array {
			return _cols;
		}

		public function getColsOutgoing():Array {
			return _colsOut;
		}

		public function getSubOracleId(nr:int):String {
			return _rel.id[nr];
		}

		public function getSubEntity(nr:int):String {
			return _rel.entity[nr];
		}

		public function getSodSubName():String {
			return _rel.sodName ? _rel.sodName : _rel.entity[1];
		}

		public function getRecordsBySubId(ob:Object):Array {
			var ok:Boolean = false;
			for (var id:String in ob) {
				ok = true;
				if (_rel.id.indexOf(id)<0)
					throw new Error("Unknown ID in query: "+id);
			}
			if (!ok) {
				throw new Error("No ID in query object");
			}
			return b_fetch(ob);
//			return b_columns(cols, ob);
		}

		public function sub_exists(object:Object):Boolean {
			OOPS("=missing","sub_exists not supported currently");
			return false;
		}

		public function sub_insert(ob:Object):void {
			OOPS("=check","sub_insert not yet tested");
			var rec:Object = {
//				deleted:false,
//				error:false,
//				uppername:"",
				local_update:true
			};
			for each (var s:String in _rel.id) {
				rec[s] = ob[s];
			}
			super.insert(rec);
		}

		public function sub_delete(object:Object):void {
			OOPS("=missing","sub_delete not supported currently");
		}

		public function getLayoutFields():Array{
			return new Array();
		}
		override public function getOwnerFields():Array{
			return new Array();
		}

	}
}
