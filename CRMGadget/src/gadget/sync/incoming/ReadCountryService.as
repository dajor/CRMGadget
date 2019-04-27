package gadget.sync.incoming
{
	
	
	import gadget.dao.CountryDao;
	import gadget.dao.Database;

	public class ReadCountryService extends ReadPicklist
	{
		public function ReadCountryService()
		{
			super();
		}
		
		override protected function doRequest():void {
			var request:XML =
				<PicklistWS_GetPicklistValues_Input xmlns='urn:crmondemand/ws/picklist/'>
					<FieldName>PersonalCountry</FieldName>
					<RecordType>User</RecordType>
				</PicklistWS_GetPicklistValues_Input>;
			sendRequest("\"document/urn:crmondemand/ws/picklist/:GetPicklistValues\"", request);
		}
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
			if (!mess)
				return false;
			if (mess.indexOf("(SBL-ODS-50720)")>0
				|| mess.indexOf("(SBL-ODS-50085)")>0
				|| mess.indexOf("(SBL-SBL-00000)")>0
				|| mess.indexOf("(SBL-ODS-50731)")>0 
				|| mess.indexOf("(SBL-ODS-50735)")>0//field requested is not a valid picklist.
				//|| (mess.indexOf("(SBL-SBL-00000)")>0 && allPicklists[currentPicklist].element_name=='Sub_Class') 
			) {
				trace("pick",'User',"list",'PersonalCountry',"err:",errors.toXMLString());				
				_nbItems++;
				
			}
			
			nextPage(true);
			return true;
		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}
		
			var cnt:int = 0;
			var recordType:String = request.ns1::RecordType[0].toString();
			var fieldName:String = request.ns1::FieldName[0].toString();
			
			var picklistDao:CountryDao =Database.countryDao;
			Database.begin();
			
			for each(var pvalue:XML in result.ns2::ListOfParentPicklistValue[0].ns2::ParentPicklistValue) {
				for each(var value:XML in pvalue.ns2::ListOfPicklistValue[0].ns2::PicklistValue) {
					var code:String = value.ns2::Code[0].toString();
					
						var disabled:String = value.ns2::Disabled[0].toString();
						if(disabled=='N'){
						var currentValue:Object = picklistDao.getByCode(code);
						if(currentValue!=null) {
							currentValue.displayname = value.ns2::DisplayValue[0].toString();
							picklistDao.update(currentValue,{'code':code});
						}
						}
						
						cnt++;
						_nbItems++;
					}
				
			}
			Database.commit();
			notifyCreation(false, recordType+"/"+fieldName);
			
			nextPage(true);
			return cnt;
		}
		
		override public function getName():String {
			return "Reading Country from server..."; 
		}
		override public function getEntityName():String {
			return "Country records";
		}
	}
}