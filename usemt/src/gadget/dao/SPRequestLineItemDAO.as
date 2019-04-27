// semi-automatically generated from SPRequestLineItem.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;

	public class SPRequestLineItemDAO extends BaseDAO {

		public function SPRequestLineItemDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'sod_sprequestlineitem',
				oracle_id: 'Id',
				name_column: [ 'Id' ],	//___EDIT__THIS___
				search_columns: [ 'Id' ],
				display_name : "SPRequestLineItem",	//___EDIT__THIS___
				index: [ 'Id' ],
				columns: { 'TEXT' : textColumns }
			});
		}

		override public function get entity():String {
			return "SPRequestLineItem";
		}
		
		protected override function getIndexColumns():Array{
			return ["deleted", "local_update"];			
			
		}
		private var textColumns:Array = [
			"AuthorizedAmount",
			"AuthorizedCost",
			"AuthorizedDiscountPercent",
			"CompetitivePartner",
			"CompetitorName",
			"CompetitorProduct",
			"CompetitorProductPrice",
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
			"ExchangeDate",
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
			"ItemNumber",
			"MSRP",
			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"OtherCompetitiveInformation",
			"ProductCategory",
			"ProductDescription",
			"ProductExternalSystemId",
			"ProductId",
			"ProductIntegrationId",
			"ProductName",
			"ProductPartNumber",
			"ProductStatus",
			"ProductType",
			"PurchaseCost",
			"Quantity",
			"RequestedAmount",
			"RequestedCost",
			"RequestedDiscountPercent",
			"RequestedResalePrice",
			"SPRequestExternalSystemId",
			"SPRequestId",
			"SPRequestIntegrationId",
			"SPRequestSPRequestName",
			"SuggestedResalePrice",
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
