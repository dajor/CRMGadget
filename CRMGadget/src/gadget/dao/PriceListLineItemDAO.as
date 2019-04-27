// semi-automatically generated from PriceListLineItem.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;

	public class PriceListLineItemDAO extends BaseDAO {

		public function PriceListLineItemDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'sod_pricelistlineitem',
				oracle_id: 'Id',
				name_column: [ 'Id' ],	//___EDIT__THIS___
				search_columns: [ 'Id' ],
				display_name : "PriceListLineItem",	//___EDIT__THIS___
				index: [ 'Id' ],
				columns: { 'TEXT' : textColumns }
			});
		}

		override public function get entity():String {
			return "PriceListLineItem";
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
			"Description",
			"EffectiveFrom",
			"EffectiveTo",
			"ExchangeDate",
			"ExternalSystemId",
			"Id",
			"IndexedBoolean0",
			"IndexedDate0",
			"IndexedNumber0",
			"IndexedPick0",
			"IndexedPick1",
			"IndexedPick2",
			"IndexedPick3",
			"IndexedPick4",
			"IntegrationId",
			"LineItem",
			"ListPrice",
			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"PriceListExternalSystemId",
			"PriceListId",
			"PriceListIntegrationId",
			"PriceListPriceListName",
			"PriceListStatus",
			"PriceType",
			"ProductCategory",
			"ProductDescription",
			"ProductExternalSystemId",
			"ProductId",
			"ProductIntegrationId",
			"ProductName",
			"ProductPartNumber",
			"ProductStatus",
			"ProductType",
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
