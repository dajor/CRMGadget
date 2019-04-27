package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class ImpactCalendarDao extends SimpleTable
	{
		public function ImpactCalendarDao(sqlConnection:SQLConnection, work:Function)
		{
			super(sqlConnection,work, {
				table: 'impact_calendar',
				index: ["OpportunityId"],
				columns: { gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT",'TEXT' : textColumns }
			});
			
		}
		
		public static var textColumns:Array = [
			"OpportunityId",
			"Oct",
			"Nov",
			"Dec",
			"Jan",
			"Feb",
			"Mar",
			"Apr",
			"May",
			"Jun",
			"Jul",
			"Aug",
			"Sep",
			"OctNext",
			"NovNext",
			"DecNext",
			"JanNext",
			"FebNext",
			"MarNext",
			"AprNext",
			"MayNext",
			"JunNext",
			"JulNext",
			"AugNext",
			"SepNext",
			"ProductDescription",
			"NumberOfPatients",
			"ValueOfPatients",
			"ValueOfProduct",
			"FYTarget"];
	}
	
}