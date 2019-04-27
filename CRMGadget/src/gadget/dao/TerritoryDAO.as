// semi-automatically generated from Territory.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;

	public class TerritoryDAO extends BaseDAO {

		public function TerritoryDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'territory',
				oracle_id: 'TerritoryName',//cannot get field 'id' from oracle---bug#341
				name_column: [ 'TerritoryName' ],	//___EDIT__THIS___
				search_columns: [ 'TerritoryName' ],
				display_name : "Territory",	//___EDIT__THIS___
				index: [ 'TerritoryName' ],
				columns: { 'TEXT' : textColumns }
			});
		}

		override public function get entity():String {
			return "Territory";
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
			"CurrencyCode",
			"CurrentQuota",
			"Description",
			"ExternalSystemId",
			"Id",
			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"ParentTerritoryExternalSystemId",
			"ParentTerritoryId",
			"ParentTerritoryName",
			"TerritoryName",
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
