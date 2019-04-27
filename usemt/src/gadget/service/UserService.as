package gadget.service
{
	import gadget.dao.Database;

	public class UserService
	{
		
		public static const UNKNOWN:String = "UNKNOWN";
		public static const NESTLE:String = "NESTLE";
		public static const VETOQUINOL:String = "VETOQUINOL";
		public static const DIVERSEY:String = "DIVERSEY";
		public static const SIEMEN:String = "SIEMENS";
		public static const COLOPLAST:String = "COLOPLAST"
		
		public function UserService()
		{
		}
		
		public static function getCustomerId():String {
			try{
				return Database.preferencesDao.getCompanyName();
			}catch(e:Error){
				return UNKNOWN;
			}
			return UNKNOWN;
		}
		
	}
}