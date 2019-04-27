package gadget.sync.incoming
{
	import gadget.dao.Database;
	import gadget.util.DateUtils;
	import gadget.util.FieldUtils;
	import gadget.util.ServerTime;
	
	import mx.collections.ArrayCollection;

	public class IncomingCurrentUserData extends IncomingObject
	{
		public function IncomingCurrentUserData()
		{
			super(Database.allUsersDao.entity);
		}
		
		override protected function doRequest():void {
			
//			if (getLastSync() != NO_LAST_SYNC_DATE){
//				successHandler(null);
//				return;
//			} 
			
			var searchSpec:String =  "[UserSignInId]= '"+Database.userDao.read().user_sign_in_id+"' ";			
			
			
			var pagenow:int = _page;
			
			_lastItems = _nbItems;
			

			sendRequest("\""+getURN()+"\"", new XML(getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, pagenow*pageSize)
				.replace(SEARCHSPEC_PLACEHOLDER, searchSpec)
			));
		}
		override protected function getFields(alwaysRead:Boolean=false):ArrayCollection{
			var fields:ArrayCollection = FieldUtils.allFields(entityIDsod,alwaysRead);
			if(fields==null || fields.length<1){
				fields = new ArrayCollection([
					{element_name:'Alias'},
					{element_name:'AuthenticationType'},
					{element_name:'BusinessUnit'},
					{element_name:'BusinessUnitLevel1'},
					{element_name:'BusinessUnitLevel2'},
					{element_name:'BusinessUnitLevel3'},
					{element_name:'BusinessUnitLevel4'},
					{element_name:'CellPhone'},
					{element_name:'CreatedDate'},
					{element_name:'CurrencyCode'},
					{element_name:'Department'},
					{element_name:'Division'},
					{element_name:'EMailAddr'},
					{element_name:'EmployeeNumber'},
					{element_name:'EnableTeamContactsSync'},
					{element_name:'ExternalIdentifierForSingleSignOn'},
					{element_name:'ExternalSystemId'},
					{element_name:'FirstName'},
					{element_name:'FullName'},
					{element_name:'FundApprovalLimit'},
					{element_name:'Id'},
					{element_name:'IntegrationId'},
					{element_name:'JobTitle'},
					{element_name:'Language'},
					{element_name:'LanguageCode'},
					{element_name:'LastLoggedIn'},
					{element_name:'LastName'},
					{element_name:'LeadLimit'},
					{element_name:'Locale'},
					{element_name:'LocaleCode'},
					{element_name:'ManagerFullName'},
					{element_name:'Market'},
					{element_name:'MiddleName'},
					{element_name:'MiscellaneousNumber1'},
					{element_name:'MiscellaneousNumber2'},
					{element_name:'MiscellaneousText1'},
					{element_name:'MiscellaneousText2'},
					{element_name:'ModifiedDate'},
					{element_name:'MrMrs'},
					{element_name:'NeverCall'},
					{element_name:'NeverMail'},
					{element_name:'NevereMail'},
					{element_name:'PasswordState'},
					{element_name:'PersonalCity'},
					{element_name:'PersonalCountry'},
					{element_name:'PersonalCounty'},
					{element_name:'PersonalPostalCode'},
					{element_name:'PersonalProvince'},
					{element_name:'PersonalState'},
					{element_name:'PersonalStreetAddress'},
					{element_name:'PersonalStreetAddress2'},
					{element_name:'PersonalStreetAddress3'},
					{element_name:'PhoneNumber'},
					{element_name:'PrimaryGroup'},
					{element_name:'Region'},
					{element_name:'Role'},
					{element_name:'RoleId'},
					{element_name:'SecondaryEmail'},
					{element_name:'ShowWelcomePage'},
					{element_name:'Status'},
					{element_name:'SubMarket'},
					{element_name:'SubRegion'},
					{element_name:'TempPasswordFlag'},
					{element_name:'TimeZoneId'},
					{element_name:'TimeZoneName'},
					{element_name:'UserLoginId'},
					{element_name:'UserSignInId'}]);	
		
			}
			return fields;
			
		}
		
		
		
		
		override protected function nextPage(lastPage:Boolean):void {
			//update servertimezone
			var sec:int = DateUtils.getCurrentTimeZone()*3600;
			ServerTime.setSodTZ(sec,null,null,true);
			showCount();
			successHandler(null);
		}
	}
}