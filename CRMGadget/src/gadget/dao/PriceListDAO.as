// semi-automatically generated from PriceList.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;

	public class PriceListDAO extends BaseDAO {

		public function PriceListDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'sod_pricelist',
				oracle_id: 'Id',
				name_column: [ 'Id' ],	//___EDIT__THIS___
				search_columns: [ 'Id' ],
				display_name : "PriceList",	//___EDIT__THIS___
				index: [ 'Id' ],
				columns: { 'TEXT' : textColumns }
			});
		}

		override public function get entity():String {
			return "PriceList";
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
/*
			"ListOfAccount",
			"ListOfPartner",
			"ListOfPriceListLineItem",
			"ListOfSPRequest",
*/
			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"PriceListName",
			"Status",
			"Type",
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
