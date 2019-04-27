//VAHI Generic baseclass to support some internal intermediate tables

package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import gadget.util.ObjectUtils;
	import gadget.util.StringUtils;
	import gadget.util.TableFactory;

	public class SimpleTable extends BaseSQL {

		protected var stmt:SQLStatement;
		protected var _struct:Object;
		private var stmtSelectLastRecord:SQLStatement;
		public function SimpleTable(conn:SQLConnection, work:Function, structure:Object):void {
			_struct	= structure;

			// sanity checks
			check("table","String");
			if (!("columns" in _struct))
				_struct.columns = { 'TEXT':getColumns() };
			check("columns","Object");
			check_if("index","Array", "String");
			check_if("unique","Array", "String");

			TableFactory.create(work, conn, structure,getSpecial());

			stmt				= new SQLStatement();
			stmt.sqlConnection	= conn;
			
			stmtSelectLastRecord = new SQLStatement();
			stmtSelectLastRecord.sqlConnection = conn;
			stmtSelectLastRecord.text = "SELECT * FROM "+structure.table+" ORDER BY gadget_id desc limit 1";
		}
		
		protected function getSpecial():Object{
			return null;
		}

		private function check(entry:String, type:String, subtype:String=null):void {
			if (!(entry in _struct))
				throw new Error("table structure error: missing "+entry);
			var t:String = ObjectUtils.type(_struct[entry]);
			if (type!=t)
				throw new Error("table structure error: datatype "+t+" of "+entry+" must be "+type);
			if (subtype!=null) {
				for each (var ent:Object in _struct[entry]) {
					if (ObjectUtils.type(ent)!=subtype)
						throw new Error("table structure error: datatype of "+entry+" must be "+type+" of "+subtype);
				}
			}
		}
		
		private function check_if(entry:String, type:String, subtype:String=null):void {
			if (entry in _struct && _struct[entry]!=null)
				check(entry, type, subtype);
		}
		
		protected function runSQL(query:String, where:String, params:Object, order:String, limit:String,offset:String=null):void {
			stmt.clearParameters();
			if (params)
				for (var p:String in params){
					if (p == 'mx_internal_uid'){
						delete params[p];
						continue;
					} 
					stmt.parameters[':'+p]	= params[p];
				}
			if (params!=null && where==null)
				where = andEqualsWhere(params);
			stmt.text = query + " " + (where ? where : "") + (order ? " ORDER BY "+order : "") + (limit ? " LIMIT "+limit : "")+(offset?" OFFSET "+offset:"") + ";";
			exec(stmt);
		}
		
		protected function select_order(vars:String, where:String, params:Object, order:String, limit:String):Array {
			runSQL("SELECT "+vars+" FROM "+_struct.table, where, params, order, limit);
			return stmt.getResult().data;
		}

		protected function select(vars:String, where:String=null, params:Object=null, limit:String=null):Array {
			return select_order(vars, where, params, null, limit);
		}

		protected function select_one(vars:String, where:String=null,params:Object=null,limit:String=null):Object {
			for each (var o:Object in select(vars,where,params,limit)) {
				for each (var d:Object in o) {
					return d;
				}
			}
			return null;
		}
		
		protected function select_first(vars:String, where:String=null,params:Object=null,limit:String=null):Object {
			for each (var o:Object in select(vars,where,params,limit)) {
				return o;
			}
			return null;
		}
		
		protected function _insert(data:Object, onConflict:String=""):SimpleTable {
			var cols:String, values:String, c:String;
			
			values	= "";
			cols	= "";
			c		= "";
			for (var col:String in data) {
				if (col == 'mx_internal_uid'){
					delete data[col];
					continue;
				} 
				cols	+= c + " "  + col;
				values	+= c + " :" + col;
				c		=  ",";
			}
			runSQL("INSERT "+onConflict+" INTO "+_struct.table+" ("+cols+" ) VALUES ("+values+" );",null,data,null,null);
			return this;
		}

		// If using this, be sure not to use params in where which are already defined in data!
		public function update(data:Object, criteria:Object=null, onConflict:String=""):SimpleTable {
			var cols:String, c:String;
			var all:Object = {};
			var col:String;
			
			cols	= "";
			c		= "";
			if (criteria!=null)
				for (col in criteria) {
					all[col]=criteria[col];
				}
			for (col in data) {
				if (col == 'mx_internal_uid') continue;
				if(col in criteria) continue;
				cols	+= c + " "  + col+"=:"+col;
				c		=  ",";
				all[col]=data[col];
//				if ((col in criteria) && criteria[col]!=data[col]) {
//					throw Error("update table "+_struct.table+": column "+col+" has different data in params and data");
//				}
			}
			var where:String = andEqualsWhere(criteria);
			runSQL("UPDATE "+onConflict+" "+_struct.table+" SET "+cols, where, all, null, null);
			return this;
		}

		protected function del(where:String, params:Object=null):SimpleTable {
			runSQL("DELETE FROM "+_struct.table, where, params, null, null);
			return this;
		}
		
		protected static function andEqualsWhere(params:Object):String {
			var where:String;
			
			where = "";
			for (var col:String in params) {
			  where += " AND " +col+ "= :" + col;
			}
			return where!="" ? "WHERE "+where.substr(5) : "";
		}
		
		//VAHI use Database.begin()
		protected function begin():SimpleTable {
			stmt.sqlConnection.begin();
			return this;
		}

		protected function commit():SimpleTable {
			stmt.sqlConnection.commit();
			return this;
		}

		// PUBLIC INTERFACE
		// This shall become bigger ..

		//VAHI this is a black magic introspection function.
		// It just pulls the group of the TEXT columns (which is an array).
		// This usually is the list of tags to interface with SoD ..
		// CORRECTLY this (both!) should be pulled from somthing like gadget.util.SoDUtils,
		// but it isn't here today.
		public function stdTextColumns():Array {
			return _struct.columns.TEXT;
		}

		/** Insert or replace a record.
		 * If a unique constraint is violated (like: primary key) the
		 * record is replaces, else inserted.
		 *
		 * @param data  Object like { id:"AAB-1111-1", value:"something" }
		 * @return SimpleTable  reference to itself, so you can chain commands
		 */
		public function replace(data:Object):SimpleTable {
			return _insert(data,"OR REPLACE");
		}

		/** Insert a record.
		 * If a unique constraint is violated (like: primary key) this throws.
		 *
		 * @param data  Object like { id:"AAB-1111-1", value:"something" }
		 * @return SimpleTable  reference to itself, so you can chain commands
		 */
		public function insert(data:Object):SimpleTable {
			return _insert(data);
		}
		
		/** Delete a record. (delete_ due to delete is a reserved word)
		 * WARNING: If you do give an empty object, this is the same as
		 * "DELETE FROM table" which means, all records are deleted.
		 *
		 * @param data  Object like { id:"AAB-1111-1", value:"something" }
		 * @return SimpleTable  reference to itself, so you can chain commands
		 */
		public function delete_(data:Object):SimpleTable {
			return del(null, data);
		}

		/** Fetch records.
		 * This runs "select * from table where ..."
		 *
		 * @param where  Object like { id:"AAB-1111-1" }, if null selects all.
		 * @return Array  result array or [] (empty Array) if nothing
		 */
		public function fetch(where:Object=null):Array {
			var res:Array = select("*",null,where);
			return res==null ? [] : res;
		}

		/** Fetch the first record only.
		 * This runs "select * from table where ... limit 1"
		 *
		 * @param where  Object like { id:"AAB-1111-1" }, if null selects all.
		 * @return Object  the first record or null if no record
		 */
		public function first(where:Object=null):Object {
			return select_first("*",null,where, "1");
		}
		
		/** Fetch a single column value of the first row.
		 * This runs "select column from table where ... limit 1"
		 * and returns the first column.  If you try to cheat and
		 * give more than one column (like "col1,col2") it is random
		 * which column's value you get.
		 *
		 * @param column  String, name of the column
		 * @param where  (optional) Object like { id:"AAB-1111-1" }, if missing or null selects all.
		 * @param def  Object, replacement value if nothing or NULL encountered.
		 * @return Object  the value of the column, or def if select returns nothing or NULL.
		 */
		public function value(column:String, where:Object=null, def:Object=null):Object {
			var res:Object = select_one(column,null,where, "1");
			if (res!=null)
				return res;
			return def;
		}
		
		/** Fetch all the values of the rows as one array.
		 * This runs "select column from table where ..."
		 * and returns the array of the first column.
		 * If you give more than one column, the result
		 * is a little bit random, but all columns will be included.
		 *
		 * @param column  String, name of the column
		 * @param where  (optional) Object like { id:"AAB-1111-1" }, if missing or null selects all.
		 * @param order  (optional) Sort order
		 * @return Array  The values of the columns, or empty Array [] if nothing.
		 */
		public function values(column:String, where:Object=null, order:String=null):Array {
			var a:Array = [];
			for each (var o:Object in select_order(column,null,where,order,null)) {
				for each (var d:Object in o) {
					a.push(d);
				}
			}
			return a;
		}

		/** Fetch some columns from table with some order.
		 * This runs "select columns from ... where ... order by ..."
		 * and returns the array of the rows.
		 *
		 * @param columns String, like "col1,col2"
		 * @param where  (optional) Object like { id:"AAB-1111-1" }, if missing or null selects all.
		 * @param order  (optional) Sort order like "1,2"
		 * @return Array  The rows of objects {col1:"value1",col2:"value2"}.
		 */
		public function columns(columns:String, where:Object=null, order:String=null):Array {
			return select_order(columns,null,where,order,null);
		}
		
		public function delete_all():void {
			del(null);
		}
		
		public function getColumns():Array {
			throw new Error("getColumns is not defined");
		}
		
		public function countRecord():int {
			var result:Array = select("Count(*) AS total");
			return parseInt(result[0].total);
		}
		
		public function insert_auto_id(rec:Object):void {
			var id:int = countRecord() + 1;
			rec.Id = id
			insert(rec);
		}
		public function selectLastRecord():Object{
			exec(stmtSelectLastRecord);
			var res:Array = stmtSelectLastRecord.getResult().data;
			if(res!=null && res.length>0){
				return res[0];
			}
			return null;
		}
	}
}
