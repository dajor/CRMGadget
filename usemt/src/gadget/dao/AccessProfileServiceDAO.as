package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class AccessProfileServiceDAO extends SimpleTable {
		
		public function AccessProfileServiceDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "access_profile",
				unique: [ 'Name' ],
				index:[]
			});
		}
		
		override public function delete_all():void {
			del(null);
			Database.accessProfileServiceTransDao.delete_all();
			Database.accessProfileServiceEntryDao.delete_all();
		}
		
		override public function getColumns():Array {
			return [
				'Name',
				'Description',
				'AvailableForTeam',
				'AvailableForBook',
				'Disabled',
			];
		}
	}
}
