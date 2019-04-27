// Arnaud noted to me (VAHI) that the Id field apparently contains the ContactId.
// I am not completely sure that this field is not in fact the PartyId (which then
// happens to be the ContactId most time, but not always).
//
// Let's see how it works out.  Hopefully Arnaud is right.
// So this DAO now is implemented using following properties:
//
// A) ActivityId is missing and added on the fly in Sync - currently by a Hack of Arnaud
// B) ContactId is taken from the "Id" field
// C) There is no oracle Id.  Instead we use gadget_id for this.
//
// The C) is especially evil, the alternative would be to create an artificial column
// which is not needed at all and not filled at all.  However this column then always
// is NULL, which perhaps makes it impossible to update certain records.

package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.utils.Dictionary;
	
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	public class ActivityContactDAO extends SupportDAO {
		protected var stmtSelectContact:SQLStatement;
		protected var stmtSelectActivity:SQLStatement;
		public function ActivityContactDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				entity: ['Activity',   'Contact'],
				id:     ['ActivityId', 'Id' ],
				columns: TEXTCOLUMNS
			}
			,{
				unique:['ActivityId,Id'],
//				clean_table:true,---no need to clear db 
				name_column:["ContactFullName"],
				search_columns:["ContactFullName"],
				oracle_id:"DummySiebelRowId",		//VAHI's not so evil kludge
				columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
			});
			SupportRegistry.init_registry('Contact.Activity' , this);
			_isSyncWithParent = false;
			_isSelectAll=true;
			
			stmtSelectContact = new SQLStatement();
			stmtSelectContact.sqlConnection = sqlConnection;
			stmtSelectContact.text = "SELECT 'Contact' gadget_type, * FROM Contact WHERE ContactId in (SELECT Id FROM activity_contact WHERE ( deleted = 0 OR deleted IS null ) AND ActivityId = :ActivityId);";
			stmtSelectActivity = new SQLStatement();
			stmtSelectActivity.sqlConnection = sqlConnection;
			stmtSelectActivity.text = "SELECT 'Activity' gadget_type, * FROM Activity WHERE ActivityId in (SELECT ActivityId FROM activity_contact WHERE ( deleted = 0 OR deleted IS null ) AND Id = :ContactId) OR PrimaryContactId=:ContactId";
			
		}
		public override function getLinkFields():Dictionary{
			var fields:Dictionary = new Dictionary();
			fields["ContactLastName"]=Database.contactDao.entity;
			return fields;
			
		}
		override public final function fix_sync_incoming(ob:Object, assoc:Object=null):Boolean {
			//Fiddle in the ActivityId which is missing
			if(assoc!=null){
				ob.ActivityId = assoc.ActivityId;
				ob.Subject = assoc.Subject;		// It cannot hurt to do this.
			}
			
			//try to find DummySiebelRowId for a matching record
			ob.DummySiebelRowId = StringUtils.toString(b_value("DummySiebelRowId",{ActivityId:ob.ActivityId,Id:ob.Id}));
			return true;
		}
		
		public override function findRelatedData(parentEntity:String , oracleId:String):ArrayCollection {
			if(parentEntity==Database.activityDao.entity){
				stmtSelectContact.parameters[":ActivityId"]=oracleId;
				exec(stmtSelectContact);
				return new ArrayCollection(stmtSelectContact.getResult().data);
			}else{
				stmtSelectActivity.parameters[":ContactId"]=oracleId;
				exec(stmtSelectActivity);
				return new ArrayCollection(stmtSelectActivity.getResult().data);
			}
		}

		override public function fix_sync_add(ob:Object,parent:Object=null):void {
			b_exec("UPDATE", "SET DummySiebelRowId=gadget_id WHERE DummySiebelRowId IS NULL");
		}

		override public final function fix_sync_outgoing(ob:Object):Boolean {
			ob.DummySiebelRowId = ob.gadget_id;
			return true;
		}
		
		override protected function getIncomingIgnoreFields():ArrayCollection{
			return new ArrayCollection([
				"ActivityId",				
				"Subject",
				"AccountName"
			
			]);
		}
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection([
			
				"ActivityId",				
				"Subject",
				"ContactEmail",
				"ContactFirstName",
				"ContactFullName",
				"ContactLastName",
				
				"AccountName",	
				
				"CreatedByAlias",
				"CreatedByEMailAddr",
				"CreatedByExternalSystemId",
				"CreatedByFirstName",
				"CreatedByFullName",
				"CreatedById",
				"CreatedByIntegrationId",
				"CreatedByLastName",
				"CreatedByUserSignInId",
				"CreatedDate",
				
				"ExternalSystemId",		
				"IntegrationId",	
				
				"ModId",
				"ModifiedById",
				"ModifiedDate",
				
				"UpdatedByAlias",
				"UpdatedByEMailAddr",
				"UpdatedByExternalSystemId",
				"UpdatedByFirstName",
				"UpdatedByFullName",
				"UpdatedByIntegrationId",
				"UpdatedByLastName",
				"UpdatedByUserSignInId",
			
			]);
			
		}

		private const TEXTCOLUMNS:Array = [
//			ID(".DummySiebelRowId"),
			ID(".ActivityId"),				// Missing in WSDL
			PICK(".Subject","ActivityId"),	// Missing in WSDL
			PICK("ContactEmail", "Id"),
			PICK("ContactFirstName", "Id"),
			PICK("ContactFullName", "Id"),
			PICK("ContactLastName", "Id"),
			
			"AccountName",			//VAHI I really have no idea

			"CreatedByAlias",
			"CreatedByEMailAddr",
			"CreatedByExternalSystemId",
			"CreatedByFirstName",
			"CreatedByFullName",
			"CreatedById",
			"CreatedByIntegrationId",
			"CreatedByLastName",
			"CreatedByUserSignInId",
			"CreatedDate",

			"ExternalSystemId",		//VAHI I have no idea
			"IntegrationId",		// By default this is the "Id" of this intersection entry (but it can differ)

			"ModId",
			"ModifiedById",
			"ModifiedDate",

			"UpdatedByAlias",
			"UpdatedByEMailAddr",
			"UpdatedByExternalSystemId",
			"UpdatedByFirstName",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
		];
	}
}
