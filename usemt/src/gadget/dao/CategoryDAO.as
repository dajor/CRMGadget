// semi-automatically generated from Category.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;

	public class CategoryDAO extends BaseDAO {

		public function CategoryDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'sod_category',
				oracle_id: 'Id',
				name_column: [ 'Id' ],	//___EDIT__THIS___
				search_columns: [ 'Id' ],	//___EDIT__THIS___
				display_name : "Category",	//___EDIT__THIS___
				index: [ 'Id' ],
				columns: { 'TEXT' : textColumns }
			});
		}

		override public function get entity():String {
			return "Category";
		}
		protected override function getIndexColumns():Array{
			return ["deleted", "local_update"];			
			
		}
		private var textColumns:Array = [
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
			"Description",
			"ExternalSystemId",
			"Id",
			"IntegrationId",
			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"Name",
			"ParentCategory",
			"ParentCategoryExternalSystemId",
			"ParentCategoryId",
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
