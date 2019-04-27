package gadget.dao
{
	import flash.data.SQLConnection;
	
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	public class CustomObject2ContactDAO extends SupportDAO
	{
		public function CustomObject2ContactDAO(sqlConnection:SQLConnection, work:Function)
		{
			super(work, sqlConnection, {
				entity: [ 'Contact',   'Custom Object 2'   ],
				id:     [ 'ContactId', 'Id' ],
				columns: TEXTCOLUMNS
			},{
				//				record_type:"Account Contact",
				table: 'contact_customobject2',
				unique:['ContactId,Id'],
				name_column:["ContactFullName"],
				search_columns:["ContactFullName"],
				oracle_id:"DummySiebelRowId",		//VAHI's not so evil kludge
				columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
			});
			SupportRegistry.init_registry('Contact.CustomObject2' , this);
			_isSyncWithParent = false;
			_isGetField = false;
		}
		protected override function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection([
				"ContactId","ContactFullName"
			]);
		}
		protected override function getIncomingIgnoreFields():ArrayCollection{
			return new ArrayCollection([
				"ContactId","ContactFullName"
			]);
		}
		
		public override function findRelatedData(parentEntity:String , oracleId:String):ArrayCollection {
			if(parentEntity==Database.contactDao.entity){
				return Database.contactDao.getContactCustomObject2(oracleId);
			}else{
				return Database.customObject2Dao.getContactCustomObject2(oracleId);
			}
		}
		
		override public final function fix_sync_incoming(ob:Object, assoc:Object=null):Boolean {
			//Fiddle in the ActivityId which is missing
			//ob.ContactId = assoc.ContactId;
			
			//try to find DummySiebelRowId for a matching record
			ob.DummySiebelRowId = StringUtils.toString(b_value("DummySiebelRowId",{ContactId:ob.ContactId,Id:ob.Id}));
			return true;
		}
		
		override public function fix_sync_add(ob:Object,parent:Object=null):void {
			b_exec("UPDATE", "SET DummySiebelRowId=gadget_id WHERE DummySiebelRowId IS NULL");
		}
		
		override public final function fix_sync_outgoing(ob:Object):Boolean {
			ob.DummySiebelRowId = ob.gadget_id;
			return true;
		}
		
		override public function deleteByChildId(parentId:String,childId:String):void{
			exec_cmd("DELETE FROM contact_account WHERE ContactId='"+parentId+"' AND Id='"+childId+"'");
		}
		
		private const TEXTCOLUMNS:Array = [
			//ignore ContactId
			"ContactId",
			"ContactFullName",
			"ModifiedDate",
			"CreatedDate",
			"ModifiedById",
			"CreatedById",
			"ModId",
			"Id",
			"Type",
			"Name",
			"CreatedBy",
			"ExternalSystemId",
			"IntegrationId",
			"UpdatedByFirstName",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			"UpdatedByAlias",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByExternalSystemId",
			"UpdatedByEMailAddr",
			"CreatedByUserSignInId",
			"CreatedByAlias",
			"CreatedByIntegrationId",
			"CreatedByExternalSystemId",
			"CreatedByEMailAddr",
			"ModifiedBy"	
			];
			
			
	}
}