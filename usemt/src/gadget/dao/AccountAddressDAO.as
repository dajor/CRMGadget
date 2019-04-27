//Not used (Account Team cannot be fetched as it is missing.)
package gadget.dao
{
	import flash.data.SQLConnection;

	public class AccountAddressDAO extends SupportDAO	{

		public function AccountAddressDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				sodName: 'Address',
				entity: [ 'Account',   'Address'   ],
				id:     [ 'Id' ],
				columns: TEXTCOLUMNS
				
			},{
				record_type:"CUT Address",
				name_column:["Address"],
				search_columns:["Address"]
			});
			_isGetField = true;
		}
		
		private const TEXTCOLUMNS:Array = [
			ID("Id"),
			//PICK(".Subject","AccountId"),	
			"ModifiedBy",
			"ExternalSystemId",
			"CreatedBy",
			"CreatedDate",
			"ModifiedDate",
			"ModId",
			// "AddressId",
			"City",
			"Country",
			"County",
			"Description",
			"IntegrationId",
			"ZipCode",
			"Province",
			"StateProvince",
			"Address",
			"StreetAddress2",
			"StreetAddress3",
			"ModifiedById",
			"CreatedById"
			
		];
	}
}