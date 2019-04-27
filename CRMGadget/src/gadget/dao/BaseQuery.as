//VAHI New Baseclass to support more generic way of queries
// (base on SimpleTable)
package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import gadget.util.ObjectUtils;
	import gadget.util.StringUtils;
	import gadget.util.TableFactory;

	public class BaseQuery extends BaseSQL {

		private var m_stmt:SQLStatement;
		private var m_struct:Object;

		
		public function get daoStructure():Object {
			return m_struct;
		}

		public function get entity():String {
			throw Error("getter BaseDAO.entity not overwritten");
			return "";
		}

		public function BaseQuery(work:Function, conn:SQLConnection, structure:Object, special:Object):void {

			if (conn==null)
				return;


			m_struct	= structure;

			if (structure) {
				// sanity checks
				m_check("table","String");
				m_check("columns","Object");
				m_check_if("index","Array", "String");
				m_check_if("unique","Array", "String");
			}

			TableFactory.create(work, conn, structure, special);

			m_stmt = new SQLStatement();
			m_stmt.sqlConnection	= conn;
		}

		private function m_check(entry:String, type:String, subtype:String=null):void {
			if (!(entry in m_struct))
				throw new Error("table structure error: missing "+entry);
			var t:String = ObjectUtils.type(m_struct[entry]);
			if (type!=t)
				throw new Error("table structure error: datatype "+t+" of "+entry+" must be "+type);
			if (subtype!=null) {
				for each (var ent:Object in m_struct[entry]) {
					if (ObjectUtils.type(ent)!=subtype)
						throw new Error("table structure error: datatype of "+entry+" must be "+type+" of "+subtype);
				}
			}
		}
		
		private function m_check_if(entry:String, type:String, subtype:String=null):void {
			if (entry in m_struct && m_struct[entry]!=null)
				m_check(entry, type, subtype);
		}
		
		private function q_exec(query:String, where:String, params:Object, order:String, limit:String):void {
			m_stmt.clearParameters();
			if (params)
				for (var p:String in params)
					m_stmt.parameters[':'+p]	= params[p];
			if (params!=null && where==null)
				where = s_andEqualsWhere(params);
			m_stmt.text		= query + " " + (where ? where : "") + (order ? " ORDER BY "+order : "") + (limit ? " LIMIT "+limit : "") + ";";

			exec(m_stmt);
		}
		
		private function q_all(query:String, where:String, params:Object, order:String, limit:String):Array {
			q_exec(query,where,params,order,limit);
			return m_stmt.getResult().data;
		}
		
		private function q_select_order(vars:String, where:String, params:Object, order:String, limit:String):Array {
			return q_all("SELECT "+vars+" FROM "+m_struct.table, where, params, order, limit);
		}

		private function q_select(vars:String, where:String=null, params:Object=null, limit:String=null):Array {
			return q_select_order(vars, where, params, null, limit);
		}

		private function q_select_one(vars:String, where:String=null,params:Object=null,limit:String=null):Object {
			for each (var o:Object in q_select(vars,where,params,limit)) {
				for each (var d:Object in o) {
					return d;
				}
			}
			return null;
		}




		
		private static function s_andEqualsWhere(params:Object):String {
			var where:String;
			
			where = "";
			for (var col:String in params) {
			  where += " AND " +col+ "= :" + col;
			}
			return where!="" ? "WHERE "+where.substr(5) : "";
		}
		




		/** Fetch records.
		 * This runs "select * from table where ..."
		 *
		 * @param where  Object like { id:"AAB-1111-1" }, if null selects all.
		 * @return Array  result array or [] (empty Array) if nothing
		 */
		protected function b_fetch(where:Object=null):Array {
			var res:Array = q_select("*",null,where);
			return res==null ? [] : res;
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
		protected function b_value(column:String, where:Object=null, def:Object=null):Object {
			var res:Object = q_select_one(column,null,where, "1");
			if (res!=null)
				return res;
			return def;
		}


		protected function exec_cmd(cmd:String):void{
			q_exec(cmd,null,null,null,null);
		}

		protected function b_exec(cmd:String, rest:String=""):void {
			q_exec(cmd+" "+m_struct.table+" "+rest, null, null, null, null);
		}



	}
}
