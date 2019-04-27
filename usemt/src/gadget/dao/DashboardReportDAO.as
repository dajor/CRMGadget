package gadget.dao{
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import gadget.util.DateUtils;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	
	public class DashboardReportDAO extends SimpleTable{
		
		
		private var stmtSelect:SQLStatement;
		private var stmtSelectSaleRep:SQLStatement;
		private var stmtSelectSegmentSplit:SQLStatement;
		private var stmtSelectOwnerSaleRep:SQLStatement;
		
		// New Version
		private var stmtSelectSegmentA:SQLStatement;
		private var stmtSelectSegmentB:SQLStatement;
		private var stmtSelectSegmentC:SQLStatement;
		private var stmtSelectSegmentD:SQLStatement;
		
		private var stmtSelectAccount:SQLStatement;
		private var stmtAccountInfo:SQLStatement;
		private var stmtTargetAccount:SQLStatement;
		private var stmtTargetNextMonth:SQLStatement;
		private var stmtAccountActivity:SQLStatement;
		
		private var stmtTredTarget:SQLStatement;
		private var stmtTredActual:SQLStatement;
		
		private var stmtGetRecord:SQLStatement;
		
		public function DashboardReportDAO(sqlConnection:SQLConnection, work:Function){
			
			super(sqlConnection, work, {
				table: 'segment_target_default',
				unique : ["Month, Year"],
				columns: { 'TEXT' : ["Month", "Year", "TerritoryId"]}
			});
			
			
			stmtSelect = new SQLStatement();
			stmtSelect.sqlConnection = sqlConnection;
			stmtSelect.text = "SELECT SUM(IndexedNumber0) AS Target, CustomObject5Id, CustomObject5Name FROM sod_customobject4 " +
				"WHERE IndexedPick2=:month AND IndexedPick0=:year AND IndexedNumber0 IS NOT NULL GROUP BY CustomObject5Id, IndexedPick2, IndexedPick0";
			
			var subSql:String = "SELECT AccountId FROM sod_customobject15 "; 
			var subWhereStart:String = " WHERE CustomObject5Id=:customObject5Id AND IndexedPick0 IN (";
			var subWwhereEnd:String = ") AND AccountId IS NOT NULL";
			
			var sqlStart:String = "SELECT COUNT(Subject) AS Actual FROM activity " + 
				"WHERE AccountId IN ( " ;
			var sqlEnd:String = " ) AND Type = 'Meeting' AND DueDate >=:startdate AND DueDate <=:enddate AND AccountId IS NOT NULL GROUP BY AccountId";
			
			
			var subParam:String = "'A', 'B', 'C', 'D'";
			
			stmtSelectSaleRep = new SQLStatement();
			stmtSelectSaleRep.sqlConnection = sqlConnection;
			stmtSelectSaleRep.text = sqlStart + subSql + subWhereStart + subParam + subWwhereEnd + sqlEnd;
			
			// New Version
			stmtSelectSegmentA = new SQLStatement();
			stmtSelectSegmentA.sqlConnection = sqlConnection;
			stmtSelectSegmentA.text = sqlStart + subSql + subWhereStart + "'A'" + subWwhereEnd + sqlEnd;
			
			stmtSelectSegmentB = new SQLStatement();
			stmtSelectSegmentB.sqlConnection = sqlConnection;
			stmtSelectSegmentB.text = sqlStart + subSql + subWhereStart + "'B'" + subWwhereEnd + sqlEnd;
			
			stmtSelectSegmentC = new SQLStatement();
			stmtSelectSegmentC.sqlConnection = sqlConnection;
			stmtSelectSegmentC.text = sqlStart + subSql + subWhereStart + "'C'" + subWwhereEnd + sqlEnd;
			
			stmtSelectSegmentD = new SQLStatement();
			stmtSelectSegmentD.sqlConnection = sqlConnection;
			stmtSelectSegmentD.text = sqlStart + subSql + subWhereStart + "'D'" + subWwhereEnd + sqlEnd;
			
			stmtSelectOwnerSaleRep = new SQLStatement();
			stmtSelectOwnerSaleRep.sqlConnection = sqlConnection;
			stmtSelectOwnerSaleRep.text = "SELECT OwnerFullName FROM sod_customobject15 WHERE CustomObject5Id=:customObject5Id GROUP BY OwnerId";
			
			
			// For Tab Account
			
			stmtAccountInfo = new SQLStatement();
			stmtAccountInfo.sqlConnection = sqlConnection;
			stmtAccountInfo.text = "SELECT AccountId, AccountName, CustomPickList1 AS Channel FROM account WHERE AccountId IN ( " + subSql + subWhereStart + subParam + subWwhereEnd + " )";
			
			stmtAccountActivity = new SQLStatement();
			stmtAccountActivity.sqlConnection = sqlConnection;
			stmtAccountActivity.text = "SELECT AccountId, COUNT(Subject) AS ActualVisitYtd FROM activity WHERE AccountId IN ( " + subSql + subWhereStart + subParam + subWwhereEnd + sqlEnd;
			
			stmtSelectAccount = new SQLStatement();
			stmtSelectAccount.sqlConnection = sqlConnection;
			stmtSelectAccount.text = "SELECT AccountId, IndexedPick0 AS Segment FROM sod_customobject15 " + subWhereStart + subParam + subWwhereEnd;
			
			stmtTargetAccount = new SQLStatement();
			stmtTargetAccount.sqlConnection = sqlConnection;
			stmtTargetAccount.text = "SELECT AccountId, SUM(IndexedNumber0) AS TargetVisitYtd FROM sod_customobject4 WHERE AccountId IN ( "+
				subSql + subWhereStart + subParam + subWwhereEnd +
				" ) AND IndexedPick1 <=:month AND IndexedPick0 <=:year AND IndexedNumber0 IS NOT NULL GROUP BY AccountId";
			
			
			stmtTargetNextMonth = new SQLStatement();
			stmtTargetNextMonth.sqlConnection = sqlConnection;
			stmtTargetNextMonth.text = "SELECT AccountId, IndexedNumber0 AS TargetVisitsNextMonth FROM sod_customobject4 WHERE AccountId In ( " + 
				subSql + subWhereStart + subParam + subWwhereEnd + 
				" ) AND IndexedPick1 =:month AND IndexedPick0 =:year";
			
			// End For Tab Account
			
			
			// Tred 3 months
			stmtTredTarget = new SQLStatement();
			stmtTredTarget.sqlConnection = sqlConnection;
			stmtTredTarget.text = "SELECT SUM(IndexedNumber0) AS Target, IndexedPick2 AS Month FROM sod_customobject4 " + 
				"WHERE IndexedPick1 =:month AND IndexedPick0 =:year AND CustomObject5Id=:customObject5Id AND IndexedNumber0 IS NOT NULL " +
				"GROUP BY CustomObject5Id, IndexedPick2, IndexedPick0";
			
			stmtTredActual = new SQLStatement();
			stmtTredActual.sqlConnection = sqlConnection;
			stmtTredActual.text = "SELECT COUNT(Subject) AS Actual FROM activity WHERE AccountId IN ( " + subSql + subWhereStart + subParam + subWwhereEnd + sqlEnd;
			
			
			// Old Version
//			"SELECT COUNT(Name) AS Actual, OwnerFullName FROM sod_customobject15 " +
//				"WHERE CustomObject5Id=:customObject5Id AND IndexedPick0 IN ('A', 'B', 'C', 'D') GROUP BY OwnerId";
			
			// Old Version
			stmtSelectSegmentSplit = new SQLStatement();
			stmtSelectSegmentSplit.sqlConnection = sqlConnection;
			stmtSelectSegmentSplit.text = "SELECT COUNT(Name) AS Total, " +
				"(SELECT COUNT(Name) FROM sod_customobject15 WHERE CustomObject5Id=:customObject5Id AND IndexedPick0 IN ('A') GROUP BY OwnerId) AS A, " +
				"(SELECT COUNT(Name) FROM sod_customobject15 WHERE CustomObject5Id=:customObject5Id AND IndexedPick0 IN ('B') GROUP BY OwnerId) AS B, " +
				"(SELECT COUNT(Name) FROM sod_customobject15 WHERE CustomObject5Id=:customObject5Id AND IndexedPick0 IN ('C') GROUP BY OwnerId) AS C, " +
				"(SELECT COUNT(Name) FROM sod_customobject15 WHERE CustomObject5Id=:customObject5Id AND IndexedPick0 IN ('D') GROUP BY OwnerId) AS D " +
				"FROM sod_customobject15 WHERE CustomObject5Id=:customObject5Id AND IndexedPick0 IN ('A', 'B', 'C', 'D') GROUP BY OwnerId";
			
			stmtGetRecord = new SQLStatement();
			stmtGetRecord.sqlConnection = sqlConnection;
			stmtGetRecord.text = "SELECT * FROM segment_target_default";
			
		}
		
		public function getTredData(territoryId:String, date:Date):Array{
			var array:Array = new Array();
			for(var i:int = 3; i>=0; i--){
				var newDate:Date = new Date(date.fullYear, date.month, date.date);
				if((date.month - (i+1)) < 0) {
					newDate.setFullYear(newDate.fullYear - 1);
					newDate.setMonth((date.month - (i+1)) + 12);
				}else{
					newDate.setMonth(date.month - (i+1));
				}
				array.push(generateTredData(territoryId, newDate));
			}
			return array;
		}
		
		private function generateTredData(territoryId:String, date:Date):Object{
			var startDate:String = DateUtils.format(new Date(date.fullYear, date.month, 1),DateUtils.DATABASE_DATE_FORMAT);
			var tempEndDate:Date = new Date(date.fullYear, date.month+1, 0);
			var endDate:String = DateUtils.format(tempEndDate, DateUtils.DATABASE_DATE_FORMAT);
			
			stmtTredTarget.parameters[":customObject5Id"] = territoryId;
			stmtTredTarget.parameters[":month"] = date.month + 1;
			stmtTredTarget.parameters[":year"] = date.month + 1 > 11 ? date.fullYear + 1 : date.fullYear;
			exec(stmtTredTarget);
			var arr:Array = stmtTredTarget.getResult().data;
			var record:Object = checkArrayNull(arr);
			if(record == null){
				record = new Object();
				var format:DateFormatter = new DateFormatter();
				format.formatString = "MMMMM YYYY";
				var displayMonth:String = format.format(date);
				record["Target"] = "0";
				record["Month"] = displayMonth.split(" ")[0];
			}
			stmtTredActual.parameters[":customObject5Id"] = territoryId;
			stmtTredActual.parameters[":startdate"] = startDate;
			stmtTredActual.parameters[":enddate"] = endDate;
			exec(stmtTredActual);
			arr = stmtTredActual.getResult().data;
			var obj:Object = checkArrayNull(arr);
			if(obj == null){
				record["Actual"] = "0";
			}else{
				record["Actual"] = obj["Actual"];	
			}
			return record;
		}
		
		public function getAllAccounts(territoryId:String, date:Date):Array{
			var resultAccount:Array = new Array();
			
			var startDate:String = DateUtils.format(new Date(date.fullYear, date.month, 1),DateUtils.DATABASE_DATE_FORMAT);
			var tempEndDate:Date = new Date(date.fullYear, date.month+1, 0);
			var endDate:String = DateUtils.format(tempEndDate, DateUtils.DATABASE_DATE_FORMAT);
			
			stmtSelectAccount.parameters[":customObject5Id"] = territoryId;
			exec(stmtSelectAccount);
			var arr:Array = stmtSelectAccount.getResult().data;
			
			if(arr != null && arr.length > 0){
				var mappingAccount:Object = new Object();
				for each(var obj:Object in arr){
					mappingAccount[obj["AccountId"]] = obj;
				}
				
				stmtAccountActivity.parameters[":customObject5Id"] = territoryId;
				stmtAccountActivity.parameters[":startdate"] = startDate;
				stmtAccountActivity.parameters[":enddate"] = endDate;
				exec(stmtAccountActivity);
				arr = stmtAccountActivity.getResult().data;
				convertResultToMap(arr, mappingAccount);
				
				stmtAccountInfo.parameters[":customObject5Id"] = territoryId;
				exec(stmtAccountInfo);
				arr = stmtAccountInfo.getResult().data;
				convertResultToMap(arr, mappingAccount, "0");
				
				
				stmtTargetAccount.parameters[":customObject5Id"] = territoryId;
				stmtTargetAccount.parameters[":month"] = date.getMonth() + 1;
				stmtTargetAccount.parameters[":year"] = date.getFullYear();
				exec(stmtTargetAccount);
				arr = stmtTargetAccount.getResult().data;
				convertResultToMap(arr, mappingAccount, "0");
				
				// For Next Month
				date.setMonth(date.getMonth() + 1);				
				stmtTargetNextMonth.parameters[":customObject5Id"] = territoryId;
				stmtTargetNextMonth.parameters[":month"] = date.getMonth();
				stmtTargetNextMonth.parameters[":year"] = date.getFullYear();
				exec(stmtTargetNextMonth);
				arr = stmtTargetNextMonth.getResult().data;
				convertResultToMap(arr, mappingAccount, "0");
				
				for(var key:String in mappingAccount){
					var object:Object = mappingAccount[key];
					if(!object.hasOwnProperty("ActualVisitYtd")){
						object["ActualVisitYtd"] = "0";
					}
					if(!object.hasOwnProperty("TargetVisitYtd")){
						object["TargetVisitYtd"] = "0";
					}
					if(!object.hasOwnProperty("TargetVisitsNextMonth")){
						object["TargetVisitsNextMonth"] = "0";
					}
					resultAccount.push(object);
				}
				
			}
			return resultAccount;
		}
		
		private function convertResultToMap(arr:Array, mappingAccount:Object, defaultValue:String=""):void{
			for each(var record:Object in arr){
				var object:Object = mappingAccount[record["AccountId"]] ? mappingAccount[record["AccountId"]] : new Object();
				for(var field:String in record){
					if(field == "AccountId") continue;
					object[field] = record[field] ? record[field] : defaultValue;
				}
				mappingAccount[record["AccountId"]] = object;
			}
		}
		
		public function getDefaultRecord():Object{
			exec(stmtGetRecord);
			var sqlResult:SQLResult = stmtGetRecord.getResult();
			if(sqlResult){
				var arr:Array = sqlResult.data;
				if(arr != null && arr.length > 0)
					return arr[arr.length - 1];
			}
			return null;
		}
		
		public function getSegmentSplit(territoryId:String, date:Date):Object{
			// Old Version
//			stmtSelectSegmentSplit.parameters[":customObject5Id"] = territory;
//			exec(stmtSelectSegmentSplit);
//			var sqlResult:SQLResult = stmtSelectSegmentSplit.getResult();
//			if(sqlResult){
//				var arr:Array = sqlResult.data;
//				if(arr != null && arr.length > 0)
//					return arr[0];
//			}
			
			var startDate:String = DateUtils.format(new Date(date.fullYear, date.month, 1),DateUtils.DATABASE_DATE_FORMAT);
			var tempEndDate:Date = new Date(date.fullYear, date.month+1, 0);
			var endDate:String = DateUtils.format(tempEndDate, DateUtils.DATABASE_DATE_FORMAT);
			
			
			stmtSelectSaleRep.parameters[":customObject5Id"] = territoryId;
			stmtSelectSaleRep.parameters[":startdate"] = startDate;
			stmtSelectSaleRep.parameters[":enddate"] = endDate;
			exec(stmtSelectSaleRep);
			var object:Object = new Object();
			var arr:Array = stmtSelectSaleRep.getResult().data;
			var tempObject:Object = checkArrayNull(arr);
			object["Total"] = tempObject ? tempObject["Actual"] : "0";
			
			var arrayCollection:ArrayCollection = new ArrayCollection([
				{A:stmtSelectSegmentA}, {B:stmtSelectSegmentB}, {C:stmtSelectSegmentC}, {D:stmtSelectSegmentD}
			]);
			
			for each(var item:Object in arrayCollection){
				for(var key:String in item){
					var tempStatement:SQLStatement = item[key] as SQLStatement;
					tempStatement.parameters[":customObject5Id"] = territoryId;
					tempStatement.parameters[":startdate"] = startDate;
					tempStatement.parameters[":enddate"] = endDate;
					exec(tempStatement);
					arr = tempStatement.getResult().data;
					tempObject = checkArrayNull(arr);
					object[key] = tempObject ? tempObject["Actual"] : "0";
				}
			}
						
			return object;
		}
		
		private function checkArrayNull(arr:Array):Object{
			if(arr != null && arr.length > 0){
				return arr[0];
			}
			return null;
		}
		
		/**
		 * month : 'March'
		 * year : 2013
		*/
		public function generateTargets(month:String, year:int):Array{
			stmtSelect.parameters[":month"] = month;
			stmtSelect.parameters[":year"] = year;
			exec(stmtSelect);
			return stmtSelect.getResult().data;
		}
		
		
		public function getSalesRep(territoryId:String, date:Date):Object{
			var startDate:String = DateUtils.format(new Date(date.fullYear, date.month, 1),DateUtils.DATABASE_DATE_FORMAT);
			var tempEndDate:Date = new Date(date.fullYear, date.month+1, 0);
			var endDate:String = DateUtils.format(tempEndDate, DateUtils.DATABASE_DATE_FORMAT);
			
			stmtSelectSaleRep.parameters[":customObject5Id"] = territoryId;
			stmtSelectSaleRep.parameters[":startdate"] = startDate;
			stmtSelectSaleRep.parameters[":enddate"] = endDate;
			exec(stmtSelectSaleRep);
			stmtSelectOwnerSaleRep.parameters[":customObject5Id"] = territoryId;
			exec(stmtSelectOwnerSaleRep);
			var arr:Array = stmtSelectSaleRep.getResult().data;
			if(arr != null && arr.length > 0){
				var obj:Object = arr[0];
				var arr1:Array = stmtSelectOwnerSaleRep.getResult().data;
				var object:Object = checkArrayNull(arr1);
				obj["OwnerFullName"] = object ? object["OwnerFullName"] : "";
				return obj;
			}
			return null;
		}
		
		
	}
}