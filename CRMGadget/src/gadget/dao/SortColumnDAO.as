package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.util.TableFactory;

	public class SortColumnDAO extends BaseSQL
	{
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtSelect:SQLStatement;
		public function SortColumnDAO(sqlConnection:SQLConnection, work:Function)
		{
			TableFactory.create(work, sqlConnection, {
				table: "sort_column",
				index: [ 'entity' ],
				columns: {
					entity:"TEXT",
					column_order:"TEXT",
					order_type:"TEXT"
				}
			});
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO sort_column (entity, column_order, order_type) VALUES (:entity, :column_order, :order_type)";

			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE sort_column SET column_order = :column_order, order_type = :order_type WHERE entity = :entity";

			stmtSelect = new SQLStatement();
			stmtSelect.sqlConnection = sqlConnection;
			stmtSelect.text = "SELECT * FROM sort_column WHERE entity = :entity";

		}
		
		public function insert(sortCol:Object):void {
			stmtInsert.parameters[':entity'] = sortCol.entity;
			stmtInsert.parameters[':column_order'] = sortCol.column_order;
			stmtInsert.parameters[':order_type'] = sortCol.order_type;
			exec(stmtInsert);
		}
		
		public function update(sortCol:Object):void {
			stmtUpdate.parameters[':entity'] = sortCol.entity;
			stmtUpdate.parameters[':column_order'] = sortCol.column_order;
			stmtUpdate.parameters[':order_type'] = sortCol.order_type;
			exec(stmtUpdate);
		}
		public function find(entity:String):Object{
			stmtSelect.parameters[':entity'] = entity;
			exec(stmtSelect);
			var sqlResult:SQLResult = stmtSelect.getResult();
			if (sqlResult.data == null || sqlResult.data.length == 0) {
				return null;
			}
			return sqlResult.data[0];
		}
		public function replace(sortCol:Object):void {
			if (find(sortCol.entity))
				update(sortCol);
			else
				insert(sortCol);
		}
	}
}