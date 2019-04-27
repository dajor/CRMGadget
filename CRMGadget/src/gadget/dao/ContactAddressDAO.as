// semi-automatically generated from CRMOD_LS_ContactLicenses.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;

	public class ContactAddressDAO extends SupportDAO {

		public function ContactAddressDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				sodName: 'Address',
				entity: [ 'Contact',   'Address'   ],
				id:     ['Id' ],
				columns: TEXTCOLUMNS
				
			},{
				record_type:"Call Address",
				name_column:["Address"],
				search_columns:["Address"]
			});
		}

		
		private const TEXTCOLUMNS:Array = [
			ID("Id"),
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
