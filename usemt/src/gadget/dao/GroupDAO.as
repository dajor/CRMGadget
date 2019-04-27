// semi-automatically generated from Group.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;

	public class GroupDAO extends BaseDAO {

		public function GroupDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'sod_group',
				oracle_id: 'Id',
				name_column: [ 'Name' ],	//___EDIT__THIS___
				search_columns: [ 'Name' ],
				display_name : "Group",	//___EDIT__THIS___
				index: [ 'Id' ],
				columns: { 'TEXT' : textColumns }
			});
		}

		override public function get entity():String {
			return "Group";
		}
		
		protected override function getIndexColumns():Array{
			return ["deleted", "local_update" ];			
			
		}
		
		private var textColumns:Array = [
			"CreatedBy",
			"CreatedByAlias",
			"CreatedByEMailAddr",
			"CreatedByExt",
			"CreatedByExternalSystemId",
			"CreatedById",
			"CreatedByIntegrationId",
			"CreatedByUserSignInId",
			"CreatedDate",
			"CreatedDateExt",
			"Description",
			"Id",
			"ModId",
			"ModifiedBy",
			"ModifiedByAlias",
			"ModifiedByExt",
			"ModifiedById",
			"ModifiedDate",
			"ModifiedDateExt",
			"Name",
			"UpdatedByAlias",
			"UpdatedByEMailAddr",
			"UpdatedByExternalSystemId",
			"UpdatedByFirstName",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			"UserGroupExternalSystemId",
			"UserGroupIntegrationId",
			];
	}
}
