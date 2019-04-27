package gadget.util
{
	import com.adobe.crypto.MD5;
	
	import flash.data.SQLColumnSchema;
	import flash.data.SQLConnection;
	import flash.data.SQLIndexSchema;
	import flash.data.SQLResult;
	import flash.data.SQLSchemaResult;
	import flash.data.SQLStatement;
	import flash.data.SQLTableSchema;
	import flash.errors.SQLError;
	
	import gadget.dao.BaseSQL;
	import gadget.dao.Database;

	
	public class TableFactory extends BaseSQL
	{
		// Fields in "structure":
		// table:"Name" - defaults to passed in table (entity) name
		// search_columns: indexed columns for quicksearch
		// display_name:"friendly name" - name the user will see
		// drop_table:true/false - default false, if true, re-created by "drop/create" instead "alter add column"
		// create_cb:function - default none, function to call after table has been created
		// create_index_cb:function - default none, function to call after indexes have been created
		// index:[] - Array of String - list of indexes
		// unique:[] - Array of String - list of unique indexes (use this instead of primary)
		// columns:{} - see below
		// Fields in special (if present):
		// table: Overwritten table name
		// columns:{} - see "structure", additional columns
		// index:[] - see "structure", additional indexes
		// unique:[] - see "structure", additional indexes
		//
		// Columns can be defined like follows:
		// column:"TYPE",
		// column:{type:"TYPE",whatever:parameters}
		// "TYPE":["column1","column2",...]
		// sadly we cannot write: ['col1','col2',...]:"TYPE"
		
		public static function create(work:Function, conn:SQLConnection, structure:Object, special:Object=null):void {
			if (work==null) {
				return;	// Table must have been created already.  USE THIS FOR TESTS
			}

			if (!structure) {
				trace("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
				trace("==============================================================");
				trace("WARNING",special.table,"STILL OLD STRUCTURE");
				trace("==============================================================");
				return;
			}

			if (structure.primary)
				throw new Error("primary key no more supported, use unique!");

			var A:TableInternCreateObject = new TableInternCreateObject();
			A.work		= work;
			A.stmt		= new SQLStatement();
			A.special	= special ? special : {};
			A.table		= A.special.table ? A.special.table : structure.table;
			A.structure	= structure;
			A.dn		= structure.display_name ? structure.display_name : A.table;
			A.callcallback = false;
			A.stmt.sqlConnection = conn;
			A.cols		= {};
			A.colslc	= {};
			
			if (A.table.substr(0,1)=="_")
				throw new Error(A.dn + ": table names must not start with underscore: " + A.table);
			
			function columnAdd(col:String, type:Object):void {
				A.cols[col] = type;
				if (col.toLowerCase() in A.colslc)
					throw new Error(A.dn + ": duplicate column defined: " + col);
				A.colslc[col.toLowerCase()] = true;
			}

			function columnsAdd(cols:Object):void {
				if (cols==null)
					return;
				for (var col:String in cols) {
					var type:Object = cols[col];
					if (type is String) {		// column:"TYPE"
						columnAdd(col, {type:type as String});
					} else if (type is Array) { // "TYPE":['column1','column2',...] 
						for each (var name:String in type) {
							columnAdd(name, {type:col});
						}
					} else {	// column:{type:"whatever",specials:whatever}
						columnAdd(col, type);
					}
				}
			}
			
			columnsAdd(A.structure.columns);
			columnsAdd(A.special.columns);

			if (A.table != A.table.toLowerCase())
				throw new Error("internal error, table name must be all lowercase: " + A.table);
			
			work("Checking "+ A.dn +" table...", function(params:Object):void {
				
				try {
					loadSchema(conn, SQLTableSchema, A.table);
				} catch (e:SQLError){
					trace("table",A.table,"does not exist",e.message);
					createTable(A);
					return;
				}

				var check:Object = {};
				var checklc:Object = {};

				for each (var colsc:SQLColumnSchema in conn.getSchemaResult().tables[0].columns) {
					var cdef:String = colsc.dataType;
					if (colsc.primaryKey)
						cdef += " primary key";
					else if (!colsc.allowNull)
						cdef += " not null";
					if (colsc.autoIncrement)
						cdef += " autoincrement";
					check[colsc.name]=cdef.toLowerCase();
					checklc[colsc.name.toLowerCase()]=true;
				}

				
				var missing_col:Boolean = false;
				var mismatch_col:Boolean = false;

				for (var col:String in A.cols) {
					if (!(col in check)) {
						if (col.toLowerCase() in checklc) {
							mismatch_col = true;
							trace("in table",A.table,"wrong CAPS col",col);
						} else {
							missing_col = true;
							//except drop_table if missing column is ood_lastmodified 
							if(col.toLocaleLowerCase()=='ood_lastmodified' || col.toLocaleLowerCase()=='important' || col.toLocaleLowerCase()=='favorite'){
								A.structure.drop_table=false;
							}
							trace("in table",A.table,"missing col",col);
						}
					} else if (A.cols[col].type.toLowerCase().replace(/ DEFAULT .*$/i,"")!=check[col]) {
						trace("in table",A.table,"col",col,'datatype mismatch: is',check[col],'want',A.cols[col].type);
						mismatch_col = true;
					}
				}

				var superfluous_col:Boolean = false;

				for (col in check) {
					if (!(col.toLowerCase() in A.colslc)) {
						superfluous_col = true;
						trace("in table",A.table,"superfluous col",col);
					}
				}

				if (!missing_col && !mismatch_col && !superfluous_col) {
					checkIndexes(A);
					return;
				}
				
				if (A.structure.drop_table || A.structure.must_drop) {
					work("Dropping and creating " + A.dn + " table...", function(params:Object):void {
						
						A.stmt.text = "DROP TABLE "+A.table;
						exec(A.stmt, false);
						
						createTable(A);
					});
					return;
				}

				if (missing_col) {
					for (col in A.cols) {
						if (!(col in check)) {
							A.callcallback = true;
							
							work("Adding "+ A.dn +" column " + col + " ...", function(params:Object):void {
								try {
									Database.begin();
									A.stmt.text = "ALTER TABLE "+A.table+" ADD COLUMN "+column_def(A.cols, params.col);
									exec(A.stmt, false);
									
									if (A.cols[params.col].init!=null) {
										var s:String = A.cols[params.col].init;
										if (s!=null) {
											A.stmt.text = "UPDATE " + A.table + " SET " + params.col + " = " + s;
											exec(A.stmt, false);
										}
									}else if(params.col=="ood_lastmodified"){
										var colModifiedDate:String="ModifiedDate";
										if(A.table=='product'){
											colModifiedDate="ModifiedByDate";
										}
										A.stmt.text = "UPDATE " + A.table + " SET " + params.col + " = "+colModifiedDate;
										exec(A.stmt, false);										
									}
									Database.commit();
								} catch (e:Error) {
									Database.rollback();
									throw e;
								}
							},{col:col});
						}
					}
				}

				if (mismatch_col || (superfluous_col && A.structure.clean_table)) {

					A.callcallback = true;
					work("Dropping " + A.dn + " del table...", function(params:Object):void {
						A.stmt.text = "DROP TABLE IF EXISTS _del_"+A.table;
						exec(A.stmt, false);
					});
					work("Dropping " + A.dn + " tmp table...", function(params:Object):void {
						A.stmt.text = "DROP TABLE IF EXISTS _tmp_"+A.table;
						exec(A.stmt, false);
					});
					work("Creating " + A.dn + " tmp table...", function(params:Object):void {
						A.stmt.text = "CREATE TABLE _tmp_"+A.table+" ( "+ columnDefs(A.cols) + " );";
						exec(A.stmt, false);
					});
					work("Copying " + A.dn + " table...", function(params:Object):void {
						
						var allc:Array = [];
						for (col in A.colslc) {
							if (col in checklc) {
								allc.push(col);
							}
						}
						var bothCols:String = allc.join(", ");
						A.stmt.text = "INSERT INTO _tmp_"+A.table+" ( " + bothCols + " ) SELECT " + bothCols + " FROM "+A.table;
						exec(A.stmt, false);
					});

					work("Renaming " + A.dn + " table...", function(params:Object):void {
						try {
							Database.begin();
							
							A.stmt.text = "ALTER TABLE "+A.table+" RENAME TO _del_"+A.table;
							exec(A.stmt, false);

							A.stmt.text = "ALTER TABLE _tmp_"+A.table+" RENAME TO "+A.table;
							exec(A.stmt, false);
							
							Database.commit();
						} catch (e:Error) {
							Database.rollback();
							throw e;
						}
					});
					work("Dropping " + A.dn + " del table...", function(params:Object):void {
						A.stmt.text = "DROP TABLE _del_"+A.table;
						exec(A.stmt, false);
					});
				}

				work("Checking " + A.dn + " indexes ...", function(params:Object):void {
					checkIndexes(A);
				});
			});
		}

		private static function column_def(container:Object, col:String):String {
			return col+" "+container[col].type;
		}

		private static function columnDefs(container:Object):String {
			var arr:Array = [];
			for (var col:String in container) {
				arr.push(column_def(container, col));
			}
			return arr.join(", ");
		}

		// Create a table from a description, see comment at create() how it looks like.
		private static function createTable(A:TableInternCreateObject):void {

			A.stmt.text = "CREATE TABLE "+A.table+" ( "+ columnDefs(A.cols) + " );";
			exec(A.stmt, false);

			A.callcallback = true;
			checkIndexes(A);
		}
		
		private static function checkIndexes(A:TableInternCreateObject):void {
			var all_indices:Object = {};
			var known_index:Object = {};
			var indices:Array = [];

			function addIndex(index:Array, type:String):void {
				if (index!=null) {
					for each (var idx:String in index) {
						//VAHI if you manage to find two valid indices which make sense
						// and that have the same MD5 sum, I owe you a pizza.
						all_indices["i_"+A.table+"_"+MD5.hash(A.table+" "+idx+" "+type)] = {
							columns: idx,
							unique: type
						}
					}
				}
			}
			
			addIndex(A.structure.index, "");
			addIndex(A.special.index, "");
			addIndex(A.structure.unique, "UNIQUE");
			addIndex(A.special.unique, "UNIQUE");
			
			// check for superfluous indices in the table
			try {
				loadSchema(A.stmt.sqlConnection, SQLIndexSchema, A.table);
				indices = A.stmt.sqlConnection.getSchemaResult().indices;
			} catch (e:SQLError) {
				trace("no indices in",A.table);
			}
			for each (var idx:SQLIndexSchema in indices) {
				if (!(idx.name in all_indices)) {
					if (idx.sql==null) {
						// if SQL is NULL it is the SQLite internal primary key
						trace("WARNING: cannot remove primary key",idx.name,"from",A.table);
					} else {
						A.work("Dropping "+ A.dn +" index "+ idx.name +" ...", function(params:Object):void {
							A.stmt.text = "DROP INDEX " + params.idx.name + ";";
							trace("###########################################################################");
							trace("was:",params.idx.sql);
							exec(A.stmt, false);
							trace("###########################################################################");
						},{idx:idx});
					}
				}
				known_index[idx.name] = 1;
			}

			// Add all missing indexes
			var addIndexes:Boolean = false;
			for (var index:String in all_indices) {
				if (!(index in known_index)) {
					A.work("Create "+ A.dn +" index "+ index +" ...", function(params:Object):void {
						A.stmt.text = "CREATE " + params.idx.unique + " INDEX " + params.name + " ON " + A.table + " ( " + params.idx.columns + " );";
						exec(A.stmt, false);
					},{name:index, idx:all_indices[index]});
				}
			}

			if (addIndexes && A.structure.create_index_cb!=null)
				A.work("Index callback for " + A.dn +" ...", function(params:Object):void {
					A.structure.create_index_cb(A.structure);
				});
			if (A.callcallback && A.structure.create_cb!=null)
				A.work("Create callback for "+ A.dn +" ...", function(params:Object):void {
					A.structure.create_cb(A.structure);
				});
		}
	}
}
