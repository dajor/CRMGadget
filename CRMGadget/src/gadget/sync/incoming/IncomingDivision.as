package gadget.sync.incoming
{
	import gadget.dao.Database;

	public class IncomingDivision extends IncomingObject
	{
		public function IncomingDivision()
		{
			super(Database.divisionDao.entity);
		}
		
		protected override function getViewmode():String{
			
			return "Broadest";
		}
	}
}