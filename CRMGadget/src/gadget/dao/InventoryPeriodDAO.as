// semi-automatically generated from CRMODLS_InventoryPeriod.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;

	public class InventoryPeriodDAO extends BaseDAO {

		public function InventoryPeriodDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'sod_inventoryperiod',
				oracle_id: 'Id',
				name_column: [ 'Id' ],	//___EDIT__THIS___
				search_columns: [ 'Id' ],
				display_name : "InventoryPeriod",	//___EDIT__THIS___
				index: [ 'Id' ],
				columns: { 'TEXT' : textColumns }
			});
		}

		override public function get entity():String {
			return "InventoryPeriod";
		}
		
		private var textColumns:Array = [
			"ActiveFlg",
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
			"EndDate",
			"ExternalSystemId",
			"Id",
			"IndexedBoolean0",
			"IndexedCurrency0",
			"IndexedDate0",
			"IndexedNumber0",
			"IndexedPick0",
			"IndexedPick1",
			"IndexedPick2",
			"IndexedPick3",
			"IndexedPick4",
/*
			"ListOfInventoryAuditReport",
			"ListOfSampleInventory",
			"ListOfSampleTransaction",
*/
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
			"ReconciledFlg",
			"StartDate",
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
