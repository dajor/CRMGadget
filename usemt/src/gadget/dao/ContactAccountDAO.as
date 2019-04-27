package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class ContactAccountDAO extends SupportDAO {

		
		protected var stmtFindMissingContact:SQLStatement;
		public function ContactAccountDAO(sqlConnection:SQLConnection, work:Function) {

			super(work, sqlConnection, {
				entity: [ 'Contact',   'Account'   ],
				id:     [ 'ContactId', 'AccountId' ],
				columns: TEXTCOLUMNS
			},{
//				record_type:"Account Contact",
				unique:['ContactId,AccountId'],
				name_column:["ContactFullName"],
				search_columns:["AccountName"],
				oracle_id:"Id",		//VAHI's not so evil kludge
				columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
			});
			SupportRegistry.init_registry('Account.Contact' , this);
			_isSyncWithParent = false;
			_isGetField = true;
			stmtFindMissingContact = new SQLStatement();
			stmtFindMissingContact.sqlConnection = sqlConnection;
			stmtFindMissingContact.text = "select ContactId from contact_account where ContactType!='End User' and ContactId not in(select contactid from contact)";
		}
		
		
		override public function deleteByChildId(parentId:String,childId:String):void{
			exec_cmd("DELETE FROM contact_account WHERE AccountId='"+parentId+"' AND ContactId='"+childId+"'");
		}
		
		public function findMissingContact():ArrayCollection{
			exec(stmtFindMissingContact);
			var items:ArrayCollection = new ArrayCollection(stmtFindMissingContact.getResult().data);
			var result:ArrayCollection = new ArrayCollection();
			if(items.length>0){
				for each(var o:Object in items){
					var id:String = o['ContactId'];
					if(id!=null && id.indexOf("#")==-1){
						result.addItem(id);	
					}
					
				}
				
			}
			return result;
		}

		private const TEXTCOLUMNS:Array = [
			ID("Id"),
			
			PICK("AccountExternalSystemId","AccountId"),
			PICK("AccountName","AccountId"),
			PICK("AccountIntegrationId","AccountId"),
			PICK("AccountLocation","AccountId"),
			PICK("AccountMainPhone","AccountId"),
			PICK("AccountType","AccountId"),

			PICK("ContactEmail","ContactId"),
			PICK("ContactExternalSystemId","ContactId","ExternalSystemId"),
			PICK("ContactFirstName","ContactId"),
			PICK("ContactFullName","ContactId"),
			PICK("ContactIntegrationId","ContactId","IntegrationId"),
			PICK("ContactJobTitle","ContactId","JobTitle"),
			PICK("ContactLastName","ContactId"),
			PICK("ContactType","ContactId"),
			PICK("ContactWorkPhone","ContactId","WorkPhone"),

			"AccountId",
			"ContactId",
			"CreatedBy",
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

			"Description",		// comment (non-mandatory title)

			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",

			"PrimaryAccount",	// Boolean
			"PrimaryContact",	// Boolean

			"Role",				//VAHI I really have no idea
			"RoleList",			//VAHI I really have no idea

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