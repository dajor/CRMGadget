package gadget.sync.incoming
{
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.sync.task.SyncTask;
	
	public class GetOwnerUserData extends SyncTask {
		
		
		private var handlerCompleteGetOwnerUser:Function = null;
		private var sessionId:String = null;
		
		public function GetOwnerUserData(completeHandler:Function, sessionId:String){
			// super(Database.allUsersDao.entity);
			// this.currentUser = currentUser;
			this.handlerCompleteGetOwnerUser = completeHandler;
			this.sessionId = sessionId;
		}
		
		override protected function doRequest():void {
			
			var currentUser:Object = Database.userDao.read();
			var soapAction:String = "\"document/urn:crmondemand/ws/ecbs/user/:UserQueryPage\"";
			
			var searchSpec:String =  "[UserSignInId]= '" + currentUser.user_sign_in_id + "' ";	
			
			/*var userFields:String = "";
			for each(var field:String in USER_FIELDS){
				userFields += "<" + field + ">";
			}*/
			
			// urn:crmondemand/ws/ecbs/user/
			var rXml:XML = <UserQueryPage_Input xmlns='urn:crmondemand/ws/ecbs/user/'>
				<ViewMode>Broadest</ViewMode>
				<ListOfUser pagesize={50} startrownum={0}>
					<User searchspec={searchSpec}>
						<Alias/>
						<AuthenticationType/>
						<BusinessUnit/>
						<BusinessUnitLevel1/>
						<BusinessUnitLevel2/>
						<BusinessUnitLevel3/>
						<BusinessUnitLevel4/>
						<CellPhone/>
						<CreatedDate/>
						<CurrencyCode/>
						<CustomPickList0/>
						<Department/>
						<Division/>
						<EMailAddr/>
						<EmployeeNumber/>
						<EnableTeamContactsSync/>
						<ExternalIdentifierForSingleSignOn/>
						<ExternalSystemId/>
						<FirstName/>
						<FundApprovalLimit/>
						<Id/>
						<IntegrationId/>
						<JobTitle/>
						<Language/>
						<LanguageCode/>
						<LastLoggedIn/>
						<LastName/>
						<LeadLimit/>
						<Locale/>
						<LocaleCode/>
						<ManagerFullName/>
						<Market/>
						<MiddleName/>
						<MiscellaneousNumber1/>
						<MiscellaneousNumber2/>
						<MiscellaneousText1/>
						<MiscellaneousText2/>
						<ModifiedDate/>
						<MrMrs/>
						<NeverCall/>
						<NevereMail/>
						<NeverMail/>
						<PasswordState/>
						<PersonalCity/>
						<PersonalCountry/>
						<PersonalCounty/>
						<PersonalPostalCode/>
						<PersonalProvince/>
						<PersonalState/>
						<PersonalStreetAddress/>
						<PersonalStreetAddress2/>
						<PersonalStreetAddress3/>
						<PhoneNumber/>
						<PrimaryGroup/>
						<Region/>
						<Role/>
						<RoleId/>
						<SecondaryEmail/>
						<ShowWelcomePage/>
						<Status/>
						<SubMarket/>
						<SubRegion/>
						<TempPasswordFlag/>
						<TimeZoneId/>
						<TimeZoneName/>
						<UserLoginId/>
						<UserSignInId/>
						<WorkFax/>
					</User>
				</ListOfUser>
			</UserQueryPage_Input>;
			
			var preferences:Object = Database.preferencesDao.read();
			
			// doSendRequest2(soapAction, rXml, preferences);
			sendRequest(soapAction, rXml);
		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			
			var tmpOb:Object={};
			var entityIDns:String = "User";
			var entitySod:String = "User";
			var ns2:Namespace = new Namespace("urn:/crmondemand/xml/"+entityIDns+"/Data");
			var listObject:XML = result.child(new QName(ns2.uri, "ListOfUser"))[0];
			var list:XMLList = listObject.child(new QName(ns2.uri,entityIDns));
				for each (var data:XML in list) {
					for each (var fieldName:String in USER_FIELDS) {
						var xmllist:XMLList = data.child(new QName(ns2.uri,WSProps.ws10to20(entitySod, fieldName)));
						if (xmllist.length()>1)
							trace(fieldName,xmllist.length());
						if (xmllist.length() > 0) {
							tmpOb[fieldName] = xmllist[0].toString();
						} else {
							tmpOb[fieldName] = null;
						}
					}
					break;
				}
			
			handlerCompleteGetOwnerUser(tmpOb, "", sessionId);			
			return 0;
		}
		
		override public function getEntityName():String {
			return "AllUser";
		}
		
		override public function getName():String {
			return "Receiving current user updates from server..."; 
		}
		
		
		override protected function nextPage(lastPage:Boolean, minRow:int=0, mustBeSame:String=''):void {
					
		}
		
		
		public static const USER_FIELDS:Array = [
			"Alias",
			"AuthenticationType",
			"BusinessUnit",
			"BusinessUnitLevel1",
			"BusinessUnitLevel2",
			"BusinessUnitLevel3",
			"BusinessUnitLevel4",
			"CellPhone",
			"CreatedDate",
			"CurrencyCode",
			"CustomPickList0",
			"Department",
			"Division",
			"EMailAddr",
			"EmployeeNumber",
			"EnableTeamContactsSync",
			"ExternalIdentifierForSingleSignOn",
			"ExternalSystemId",
			"FirstName",
			"FundApprovalLimit",
			"Id",
			"IntegrationId",
			"JobTitle",
			"Language",
			"LanguageCode",
			"LastLoggedIn",
			"LastName",
			"LeadLimit",
			"Locale",
			"LocaleCode",
			"ManagerFullName",
			"Market",
			"MiddleName",
			"MiscellaneousNumber1",
			"MiscellaneousNumber2",
			"MiscellaneousText1",
			"MiscellaneousText2",
			"ModifiedDate",
			"MrMrs",
			"NeverCall",
			"NeverMail",
			"NevereMail",
			"PasswordState",
			"PersonalCity",
			"PersonalCountry",
			"PersonalCounty",
			"PersonalPostalCode",
			"PersonalProvince",
			"PersonalState",
			"PersonalStreetAddress",
			"PersonalStreetAddress2",
			"PersonalStreetAddress3",
			"PhoneNumber",
			"PrimaryGroup",
			"Region",
			"Role",
			"RoleId",
			"SecondaryEmail",
			"ShowWelcomePage",
			"Status",
			"SubMarket",
			"SubRegion",
			"TempPasswordFlag",
			"TimeZoneId",
			"TimeZoneName",
			"UserLoginId",
			"UserSignInId",
			"WorkFax",
			
		];
		
		
		
	}
	
	
	
}