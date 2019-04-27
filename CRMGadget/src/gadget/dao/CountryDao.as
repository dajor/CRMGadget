package gadget.dao
{
	import flash.data.SQLConnection;
	
	import gadget.util.StringUtils;
	
	import org.flexunit.runner.Result;

	public class CountryDao extends SimpleTable
	{
		public function CountryDao(sqlConnection:SQLConnection,work:Function)
		{
			super(sqlConnection, work, {
				table: 'country',
				index: ["code"],
				unique : ["code"],
				columns: {gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT", 'TEXT' : ["code", "displayname","distance"]}
			});
			
		}
		public function getByCode(code:String):Object{
			var result:Array = fetch({'code':code});
			if(result!=null&& result.length>0){
				return result[0];
			}
			return null;
		}
		public function getDistance(code:String):String{
			var result:Object = getByCode(code);
			if(result!=null){
				var distance:String = result.distance;
				if(!StringUtils.isEmpty(distance)){
					return distance;
				}
			}
			//miles is default
			return 'imperial';
			
		}
		
		
	

		
	}
}