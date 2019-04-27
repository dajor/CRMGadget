// semi-automatically generated from CRMODLS_Signature.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;

	public class SignatureDAO extends BaseDAO {

		public function SignatureDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'sod_signature',
				oracle_id: 'Id',
				name_column: [ 'Id' ],	//___EDIT__THIS___
				search_columns: [ 'Id' ],
				display_name : "Signature",	//___EDIT__THIS___
				index: [ 'Id' ],
				columns: { 'TEXT' : textColumns }
			});
		}
		
		override public function get entity():String {
			return "Signature";
		}
		
		private var textColumns:Array = [
			"ActivityCallType",
			"ActivityExternalSystemId",
			"ActivityId",
			"ActivityIntegrationId",
			"ActivityStatus",
			"ActivitySubject",
			"ContactAccountName",
			"ContactEmail",
			"ContactExternalSystemId",
			"ContactFirstName",
			"ContactFullName",
			"ContactId",
			"ContactIntegrationId",
			"ContactLastName",
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
			"DenormContactFirstName",
			"DenormContactLastName",
			"DisclaimerText",
			"ExternalSystemId",
			"HeaderText",
			"Id",
			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"OwnerAlias",
			"OwnerEMailAddr",
			"OwnerExternalSystemId",
			"OwnerFirstName",
			"OwnerFullName",
			"OwnerId",
			"OwnerIntegrationId",
			"OwnerLastName",
			"OwnerUserSignInId",
			"SalesRepFirstName",
			"SalesRepLastName",
			"SignatureCtrl",
			"SignatureDate",
			"TitleFieldSign",
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
