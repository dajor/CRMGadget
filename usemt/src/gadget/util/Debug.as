package gadget.util
{
	import gadget.dao.Database;

	public class Debug
	{
		public static function isVerbose():Boolean {
			var verb:String = Database.preferencesDao.getStrValue("verbose");
			return (verb && verb>"0");
		}
	}
}