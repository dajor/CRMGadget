package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import gadget.util.TableFactory;
	
	import mx.collections.ArrayCollection;
	
	public class RevenueDao extends SimpleTable
	{
		private var stmtDrop:SQLStatement =null;
		private var stmtDelete:SQLStatement =null;
		private var stmtSelectByShipName:SQLStatement =null;
		private var stmtUpdateAsOfDate:SQLStatement =null;
		private var work:Function;
		private var sqlConnection:SQLConnection;
		public function RevenueDao(sqlConnection:SQLConnection, work:Function)
		{
			super(sqlConnection,work,  {
				table: 'revenue',
				columns: { 'TEXT' : textColumns }
			});
			this.work = work;
			this.sqlConnection = sqlConnection;
			stmtDrop = new SQLStatement();
			stmtDrop.sqlConnection = sqlConnection;
			stmtSelectByShipName = new SQLStatement();
			stmtSelectByShipName.sqlConnection = sqlConnection;
			
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			
			stmtUpdateAsOfDate = new SQLStatement();
			stmtUpdateAsOfDate.sqlConnection = sqlConnection;
			
		}
		public function dropAndRecreateTable(columns:Array):void{
			try {
				stmtDrop.text = "DROP TABLE revenue" ;
				exec(stmtDrop);
			} catch (e:SQLError) {
				// ignore
			}
			createTable(this.sqlConnection,columns);
			
		}
		public function delete_by(where:String):void{
			try {
				stmtDelete.text = "Delete From revenue where " + where;
				exec(stmtDelete);
			} catch (e:SQLError) {
				// ignore
			}
			
			
		}
		public function updateAsOfDate(asOfDate:String):void{
			stmtUpdateAsOfDate.text = "update revenue set AsOfDate='" + asOfDate +"'";
			exec(stmtUpdateAsOfDate);
		}
	
		private  function createTable(sqlConnection:SQLConnection, columns:Array):void {
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = sqlConnection;
			var strSQL:String = 'CREATE TABLE revenue (';
			
			for(var i:int=0; i<columns.length; i++){
				var column:String = columns[i];
				strSQL += column + ' TEXT';
				if(i<columns.length-1) strSQL += ', ';
			}
			
			strSQL += ')';
			stmt.text = strSQL;
			exec(stmt);
		}
		public  function query(where:String):ArrayCollection {
			stmtSelectByShipName.text = "select * from revenue where " + where;
			exec(stmtSelectByShipName);
			
			return new ArrayCollection(stmtSelectByShipName.getResult().data);
		}
		private var textColumns:Array = [
		"Data_Type",
		"importedDate",
		"Month",
		"ProductFamily",
		"QtrFY",
		"Company",
		"Territory",
		"TMID",
		"TM",
		"RMID",
		"RM",
		"ShipToName",
		"ShipTo",
		"ShipToAddress1",
		"ShipToAddress2",
		"ShipToCity",
		"ShipToState",
		"ShipToZip",
		"Item",
		"ItemDescrip",
		"BusinessArea",
		"PriorDayRevenue",
		"Group_",
		"Brand",
		"Catalog",
		"Description",
		"ShipToPrimary",
		"AsofDate",
		"BrandDescription",
		"HIERARCHY_LV1",
		"HIERARCHY_LV2",
		"HIERARCHY_LV3",
		"HIERARCHY_LV4",
		"HIERARCHY_LV5",
		"CORP_SALE_IND",
		"MonthRevenue",
		"QTDRevenue",
		"MATRevenue",
		"YTDRevenue",
		"YTDGrowth",
		"LYMonthRevenue",
		"LYQTDRevenue",
		"LYMATRevenue",
		"LYYTDRevenue"];
	}
}