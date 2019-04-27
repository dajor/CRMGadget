package gadget.dao
{
	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;
	
	public class CustomeObjectBaseDao extends BaseDAO
	{
		public function CustomeObjectBaseDao(work:Function, sqlConnection:SQLConnection, structure:Object)
		{
			super(work, sqlConnection, structure);
		}
		
		override public function getOwnerFields():Array{
			var mapfields:Array = [
				{entityField:"OwnerAlias", userField:"Alias"},{entityField:"OwnerId", userField:"Id"}
			];
			return mapfields;
			
		}
		
		override public function getIgnoreCopyFields():ArrayCollection{
			return new ArrayCollection(
				[					
					'Id',
					'gadget_id',
					'local_update',
					'delete',
					'error',
					'ood_lastmodified',
					'sync_number',
					'important',
					'favorite'
				]);
		}
	}
}