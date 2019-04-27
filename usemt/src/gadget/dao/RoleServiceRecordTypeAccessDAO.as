package gadget.dao
{
	import flash.data.SQLConnection;
	
	import gadget.service.RightService;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	public class RoleServiceRecordTypeAccessDAO extends SimpleTable {
		
		public function RoleServiceRecordTypeAccessDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				drop_table:true,
				create_cb:function(struct:Object):void { Database.lastsyncDao.unsync('gadget.sync.task::RoleService'); },
				table: "role_service_type",
				unique: [ 'RoleServiceRoleName,RecordName' ],
				index:[]
			});
		}
		
		override public function getColumns():Array {
			return [
				"RoleServiceRoleName",
				"CanCreate",
				"CanReadAll",
				"HasAccess",
				"RecordName",
			];
		}

		
		/**
		 * if item is not exist, it will insert a new record. Otherwise, it will update the existing record. 
		 * @param right
		 * @param entity
		 * 
		 */
		public function upsert(right:Object, entity:String):void {
			var role:String = Database.rightDAO.getRole();
			var prevRight:Object = Database.rightDAO.getRight(role, entity);
			if (prevRight == null) {
				prevRight = {HasAccess:"true", CanCreate:"true", RecordName:entity, RoleServiceRoleName:role, CanReadAll:"true"};				
			}
			Utils.mergeModel(prevRight, right);
			replace(prevRight);
		}
		
	}
}
