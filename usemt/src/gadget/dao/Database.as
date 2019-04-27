// In order to show what's going on in the splash screen, every action is pushed into an array (handled in MainWindow.mxml)
// Between calls to the work pieces, the GUI gets some time to display the current task.

// Task parameters must be passed as object parameters to anonymous functions, else only the last values are taken into account,
// which cause bugs when we are inside a for loop.

// The functions have been renamed to following schema (first letter):
//	Iname	Init functions which must only call Iname or Xname functions to do all the dirty work.
//	Xname	A function which create some piece(s) of work.  ALL ACCESS TO DB MUST BE WITHIN THE WORKER! 
//	Yname	A function which is used in the transactional part (the last piece of work)
//	Zname	A function which must only be called from within worker parts or Y-functions.
// without the rename it's too confusing to keep oversight.
//
// These are the templates.  Please note that the functions are all "private function", nothing else.
//
// private function I___CHANGEME____(sqlConnection:SQLConnection):void {
//    HERE ONLY X FUNCTIONS ARE CALLED, NO USE OF _work()
// }
//
// private function X___CHANGEME____(sqlConnection:SQLConnection __ADDITIONAL_PARAMETERS__):void {
//    _work("Checking table "+table + "...", function(params:Object):void {
//      HERE YOU __MUST__NOT__ CALL ANY I OR X FUNCTIONS
//    }, {__OPTIONAL_PARAMETER_OBJECT__});
//   Optionally call more _work() here.
// private function Y___CHANGEME____(__PARAMETERS__):void {
//    HERE YOU MUST NOT CALL ANY I OR X FUNCTIONS
//    You should only call Z functions.
// }
// private function Z___CHANGEME____(__PARAMETERS__):__RETURN__ {
//    HERE YOU MUST NOT CALL I, X OR Y FUNCTIONS.
// }

package gadget.dao {
	
	import com.google.analytics.debug.Alert;
	
	import flash.data.SQLColumnSchema;
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLSchemaResult;
	import flash.data.SQLStatement;
	import flash.data.SQLTableSchema;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import gadget.i18n.i18n;
	import gadget.service.LocaleService;
	import gadget.sync.WSProps;
	import gadget.util.DateUtils;
	import gadget.util.EncryptionKeyGenerator;
	import gadget.util.FieldUtils;
	import gadget.util.OOPStrace;
	import gadget.util.SodUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.StringUtil;
	
	
	public class Database extends BaseSQL {
		
		public static const ENCRYPTED_DB_NAME:String = "gadget2gox.db";
		public static const DB_NAME:String = "gadget2go.db";
		public static const DISABLE_EULA:String = "disable_eula.txt";
		public static const CUSTOM_DATABASE:String = "gadget_conf.xml";
		public static const FAVORITE:int = -8;
		public static const IMPORTANT:int = -9;
		public static const MISSING_PDF:int =-4;
		public static const CUSTOMERS:int = -3;
		public static const COMPETITORS:int =-4;
		private var _relatedButtonDAO:RelatedButtonDAO;
		private var _image:ImageDAO;
		private var _tempFolder:File;
		private var _sqlConnection:SQLConnection;
		private var _preferencesDao:PreferencesDAO;
		private var _contactDao:ContactDAO;
		private var _accountDao:AccountDAO;
		private var _opportunityDao:OpportunityDAO;
		private var _activityDao:ActivityDAO;
		private var _linkDao:LinkDAO;
		private var _filterDao:FilterDAO;
		private var _customTableWidthConfigurationDAO:CustomTableWidthConfigurationDAO;
		private var _criteriaDao:CriteriaDAO;
		private var _picklistDao:PicklistDAO;
		private var _userDao:UserDAO;
		private var _registeredUserDao:RegisteredUserDAO;
		private var _addressDao:AddressDAO;
		private var _netbreezeDao: NetbreezeDAO;
		private var _netbreezeAccountDao: NetbreezeAccountDAO;
		private var _layoutDao:LayoutDAO;
		private var _customFieldDao:CustomFieldDAO;
		private var _customFieldTranslatorDao:CustomFieldTranslatorDAO;
		private var _customPicklistValueDao:CustomPicklistValueDAO;
		private var _validationRuleDAO:ValidationRuleDAO;
		private var _validationRuleTranslatorDAO:ValidationRuleTranslatorDAO;
		private var _columnsLayoutDao:ColumnsLayoutDAO;
		private var _attachmentDao:AttachmentDAO;
		private var _activityUserDao:ActivityUserDAO;
		private var _productDao:ProductDAO;
		private var _serviceDao:ServiceDAO;
		private var _fieldDao:FieldDAO;
		private var _salesProcDao:SalesProcDAO;
		private var _salesStageDao:SalesStageDAO;
		private var _campaignDao:CampaignDAO;
		private var _transactionDao:TransactionDAO;
		private var _subSyncDao:SubSyncDAO;
		private var _relationManagementDao:RelationManagementDAO;
		private var _customObject1Dao:CustomObject1DAO;		
		private var _opportunityTeamDao:OpportunityTeamDAO;
		private var _recentDao:RecentDAO;
		private var _bookmarkDao:BookmarkDAO;
		private var _recordTypeDao:RecordTypeDAO;
		private var _leadDao:LeadDAO;
		private var _lastsyncDao:LastSyncDAO;
		private var _validationDao:ValidationDAO;
		private var _incomingSyncDao:IncomingSyncDAO;
		private var _customLayoutDao:CustomLayoutDAO;
		private var _errorLoggingDao:ErrorLoggingDAO;	//VAHI added for better Sync error reporting
		private var _activityProductDao:ActivityProductDAO;
		private var _allUsersDao:AllUsersDAO;
		private var _accountActivityDao:AccountActivityDAO;	//VAHI needed
		
		private var _accountOpportunityDao:AccountOpportunityDAO;
		private var _accountAccountDao:AccountAccountDAO;
		private var _accountCustomObject2Dao:AccountCustomObject2DAO;
		private var _accountCustomObject3Dao:AccountCustomObject3DAO;
		private var _accountCustomObject4Dao:AccountCustomObject4DAO;
		private var _accountCustomObject10Dao:AccountCustomObject10DAO;
		private var _accountObjectiveDao:AccountObjectiveDAO;
		private var _accountServiceRequestDao:AccountServiceRequestDAO;
		private var _contactOpportunityDao:ContactOpportunityDAO;
		private var _incomingSyncHistoryDao:IncomingSyncHistoryDAO;
		private var _customRecordTypeServiceDao:CustomRecordTypeServiceDAO;
		private var _customRecordTypeTranslationsDao:CustomRecordTypeTranslationsDAO;
		private var _fieldManagementServiceDao:FieldManagementServiceDAO;
		private var _cascadingPicklistDAO:CascadingPicklistDAO;
		private var _fieldTranslationDataDao:FieldTranslationDataDAO;
		private var _fieldFinderDao:FieldFinderDAO;
		private var _finderDao:FinderDAO;
		private var _finderMapDao:FinderMapDAO;
		private var _queryDao:QueryDAO;
		private var _viewLayoutDAO:ViewLayoutDAO;
		private var _rightDAO:RightDAO;
		private var _currentUserDAO:CurrentUserDAO;
		private var _feedDAO:FeedDAO;
		private var _feedUserDAO:FeedUserDAO;
		private var _feedFollowerDAO:FeedFollowerDAO;
		private var _feedUpdateDAO:FeedUpdateDAO;
		private var _feedUpdateDetailDAO:FeedUpdateDetailDAO;
		private var _feedOwnerDAO:FeedOwnerDAO;
		private var _feedEntityDAO:FeedEntityDAO;
		private var _feedGroupDAO:FeedGroupDAO;
		private var _feedGroupMemberDAO:FeedGroupMemberDAO;
		private var _feedHistoryDAO:FeedHistoryDAO;
		private var _reportDAO:ReportDAO;
		private var _reportFieldsDAO:ReportFieldsDAO;
		private var _sqlListDAO:SQLListDAO;
		private var _territoryTreeDAO:TerritoryTreeDAO;
		private var _depthStructureTreeDAO:DepthStructureTreeDAO;
		private var _dashboardLayoutDAO:DashboardLayoutDAO;
		private var _dashboardFilterDAO:DashboardFilterDAO;		
		private var _syncNumberDAO:SyncNumberDAO;
		private var _customLayoutConditionDAO:CustomLayoutConditionDAO;
		private var _accountCompetitorDao:AccountCompetitorDAO;
		private var _opportunityCompetitorDao:OpportunityCompetitorDAO;
		private var _accountPartnerDao:AccountPartnerDAO;
		private var _accountNoteDao:AccountNoteDAO;
		private var _contactNoteDao:ContactNoteDAO;
		private var _relatedContactDao:RelatedContactDAO;
		private var _accountRelatedDao:AccountRelationshipDAO;
		private var _opportunityNoteDao:OpportunityNoteDAO;
		private var _campaignNoteDao:CampaignNoteDAO;
		private var _serviceNoteDao:ServiceRequestNoteDAO;
		private var _opportunityPartnerDao:OpportunityPartnerDAO;
		private var _opportunityProductRevenueDao:OpportunityProductRevenueDAO;		
		private var _reportAdminDao:ReportAdminDAO;
		private var _reportAdminChildDao:ReportAdminChildDAO;
		private var _subColumnLayoutDao:SubColumnLayoutDAO;
		private var _timeZoneDao:TimeZoneDAO;
		private var _customObject2ContactDao:CustomObject2ContactDAO;
		private  var _sortColumnDao:SortColumnDAO;
		private  var _revenueDao:RevenueDao;
		private  var _revenueMappingProductFamilyDao:RevenueMappingProductFamilyDao;
		
		private var _templateDao:OrderTemplate;
		private var _templateItemDao:OrderTemplateItem;
		
		public static function get templateDao():OrderTemplate
		{
			return database._templateDao;
		}

		

		public static function get templateItemDao():OrderTemplateItem
		{
			return database._templateItemDao;
		}

		

		public static function get revenueMappingProductFamilyDao():RevenueMappingProductFamilyDao
		{
			return database._revenueMappingProductFamilyDao;
		}
		public static function get revenueDao():RevenueDao
		{
			return database._revenueDao;
		}
		public static function get sortColumnDao():SortColumnDAO
		{
			return database._sortColumnDao;
		}
		public static function get customObject2ContactDao():CustomObject2ContactDAO
		{
			return database._customObject2ContactDao;
		}
		public static function get opportunityContactDao():OpportunityContactDAO
		{
			return database._opportunityContactDao;
		}
		public static function get accountRelatedDao():AccountRelationshipDAO
		{
			return database._accountRelatedDao;
		}
		
		public static function get contactOpportunityDao():ContactOpportunityDAO
		{
			return database._contactOpportunityDao;
		}
		
		public static function get opportunityCompetitorDao():OpportunityCompetitorDAO
		{
			return database._opportunityCompetitorDao;
		}
		
		public static function get relationManagementDao():RelationManagementDAO
		{
			return database._relationManagementDao;
		}
		
		public static function get accountServiceRequestDao():AccountServiceRequestDAO
		{
			return database._accountServiceRequestDao;
		}
		
		public static function  get accountCustomObject10Dao():AccountCustomObject10DAO
		{
			return database._accountCustomObject10Dao;
		}
		
		public static function get accountObjectiveDao():AccountObjectiveDAO
		{
			return database._accountObjectiveDao;
		}
		
		public static function get accountOpportunityDao():AccountOpportunityDAO
		{
			return database._accountOpportunityDao;
		}
		
		public static function get accountAccountDao():AccountAccountDAO
		{
			return database._accountAccountDao;
		}
		
		public static function get accountCustomObject2Dao():AccountCustomObject2DAO
		{
			return database._accountCustomObject2Dao;
		}
		
		public static function get accountCustomObject3Dao():AccountCustomObject3DAO
		{
			return database._accountCustomObject3Dao;
		}
		
		public static function get accountCustomObject4Dao():AccountCustomObject4DAO
		{
			return database._accountCustomObject4Dao;
		}
		
		private static var _work:Function;
		private var _encryptPassword:String;
		private var _dbName:String;
		private var _processOpportunityDao:ProcessOpportunityDAO;
		private var _customFilterTranslatorDao:CustomFilterTranslatorDAO;
		private var _activitySampleDroppedDao:ActivitySampleDroppedDAO;
		private var _opportunityContactDao:OpportunityContactDAO;
		private var _dailyAgendaColumnLayoutDao:DailyAgendaColumnsLayoutDAO;
		
		private var _assessmentDao:AssessmentDAO;
		private var _questionDao:QuestionDAO;
		private var _sumFieldDao:SumFieldDAO;
		private var _answerDao:AnswerDAO;
		private var _assessmentConfigDao:AssessmentConfigDAO;
		private var _mappingTableSettingDao:MappingTableColumnSetting;
		private var _assessmentPageDao:AssessmentPageDAO;
		
		// CH
		private var _assessmentSplitterDao:AssessmentSplitterDAO;
		private var _dashboardReportDao:DashboardReportDAO;
		
		private var _assessmentMappingDao:AssessmentMappingDao;
		private var _assessmentPDFHeaderDao:AssessmentPDFHeaderDAO;
		private var _assessmentPDFColorThemeDao:AssessmentPDFColorThemeDAO;
		
		
		
		
		private const PREFERENCE_FIELDS:ArrayCollection = new ArrayCollection(
			[{field:"sodhost", value:""}, {field:"sodlogin", value:""},
				{field:"sodpass", value:""}, {field:"last_sync", value:"01/01/1970 00:00:00"}, 
				{field:"accepted_license", value:""}, {field:"config_url", value:""}, 
				{field:"interface_style", value:"tabs"}, {field:"sync_startup", value:false}, {field:"disable_gzip", value:false},
				{field:"verbose",value:"0"}, {field:"syn_interval", value:60},
				{field:"im_room_url", value: ""}, {field:"im_protocol", value: "rtmfp"},
				{field:"im_user", value: ""}, {field:"im_password", value: ""}, {field:"im_auto_sing_in", value: false},
				{field:PreferencesDAO.PDF_LOGO, value: ""},
				{field:PreferencesDAO.PDF_HEADER, value: ""},
				{field:PreferencesDAO.WINDOW_LOGO, value: ""},
				{field:PreferencesDAO.BACKGROUND_COLOR, value: ""},
				{field:PreferencesDAO.SYNC_ACCESSPROFILE, value: true},
				{field:PreferencesDAO.SYNC_ASSESSMENTSCRIPT, value: true},
				{field:PreferencesDAO.SYNC_CASCADINGPICKLIST, value: true},
				{field:PreferencesDAO.SYNC_FIELD_MANAGMENT, value: true},
				{field:PreferencesDAO.SYNC_PICKLISTSERVICE, value: true},
				{field:PreferencesDAO.SYNC_ROLE, value: true},
				//				{field:PreferencesDAO.DISABLE_CUSTOM_LAYOUT, value: false},
				{field:PreferencesDAO.ENABLE_CUSTOM_LAYOUT, value: true},
				{field:PreferencesDAO.ENABLE_LIST_LAYOUT, value: true},
				{field:PreferencesDAO.ENABLE_VIEW_LAYOUT, value: true},
				{field:PreferencesDAO.HIDE_USER_INTERFACE, value: false},
				// #310: Change request - Diversey sales - Prefernces - Connection Informations
				{field:PreferencesDAO.DISABLE_SYNCHRONIZATION_INTERVAL, value: false},
				{field:PreferencesDAO.DISABLE_CRM_ONDEMAND_URL, value: false},
				{field:PreferencesDAO.USER_SIGNATURE, value: ""},
				{field:PreferencesDAO.HIDE_USER_SIGNATURE, value: true},
				{field:PreferencesDAO.HIDE_TASK_LIST, value: false},
				{field:PreferencesDAO.ENABLE_SR_SYNC_ORDER_STATUS, value: false},
				//{field:PreferencesDAO.DISABLE_PDF_CVS_EXPORT, value: false},
				//{field:PreferencesDAO.ACCOUNT_DELETE, value: true},
				//{field:PreferencesDAO.CONTACT_DELETE, value: true},
				//{field:PreferencesDAO.LEAD_DELETE, value: true},
				//{field:PreferencesDAO.OPPORTUNITY_DELETE, value: true},
				//{field:PreferencesDAO.DISABLE_AUTORIZE_DELETION, value: true},				
				{field:PreferencesDAO.ENABLE_BUTTON_ACTIVITY_CREATE_CALL, value: true},
				{field:PreferencesDAO.UPDATE_URL, value: "http://desktop.crm-gadget.com/update.xml"},
				{field:"predefined_filters", value: "1"},
				{field:"log_files", value: "0"},
				{field:"log_fileName", value: ""},
				{field:"use_sso", value: "0"},
				{field:"window_width", value: "960"},
				{field:"window_height", value: "640"},
				{field:"window_resize", value: "0"},
				{field:"company_sso_id", value: ""},
				{field:"ms_url", value: ""},
				{field:"ms_user", value: ""},
				{field:"ms_password", value: ""},
				{field:"ms_exchange_enable", value: "0"},
				{field:"enable_google_calendar", value: "0"},
				{field:"cvs_separator", value: ","},
				{field:"important_length", value: "10"},
				{field:"recent_filter", value: "5"},
				{field:PreferencesDAO.START_AT_LOGIN, value: "0"},
				{field:PreferencesDAO.ENABLE_CUSTOM_LAYOUT, value: true},
				{field:PreferencesDAO.ENABLE_LIST_LAYOUT, value: true},
				{field:PreferencesDAO.ENABLE_VIEW_LAYOUT, value: true},
				{field:PreferencesDAO.ENABLE_FILTER, value: true},
				{field:PreferencesDAO.ENABLE_CONNECTION_INFORMATION, value: true},
				{field:PreferencesDAO.ENABLE_TRANSACTION, value: true},
				{field:PreferencesDAO.ENABLE_USER_INTERFACE, value: true},
				{field:PreferencesDAO.ENABLE_OPTION, value: true},
				{field:PreferencesDAO.ENABLE_AUTO_CONFIGURATION, value: true},
				{field:PreferencesDAO.ENABLE_FEED, value: "0"},
				{field:PreferencesDAO.FEED_URL, value: "jabber.fellow-consulting.de"},
				{field:PreferencesDAO.FEED_PORT, value: "4222"},
				{field:"company_name", value: ""},
				{field:PreferencesDAO.ADMIN_PASSWORD, value: ""},
				{field:PreferencesDAO.ENABLE_PDF_SIGNATURE, value: false},
				{field:PreferencesDAO.VISIT_CUSTOMER_GREATER_DAYS, value: 60},
				{field:PreferencesDAO.VISIT_CUSTOMER_LOWER_DAYS, value: 30},
				{field:PreferencesDAO.ENABLE_COMPETITORS, value: "1"},
				{field:PreferencesDAO.ENABLE_CUSTOMERS, value: "1"}
				
			]);
		
		private static var _database:Database = null;
		
		private static function get database():Database {
			//init(null,_database._dbName,_database._encryptPassword);
			if (_database==null)
				throw new Error("database not initialized");
			return _database;
		}
		
		public static function dbinit(workerFunction:Function, dbName:String, encryptPassword:String,resetDB:Boolean=false):SQLConnection {
			if(resetDB) _database = null;
			if (_database)
				throw new Error("database already initialized");
			_work = workerFunction;
			_database = new Database(dbName, encryptPassword);
			return _database._sqlConnection;
		}
		
		public static function changePasswordDatabase(newEncryptPassword:String):void{
			if(!StringUtils.isEmpty(newEncryptPassword)){
				var fileDB:File = File.applicationDirectory.resolvePath(getCustomDatabasePathFromFile() + "/" + ENCRYPTED_DB_NAME);
				var keyGenerator:EncryptionKeyGenerator = new EncryptionKeyGenerator();
				var encryptionKey:ByteArray = keyGenerator.getEncryptionKey(fileDB, newEncryptPassword);
				
				_database._sqlConnection.reencrypt(encryptionKey);
			}
		}
		
		public static function get activitySampleDroppedDao():ActivitySampleDroppedDAO{
			return database._activitySampleDroppedDao;
			
		}
		
		public static function get opportunityPartnerDao():OpportunityPartnerDAO{
			return _database._opportunityPartnerDao;
		}
		public static function get accountNoteDao():AccountNoteDAO{
			return database._accountNoteDao;
			
		}
		
		public static function get opportunityProductRevenueDao():OpportunityProductRevenueDAO{
			return database._opportunityProductRevenueDao;
		}
		
		public static function get contactNoteDao():ContactNoteDAO{
			return database._contactNoteDao;			
		}
		
		public static function get relatedContactDao():RelatedContactDAO{
			return database._relatedContactDao;
		}
		
		public static function get campaignNoteDao():CampaignNoteDAO{
			return database._campaignNoteDao;			
		}
		
		public static function get opportunityNoteDao():OpportunityNoteDAO{
			return database._opportunityNoteDao;
		}
		
		public static function get serviceNoteDao():ServiceRequestNoteDAO{
			return database._serviceNoteDao;
		}
		
		public static function get image():ImageDAO{
			return database._image;
		}
		public static function get tempFolder():File {
			return database._tempFolder;
		}
		
		public static function get accountDao():AccountDAO {
			return database._accountDao;
		}
		
		public static function get contactDao():ContactDAO {
			return database._contactDao;
		}
		
		public static function get opportunityDao():OpportunityDAO {
			return database._opportunityDao;
		}
		
		public static function get activityDao():ActivityDAO {
			return database._activityDao;
		}
		
		public static function get linkDao():LinkDAO {
			return database._linkDao;
		}
		
		public static function get accountCompetitorDao():AccountCompetitorDAO{
			return database._accountCompetitorDao;
		}
		
		public static function get accountPartnerDao():AccountPartnerDAO{
			return database._accountPartnerDao;
		}
		
		public static function get preferencesDao():PreferencesDAO {
			return database._preferencesDao;
		}
		
		public static function get filterDao():FilterDAO {
			return database._filterDao;
		}
		
		public static function get customTableWidthConfigurationDao():CustomTableWidthConfigurationDAO {
			return database._customTableWidthConfigurationDAO;
		}
		
		public static function get criteriaDao():CriteriaDAO {
			return database._criteriaDao;
		}
		
		public static function get picklistDao():PicklistDAO {
			return database._picklistDao;
		}
		
		public static function get userDao():UserDAO {
			return database._userDao;
		}
		
		public static function get registeredUserDao():RegisteredUserDAO {
			return database._registeredUserDao;
		}
		
		public static function get addressDao():AddressDAO {
			return database._addressDao;
		}
		
		public static function get netbreezeDao(): NetbreezeDAO {
			return database._netbreezeDao;
		}
		
		public static function get netbreezeAccountDao(): NetbreezeAccountDAO {
			return database._netbreezeAccountDao;
		}
		
		public static function get layoutDao():LayoutDAO {
			return database._layoutDao;
		}
		
		public static function get validationRuleDAO():ValidationRuleDAO {
			return database._validationRuleDAO;
		}
		public static function get validationRuleTranslotorDAO():ValidationRuleTranslatorDAO {
			return database._validationRuleTranslatorDAO;
		}
		public static function get customFieldDao():CustomFieldDAO {
			return database._customFieldDao;
		}
		
		public static function get customFieldTranslatorDao():CustomFieldTranslatorDAO {
			return database._customFieldTranslatorDao;
		}
		
		public static function get customPicklistValueDAO():CustomPicklistValueDAO {
			return database._customPicklistValueDao;
		}
		
		public static function get columnsLayoutDao():ColumnsLayoutDAO{
			return database._columnsLayoutDao;
		}
		public static function get subColumnLayoutDao():SubColumnLayoutDAO{
			return database._subColumnLayoutDao;
		}
		public static function get attachmentDao():AttachmentDAO{
			return database._attachmentDao;
		}
		
		public static function get activityUserDao():ActivityUserDAO{
			return database._activityUserDao;
		}
		
		public static function get productDao():ProductDAO {
			return database._productDao;
		}
		
		public static function get serviceDao():ServiceDAO {
			return database._serviceDao;
		}
		
		public static function get fieldDao():FieldDAO {
			return database._fieldDao;
		}
		
		public static function get salesProcDao():SalesProcDAO {
			return database._salesProcDao;
		}
		
		public static function get salesStageDao():SalesStageDAO {
			return database._salesStageDao;
		}		
		
		public static function get campaignDao():CampaignDAO {
			return database._campaignDao;
		}
		
		public static function get transactionDao():TransactionDAO {
			return database._transactionDao;
		}
		public static function get subSyncDao():SubSyncDAO {
			return database._subSyncDao;
		}
		
		public static function get customObject1Dao():CustomObject1DAO{
			return database._customObject1Dao;
		}
		
		
		public static function get recentDao():RecentDAO {
			return database._recentDao;
		}
		
		public static function get opportunityTeamDao():OpportunityTeamDAO{
			return database._opportunityTeamDao;
		}
		
		
		public static function get recordTypeDao():RecordTypeDAO{
			return database._recordTypeDao;
		}
		
		public static function get bookmarkDao():BookmarkDAO {
			return database._bookmarkDao;
		}
		
		public static function get leadDao():LeadDAO{
			return database._leadDao;
		}
		
		public static function get lastsyncDao():LastSyncDAO{
			return database._lastsyncDao;
		}
		
		public static function get processOpportunityDao():ProcessOpportunityDAO{
			return database._processOpportunityDao;
		}
		
		public static function get validationDao():ValidationDAO {
			return database._validationDao;
		}
		
		public static function get incomingSyncDao():IncomingSyncDAO {
			return database._incomingSyncDao;
		}
		public static function get syncNumberDao():SyncNumberDAO {
			return database._syncNumberDAO;
		}
		public static function get customLayoutDao():CustomLayoutDAO {
			return database._customLayoutDao;
		}
		
		public static function get errorLoggingDao():ErrorLoggingDAO {
			return database._errorLoggingDao;
		}
		
		public static function get activityProductDao():ActivityProductDAO {
			return database._activityProductDao;
		}
		
		public static function get allUsersDao():AllUsersDAO {
			return database._allUsersDao;
		}
		
		public static function get accountActivityDao():AccountActivityDAO {
			return database._accountActivityDao;
		}
		
		public static function get incomingSyncHistoryDao():IncomingSyncHistoryDAO {
			return database._incomingSyncHistoryDao;
		}
		
		public static function get customRecordTypeServiceDao():CustomRecordTypeServiceDAO {
			return database._customRecordTypeServiceDao;
		}
		
		public static function get customRecordTypeTranslationsDao():CustomRecordTypeTranslationsDAO {
			return database._customRecordTypeTranslationsDao;
		}
		
		public static function get fieldTranslationDataDao():FieldTranslationDataDAO {
			return database._fieldTranslationDataDao;
		}
		
		public static function get fieldManagementServiceDao():FieldManagementServiceDAO {
			return database._fieldManagementServiceDao;
		}
		
		public static function get cascadingPicklistDAO():CascadingPicklistDAO{
			return database._cascadingPicklistDAO;
		}
		
		
		public static function get fieldFinderDAO():FieldFinderDAO {
			return database._fieldFinderDao;
		}
		
		public static function get finderDAO():FinderDAO {
			return database._finderDao;
		}
		
		public static function get finderMapDAO():FinderMapDAO {
			return database._finderMapDao;
		}
		
		private var _accountTeamDao:AccountTeamDAO;
		public static function get accountTeamDao():AccountTeamDAO {
			return database._accountTeamDao;
		}
		
		private var _accountAddressDao:AccountAddressDAO;
		public static function get accountAddressDao():AccountAddressDAO {
			return database._accountAddressDao;
		}
		
		private var _contactAddressDao:ContactAddressDAO;
		public static function get contactAddressDao():ContactAddressDAO {
			return database._contactAddressDao;
		}
		
		private var _customObject2Dao:CustomObject2DAO;
		public static function get customObject2Dao():CustomObject2DAO {
			return database._customObject2Dao;
		}
		
		private var _customObject14Dao:CustomObject14DAO;
		public static function get customObject14Dao():CustomObject14DAO {
			return database._customObject14Dao;
		}
		
		private var _policyDao:PolicyDAO;
		public static function get policyDao():PolicyDAO {
			return database._policyDao;
		}
		
		private var _policyHolderDao:PolicyHolderDAO;
		public static function get policyHolderDao():PolicyHolderDAO {
			return database._policyHolderDao;
		}
		
		private var _picklistServiceDao:PicklistServiceDAO;
		public static function get picklistServiceDao():PicklistServiceDAO {
			return database._picklistServiceDao;
		}
		
		private var _currencyServiceDao:CurrencyServiceDAO;
		public static function get currencyServiceDao():CurrencyServiceDAO {
			return database._currencyServiceDao;
		}
		
		private var _industryDAO:IndustryDAO;
		public static function get industryDAO():IndustryDAO {
			return database._industryDAO;
		}
		
		public static function get queryDao():QueryDAO{
			return database._queryDao;
		}
		
		public static function get viewLayoutDAO():ViewLayoutDAO{
			return database._viewLayoutDAO;
		}
		
		public static function get rightDAO():RightDAO{
			return database._rightDAO;
		}
		
		public static function get currentUserDAO():CurrentUserDAO{
			return database._currentUserDAO;
		}
		
		public static function get feedDAO():FeedDAO{
			return database._feedDAO;
		}
		
		public static function get feedUserDAO():FeedUserDAO{
			return database._feedUserDAO;
		}
		
		public static function get feedFollowerDAO():FeedFollowerDAO{
			return database._feedFollowerDAO;
		}
		
		public static function get feedUpdateDAO():FeedUpdateDAO{
			return database._feedUpdateDAO;
		}
		
		public static function get feedUpdateDetailDAO():FeedUpdateDetailDAO{
			return database._feedUpdateDetailDAO;
		}
		
		public static function get feedOwnerDAO():FeedOwnerDAO {
			return database._feedOwnerDAO;
		}
		
		public static function get feedEntityDAO():FeedEntityDAO {
			return database._feedEntityDAO;
		}
		
		public static function get feedGroupDAO():FeedGroupDAO {
			return database._feedGroupDAO;
		}
		
		public static function get feedGroupMemberDAO():FeedGroupMemberDAO {
			return database._feedGroupMemberDAO;
		}
		
		public static function get feedHistoryDAO():FeedHistoryDAO {
			return database._feedHistoryDAO;
		}
		
		public static function get customLayoutConditionDAO():CustomLayoutConditionDAO{
			return database._customLayoutConditionDAO;
		}
		
		public static function get reportDAO():ReportDAO{
			return database._reportDAO;
		}
		
		public static function get reportFieldsDAO():ReportFieldsDAO{
			return database._reportFieldsDAO;
		}
		
		public static function get sqlListDAO():SQLListDAO {
			return database._sqlListDAO;
		}
		
		public static function get territoryTreeDAO():TerritoryTreeDAO {
			return database._territoryTreeDAO;
		}
		
		public static function get depthStructureTreeDAO():DepthStructureTreeDAO {
			return database._depthStructureTreeDAO;
		}
		
		public static function get dashboardLayoutDAO():DashboardLayoutDAO {
			return database._dashboardLayoutDAO;
		}
		
		public static function get dashboardFilterDAO():DashboardFilterDAO {
			return database._dashboardFilterDAO;
		}
		
		public static function get reportAdminChildDao():ReportAdminChildDAO {
			return database._reportAdminChildDao;
		}
		
		public static function get reportAdminDao():ReportAdminDAO {
			return database._reportAdminDao;
		}
		
		/////////////////////////////////////////////////////////////////////////////
		
		private var _applicationDao:ApplicationDAO;
		public static function get applicationDao():ApplicationDAO {
			return database._applicationDao;
		}
		
		private var _assetDao:AssetDAO;
		public static function get assetDao():AssetDAO {
			return database._assetDao;
		}
		
		private var _bookDao:BookDAO;
		public static function get bookDao():BookDAO {
			return database._bookDao;
		}
		
		private var _planAccountDao:PlanAccountDAO;
		public static function get planAccountDao():PlanAccountDAO {
			return database._planAccountDao;
		}
		
		private var _planContactDao:PlanContactDAO;
		public static function get planContactDao():PlanContactDAO {
			return database._planContactDao;
		}
		
		private var _businessPlanDao:BusinessPlanDAO;
		public static function get businessPlanDao():BusinessPlanDAO {
			return database._businessPlanDao;
		}
		
		private var _inventoryAuditReportDao:InventoryAuditReportDAO;
		public static function get inventoryAuditReportDao():InventoryAuditReportDAO {
			return database._inventoryAuditReportDao;
		}
		
		private var _inventoryPeriodDao:InventoryPeriodDAO;
		public static function get inventoryPeriodDao():InventoryPeriodDAO {
			return database._inventoryPeriodDao;
		}
		
		private var _modificationTrackingDao:ModificationTrackingDAO;
		public static function get modificationTrackingDao():ModificationTrackingDAO {
			return database._modificationTrackingDao;
		}
		
		private var _objectivesDao:ObjectivesDAO;
		public static function get objectivesDao():ObjectivesDAO {
			return database._objectivesDao;
		}
		
		private var _messageResponseDao:MessageResponseDAO;
		public static function get messageResponseDao():MessageResponseDAO {
			return database._messageResponseDao;
		}
		
		private var _planOpportunityDao:PlanOpportunityDAO;
		public static function get planOpportunityDao():PlanOpportunityDAO {
			return database._planOpportunityDao;
		}
		
		private var _sampleDisclaimerDao:SampleDisclaimerDAO;
		public static function get sampleDisclaimerDao():SampleDisclaimerDAO {
			return database._sampleDisclaimerDao;
		}
		
		private var _sampleInventoryDao:SampleInventoryDAO;
		public static function get sampleInventoryDao():SampleInventoryDAO {
			return database._sampleInventoryDao;
		}
		
		private var _sampleLotDao:SampleLotDAO;
		public static function get sampleLotDao():SampleLotDAO {
			return database._sampleLotDao;
		}
		
		private var _signatureDao:SignatureDAO;
		public static function get signatureDao():SignatureDAO {
			return database._signatureDao;
		}
		
		private var _allocationDao:AllocationDAO;
		public static function get allocationDao():AllocationDAO {
			return database._allocationDao;
		}
		
		private var _contactLicenseDao:ContactLicenseDAO;
		public static function get contactLicenseDao():ContactLicenseDAO {
			return database._contactLicenseDao;
		}
		
		private var _messagePlanDao:MessagePlanDAO;
		public static function get messagePlanDao():MessagePlanDAO {
			return database._messagePlanDao;
		}
		
		private var _msgPlanItemDao:MsgPlanItemDAO;
		public static function get msgPlanItemDao():MsgPlanItemDAO {
			return database._msgPlanItemDao;
		}
		
		private var _msgPlanItemRelationDao:MsgPlanItemRelationDAO;
		public static function get msgPlanItemRelationDao():MsgPlanItemRelationDAO {
			return database._msgPlanItemRelationDao;
		}
		
		private var _transactionItemDao:TransactionItemDAO;
		public static function get transactionItemDao():TransactionItemDAO {
			return database._transactionItemDao;
		}
		
		private var _sampleTransactionDao:SampleTransactionDAO;
		public static function get sampleTransactionDao():SampleTransactionDAO {
			return database._sampleTransactionDao;
		}
		
		private var _categoryDao:CategoryDAO;
		public static function get categoryDao():CategoryDAO {
			return database._categoryDao;
		}
		
		private var _dealerDao:DealerDAO;
		public static function get dealerDao():DealerDAO {
			return database._dealerDao;
		}
		
		private var _claimDao:ClaimDAO;
		public static function get claimDao():ClaimDAO {
			return database._claimDao;
		}
		
		private var _contactBestTimesDao:ContactBestTimesDAO;
		public static function get contactBestTimesDao():ContactBestTimesDAO {
			return database._contactBestTimesDao;
		}
		
		private var _coverageDao:CoverageDAO;
		public static function get coverageDao():CoverageDAO {
			return database._coverageDao;
		}
		
		private var _customObject3Dao:CustomObject3DAO;
		public static function get customObject3Dao():CustomObject3DAO {
			return database._customObject3Dao;
		}
		
		private var _customObject10Dao:CustomObject10DAO;
		public static function get customObject10Dao():CustomObject10DAO {
			return database._customObject10Dao;
		}
		
		private var _customObject11Dao:CustomObject11DAO;
		public static function get customObject11Dao():CustomObject11DAO {
			return database._customObject11Dao;
		}
		
		private var _customObject12Dao:CustomObject12DAO;
		public static function get customObject12Dao():CustomObject12DAO {
			return database._customObject12Dao;
		}
		
		private var _customObject13Dao:CustomObject13DAO;
		public static function get customObject13Dao():CustomObject13DAO {
			return database._customObject13Dao;
		}
		
		private var _customObject15Dao:CustomObject15DAO;
		public static function get customObject15Dao():CustomObject15DAO {
			return database._customObject15Dao;
		}
		
		private var _customObject4Dao:CustomObject4DAO;
		public static function get customObject4Dao():CustomObject4DAO {
			return database._customObject4Dao;
		}
		
		private var _customObject5Dao:CustomObject5DAO;
		public static function get customObject5Dao():CustomObject5DAO {
			return database._customObject5Dao;
		}
		
		private var _customObject6Dao:CustomObject6DAO;
		public static function get customObject6Dao():CustomObject6DAO {
			return database._customObject6Dao;
		}
		
		private var _customObject7Dao:CustomObject7DAO;
		public static function get customObject7Dao():CustomObject7DAO {
			return database._customObject7Dao;
		}
		
		private var _customObject8Dao:CustomObject8DAO;
		public static function get customObject8Dao():CustomObject8DAO {
			return database._customObject8Dao;
		}
		
		private var _customObject9Dao:CustomObject9DAO;
		public static function get customObject9Dao():CustomObject9DAO {
			return database._customObject9Dao;
		}
		
		private var _damageDao:DamageDAO;
		public static function get damageDao():DamageDAO {
			return database._damageDao;
		}
		
		private var _dealRegistrationDao:DealRegistrationDAO;
		public static function get dealRegistrationDao():DealRegistrationDAO {
			return database._dealRegistrationDao;
		}
		
		private var _financialAccountDao:FinancialAccountDAO;
		public static function get financialAccountDao():FinancialAccountDAO {
			return database._financialAccountDao;
		}
		
		private var _financialAccountHolderDao:FinancialAccountHolderDAO;
		public static function get financialAccountHolderDao():FinancialAccountHolderDAO {
			return database._financialAccountHolderDao;
		}
		
		private var _financialAccountHoldingDao:FinancialAccountHoldingDAO;
		public static function get financialAccountHoldingDao():FinancialAccountHoldingDAO {
			return database._financialAccountHoldingDao;
		}
		
		private var _financialPlanDao:FinancialPlanDAO;
		public static function get financialPlanDao():FinancialPlanDAO {
			return database._financialPlanDao;
		}
		
		private var _financialProductDao:FinancialProductDAO;
		public static function get financialProductDao():FinancialProductDAO {
			return database._financialProductDao;
		}
		
		private var _financialTransactionDao:FinancialTransactionDAO;
		public static function get financialTransactionDao():FinancialTransactionDAO {
			return database._financialTransactionDao;
		}
		
		private var _fundDao:FundDAO;
		public static function get fundDao():FundDAO {
			return database._fundDao;
		}
		
		private var _groupDao:GroupDAO;
		public static function get groupDao():GroupDAO {
			return database._groupDao;
		}
		
		private var _householdDao:HouseholdDAO;
		public static function get householdDao():HouseholdDAO {
			return database._householdDao;
		}
		
		private var _insurancePropertyDao:InsurancePropertyDAO;
		public static function get insurancePropertyDao():InsurancePropertyDAO {
			return database._insurancePropertyDao;
		}
		
		private var _involvedPartyDao:InvolvedPartyDAO;
		public static function get involvedPartyDao():InvolvedPartyDAO {
			return database._involvedPartyDao;
		}
		
		private var _mDFRequestDao:MDFRequestDAO;
		public static function get mDFRequestDao():MDFRequestDAO {
			return database._mDFRequestDao;
		}
		
		private var _medEdDao:MedEdEventDAO;
		public static function get medEdDao():MedEdEventDAO {
			return database._medEdDao;
		}
		
		private var _noteDao:NoteDAO;
		public static function get noteDao():NoteDAO {
			return database._noteDao;
		}
		
		private var _portfolioDao:PortfolioDAO;
		public static function get portfolioDao():PortfolioDAO {
			return database._portfolioDao;
		}
		
		private var _priceListDao:PriceListDAO;
		public static function get priceListDao():PriceListDAO {
			return database._priceListDao;
		}
		
		private var _priceListLineItemDao:PriceListLineItemDAO;
		public static function get priceListLineItemDao():PriceListLineItemDAO {
			return database._priceListLineItemDao;
		}
		
		private var _sPRequestDao:SPRequestDAO;
		public static function get sPRequestDao():SPRequestDAO {
			return database._sPRequestDao;
		}
		
		private var _sPRequestLineItemDao:SPRequestLineItemDAO;
		public static function get sPRequestLineItemDao():SPRequestLineItemDAO {
			return database._sPRequestLineItemDao;
		}
		
		private var _solutionDao:SolutionDAO;
		public static function get solutionDao():SolutionDAO {
			return database._solutionDao;
		}
		
		private var _territoryDao:TerritoryDAO;
		public static function get territoryDao():TerritoryDAO {
			return database._territoryDao;
		}
		
		private var _vehicleDao:VehicleDAO;
		public static function get vehicleDao():VehicleDAO {
			return database._vehicleDao;
		}
		
		/////////////////////////////////////////////////////////////////////////////
		
		private var _activityContactDao:ActivityContactDAO;
		public static function get activityContactDao():ActivityContactDAO {
			return database._activityContactDao;
		}
		
		private var _contactTeamDao:ContactTeamDAO;
		public static function get contactTeamDao():ContactTeamDAO{
			return database._contactTeamDao;
		}
		
		private var _accessProfileServiceDao:AccessProfileServiceDAO;
		public static function get accessProfileServiceDao():AccessProfileServiceDAO {
			return database._accessProfileServiceDao;
		}
		
		private var _accessProfileServiceTransDao:AccessProfileServiceTransDAO;
		public static function get accessProfileServiceTransDao():AccessProfileServiceTransDAO {
			return database._accessProfileServiceTransDao;
		}
		
		private var _accessProfileServiceEntryDao:AccessProfileServiceEntryDAO;
		public static function get accessProfileServiceEntryDao():AccessProfileServiceEntryDAO {
			return database._accessProfileServiceEntryDao;
		}
		
		private var _roleServiceDao:RoleServiceDAO;
		public static function get roleServiceDao():RoleServiceDAO {
			return database._roleServiceDao;
		}
		
		private var _roleServiceAvailableTabDao:RoleServiceAvailableTabDAO;
		public static function get roleServiceAvailableTabDao():RoleServiceAvailableTabDAO {
			return database._roleServiceAvailableTabDao;
		}
		
		private var _roleServiceLayoutDao:RoleServiceLayoutDAO;
		public static function get roleServiceLayoutDao():RoleServiceLayoutDAO {
			return database._roleServiceLayoutDao;
		}
		
		private var _roleServicePageLayoutDao:RoleServicePageLayoutDAO;
		public static function get roleServicePageLayoutDao():RoleServicePageLayoutDAO {
			return database._roleServicePageLayoutDao;
		}
		
		private var _roleServicePrivilegeDao:RoleServicePrivilegeDAO;
		public static function get roleServicePrivilegeDao():RoleServicePrivilegeDAO {
			return database._roleServicePrivilegeDao;
		}
		
		private var _roleServiceRecordTypeAccessDao:RoleServiceRecordTypeAccessDAO;
		public static function get roleServiceRecordTypeAccessDao():RoleServiceRecordTypeAccessDAO {
			return database._roleServiceRecordTypeAccessDao;
		}
		
		private var _roleServiceSelectedTabDao:RoleServiceSelectedTabDAO;
		public static function get roleServiceSelectedTabDao():RoleServiceSelectedTabDAO {
			return database._roleServiceSelectedTabDao;
		}
		
		
		private var _roleServiceTransDao:RoleServiceTransDAO;
		public static function get roleServiceTransDao():RoleServiceTransDAO {
			return database._roleServiceTransDao;
		}
		
		private var _contactAccountDao:ContactAccountDAO;
		public static function get contactAccountDao():ContactAccountDAO {
			return database._contactAccountDao;
		}
		
		public static function get customFilterTranslatorDao():CustomFilterTranslatorDAO {
			return database._customFilterTranslatorDao;
		}
		
		
		
		public static function exist(dbName:String):Boolean {
			return File.userDirectory.resolvePath(dbName).exists ? true : false;
		}
		
		public static function getCustomDatabasePathFromFile():String {
			var file:File = File.userDirectory.resolvePath(Database.CUSTOM_DATABASE);
			if(file.exists){
				var xml:XML = new XML(Utils.readUTFBytes(file));
				var location:String = xml.elements("databaselocation").toString();
				if(location.toLocaleLowerCase()=='default'){
					location = File.userDirectory.nativePath;
				}
				
				return location;
			}
			return null;
		}
		
		
		public static function getConfigXML():XML{
			var file:File = File.userDirectory.resolvePath(Database.CUSTOM_DATABASE);
			if(file.exists){
				var xml:XML = new XML(Utils.readUTFBytes(file));
				return xml;
			}
			return null;
		}
		public static function get dailyAgendaColumnLayoutDao():DailyAgendaColumnsLayoutDAO {
			return database._dailyAgendaColumnLayoutDao;
		}
		
		public static function get assessmentDao():AssessmentDAO {
			return database._assessmentDao;
		}
		
		public static function get questionDao():QuestionDAO {
			return database._questionDao;
		}
		public static function get sumFieldDao():SumFieldDAO {
			return database._sumFieldDao;
		}
		public static function get answerDao():AnswerDAO {
			return database._answerDao;
		}
		
		public static function get assessmentConfigDao():AssessmentConfigDAO {
			return database._assessmentConfigDao;
		}
		
		
		public static function get mappingTableSettingDao():MappingTableColumnSetting{
			return database._mappingTableSettingDao;
		}
		
		public static function get assessmentPageDao():AssessmentPageDAO {
			return database._assessmentPageDao;
		}
		
		public static function get assessmentMappingDao():AssessmentMappingDao{
			return database._assessmentMappingDao;
		}
		public static function get assessmentPDFHeaderDao():AssessmentPDFHeaderDAO{
			return database._assessmentPDFHeaderDao;
		}
		public static function get assessmentPDFColorThemeDao():AssessmentPDFColorThemeDAO{
			return database._assessmentPDFColorThemeDao;
		}
		
		// CH
		public static function get assessmentSplitterDao():AssessmentSplitterDAO{
			return database._assessmentSplitterDao
		}
		
		public static function get dashboardReportDao():DashboardReportDAO{
			return database._dashboardReportDao;
		}
		
		public static function get timeZoneDao():TimeZoneDAO{
			return database._timeZoneDao;
		}
		
		public static function get relatedButtonDao():RelatedButtonDAO {
			return database._relatedButtonDAO;
		}
		
		public static function cleanDb():void{
			database._sqlConnection.compact(); // cleans up the database and reduces its size
		}
		
		public function Database(dbName:String, encryptPassword:String) {
			
			_sqlConnection = new SQLConnection();
			
			var fileDB:File;
//			//hardcode
//			dbName = DB_NAME;//for testing
			// Change Request #217
			if(Database.exist(CUSTOM_DATABASE)) {  // if custom database file exist we get path from this file, otherwise get from current user directory
				fileDB = File.applicationDirectory.resolvePath(getCustomDatabasePathFromFile() + "/" + dbName);
			}else {
				fileDB = File.userDirectory.resolvePath(dbName);
			}
			
			var isNewDB:Boolean = !fileDB.exists;
			const AUTOCOMPACT:Boolean = false;	//VAHI Keep it false for now.
			
			if(dbName == ENCRYPTED_DB_NAME){
				_encryptPassword = encryptPassword;
				var keyGenerator:EncryptionKeyGenerator = new EncryptionKeyGenerator();
				var encryptionKey:ByteArray = keyGenerator.getEncryptionKey(fileDB, encryptPassword);
				_sqlConnection.open(fileDB,SQLMode.CREATE,AUTOCOMPACT,1024,encryptionKey);
			} else {
				_sqlConnection.open(fileDB,SQLMode.CREATE,AUTOCOMPACT);
			}
		
			//			_work("Compressing database. This might take a while...", function(params:Object):void {
			//				// if (AUTOCOMPACT && !_sqlConnection.autoCompact)
			//				_sqlConnection.compact(); // cleans up the database and reduces its size
			//			});
			
			_work("Initializing Database...", Istart, {dbName:dbName, isNewDB:isNewDB});
		}
		
		private function Istart(params:Object):void {
			_dbName = params.dbName;
			
			if (params.isNewDB) {
				XcreateDatabase(_sqlConnection);
			}
			//it is must be first
			_errorLoggingDao = new ErrorLoggingDAO(_sqlConnection, _work);
			// we need user dao from the beginning for locale stuff.
			// support DAOs needs this one.
			// the fact that DAOs constructors references themselves is annoying
			// and might cause problems in the future.
			_userDao = new UserDAO(_sqlConnection,_work);
			
			_activitySampleDroppedDao = new ActivitySampleDroppedDAO(_work,_sqlConnection);
			//_image = new ImageDAO(_sqlConnection, _work);
			
			
			
			// We need this immediately
			// This is without worker because it hacks itself immediately into existence
			// (we are now in a worker here, so that's ok)
			_preferencesDao = new PreferencesDAO(_sqlConnection);
			// We need this next.
			// Some things below will unsync itself.
			_lastsyncDao = new LastSyncDAO(_sqlConnection, _work);
			
			
			
			_registeredUserDao = new RegisteredUserDAO(_sqlConnection, _work);
			
			_addressDao = new AddressDAO(_sqlConnection,_work);
			
			
			_incomingSyncDao = new IncomingSyncDAO(_sqlConnection);
			_syncNumberDAO = new SyncNumberDAO(_sqlConnection, _work);
			_accountDao = new AccountDAO(_sqlConnection, _work);
			_activityDao = new ActivityDAO(_sqlConnection, _work);
			_campaignDao = new CampaignDAO(_sqlConnection, _work);
			_contactDao = new ContactDAO(_sqlConnection, _work);			
			_customObject1Dao = new CustomObject1DAO(_sqlConnection, _work);
			_leadDao = new LeadDAO(_sqlConnection, _work);
			_opportunityDao = new OpportunityDAO(_sqlConnection, _work);
			_productDao = new ProductDAO(_sqlConnection, _work);
			_serviceDao = new ServiceDAO(_sqlConnection, _work);
			_accountTeamDao = new AccountTeamDAO(_sqlConnection, _work);
			_contactTeamDao= new ContactTeamDAO(_sqlConnection,_work);
			
			_accountAddressDao = new AccountAddressDAO(_sqlConnection, _work);
			_contactAddressDao = new ContactAddressDAO(_sqlConnection, _work);
			
			_allUsersDao = new AllUsersDAO(_sqlConnection, _work);
			_incomingSyncHistoryDao = new IncomingSyncHistoryDAO(_sqlConnection, _work);
			_customObject2Dao = new CustomObject2DAO(_sqlConnection, _work);
			_customObject14Dao = new CustomObject14DAO(_sqlConnection, _work);
			_policyDao = new PolicyDAO(_sqlConnection, _work);
			_policyHolderDao = new PolicyHolderDAO(_sqlConnection, _work);
			
			_accountActivityDao = new AccountActivityDAO(_sqlConnection, _work);
			_accountCompetitorDao = new AccountCompetitorDAO(_work,_sqlConnection);
			_opportunityCompetitorDao = new OpportunityCompetitorDAO(_work,_sqlConnection);
			_accountPartnerDao = new AccountPartnerDAO(_work,_sqlConnection);
			_customRecordTypeServiceDao = new CustomRecordTypeServiceDAO(_sqlConnection, _work);
			_customRecordTypeTranslationsDao = new CustomRecordTypeTranslationsDAO(_sqlConnection, _work);
			_fieldTranslationDataDao = new FieldTranslationDataDAO(_sqlConnection, _work);
			_fieldManagementServiceDao = new FieldManagementServiceDAO(_sqlConnection, _work);
			_cascadingPicklistDAO = new CascadingPicklistDAO(_sqlConnection, _work);
			_picklistServiceDao = new PicklistServiceDAO(_sqlConnection, _work);
			_currencyServiceDao = new CurrencyServiceDAO(_sqlConnection, _work);
			_industryDAO = new IndustryDAO(_sqlConnection, _work);
			
			_activityUserDao = new ActivityUserDAO(_sqlConnection, _work);
			_activityContactDao = new ActivityContactDAO(_sqlConnection, _work);
			
			_accessProfileServiceDao = new AccessProfileServiceDAO(_sqlConnection, _work);
			_accessProfileServiceEntryDao = new AccessProfileServiceEntryDAO(_sqlConnection, _work);
			_accessProfileServiceTransDao = new AccessProfileServiceTransDAO(_sqlConnection, _work);
			
			_roleServiceDao = new RoleServiceDAO(_sqlConnection, _work);
			_roleServiceAvailableTabDao = new RoleServiceAvailableTabDAO(_sqlConnection, _work);
			_roleServiceLayoutDao = new RoleServiceLayoutDAO(_sqlConnection, _work);
			_roleServicePageLayoutDao = new RoleServicePageLayoutDAO(_sqlConnection, _work);
			_roleServicePrivilegeDao = new RoleServicePrivilegeDAO(_sqlConnection, _work);
			_roleServiceRecordTypeAccessDao = new RoleServiceRecordTypeAccessDAO(_sqlConnection, _work);
			_roleServiceSelectedTabDao = new RoleServiceSelectedTabDAO(_sqlConnection, _work);
			_roleServiceTransDao = new RoleServiceTransDAO(_sqlConnection, _work);
			
			_applicationDao = new ApplicationDAO(_sqlConnection, _work);
			_assetDao = new AssetDAO(_sqlConnection, _work);
			_bookDao = new BookDAO(_sqlConnection, _work);
			_planAccountDao = new PlanAccountDAO(_sqlConnection, _work);
			_planContactDao = new PlanContactDAO(_sqlConnection, _work);
			_businessPlanDao = new BusinessPlanDAO(_sqlConnection, _work);
			_inventoryAuditReportDao = new InventoryAuditReportDAO(_sqlConnection, _work);
			_inventoryPeriodDao = new InventoryPeriodDAO(_sqlConnection, _work);
			_modificationTrackingDao = new ModificationTrackingDAO(_sqlConnection, _work);
			_objectivesDao = new ObjectivesDAO(_sqlConnection, _work);
			_messageResponseDao = new MessageResponseDAO(_sqlConnection, _work);
			_planOpportunityDao = new PlanOpportunityDAO(_sqlConnection, _work);
			_sampleDisclaimerDao = new SampleDisclaimerDAO(_sqlConnection, _work);
			_sampleInventoryDao = new SampleInventoryDAO(_sqlConnection, _work);
			_sampleLotDao = new SampleLotDAO(_sqlConnection, _work);
			_signatureDao = new SignatureDAO(_sqlConnection, _work);
			_allocationDao = new AllocationDAO(_sqlConnection, _work);
			_contactLicenseDao = new ContactLicenseDAO(_sqlConnection, _work);
			_messagePlanDao = new MessagePlanDAO(_sqlConnection, _work);
			_msgPlanItemDao = new MsgPlanItemDAO(_sqlConnection, _work);
			_msgPlanItemRelationDao = new MsgPlanItemRelationDAO(_sqlConnection, _work);
			_transactionItemDao = new TransactionItemDAO(_sqlConnection, _work);
			_sampleTransactionDao = new SampleTransactionDAO(_sqlConnection, _work);
			_categoryDao = new CategoryDAO(_sqlConnection, _work);
			_dealerDao = new DealerDAO(_sqlConnection, _work);
			_claimDao = new ClaimDAO(_sqlConnection, _work);
			_contactBestTimesDao = new ContactBestTimesDAO(_sqlConnection, _work);
			_coverageDao = new CoverageDAO(_sqlConnection, _work);
			_customObject3Dao = new CustomObject3DAO(_sqlConnection, _work);
			_customObject10Dao = new CustomObject10DAO(_sqlConnection, _work);
			_customObject11Dao = new CustomObject11DAO(_sqlConnection, _work);
			_customObject12Dao = new CustomObject12DAO(_sqlConnection, _work);
			_customObject13Dao = new CustomObject13DAO(_sqlConnection, _work);
			_customObject15Dao = new CustomObject15DAO(_sqlConnection, _work);
			_customObject4Dao = new CustomObject4DAO(_sqlConnection, _work);
			_customObject5Dao = new CustomObject5DAO(_sqlConnection, _work);
			_customObject6Dao = new CustomObject6DAO(_sqlConnection, _work);
			_customObject7Dao = new CustomObject7DAO(_sqlConnection, _work);
			_customObject8Dao = new CustomObject8DAO(_sqlConnection, _work);
			_customObject9Dao = new CustomObject9DAO(_sqlConnection, _work);
			_damageDao = new DamageDAO(_sqlConnection, _work);
			_dealRegistrationDao = new DealRegistrationDAO(_sqlConnection, _work);
			_financialAccountDao = new FinancialAccountDAO(_sqlConnection, _work);
			_financialAccountHolderDao = new FinancialAccountHolderDAO(_sqlConnection, _work);
			_financialAccountHoldingDao = new FinancialAccountHoldingDAO(_sqlConnection, _work);
			_financialPlanDao = new FinancialPlanDAO(_sqlConnection, _work);
			_financialProductDao = new FinancialProductDAO(_sqlConnection, _work);
			_financialTransactionDao = new FinancialTransactionDAO(_sqlConnection, _work);
			_fundDao = new FundDAO(_sqlConnection, _work);
			_groupDao = new GroupDAO(_sqlConnection, _work);
			_householdDao = new HouseholdDAO(_sqlConnection, _work);
			_insurancePropertyDao = new InsurancePropertyDAO(_sqlConnection, _work);
			_involvedPartyDao = new InvolvedPartyDAO(_sqlConnection, _work);
			_mDFRequestDao = new MDFRequestDAO(_sqlConnection, _work);
			_medEdDao = new MedEdEventDAO(_sqlConnection, _work);
			_noteDao = new NoteDAO(_sqlConnection, _work);
			_portfolioDao = new PortfolioDAO(_sqlConnection, _work);
			_priceListDao = new PriceListDAO(_sqlConnection, _work);
			_priceListLineItemDao = new PriceListLineItemDAO(_sqlConnection, _work);
			_sPRequestDao = new SPRequestDAO(_sqlConnection, _work);
			_sPRequestLineItemDao = new SPRequestLineItemDAO(_sqlConnection, _work);
			_solutionDao = new SolutionDAO(_sqlConnection, _work);
			_territoryDao = new TerritoryDAO(_sqlConnection, _work);
			_vehicleDao = new VehicleDAO(_sqlConnection, _work);
			_accountNoteDao = new AccountNoteDAO(_work,_sqlConnection);
			_contactNoteDao = new ContactNoteDAO(_work,_sqlConnection);
			_campaignNoteDao = new CampaignNoteDAO(_work,_sqlConnection);
			_opportunityNoteDao = new OpportunityNoteDAO(_work,_sqlConnection);
			_serviceNoteDao = new ServiceRequestNoteDAO(_work,_sqlConnection);
			_relatedContactDao = new RelatedContactDAO(_sqlConnection,_work);
			_accountRelatedDao = new AccountRelationshipDAO(_sqlConnection,_work);
			_activityProductDao = new ActivityProductDAO(_sqlConnection, _work);
			_contactAccountDao = new ContactAccountDAO(_sqlConnection, _work);
			_bookmarkDao = new BookmarkDAO(_sqlConnection, _work);
			_recentDao = new RecentDAO(_sqlConnection, 10, _work);
			_columnsLayoutDao = new ColumnsLayoutDAO(_sqlConnection, _work);
			_subColumnLayoutDao = new SubColumnLayoutDAO(_sqlConnection, _work);
			_viewLayoutDAO = new ViewLayoutDAO(_sqlConnection, _work);
			_recordTypeDao = new RecordTypeDAO(_sqlConnection,_work);
			_layoutDao = new LayoutDAO(_sqlConnection, _work); 
			_validationRuleDAO = new ValidationRuleDAO(_sqlConnection, _work);
			_validationRuleTranslatorDAO = new ValidationRuleTranslatorDAO(_sqlConnection, _work);
			_customFieldDao = new CustomFieldDAO(_sqlConnection, _work);
			_customFieldTranslatorDao = new CustomFieldTranslatorDAO(_sqlConnection, _work);
			_customPicklistValueDao = new CustomPicklistValueDAO(_sqlConnection, _work);
			_finderDao = new FinderDAO(_sqlConnection, _work);
			_opportunityPartnerDao = new OpportunityPartnerDAO(_work,_sqlConnection);
			_opportunityProductRevenueDao = new OpportunityProductRevenueDAO(_work,_sqlConnection);			
			_reportDAO = new ReportDAO(_sqlConnection, _work);
			_reportFieldsDAO = new ReportFieldsDAO(_sqlConnection, _work);
			
			_sqlListDAO = new SQLListDAO(_sqlConnection, _work);
			_territoryTreeDAO = new TerritoryTreeDAO(_sqlConnection, _work);
			_depthStructureTreeDAO = new DepthStructureTreeDAO(_sqlConnection, _work);
			_dashboardLayoutDAO = new DashboardLayoutDAO(_sqlConnection, _work);
			_dashboardFilterDAO = new DashboardFilterDAO(_sqlConnection, _work);
			_reportAdminDao = new ReportAdminDAO(_sqlConnection, _work);
			_reportAdminChildDao = new ReportAdminChildDAO(_sqlConnection, _work);
			_accountObjectiveDao = new AccountObjectiveDAO( _work,_sqlConnection);
			_accountOpportunityDao = new AccountOpportunityDAO(_sqlConnection,_work);
			_accountCustomObject2Dao = new AccountCustomObject2DAO(_sqlConnection,_work);
			_accountCustomObject3Dao = new AccountCustomObject3DAO(_sqlConnection,_work);
			_accountCustomObject4Dao = new AccountCustomObject4DAO(_sqlConnection,_work);
			_accountCustomObject10Dao = new AccountCustomObject10DAO(_sqlConnection,_work);
			_accountAccountDao = new AccountAccountDAO(_sqlConnection,_work);
			_contactOpportunityDao = new ContactOpportunityDAO(_sqlConnection,_work);
			_accountServiceRequestDao = new AccountServiceRequestDAO(_sqlConnection,_work);
			_customObject2ContactDao = new CustomObject2ContactDAO(_sqlConnection,_work);
			//VAHI END refactored
			_relationManagementDao = new RelationManagementDAO(_sqlConnection,_work);
			
			// VAHI BEGIN to be refactored
			
			_fieldFinderDao = new FieldFinderDAO(_sqlConnection);
			_finderMapDao = new FinderMapDAO(_sqlConnection);
			_linkDao = new LinkDAO(_sqlConnection);
			_filterDao = new FilterDAO(_sqlConnection);
			_customTableWidthConfigurationDAO = new CustomTableWidthConfigurationDAO(_sqlConnection);
			_criteriaDao = new CriteriaDAO(_sqlConnection);
			_picklistDao = new PicklistDAO(_sqlConnection);
			_netbreezeDao = new NetbreezeDAO(_sqlConnection);
			_netbreezeAccountDao = new NetbreezeAccountDAO(_sqlConnection);
			_attachmentDao = new AttachmentDAO(_sqlConnection, _work);
			_fieldDao = new FieldDAO(_sqlConnection);
			_salesProcDao = new SalesProcDAO(_sqlConnection);
			_salesStageDao = new SalesStageDAO(_sqlConnection);
			_transactionDao = new TransactionDAO(_sqlConnection);
			_subSyncDao = new SubSyncDAO(_sqlConnection,_work);
			
			_opportunityTeamDao = new OpportunityTeamDAO(_work,_sqlConnection);
			_validationDao = new ValidationDAO(_sqlConnection, _work);
			_processOpportunityDao = new ProcessOpportunityDAO(_sqlConnection);
			_customLayoutDao = new CustomLayoutDAO(_sqlConnection,_work);
			_queryDao = new QueryDAO(_sqlConnection);
			// VAHI END to be refactored
			
			_rightDAO = new RightDAO(_sqlConnection);
			
			_currentUserDAO = new CurrentUserDAO(_sqlConnection);
			
			_feedDAO = new FeedDAO(_sqlConnection, _work);
			
			_feedUserDAO = new FeedUserDAO(_sqlConnection, _work);
			
			_feedFollowerDAO = new FeedFollowerDAO(_sqlConnection, _work);
			
			_feedUpdateDAO = new FeedUpdateDAO(_sqlConnection, _work);
			
			_feedUpdateDetailDAO = new FeedUpdateDetailDAO(_sqlConnection, _work);
			
			_feedOwnerDAO = new FeedOwnerDAO(_sqlConnection);
			
			_feedEntityDAO = new FeedEntityDAO(_sqlConnection, _work);
			
			_feedGroupDAO = new FeedGroupDAO(_sqlConnection, _work);
			
			_feedGroupMemberDAO = new FeedGroupMemberDAO(_sqlConnection, _work);
			
			_dailyAgendaColumnLayoutDao = new DailyAgendaColumnsLayoutDAO(_sqlConnection, _work);
			_opportunityContactDao = new OpportunityContactDAO(_work,_sqlConnection);
			_feedHistoryDAO = new FeedHistoryDAO(_sqlConnection, _work);
			
			_customLayoutConditionDAO = new CustomLayoutConditionDAO(_sqlConnection,_work);
			
			_customFilterTranslatorDao = new CustomFilterTranslatorDAO(_sqlConnection, _work);		
			_questionDao =new  QuestionDAO(_sqlConnection, _work);
			_sumFieldDao = new SumFieldDAO(_sqlConnection,_work);
			_assessmentDao = new AssessmentDAO(_sqlConnection, _work);
			
			_answerDao = new AnswerDAO(_sqlConnection, _work);
			
			_assessmentConfigDao = new AssessmentConfigDAO(_sqlConnection, _work);
			_mappingTableSettingDao = new MappingTableColumnSetting(_sqlConnection, _work);
			
			_assessmentPageDao = new AssessmentPageDAO(_sqlConnection, _work);
			
			_assessmentMappingDao = new AssessmentMappingDao(_sqlConnection,_work);
			
			_assessmentPDFHeaderDao = new AssessmentPDFHeaderDAO(_sqlConnection,_work);
			
			_assessmentPDFColorThemeDao = new AssessmentPDFColorThemeDAO(_sqlConnection,_work);
			// CH 
			_assessmentSplitterDao = new AssessmentSplitterDAO(_sqlConnection, _work);
			_dashboardReportDao = new DashboardReportDAO(_sqlConnection, _work);
			
			_timeZoneDao = new TimeZoneDAO(_sqlConnection, _work);
			
			
			// create temporary directory
			_tempFolder = File.createTempDirectory();
			
			_relatedButtonDAO = new RelatedButtonDAO(_sqlConnection);
			
			_sortColumnDao = new SortColumnDAO(_sqlConnection, _work);
			_revenueDao = new RevenueDao(_sqlConnection, _work);
			_revenueMappingProductFamilyDao = new RevenueMappingProductFamilyDao(_sqlConnection, _work);
			_templateDao=new OrderTemplate(_sqlConnection,_work);
			_templateItemDao=new OrderTemplateItem(_sqlConnection,_work);
			
		}
		
		
		public static  function checkBeforeStart():void{
			if(database==null) return;
			// CH custom_layout
			//database.XcheckCustomLayoutTable(database._sqlConnection);
			
			//VAHI now doing the update even after a fresh init
			// This prevents future bugs because the code becomes too difficult.
			database.IcheckAndRecreateTables(database._sqlConnection);
			database.IupdateDatabase(database._sqlConnection);
			
			// CH now doing in new framework 
			//IcheckIndexes(_sqlConnection);
			
			var columns:ArrayCollection = new ArrayCollection([
				{old_key: "disable_button_sr_sync_accept_unaccept", new_key: "enable_button_sr_sync_accept_unaccept", new_value: false}
			]);
			database.XchangePrefsKey(database._sqlConnection, columns);
			
			database.XcheckDefaultEntries(database._sqlConnection);
			database.XcheckTablePrefs(database._sqlConnection);
			
			// custom layouts set default background
			database.XupdateBackgroundColor(database._sqlConnection);
			
			//clean assessment mapping data
			assessmentMappingDao.cleanMapping();
			
			_work = null;	//VAHI make sure we do not accidentally use it later
			
			LocaleService.reset();
			
			database.initTimeZoneData();
		}
		
		//insert data to timezone by hardcoded
		private function initTimeZoneData():void{
			if(_timeZoneDao.count()<=0){
				_timeZoneDao.initData();
			}
		}
		
		private function XcheckDefaultEntries(sqlConnection:SQLConnection):void {
			_work("Checking default entries...", function(params:Object):void {
				
				begin();
				
				// detail layout
				YcheckLayout("Account");
				YcheckLayout("Contact");
				YcheckLayout("Opportunity");
				YcheckLayout("Activity"); // task
				YcheckLayout("Activity",1); // appointment
				YcheckLayout("Activity",2); // call
				YcheckLayout("Product");
				YcheckLayout("Service Request");
				YcheckLayout("Campaign");
				YcheckLayout("Custom Object 1");
				YcheckLayout("Lead");
				YcheckLayout("Custom Object 2");
				YcheckLayout("Custom Object 3");
				YcheckLayout("CustomObject7");
				YcheckLayout("CustomObject14");
				YcheckLayout("CustomObject4");
				YcheckLayout("CustomObject5");
				YcheckLayout("CustomObject6");
				YcheckLayout("CustomObject8");
				YcheckLayout("CustomObject9");
				YcheckLayout("CustomObject10");
				YcheckLayout("CustomObject11");
				YcheckLayout("CustomObject12");
				YcheckLayout("CustomObject13");
				YcheckLayout("CustomObject15");
				YcheckLayout("Asset");
				YcheckLayout("Territory");
				YcheckLayout("Note");
				YcheckLayout("MedEdEvent");
				YcheckLayout("BusinessPlan");
				YcheckLayout(opportunityProductRevenueDao.entity);
				YcheckLayout(activitySampleDroppedDao.entity);
				YcheckLayout(accountNoteDao.entity);
				YcheckLayout(accountPartnerDao.entity);
				YcheckLayout(accountCompetitorDao.entity);
				YcheckLayout(accountTeamDao.entity);
				YcheckLayout(campaignNoteDao.entity);
				YcheckLayout(contactNoteDao.entity);
				YcheckLayout(contactTeamDao.entity);
				YcheckLayout(opportunityCompetitorDao.entity);
				//YcheckListLayout("Contact Relationships");
				YcheckLayout(opportunityNoteDao.entity);
				YcheckLayout(opportunityTeamDao.entity);
				YcheckLayout(opportunityPartnerDao.entity);
				YcheckLayout(serviceNoteDao.entity);
				YcheckLayout(relatedContactDao.entity);
				YcheckLayout(objectivesDao.entity);
				YcheckLayout(activityProductDao.entity);
				YcheckLayout(accountRelatedDao.entity);
				YcheckLayout(opportunityContactDao.entity);
				YcheckLayout(activityContactDao.entity);
				// list Layout
				YcheckListLayout("Account");
				YcheckListLayout("Contact");
				YcheckListLayout("Opportunity");
				YcheckListLayout("Activity");
				YcheckListLayout("Product");
				YcheckListLayout("Service Request");
				YcheckListLayout("Campaign");
				YcheckListLayout("Custom Object 1");
				YcheckListLayout("Lead");
				YcheckListLayout("Custom Object 2");
				YcheckListLayout("Custom Object 3");
				YcheckListLayout("CustomObject7");
				YcheckListLayout("CustomObject14");
				YcheckListLayout("CustomObject4");
				YcheckListLayout("CustomObject5");
				YcheckListLayout("CustomObject6");
				YcheckListLayout("CustomObject8");
				YcheckListLayout("CustomObject9");
				YcheckListLayout("CustomObject10");
				YcheckListLayout("CustomObject11");
				YcheckListLayout("CustomObject12");
				YcheckListLayout("CustomObject13");
				YcheckListLayout("CustomObject15");
				YcheckListLayout("Asset");
				YcheckListLayout("Territory");
				YcheckListLayout("Note");
				YcheckListLayout("MedEdEvent");
				YcheckListLayout("BusinessPlan");
				
				YcheckListLayout(accountRelatedDao.entity);
				YcheckListLayout(activityProductDao.entity);
				YcheckListLayout(opportunityProductRevenueDao.entity);
				YcheckListLayout(activitySampleDroppedDao.entity);
				YcheckListLayout(accountNoteDao.entity);
				YcheckListLayout(accountPartnerDao.entity);
				YcheckListLayout(accountCompetitorDao.entity);
				YcheckListLayout(accountTeamDao.entity);
				YcheckListLayout(opportunityCompetitorDao.entity);
				//YcheckListLayout(accountObjectiveDao.entity);
				YcheckListLayout(accountAddressDao.entity);
				
				YcheckListLayout(campaignNoteDao.entity);
				YcheckListLayout(contactNoteDao.entity);
				YcheckListLayout(contactTeamDao.entity);
				YcheckListLayout(relatedContactDao.entity);
				YcheckListLayout(opportunityNoteDao.entity);
				YcheckListLayout(opportunityTeamDao.entity);
				YcheckListLayout(opportunityPartnerDao.entity);
				YcheckListLayout(serviceNoteDao.entity);
				YcheckListLayout(objectivesDao.entity);
				YcheckListLayout(opportunityContactDao.entity);
				YcheckListLayout(activityContactDao.entity);
				// view Layout
				YcheckViewLayout("Account");
				YcheckViewLayout("Contact");
				YcheckViewLayout("Opportunity");
				YcheckViewLayout("Activity");
				YcheckViewLayout("Product");
				YcheckViewLayout("Service Request");
				YcheckViewLayout("Campaign");
				YcheckViewLayout("Custom Object 1");
				YcheckViewLayout("Lead");
				YcheckViewLayout("Custom Object 2");
				YcheckViewLayout("Custom Object 3");
				YcheckViewLayout("CustomObject7");
				YcheckViewLayout("CustomObject14");
				YcheckViewLayout("CustomObject4");
				YcheckViewLayout("CustomObject5");
				YcheckViewLayout("CustomObject6");
				YcheckViewLayout("CustomObject8");
				YcheckViewLayout("CustomObject9");
				YcheckViewLayout("CustomObject10");
				YcheckViewLayout("CustomObject11");
				YcheckViewLayout("CustomObject12");
				YcheckViewLayout("CustomObject13");
				YcheckViewLayout("CustomObject15");
				YcheckViewLayout("Asset");
				YcheckViewLayout("Territory");
				YcheckViewLayout("Note");
				YcheckViewLayout("MedEdEvent");
				YcheckViewLayout("BusinessPlan");
				YcheckViewLayout(Database.objectivesDao.entity);
				YcheckViewLayout(opportunityContactDao.entity);
				YcheckViewLayout(activityContactDao.entity);
				//field:String = null, operator:String = null, value:String = null
				// custom layouts
				
				YcheckCustomLayout("Account", "accountDefault", "Account", "Accounts");
				YcheckCustomLayout("Contact", "contactDefault", "Contact", "Contacts");
				YcheckCustomLayout("Opportunity", "opportunityDefault", "Opportunity", "Opportunities");
				YcheckCustomLayout(activityProductDao.entity, "productDefault", "Product Detailed", "Product Detailed");
				YcheckCustomLayout(opportunityProductRevenueDao.entity, "opportunityDefault", "Opporttunity Revenue", "Opporttunity Revenues");
				YcheckCustomLayout(activitySampleDroppedDao.entity, "activityTaskDefault", "Sample Dropped", "Samples Dropped");
				YcheckCustomLayout(accountNoteDao.entity,"accountDefault","Note", "Notes");
				//YcheckCustomLayout(accountObjectiveDao.entity,"accountDefault","Objectives", "Objectives");
				//YcheckCustomLayout(addressDao.entity,"accountDefault","Address", "Address");
				YcheckCustomLayout(accountPartnerDao.entity,"accountDefault","Partner","Partners");
				YcheckCustomLayout(accountCompetitorDao.entity,"accountDefault","Competitor","Competitors");
				YcheckCustomLayout(accountTeamDao.entity,"accountDefault","Account Team","Account Teams");
				YcheckCustomLayout(contactNoteDao.entity,"contactDefault","Note", "Notes");
				YcheckCustomLayout(contactTeamDao.entity,"contactDefault","Contact Team","Contact Teams");
				YcheckCustomLayout(relatedContactDao.entity,"contactDefault","Contact Relationship", "Contact Relationships");
				YcheckCustomLayout(campaignNoteDao.entity,"campaignDefault","Note", "Notes");
				//YcheckCustomLayout("Contact Relationships");
				YcheckCustomLayout(opportunityNoteDao.entity,"opportunityDefault","Note", "Notes");
				YcheckCustomLayout(opportunityTeamDao.entity,"opportunityDefault","Opportunity Team","Opportunity Teams");
				YcheckCustomLayout(opportunityPartnerDao.entity,"opportunityDefault","Opportunity Partner","Opportunity Partners");
				YcheckCustomLayout(serviceNoteDao.entity,"serviceDefault","Note", "Notes");
				YcheckCustomLayout(opportunityCompetitorDao.entity,"opportunityDefault","Competitor","Competitors");
				YcheckCustomLayout(accountRelatedDao.entity,"accountDefault","Account Relationship","Account Relationships");
				YcheckCustomLayout(opportunityContactDao.entity,"contactDefault","Contact","Contacts");
				/*
				CH
				1) activity != Appointment 									-----------> TASK
				2) activity = Appointment and CallType != 'Account Call' 	-----------> APPOINTMENT
				3) activity = Appointment and CallType = 'Account Call' 	-----------> CALL
				*/
				
				YcheckCustomLayout("Activity", "activityTaskDefault", "Activity", "Activities", 0, [{column_name:'Activity', operator:'!=', params:'Appointment'}]);
				YcheckCustomLayout("Activity", "activityAppointmentDefault", "Appointment", "Appointments", 1, [{column_name:'Activity', operator:'=', params:'Appointment'}, {column_name:'CallType', operator:'!=', params:'Account Call'}]);
				YcheckCustomLayout("Activity", "activityCallDefault", "Call", "Calls", 2, [{column_name:'Activity', operator:'=', params:'Appointment'}, {column_name:'CallType', operator:'=', params:'Account Call'}]);
				
				
				
				YcheckCustomLayout("Product", "productDefault", "Product", "Products");
				YcheckCustomLayout("Service Request", "serviceDefault", "Service Request", "Service Requests");
				YcheckCustomLayout("Campaign", "campaignDefault", "Campaign", "Campaigns");
				YcheckCustomLayout("Custom Object 1", "customDefault", "Custom Object 1", "Custom Objects 1");
				YcheckCustomLayout("Lead", "leadDefault", "Lead", "Leads");
				YcheckCustomLayout("Custom Object 2", "custom2Default", "Custom Object 2", "Custom Objects 2");
				YcheckCustomLayout("Custom Object 3", "custom3Default", "Custom Object 3", "Custom Objects 3");
				YcheckCustomLayout("CustomObject14", "custom14Default", "Custom Object 14", "Custom Objects 14");
				YcheckCustomLayout("CustomObject7", "custom7Default", "Custom Object 7", "Custom Objects 7");
				YcheckCustomLayout("CustomObject4", "custom4Default", "Custom Object 4", "Custom Objects 4");
				YcheckCustomLayout("CustomObject5", "custom5Default", "Custom Object 5", "Custom Objects 5");
				YcheckCustomLayout("CustomObject6", "custom6Default", "Custom Object 6", "Custom Objects 6");
				YcheckCustomLayout("CustomObject8", "custom8Default", "Custom Object 8", "Custom Objects 8");
				YcheckCustomLayout("CustomObject9", "custom9Default", "Custom Object 9", "Custom Objects 9");
				YcheckCustomLayout("CustomObject10", "custom10Default", "Custom Object 10", "Custom Objects 10");
				YcheckCustomLayout("CustomObject11", "custom10Default", "Custom Object 11", "Custom Objects 11");
				YcheckCustomLayout("CustomObject12", "custom10Default", "Custom Object 12", "Custom Objects 12");
				YcheckCustomLayout("CustomObject13", "custom10Default", "Custom Object 13", "Custom Objects 13");
				YcheckCustomLayout("CustomObject15", "custom15Default", "Custom Object 15", "Custom Objects 15");
				
				YcheckCustomLayout("Activity.Product", "productDefault", "Product Detailed", "Product Detailed");
				YcheckCustomLayout("Contact.Account", "contactDefault", "Contact", "Contacts");
				YcheckCustomLayout("Account.Contact", "accountDefault", "Account", "Accounts");
				YcheckCustomLayout("Asset", "assetDefault", "Asset", "Assets");
				YcheckCustomLayout("Territory", "territoryDefault", "Territory", "Territories");
				YcheckCustomLayout("Note", "noteDefault", "Note", "Notes");
				YcheckCustomLayout("MedEdEvent", "MedEdDefault", "MedEd Event", "MedEd Events");
				YcheckCustomLayout("BusinessPlan", "BusinessDefault", "Business Plan", "Business Plans");
				YcheckCustomLayout(Database.objectivesDao.entity, "ObjectivesDefault", "Objective", "Objectives");
				YcheckCustomLayout(Database.activityContactDao.entity, "contactDefault", "Contact", "Contacts");
				YcheckPrefs(PreferencesDAO.PDF_LOGO,sqlConnection);
				YcheckPrefs(PreferencesDAO.WINDOW_LOGO,sqlConnection);
				YcheckPrefs(PreferencesDAO.USER_SIGNATURE,sqlConnection);
				
				YcheckPicklist_Service(sqlConnection);
				
				YcheckPicklist_Disabled(sqlConnection);
				
				YcheckFinder();
				
				// CH : check Owner in Table Fields when entity is Activity
				ycheckMissingField();
				
				//insert data default filter
				YcheckDefaultFilter();
				
				
				//insert data transaction
				YcheckTransaction();
				
				YcheckFeeds();
				YcheckSubTransaction();				
				
				
				commit();
				
			});
			
		}
		
		private function YcheckPicklist_Service(sqlConnection:SQLConnection):void {			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = sqlConnection;
			stmt.text = "SELECT Name FROM picklist_service WHERE FieldName = 'CustomPickList0' LIMIT 1";
			try {
				//exec(stmt);
				//var result:SQLResult = stmt.getResult();
				//if (result==null || (result!=null && result.data == null)) {
				var stmtUpdate:SQLStatement = new SQLStatement();
				stmtUpdate.sqlConnection = sqlConnection;
				stmtUpdate.text = "UPDATE picklist_service SET FieldName = 'CustomPickList0' WHERE Name = 'PICK_000' AND FieldName = 'CustomPickList'";
				exec(stmtUpdate);
				//}
			} catch (e:SQLError) {
				trace(e);
			}
			
		}
		
		private function YcheckPicklist_Disabled(sqlConnection:SQLConnection):void {			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = sqlConnection;
			stmt.text = "SELECT * FROM picklist LIMIT 1";
			try {
				exec(stmt);
				var result:SQLResult = stmt.getResult();
				//if (result==null || (result!=null && result.data == null)) {
				if (result!=null && result.data != null) {
					var obj:Object = result.data[0];
					if (obj.value != 'null' && StringUtils.isEmpty(obj.disabled)) {
						var stmtUpdate:SQLStatement = new SQLStatement();
						stmtUpdate.sqlConnection = sqlConnection;
						stmtUpdate.text = "UPDATE picklist SET disabled = 'N'";
						exec(stmtUpdate);
					}					
				}
			} catch (e:SQLError) {
				trace(e);
			}
		}
		
		private function YcheckPrefs(logo:String,sqlConnection:SQLConnection):void {
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = sqlConnection;
			stmt.text = "SELECT * FROM prefs WHERE key = '" + logo + "' LIMIT 1";
			try {
				exec(stmt);
				var result:SQLResult = stmt.getResult();
				if (result!=null && result.data != null) {
					var obj:Object = result.data[0];
					if (obj.value == 'null') {
						var stmtUpdate:SQLStatement = new SQLStatement();
						stmtUpdate.sqlConnection = sqlConnection;
						stmtUpdate.text = "UPDATE prefs SET value = null WHERE key = '" + logo + "'";
						exec(stmtUpdate);
					}
				}
			} catch (e:SQLError) {
				trace(e);
			}
		}
		
		private function YcheckFinder():void {
			
			var fieldFinders:ArrayCollection = new ArrayCollection([
				{entity:'Account', element_name:'Owner', finder:'OwnerFinder'},
				{entity:'Account', element_name:'OwnerId', finder:'OwnerFinder'},
				{entity:'Contact', element_name:'Owner', finder:'OwnerFinder'},
				{entity:'Contact', element_name:'OwnerId', finder:'OwnerFinder'},
				{entity:'Service Request', element_name:'Owner', finder:'OwnerFinder'},
				{entity:'Service Request', element_name:'OwnerId', finder:'OwnerFinder'},
				{entity:'Service Request', element_name:'Product', finder:'ProductFinder'},
				{entity:'Activity', element_name:'AddressId', finder:'AddressFinder'},
				{entity:'Activity', element_name:'Address', finder:'AddressFinder'},
				{entity:'Activity', element_name:'OwnerId', finder:'ActivityOwnerFinder'},
				{entity:'Activity', element_name:'Alias', finder:'ActivityOwnerFinder'},
				{entity:'Activity', element_name:'Owner', finder:'ActivityOwnerFinder'},
				{entity:'Activity', element_name:'AssignedTo', finder:'ActivityOwnerFinder'},
				{entity:'Activity', element_name:'CustomObject14Id', finder:'ActivityCustomObject14Finder'},
				{entity:'Activity', element_name:'DelegatedBy', finder:'ActivityDelegatedByFinder'},
				{entity:'Activity', element_name:'DelegatedById', finder:'ActivityDelegatedByFinder'},
				{entity:'Opportunity', element_name:'Owner', finder:'OwnerFinder'},
				{entity:'Opportunity', element_name:'OwnerId', finder:'OwnerFinder'},
				// Bug #116
				{entity:'Lead', element_name:'SalesPersonFullName', finder:'SalesRepFinder'},
				{entity:'Lead', element_name:'SalesRepId', finder:'SalesRepFinder'},
				{entity:'Lead', element_name:'Owner', finder:'LeadOwnerFinder'},
				{entity:'Lead', element_name:'OwnerId', finder:'LeadOwnerFinder'},
				{entity:'Lead', element_name:'LeadOwner', finder:'LeadOwnerFinder'},
				{entity:'Opportunity.Product', element_name:'Owner', finder:'OpportunityProductOwnerFinder'},
				//Change Request #5890 CRO
				{entity:'CustomObject10', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject10', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject11', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject11', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject12', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject12', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject13', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject13', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject14', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject14', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject15', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject15', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'Custom Object 1', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'Custom Object 1', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'Custom Object 2', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'Custom Object 2', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'Custom Object 3', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'Custom Object 3', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject4', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject4', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject5', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject5', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject6', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject6', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject7', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject7', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject8', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject8', element_name:'OwnerId', finder:'COOwnerFinder'},
				{entity:'CustomObject9', element_name:'OwnerAlias', finder:'COOwnerFinder'},
				{entity:'CustomObject9', element_name:'OwnerId', finder:'COOwnerFinder'}
				
				
			]);
			
			var finders:ArrayCollection = new ArrayCollection([
				{id:'AddressFinder', finder_table:'Address', display_column:'Full_Address', key_column:'Id'},
				{id:'OwnerFinder', finder_table:'AllUsers', display_column:'FirstName,LastName', key_column:'Id'},
				{id:'ActivityOwnerFinder', finder_table:'AllUsers', display_column:'FirstName,LastName', key_column:'Id'},
				{id:'ProductFinder', finder_table:'Product', display_column:'Name', key_column:'Name'},
				{id:'ActivityCustomObject14Finder', finder_table:'Custom_Object_14', display_column:'Name', key_column:'Id'},
				{id:'ActivityDelegatedByFinder', finder_table:'AllUsers', display_column:'Alias', key_column:'Id'},				
				// Bug #116
				{id:'SalesRepFinder', finder_table:'AllUsers', display_column:'Alias', key_column:'Id'},
				{id:'LeadOwnerFinder', finder_table:'AllUsers', display_column:'Alias', key_column:'Id'},
				{id:'OpportunityProductOwnerFinder', finder_table:'AllUsers', display_column:'FirstName,LastName', key_column:'Id'},
				//Change Request #5890 CRO
				{id:'COOwnerFinder', finder_table:'AllUsers', display_column:'Alias', key_column:'Id'}
			]);
			
			var findersMap:ArrayCollection = new ArrayCollection([
				{id:'AddressFinder', field:'AddressId', column:'Id'},  
				{id:'AddressFinder', field:'Address', column:'Full_Address'},
				{id:'OwnerFinder', field:'Owner', column:'Alias'},			
				{id:'OwnerFinder', field:'OwnerId', column:'Id'},
				{id:'OwnerFinder', field:'OwnerEmailAddress', column:'EMailAddr'},
				{id:'ActivityOwnerFinder', field:'Alias', column:'Alias'},
				{id:'ActivityOwnerFinder', field:'Owner', column:'Alias'},
				{id:'ActivityOwnerFinder', field:'OwnerId', column:'Id'},
				{id:'ActivityOwnerFinder', field:'AssignedTo', column:'FullName'},
				{id:'ProductFinder', field:'Product', column:'Name'},
				{id:'ActivityCustomObject14Finder', field:'CustomObject14Id', column:'Id'},
				{id:'ActivityCustomObject14Finder', field:'Name', column:'Name'},
				{id:'ActivityDelegatedByFinder', field:'DelegatedBy', column:'Alias'},
				{id:'ActivityDelegatedByFinder', field:'DelegatedById', column:'Id'},
				// Bug #116
				{id:'SalesRepFinder', field:'SalesPersonFullName', column:'Alias'},
				{id:'SalesRepFinder', field:'SalesRepId', column:'Id'},
				{id:'LeadOwnerFinder', field:'Owner', column:'Alias'},
				{id:'LeadOwnerFinder', field:'OwnerId', column:'Id'},
				{id:'LeadOwnerFinder', field:'LeadOwner', column:'Alias'},
				{id:'OpportunityProductOwnerFinder', field:'Owner', column:'Alias'},
				{id:'OpportunityProductOwnerFinder', field:'OwnerId', column:'Id'},
				//Change Request #5890 CRO
				{id:'COOwnerFinder', field:'OwnerAlias', column:'Alias'},			
				{id:'COOwnerFinder', field:'OwnerId', column:'Id'},
				
			]);
			
			Database.fieldFinderDAO.deleteAll();
			Database.finderDAO.deleteAll();
			Database.finderMapDAO.deleteAll();
			
			for each(var fieldFinder:Object in fieldFinders){
				Database.fieldFinderDAO.insert(fieldFinder);
			}
			for each(var finder:Object in finders){
				Database.finderDAO.insert_finder(finder);
			}
			for each(var finderMap:Object in findersMap){
				Database.finderMapDAO.insert(finderMap);
			}
			
		}
		
		public static function ycheckMissingField():void{			
			if(allUsersDao.ownerUser()[DAOUtils.getOracleId(allUsersDao.entity)]==null){
				return;//no need to check when empty data base
			}
			if(database._fieldDao.findFieldByPrimaryKey("Activity", "Owner")==null){
				database._fieldDao.insert({entity:"Activity", element_name:"Owner", display_name:i18n._("GLOBAL_OWNER@Owner"), data_type:"Picklist"});
			}
			if(database._fieldDao.findFieldByPrimaryKey("Activity", "Address")==null){
				database._fieldDao.insert({entity:"Activity", element_name:"Address", display_name:i18n._('GLOBAL_ADDRESS@Address'), data_type:"Picklist"});
			}
			if(database._fieldDao.findFieldByPrimaryKey("Activity", "IsPrivateEvent")==null){
				database._fieldDao.insert({entity:"Activity", element_name:"IsPrivateEvent", display_name:i18n._('GLOBAL_PRIVATE_EVENT@Private Event'), data_type:"BOOLEAN"});
			}
			if(database._fieldDao.findFieldByPrimaryKey("Activity", "GUID")==null){
				database._fieldDao.insert({entity:"Activity", element_name:"GUID", display_name:'GUID', data_type:"TEXT"});
			}
			if(database._fieldDao.findFieldByPrimaryKey("Activity", "GDATA")==null){
				database._fieldDao.insert({entity:"Activity", element_name:"GDATA", display_name:'GDATA', data_type:"TEXT"});
			}
			//CRO  closed 07-06-11
			/*if(database._fieldDao.findFieldByPrimaryKey("Service Request", "GroupReport")==null){
			database._fieldDao.insert({entity:"Service Request", element_name:"GroupReport", display_name:'Report Group', data_type:"Checkbox"});
			}*/
			if(database._fieldDao.findFieldByPrimaryKey("Contact", "ms_change_key")==null){
				database._fieldDao.insert({entity:"Contact", element_name:"ms_change_key", display_name:i18n._('MS_CHANGE_KEY@Microsoft Change Key'), data_type:"TEXT"});
			}
			if(database._fieldDao.findFieldByPrimaryKey("Contact", "ms_id")==null){
				database._fieldDao.insert({entity:"Contact", element_name:"ms_id", display_name:i18n._('MS_CHANGE_ID@Microsoft Change Id'), data_type:"TEXT"});
			}
			if(database._fieldDao.findFieldByPrimaryKey("Activity", "ms_change_key")==null){
				database._fieldDao.insert({entity:"Activity", element_name:"ms_change_key", display_name:i18n._('MS_CHANGE_KEY@Microsoft Change Key'), data_type:"TEXT"});
			}
			if(database._fieldDao.findFieldByPrimaryKey("Activity", "ms_id")==null){
				database._fieldDao.insert({entity:"Activity", element_name:"ms_id", display_name:i18n._('MS_CHANGE_ID@Microsoft Change Id'), data_type:"TEXT"});
			}
			if(database._fieldDao.findFieldByPrimaryKey("Activity", "ms_local_change")==null){
				database._fieldDao.insert({entity:"Activity", element_name:"ms_local_change", display_name:i18n._('MS_LOCAL_CHANGE@Microsoft Local Change'), data_type:"TEXT"});
			}
			
			if(database._fieldDao.findFieldByPrimaryKey("Activity", "CompletedDatetime")==null){
				database._fieldDao.insert({entity:"Activity", element_name:"CompletedDatetime", display_name:i18n._('GLOBAL_COMPLETED_DATE@Completed Date'), data_type:"Date/Time"});
			}
			
			if(database._fieldDao.findFieldByPrimaryKey("BusinessPlan", "PeriodId")==null){
				database._fieldDao.insert({entity:"BusinessPlan", element_name:"PeriodId", display_name:i18n._('PERIOD_ID@Period Id'), data_type:"ID"});
				database._fieldDao.insert({entity:"BusinessPlan", element_name:"ParentPlanNameId", display_name:i18n._('PARENT_PLANNAME_ID@Parent PlanName Id'), data_type:"ID"});
			}
			
			
		}
		
		public static function cleanup():void {
			database._tempFolder.deleteDirectory(true);
		}
		
		public static function begin():void {
			BaseSQL.begin(database._sqlConnection);
		}
		
		public static function commit():void {
			BaseSQL.commit(database._sqlConnection);
		}
		
		public static function rollback():void {
			BaseSQL.rollback(database._sqlConnection);
		}
		
		private function XcreateDatabase(sqlConnection:SQLConnection):void {
			var stmt1:SQLStatement = new SQLStatement();
			stmt1.sqlConnection = sqlConnection;
			stmt1.text = "CREATE TABLE user (id TEXT, full_name TEXT, user_sign_in_id TEXT, Avatar TEXT)"
			exec(stmt1);
			
			
			_work("Creating tables...", function(params:Object):void {
				
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;
				
				
				//				stmt.text = "CREATE TABLE opportunity_product (gadget_id INTEGER, ProductId TEXT, PurchasePrice TEXT, Quantity TEXT, PRIMARY KEY(gadget_id, ProductId))"; 
				//				exec(stmt);		
				
				
				// stmt.text = "CREATE TABLE picklist (record_type TEXT, field_name TEXT, code TEXT, value TEXT, PRIMARY KEY(record_type, field_name, code, value))";
				stmt.text = "CREATE TABLE picklist (record_type TEXT, field_name TEXT, code TEXT, value TEXT,disabled TEXT, PRIMARY KEY(record_type, field_name, code, value,disabled))";
				exec(stmt);
				
				stmt.text = "CREATE TABLE netbreezeuser (id TEXT PRIMARY KEY, full_name TEXT, user_sign_in_id TEXT, netbreeze_id TEXT)";
				exec(stmt);
				
				stmt.text = "CREATE TABLE netbreeze_account (account_id TEXT PRIMARY KEY, account_name TEXT, dashboard_url TEXT, user_id TEXT)";
				exec(stmt);
				
				stmt.text = "CREATE TABLE field(entity TEXT, element_name TEXT, display_name TEXT, data_type TEXT, PRIMARY KEY(entity, element_name))";
				exec(stmt);
				
				//				stmt.text = "CREATE TABLE attachment (entity TEXT, gadget_id TEXT, num INTEGER, data BLOB, filename TEXT, AttachmentId TEXT, PRIMARY KEY(entity, gadget_id, num))";
				//				exec(stmt);
				
				
				stmt.text = "CREATE TABLE transactions (entity TEXT, enabled BOOLEAN, display_name TEXT, filter_id TEXT, parent_entity TEXT,default_filter INTEGER, sync_ws20 BOOLEAN, sync_activities BOOLEAN, sync_attachments BOOLEAN, read_only BOOLEAN, rank INTEGER,sync_order INTEGER, advanced_filter INTEGER,authorize_deletion,authorize_deletion_disable INTEGER, PRIMARY KEY(entity))";
				exec(stmt);
				
				stmt.text = "CREATE TABLE salesproc (id TEXT, name TEXT, description TEXT, default_stage TEXT)";
				exec(stmt);
				
				stmt.text = "CREATE TABLE salesstage (id TEXT, sales_proc_id TEXT, sales_stage_order int, name TEXT)";
				exec(stmt);
					
				//				stmt.text = "CREATE TABLE process_opportunity(process_id TEXT, opportunity_type_id TEXT, opportunity_type_name TEXT, PRIMARY KEY(process_id, opportunity_type_id))";
				//				exec(stmt);
				
			});	
		}
		
		private function XcheckFieldFinderTable(sqlConnection:SQLConnection):void {
			_work("Checking field finder table...", function(params:Object):void {
				
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;
				stmt.text = 'SELECT * FROM field_finder LIMIT 0';
				try {
					exec(stmt);
				} catch (e:SQLError){
					stmt.text = "CREATE TABLE field_finder(entity TEXT, element_name TEXT, finder TEXT, primary key(entity, element_name))";
					exec(stmt);
				}
			});
		}	
		
		private function XcheckRelatedButtonTable(sqlConnection:SQLConnection):void {
			_work("Checking related button table...", function(params:Object):void {
				
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;
				stmt.text = 'SELECT * FROM related_button LIMIT 0';
				try {
					exec(stmt);
				} catch (e:SQLError){
					stmt.text = "CREATE TABLE related_button(parent_entity TEXT,entity TEXT, disable BOOLEAN, primary key(parent_entity, entity))";
					exec(stmt);
				}
			});
		}	
		
		private function XcheckFinderMapTable(sqlConnection:SQLConnection):void {
			_work("Checking finder map table...", function(params:Object):void {
				
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;
				stmt.text = 'SELECT * FROM finder_map LIMIT 0';
				try {
					exec(stmt);
				} catch (e:SQLError){
					stmt.text = "CREATE TABLE finder_map(id TEXT, field TEXT, column TEXT, primary key(id, field))";
					exec(stmt);
				}
			});
		}				
		
//		private function XcheckCustomLayoutTable(sqlConnection:SQLConnection):void {
//			_work("Checking layout table...", function(params:Object):void {
//				var stmt:SQLStatement = new SQLStatement();
//				stmt.sqlConnection = sqlConnection;
//				stmt.text = "SELECT field, operator, value FROM custom_layout LIMIT 0";
//				try{
//					stmt.execute();
//					stmt = new SQLStatement();
//					stmt.sqlConnection = sqlConnection;
//					stmt.text = "DROP TABLE custom_layout";
//					stmt.execute();
//					stmt = new SQLStatement();
//					stmt.sqlConnection = sqlConnection;
//					stmt.text = "DROP TABLE custom_layout_condition";
//					stmt.execute();
//				}catch(e:SQLError){
//					// ignore
//				}finally{
//					var columns:ArrayCollection = new ArrayCollection([
//						{name: "entity", type: "TEXT"},
//						{name: "subtype", type: "INTEGER"},
//						{name: "layout_name", type: "TEXT"},
//						{name: "deletable", type: "BOOLEAN"},
//						{name: "custom_layout_icon", type: "TEXT"},
//						{name: "background_color", type: "TEXT"},
//						{name: "display_name", type: "TEXT"},
//						{name: "display_name_plural", type: "TEXT"},
//						{name: "layout_depend_on", type: "TEXT"},
//						{name: "custom_layout_title", type: "TEXT"} // Change Request #747
//					]);
//					stmt = new SQLStatement();
//					stmt.sqlConnection = sqlConnection;
//					stmt.text = 'SELECT * FROM custom_layout LIMIT 0';
//					try {
//						stmt.execute();
//					} catch (e:SQLError){
//						ZcreateTable(sqlConnection, "custom_layout", columns, ["entity", "subtype"]);
//					}
//				}
//				
//				
//			});
//		}	
		
		
		//VAHI always wrap it into a worker within an X function!
		// (And use the X-marker to let one remember!)
		private function XcheckNetbreezeUserTable(sqlConnection: SQLConnection): void
		{
			_work("Checking netbreezeuser table...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;	
				stmt.text = 'SELECT * FROM netbreezeuser LIMIT 0';
				try {
					exec(stmt);
				} catch (e:SQLError){
					stmt.text = "CREATE TABLE netbreezeuser (id TEXT PRIMARY KEY, full_name TEXT, user_sign_in_id TEXT, netbreeze_id TEXT)";
					exec(stmt);
				}
			});
		}
		
		//VAHI always wrap it into a worker within an X function!
		// (And use the X-marker to let one remember!)
		private function XcheckNetbreezeAccountTable(sqlConnection: SQLConnection): void
		{
			_work("Checking netbreeze_account table...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;	
				stmt.text = 'SELECT * FROM netbreeze_account LIMIT 0';
				try {
					exec(stmt);
				} catch (e:SQLError){
					stmt.text = "CREATE TABLE netbreeze_account (account_id TEXT PRIMARY KEY, account_name TEXT, dashboard_url TEXT, user_id TEXT)";
					exec(stmt);
				}
			});
		}
		
		
		private function XfixActivityIdNull(sqlConnection: SQLConnection):void {
			_work("Fixing NULL activity IDs...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;	
				stmt.text = "UPDATE activity SET activityId = '#' || gadget_id WHERE activityId IS NULL";
				exec(stmt);
			});
		}
		private function fixAttachments(sqlConnection: SQLConnection):void{
			
			_work("Fixing Attachments...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;	
				stmt.text = "select a1.* from attachment a1 where " +
				"exists (select * from attachment a2 where a1.gadget_id = a2.gadget_id " +
				"and a1.filename = a2.filename and a1.entity = a2.entity and a1.attachmentId > a2.attachmentId)";
				exec(stmt);
				
				var sqlResult :Object = stmt.getResult();
				if(sqlResult != null){
					
					var listResults:Array = sqlResult.data;
					for each(var obj:Object in listResults){
						
						stmt.text = "delete from attachment where gadget_id = '"+obj.gadget_id +"' and " +
						"filename = '"+obj.filename +"' and entity = '"+obj.entity +"' and attachmentId = '"+obj.AttachmentId +"'";
						exec(stmt);
					} 
					
				}
				
			});
			
		}
		
		private function XfixLastSync(sqlConnection: SQLConnection):void {
			_work("Fixing Last Sync table...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;	
				stmt.text = "DELETE FROM last_sync WHERE task_name NOT LIKE 'successsync' AND task_name NOT LIKE 'gadget.sync.incoming%'" +
				" AND task_name NOT LIKE 'gadget.sync.outgoing%'" +
				" AND task_name NOT LIKE 'gadget.sync.tests%'" +
				" AND task_name NOT LIKE '"+MainWindow.AUTO_NEXT_SYNC+"%'"
				;
				exec(stmt);
			});
		}
		
		private var schemas:Object = {};
		
		private function checkFieldInternal(entity:String, field:String):Boolean {
			var tableName:String = DAOUtils.getTable(entity);
			if (schemas[tableName] == null) {
				try {
					loadSchema(_sqlConnection, SQLTableSchema, tableName);
				} catch (e:Error) {
					trace("missing table: entity",entity,"table",tableName,"field",field,e.message);
					return true;	//This is to provoke more errors and to fill fields table for more easy capturing
				}
				var result:SQLSchemaResult = database._sqlConnection.getSchemaResult();
				var tableSchema:SQLTableSchema = result.tables[0];
				var known:Object = {};
				for each (var colSchema:SQLColumnSchema in tableSchema.columns) {
					known[colSchema.name.toLowerCase()] = true;
				}
				schemas[tableName] = known;
			}
			if (field.toLowerCase() in schemas[tableName])
				return true;
			OOPStrace("missing field: entity",entity,"table",tableName,"field",field);
			//			errorLoggingDao.add(null, {missing_field:tableName+"."+field});
			return false;
		}
		
		public static function checkField(entity:String, field:String):Boolean {
			return database.checkFieldInternal(entity, field);
		}  
		
		//VAHI moved the recreation code into this own area
		// Note that in a distant future this all will go into the DAOs, but not today.
		private function IcheckAndRecreateTables(sqlConnection:SQLConnection):void {
			var columns:ArrayCollection;
			var primaryKey:Array;
			
			
			
			// filter table
			columns = new ArrayCollection([
				{name: "id", type: "INTEGER PRIMARY KEY AUTOINCREMENT"},
				{name: "name", type: "TEXT"},
				{name: "entity", type: "TEXT"},
				{name: "predefined", type: "BOOLEAN"},
				{name: "type", type: "INTEGER"}
			]);
			XcheckTableAndRecreate(sqlConnection, "filter", columns, null, "filter_criteria");
			
			// CustomTableWidthConfiguration table
			columns = new ArrayCollection([
				{name: "filter_id", type: "TEXT"},
				{name: "entity", type: "TEXT"},
				{name: "field_name", type: "TEXT"},
				{name: "width", type: "INTEGER"}
			]);
			XcheckTableAndRecreate(sqlConnection, "CustomTableWidthConfiguration", columns, ["filter_id","entity","field_name"]);
			
		}
		
		
		// Function that checks if the database tables are up to date.
		// If not, the adequate columns are added to the tables.		
		private function IupdateDatabase(sqlConnection:SQLConnection):void {
			var columns:ArrayCollection;
			var primaryKey:Array;
			
			//MZaadi Check if Netbreeze Tables are all ready exist
			XcheckNetbreezeUserTable(sqlConnection);
			XcheckNetbreezeAccountTable(sqlConnection);
			
			
			
			XcheckFieldFinderTable(sqlConnection);
			XcheckFinderMapTable(sqlConnection);
			
			XcheckRelatedButtonTable(sqlConnection);
			
			// new column in salestage
			XcheckColumn(sqlConnection, 'salesstage','sales_stage_order','int');
			
			
			
			// CH create new Table record type
			columns = new ArrayCollection([
				{name: "id", type: "INTEGER PRIMARY KEY AUTOINCREMENT"},
				{name: "name", type: "TEXT"},
				{name: "singularName", type:"TEXT"},
				{name: "pluralName", type:"TEXT"}
			]);
			XcheckTable(sqlConnection, 'record_type', columns);
			
			// add column display_name on transactions
			XcheckColumn(sqlConnection, 'transactions','display_name','TEXT');
			
			//XcheckColumn(sqlConnection, 'transactions', 'parent_display_name', 'TEXT');
			
			XcheckColumn(sqlConnection, 'transactions','sync_attachments','BOOLEAN');
			
			// new table process_opportunity
			columns = new ArrayCollection([{name: "process_id", type: "TEXT"}, 
				{name: "opportunity_type_id", type: "TEXT"}, 
				{name:"opportunity_type_name", type:"TEXT"}]);
			primaryKey = ["process_id", "opportunity_type_id"];
			XcheckTable(sqlConnection, "process_opportunity", columns, primaryKey);
			
			
			
			// CH check new columns in attachment 
			XcheckColumn(sqlConnection, 'attachment', 'AttachmentId', 'TEXT');
			
			// CH check filter_id column in transactions table
			XcheckColumn(sqlConnection, 'transactions','filter_id','TEXT');
			XcheckColumn(sqlConnection, 'transactions','parent_entity','TEXT');
			XcheckColumn(sqlConnection, 'transactions','column_order','TEXT');
			XcheckColumn(sqlConnection, 'transactions','order_type','TEXT');
			
			XcheckColumn(sqlConnection, 'activity', 'IsPrivateEvent', 'BOOLEAN', "0");
			XcheckColumn(sqlConnection, 'activity', 'GUID', 'TEXT');
			XcheckColumn(sqlConnection, 'activity', 'GDATA', 'TEXT');
			
			columns = new ArrayCollection([
				{name: "key", type: "TEXT"},
				{name: "value", type: "TEXT"}]);
			
			
			XcheckColumn(sqlConnection,"transactions","default_filter", "INTEGER");
			
			
			
			// filter_criteria table
			columns = new ArrayCollection([
				{name: "id", type: "INTEGER"},
				{name: "num", type: "INTEGER"},
				{name: "column_name", type: "TEXT"},
				{name: "operator", type: "TEXT"},
				{name: "param", type: "TEXT"},
				{name: "conjunction", type: "TEXT"}
			]);
			primaryKey = new Array(["id", "num"]);
			XcheckTable(sqlConnection, "filter_criteria", columns, primaryKey);
			
			// CH add one field in table filter_criteria
			XcheckColumn(sqlConnection, 'filter_criteria','conjunction','TEXT');
			
			
			XcheckColumn(sqlConnection, 'salesproc','default_stage','TEXT');
			XcheckColumn(sqlConnection, 'picklist','disabled','TEXT');
			XcheckColumn(sqlConnection, 'picklist','Order_','INTEGER');
			XcheckColumn(sqlConnection, 'picklist_service','Order3_','INTEGER');
			
			
			XcheckColumn(sqlConnection, 'custom_record_type','ModernIconName','TEXT');
			
			// Add column sync_ws20 in table transactions
			XcheckColumn(sqlConnection, 'transactions','sync_ws20','BOOLEAN');
			XcheckColumn(sqlConnection, 'transactions','sync_activities','BOOLEAN');
			XcheckColumn(sqlConnection, 'transactions','read_only','BOOLEAN');
			XcheckColumn(sqlConnection, 'transactions','rank','INTEGER');
			XcheckColumn(sqlConnection, 'transactions','hide_relation','BOOLEAN');
			XfixActivityIdNull(sqlConnection);
			
			fixAttachments(sqlConnection);
			
			XfixLastSync(sqlConnection);
			
			// CH add new Table to store conditions of the custom layout.
//			columns = new ArrayCollection([
//				{name : "entity", type : "TEXT"},
//				{name : "subtype", type : "INTEGER"},
//				{name : "num", type : "INTEGER"},
//				{name : "column_name", type : "TEXT"},
//				{name : "operator", type : "TEXT"},
//				{name : "params", type : "TEXT"}
//			]);
//			
//			primaryKey = new Array(["entity", "subtype", "num"]);
//			XcheckTable(sqlConnection, "custom_layout_condition", columns, primaryKey);
			
			XcheckColumn(sqlConnection, "contact", "picture", "BLOB");
			XcheckColumn(sqlConnection, "contact", "ms_change_key", "TEXT");
			XcheckColumn(sqlConnection, "contact", "ms_id", "TEXT");
			XcheckColumn(sqlConnection, "activity", "ms_change_key", "TEXT");
			XcheckColumn(sqlConnection, "activity", "ms_id", "TEXT");
			XcheckColumn(sqlConnection, "activity", "ms_local_change", "TEXT");
			XcheckColumn(sqlConnection, "activity", "CompletedDatetime", "TEXT");
			XcheckColumn(sqlConnection, "sod_modificationtracking", "processed", "BOOLEAN");
			XcheckColumn(sqlConnection, "service", "StatusModified", "BOOLEAN","0");
			XcheckColumn(sqlConnection, "salesstage", "probability", "Integer");
			XcheckColumn(sqlConnection, "salesstage", "sales_category_name", "TEXT");
			
			// CH 
			XchangedDateToDatabaseDateFormat(sqlConnection, "Activity", ["StartTime", "EndTime", "DueDate"]);
			
			XchangedDateToDatabaseDateFormat(sqlConnection, "Campaign", ["StartDate", "EndDate"]);
			
			// #311: hange request - Diversey sales - Prefernces
			XcheckColumn(sqlConnection, 'transactions','filter_disable','BOOLEAN', '0');
			XcheckColumn(sqlConnection, 'transactions','display','BOOLEAN');
			XcheckColumn(sqlConnection, 'transactions','read_only_disable','BOOLEAN', '0');
			XcheckColumn(sqlConnection, 'transactions','sync_activities_disable','BOOLEAN', '0');
			XcheckColumn(sqlConnection, 'transactions','sync_attachments_disable','BOOLEAN', '0');
			XcheckColumn(sqlConnection, 'transactions','entity_disable','BOOLEAN', '0');
			XcheckColumn(sqlConnection, 'transactions','sync_order','INTEGER');
			XcheckColumn(sqlConnection, 'transactions','advanced_filter','INTEGER');
			XcheckColumn(sqlConnection, 'transactions','authorize_deletion','BOOLEAN','0');
			XcheckColumn(sqlConnection, 'transactions','authorize_deletion_disable','BOOLEAN','0');
			
			//Bug fixing 469 CRO
			XcheckColumn(sqlConnection, 'filter_criteria','param_display','TEXT');
			
			
			//XcheckColumn(sqlConnection, 'custom_field','defaultValue','TEXT');
			//XcheckColumn(sqlConnection, 'custom_field','bindField','TEXT');
			//XcheckColumn(sqlConnection, 'custom_field','bindValue','TEXT');
			//XcheckColumn(sqlConnection, 'custom_field','parentPicklist','TEXT');
			
			// XcheckColumn(sqlConnection, 'custom_field_translator','bindValue','TEXT');
			
			XcheckColumn(sqlConnection, 'detail_layout','max_chars','TEXT');
			//CRO
			XcheckColumn(sqlConnection, 'service','GroupReport','BOOLEAN','0');
			
			XcheckColumn(sqlConnection, 'custom_layout','custom_layout_title','TEXT'); // Change Request #747
			XcheckColumn(sqlConnection, 'custom_layout','layout_depend_on','TEXT');
			XcheckColumn(sqlConnection, 'question','isHeader','TEXT', '0');
		}
		
		private function XchangedDateToDatabaseDateFormat(sqlConnection:SQLConnection, entity:String, columns:Array):void {
			if(columns && columns.length>0){
				_work("Checking date column in " + entity + "...", function(params:Object):void {
					var table:String = DAOUtils.getTable(params.entity);
					var key:String = table + "_migrated";
					var stmt:SQLStatement = new SQLStatement();
					if(preferencesDao.getIntValue(key)==0){
						stmt.sqlConnection = sqlConnection;
						stmt.text = "SELECT * FROM " + table;
						exec(stmt);
						begin();
						var changed:Boolean;
						for each(var object:Object in stmt.getResult().data){
							changed = false;
							for each(var column:String in params.columns){
								if(object[column]){
									var formatString:String = DateUtils.guessDateFormat(object[column]);
									if(formatString == "MM/DD/YYYY JJ:NN:SS"){
										formatString = DateUtils.DATABASE_DATETIME_FORMAT;
									}else if(formatString == "MM/DD/YYYY"){
										formatString = DateUtils.DATABASE_DATE_FORMAT;
									}else{
										continue;	
									}
									object[column] = DateUtils.format(DateUtils.guessAndParse(object[column]), formatString);
									changed = true;
								}
							}
							if (changed) {
								getDao(params.entity).update(object);
							}
						}
						preferencesDao.setValue(key, 1);
						commit();
					}
				}, {entity:entity, columns:columns});
			}
		}
		
		private function XcheckTablePrefs(sqlConnection:SQLConnection):void{
			_work("Migrating preferences to new table...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;
				stmt.text = "SELECT * FROM preferences";
				if (!SQLexecError(stmt)) {
					var preferences:Object = stmt.getResult().data[0];
					stmt.text = "DELETE FROM prefs";
					exec(stmt);
					for each(var f:Object in PREFERENCE_FIELDS){
						f.value = preferences[f.field];
						ZexecutePrefs(f, stmt);
					}
					stmt.text = "DROP TABLE preferences";
					exec(stmt);
				} else {
					for (var i:int=0; i<PREFERENCE_FIELDS.length; i++){
						var o:Object = PREFERENCE_FIELDS.getItemAt(i);
						if(preferencesDao.getValue(o.field,null)==null){							
							preferencesDao.setValue(o.field,o.value);
						}
					}
				}
			});
		}
		
		private function XchangePrefsKey(sqlConnection:SQLConnection, columns:ArrayCollection):void{
			_work("Change columns in prefs...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;
				begin();
				for each(var col:Object in columns) {
					stmt.text = "SELECT * FROM prefs WHERE key=:old_key";
					stmt.parameters[":old_key"] = col.old_key;
					exec(stmt);
					var result:SQLResult = stmt.getResult();
					if(result.data != null) {
						try {
							stmt.text = "UPDATE prefs SET key=:new_key, value=:new_value WHERE key=:old_key";
							stmt.parameters[":new_key"] = col.new_key;
							stmt.parameters[":new_value"] = col.new_value;
							exec(stmt);
						}catch(e:SQLError) {
							// ignore
						}
					}
				}
				commit();
			}, {columns:columns});
		}
		
		private function ZexecutePrefs(object:Object, stmt:SQLStatement):void{
			stmt.text = "SELECT value FROM prefs WHERE key = '" + object.field + "'";
			exec(stmt);
			var result:SQLResult = stmt.getResult();
			if(preferencesDao.getValue(object.field,null)==null){
				//				if(typeof object.value == 'boolean'){
				//					stmt.text = "INSERT INTO prefs (key, value) values('" + object.field + "', " + object.value + ")";
				//				}else{
				//					stmt.text = "INSERT INTO prefs (key, value) values('" + object.field + "', '" + object.value + "')";
				//				}
				//				exec(stmt);
				preferencesDao.setValue(object.field,object.value);
			}
		}
		
		private function XupdateBackgroundColor(sqlConnection:SQLConnection):void{
			_work("Setting Custom Layouts defaults...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;
				stmt.text = "UPDATE custom_layout SET background_color=:background_color WHERE background_color is null";
				stmt.parameters[":background_color"] = 0xEEEEEE;
				exec(stmt);
			});
		}
		
		
		
		// Check if a columns exists in a table.
		// If not, the column is added.
		private function XcheckColumn(sqlConnection:SQLConnection, table:String, column:String, type:String, newValue:String = null):void {
			_work("Checking column "+table+"."+column + "...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;
				stmt.text = "SELECT " + params.column + " FROM " + params.table + " LIMIT 0";
				try {
					exec(stmt);
				} catch (e:SQLError) {
					// column is missing
					stmt.text = "ALTER TABLE " + params.table + " ADD " + params.column + " " + params.type;
					exec(stmt);
					
					if (params.newValue != null) {
						stmt.text = "UPDATE " + params.table + " SET " + params.column + " = " + params.newValue;
						exec(stmt);
					}
				}
			}, {table:table, column:column, type:type, newValue:newValue});
		}
		
		
		private function XcheckTableAndRecreate(sqlConnection:SQLConnection, table:String, columns:ArrayCollection, keys:Array=null, dropChild:String=null):void {
			_work("Checking table "+table + "...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;
				var cols:String = '';
				for each (var column:Object in params.columns) {
					if (cols.length > 0) {
						cols += ', ';
					}
					cols += column.name;
				}
				stmt.text += 'SELECT ' + cols + ' FROM ' + params.table + ' LIMIT 0';
				try {
					exec(stmt);
				} catch (e:SQLError) {
					try {
						stmt.text = "DROP TABLE " + params.table;
						exec(stmt);
					} catch (e:SQLError) {
						// ignore
					}
					ZcreateTable(sqlConnection, params.table, params.columns, params.keys);
					if (params.dropChild!=null) {
						try {
							stmt.text = "DROP TABLE " + params.dropChild;
							exec(stmt);
						} catch (e:SQLError) {
							// ignore
						}
					}
				}
			}, {table:table, columns:columns, keys:keys, dropChild:dropChild});
		}
		
		
		private function XcheckTable(sqlConnection:SQLConnection, table:String, columns:ArrayCollection, keys:Array=null):void {
			_work("Checking table "+table + "...", function(params:Object):void {
				var stmt:SQLStatement = new SQLStatement();
				stmt.sqlConnection = sqlConnection;
				stmt.text = 'SELECT * FROM ' + params.table + ' LIMIT 0';
				try {
					exec(stmt);
				} catch (e:SQLError){
					ZcreateTable(sqlConnection, params.table, params.columns, params.keys);
				}
			}, {table:table, columns:columns, keys:keys});
		}
		
		private  function ZcreateTable(sqlConnection:SQLConnection, table:String, columns:ArrayCollection, keys:Array=null):void {
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = sqlConnection;
			var strSQL:String = 'CREATE TABLE ' + table + ' (';
			
			for(var i:int=0; i<columns.length; i++){
				var column:Object = columns[i];
				strSQL += column.name + ' ' + column.type;
				if(i<columns.length-1) strSQL += ', ';
			}
			if(keys!=null){
				if(keys.length>0) strSQL += ', PRIMARY KEY(';
				for(i=0; i<keys.length; i++){
					strSQL += keys[i];
					if(i<keys.length-1) strSQL += ', ';
				}
				if(keys.length>0) strSQL += ')';
			}
			strSQL += ')';
			stmt.text = strSQL;
			exec(stmt);
		}
		
		private function XcheckIndex(sqlConnection:SQLConnection, table:String, columns:ArrayCollection):void{
			for each (var name:String in columns) {
				var idx:String = table + '_' + name.toLowerCase().replace(", ", "") + '_idx';
				_work("Please wait, checking index "+idx+ "...", 
					function(params:Object):void {
						var stmt:SQLStatement = new SQLStatement();
						stmt.sqlConnection = sqlConnection;
						stmt.text = 'CREATE INDEX ' + params.idx + ' ON ' + params.table + '(' + params.name + ')';
						trace(stmt.text);
						try {
							exec(stmt);
						} catch (e:SQLError){
							// do nothing
						}
					}, {idx:idx, table:table, name:name});
			}
		}
		
		private function YcheckLayout(entity:String, subtype:int = 0):void {
			if(!_layoutDao.existLayout(entity,subtype)){
				//_layoutDao.deleteLayout(entity, subtype);
				var defaultFields:Array = FieldUtils.getDefaultFields(entity);
				if(entity == "BusinessPlan"){
					trace(entity);
				}
				
				for (var i:int = 0; i < defaultFields.length; i++) {
					if (defaultFields[i].subtype == null || defaultFields[i].subtype == subtype) {
						var layout:Object = new Object();
						layout.entity = entity;
						layout.subtype = defaultFields[i].subtype ? defaultFields[i].subtype : 0;	
						layout.col = defaultFields[i].col;
						layout.row = defaultFields[i].row;
						layout.column_name = defaultFields[i].column_name;
						layout.custom = defaultFields[i].custom;
						_layoutDao.insert(layout);
					}
				}
			}			
		}
		
		
		
		private function YcheckCustomLayout(entity:String, icon:String, layoutName:String, layoutNamePlural:String, subtype:int = 0, conditions:Array = null):void{
			
			if(conditions){
				var num:int = 1;
				if(_customLayoutConditionDAO.list(entity, String(subtype)).length != conditions.length){
					_customLayoutConditionDAO.deleted(entity, String(subtype));
				}
				
				for each(var condition:Object in conditions){
					var existingCondition:Object = _customLayoutConditionDAO.find(entity, String(subtype), String(num));
					if(existingCondition != null){
						if(existingCondition.column_name != condition.column_name || 
							existingCondition.operator != condition.operator ||
							existingCondition.params != condition.params){
							_customLayoutConditionDAO.deleteCurrently(entity, String(subtype), String(num));
							existingCondition = null;
						}
					}
					if (existingCondition == null) {
						condition.entity = entity
						condition.subtype = subtype;
						condition.num = num;
						_customLayoutConditionDAO.insert(condition);
					}
					num ++;
				}
			}
			
			var existingLayout:Object = _customLayoutDao.readSubtype(entity, subtype);
			if (existingLayout == null) {
				var customLayout:Object = new Object();
				customLayout.entity = entity;
				customLayout.subtype = subtype;
				customLayout.layout_name = layoutName == null ? entity : layoutName;
				customLayout.custom_layout_icon = icon;
				customLayout.deletable = false;
				//customLayout.display_name = layoutName;
				//customLayout.display_name_plural = layoutNamePlural;
				_customLayoutDao.insert(customLayout);
			}else if( existingLayout.custom_layout_icon == null || existingLayout.custom_layout_icon == '') {
				existingLayout.custom_layout_icon = icon;
				_customLayoutDao.update(existingLayout);
			}//CRO bug fixing 371 11.01.2011
				/*else if(existingLayout.display_name==null || existingLayout.display_name == ""){
				existingLayout.display_name = entity;
				_customLayoutDao.update(existingLayout);
				}else if(existingLayout.display_name_plural == null || existingLayout.display_name_plural == ""){
				existingLayout.display_name_plural = layoutNamePlural;
				_customLayoutDao.update(existingLayout);
			}*/else if( (existingLayout.custom_layout_icon != null || existingLayout.custom_layout_icon != '') && (existingLayout.display_name == 'Call' && existingLayout.custom_layout_icon == "activity") ){
				existingLayout.custom_layout_icon = "activityCallDefault" ;
				_customLayoutDao.update(existingLayout);	
			}
		}
		
		
		private function YcheckListLayout(entity:String):void{
			if (_columnsLayoutDao.fetchColumnLayouts(entity).length == 0) {
				var fields:ArrayCollection = FieldUtils.getDefaultFieldsObject(entity);
				for (var i:int = 0; i < fields.length; i++) {
					var layoutElt:Object = new Object();
					layoutElt.entity = entity;
					layoutElt.element_name = fields[i];
					layoutElt.num = i+1;
					layoutElt.filter_type = "Default";
					_columnsLayoutDao.insert(layoutElt);
				}
			}
		}
		
		// CH
		private function YcheckViewLayout(entity:String):void{
			if (_viewLayoutDAO.selectAll(entity).length == 0) {
				var fields:ArrayCollection = FieldUtils.getDefaultFieldsObject(entity);
				for (var i:int = 0; i < fields.length; i++) {
					var layoutElt:Object = new Object();
					layoutElt.entity = entity;
					layoutElt.element_name = fields[i];
					layoutElt.num = i+1;
					_viewLayoutDAO.insertViewLayout(layoutElt);
				}
			}
		}
		
		public static function getDao(entity:String,throwError:Boolean=true):BaseDAO {
			entity = DAOUtils.getEntityByRecordType(entity);//ensure entity, because entity can be record type
			if(StringUtils.isEmpty(entity)){
				if(!throwError){
					return null;
				}
				
			}
			var d2:BaseDAO = null;
			if (entity.indexOf(".")>0) {
				d2 = SupportRegistry.getDao(entity);
			} else {
				try {
					// This can fail on the transactionProperty().dao or on database[]
					trace("entity : " + entity);
					trace("SodUtils.transactionProperty(entity) : " + SodUtils.transactionProperty(entity).dao);
					d2 = database["_" + SodUtils.transactionProperty(entity).dao];
				} catch (e:Error) { }
			}
			if (d2 == null && throwError)
				throw(Error("DAO "+entity+" could not be found!"));
			return d2;
		}
		
		
		//VAHI Prepared for ViewMode (WS2.0 Queries)
		// This is a combined registry for
		// Transactions
		// Their default settings and
		// special filters (All, My, Recent are added automatically)
		//
		// AM Please use standard naming conventions !
		// constants = UPPERCASE
		// classes = CamelCase
		// variables = camelCase
		private static const TRANSACTIONS:Array = [
			
			{entity:"Account",sync_order:1, rank:1, enabled:true, filter:[
				{type:-3, name: 'GLOBAL_CUSTOMERS'},
				{type:-4, name: 'GLOBAL_COMPETITORS'}
			]},
			{entity:"Activity",sync_order:22, rank:2, enabled:true, filter:[
				{type:-3, name: 'GLOBAL_TASK_NOT_DONE'},
				{type:-4, name: 'GLOBAL_TASK_DONE'},
				{type:-5, name: 'GLOBAL_APPOINTMENTS'},
				{type:-6, name: 'GLOBAL_TASKS'},
				{type:-7, name: 'GLOBAL_CALLS'}
			]},
			{entity:"Campaign",sync_order:6, rank:3},
			{entity:"Contact",sync_order:2, rank:4, enabled:true},
			{entity:"Custom Object 1",sync_order:9, rank:5},
			{entity:"Lead",sync_order:3, rank:6},
			{entity:"Opportunity",sync_order:5, rank:7, enabled:true, filter:[
				{type:-3, name: 'GLOBAL_LOST_OPPORTUNITIES'},
				{type:-4, name: 'GLOBAL_OPEN_OPPORTUNITIES'},
				{type:-5, name: 'GLOBAL_PROBABILITY_HIGH'},
				{type:-6, name: 'GLOBAL_PROBABILITY_LOW'},
			]},
			{entity:"Product",sync_order:4, rank:8},
			{entity:"Service Request",sync_order:8, rank:9,enabled:false,filter:[
				{type:-3, name: 'GLOBAL_NEW_SERVICE_REQUEST'},
				{type:MISSING_PDF, name: 'GLOBAL_MISSING_PDF'}]},
			
			{entity:"Custom Object 2",sync_order:10, rank:10},
			{entity:"Custom Object 3",sync_order:11, rank:11},						
			{entity:"CustomObject14",sync_order:12, rank:12},
			{entity:"CustomObject7",sync_order:13, rank:13},
			{entity:"CustomObject4",sync_order:14, rank:14},
			{entity:"CustomObject5",sync_order:15, rank:15},
			{entity:"CustomObject6",sync_order:16, rank:16},
			{entity:"CustomObject8",sync_order:17, rank:17},
			{entity:"CustomObject9",sync_order:18, rank:18},
			{entity:"CustomObject10",sync_order:19, rank:19},
			{entity:"CustomObject11",sync_order:20, rank:20},
			{entity:"CustomObject12",sync_order:21, rank:21},
			{entity:"CustomObject13",sync_order:22, rank:22},
			{entity:"CustomObject15",sync_order:23, rank:23},
			{entity:"Asset",sync_order:7, rank:24},
			{entity:"Territory",sync_order:25, rank:25},
			{entity:"Note",sync_order:26, rank:26},
			{entity:"MedEdEvent",sync_order:27, rank:27},
			{entity:"BusinessPlan",sync_order:28, rank:28},
			{entity:"Objectives",sync_order:29, rank:29}
		];
		
		//Account.Account,Account.Objective,Account.ServiceRequest,Account.Opportunity,Account.CustomObject2,
		//Account.CustomObject3,Account.CustomObject4,Account.CustomObject10,Account.Address,
		
		public static function getSubSyncable(parentEntity:String,childEntity:String):Boolean{
			for each(var obj:Object in SUB_TRANSACTIONS){
				if(obj.entity==parentEntity){
					for each(var sub:Object in obj.sub){
						if(sub.entity_name==childEntity){
							return sub.syncable;
						}
					}
					break;
				}
			}
			return false;
		}
		
		public static function getSubEntityName(parentEntity:String,name:String,sodName:String):String{
			for each(var obj:Object in SUB_TRANSACTIONS){
				if(obj.entity==parentEntity){
					for each(var sub:Object in obj.sub){
						if(sub.name==name && sub.sodname==sodName){
							return sub.entity_name;
						}
					}
					
				}
			}
			//default entity name is sodName
			return sodName;
		}
		
		private static const SUB_TRANSACTIONS:Array = [
			{entity:"Account",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true},
				{name:"Attachment",sodname:"Attachment",enabled:0,entity_name:"Attachment",syncable:true},
				{name:"AccountTeam",sodname:"Team",enabled:0,entity_name:"Account.Team",syncable:true},
				{name:"Partner",sodname:"Partner",enabled:0,entity_name:"Account.Partner",syncable:true},
				{name:"Competitor",sodname:"Competitor",enabled:0,entity_name:"Account.Competitor",syncable:true},
				{name:"Contact",sodname:"Contact",enabled:0,entity_name:"Contact",syncable:false},
				{name:"Account",sodname:"Account",enabled:0,entity_name:"Account",syncable:false},
				{name:"Account Relationships",sodname:"Related",enabled:0,entity_name:"Account.Related",syncable:true},
				{name:"Opportunity",sodname:"Opportunity",enabled:0,entity_name:"Opportunity",syncable:true},
				{name:"Custom Object 2",sodname:"Custom Object 2",enabled:0,entity_name:"Custom Object 2",syncable:false},
				{name:"Custom Object 3",sodname:"Custom Object 3",enabled:0,entity_name:"Custom Object 3",syncable:false},
				{name:"CustomObject4",sodname:"CustomObject4",enabled:0,entity_name:"CustomObject4",syncable:true},
				{name:"CustomObject10",sodname:"CustomObject10",enabled:0,entity_name:"CustomObject10",syncable:true},
				{name:"Address",sodname:"Address",enabled:0,entity_name:"Account.Address",syncable:false},
				{name:"Service Request",sodname:"Service Request",enabled:0,entity_name:"Service Request",syncable:true},
				{name:"Objectives",sodname:"Objectives",enabled:0,entity_name:"Objectives",syncable:true},				
				{name:"Note",sodname:"Note",enabled:0,entity_name:"Account.Note",syncable:true}]},
			{entity:"Activity",sub:[{name:"Attachment",sodname:"Attachment",enabled:0,entity_name:"Attachment",syncable:true},
				{name:"Sample Dropped",sodname:"SampleDropped",enabled:0,entity_name:"Activity.SampleDropped",syncable:true},
				{name:"Contact",sodname:"Contact",enabled:0,entity_name:"Activity.Contact",syncable:false},
				{name:"Products Detailed",sodname:"ProductsDetailed",enabled:0,entity_name:"Activity.Product",syncable:true},
			]},			
			{entity:"Campaign",sub:[{name:"Activity",sodname:"Activity",enabled:0,enabled:0,entity_name:"Activity",syncable:true},
				{name:"Attachment",sodname:"Attachment",enabled:0,entity_name:"Attachment",syncable:true},
				{name:"Note",sodname:"Note",enabled:0,entity_name:"Campaign.Note",syncable:true}]},
			{entity:"Contact",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true},
				{name:"Attachment",sodname:"Attachment",enabled:0,entity_name:"Attachment",syncable:true},
				{name:"ContactTeam",sodname:"Team",enabled:0,entity_name:"Contact.Team",syncable:true},
				{name:"Account",sodname:"Account",enabled:0,entity_name:"Account",syncable:false},
				{name:"Opportunity",sodname:"Opportunity",enabled:0,entity_name:"Opportunity",syncable:false},
				{name:"Lead",sodname:"Lead",enabled:0,entity_name:"Lead",syncable:false},
				{name:"Service Request",sodname:"Service Request",enabled:0,entity_name:"Service Request",syncable:false},
				{name:"Note",sodname:"Note",enabled:0,entity_name:"Contact.Note",syncable:true},
				{name:"Contact Relationships",sodname:"Related",enabled:0,entity_name:"Contact.Related",syncable:true},
				{name:"Custom Object 2",sodname:"CustomObject2",enabled:0,entity_name:"Custom Object 2",syncable:false}
			]},
			{entity:"Custom Object 1",sub:[{name:"Attachment",sodname:"Attachment",enabled:0,entity_name:"Attachment",syncable:true}]
			},
			{entity:"Lead",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true},
				{name:"Attachment",sodname:"Attachment",enabled:0,entity_name:"Attachment",syncable:true}]
			},
			{entity:"Opportunity",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true},
				{name:"Attachment",sodname:"Attachment",enabled:0,entity_name:"Attachment",syncable:true},
				{name:"Opportunity Team",sodname:"Team",enabled:0,entity_name:"Opportunity.Team",syncable:true},
				{name:"Opportunity Partner",sodname:"Partner",enabled:0,entity_name:"Opportunity.Partner",syncable:true},
				{name:"Contact",sodname:"ContactRole",enabled:0,entity_name:"Opportunity.ContactRole",syncable:true},
				{name:"Competitor",sodname:"Competitor",enabled:0,entity_name:"Opportunity.Competitor",syncable:true},
				{name:"Opportunity Product Revenue",sodname:"Product",enabled:0,entity_name:"Opportunity.Product",syncable:true},				
				{name:"Note",sodname:"Note",enabled:0,entity_name:"Opportunity.Note",syncable:true}]
			},
			//{entity:"Product",sub:[{name:"Activity",enabled:0},{name:"Attachment",enabled:0}]},
			{entity:"Service Request",sub:[{name:"Attachment",sodname:"Attachment",enabled:0,entity_name:"Attachment",syncable:true},
				{name:"Note",sodname:"Note",enabled:0,entity_name:"Service Request.Note",syncable:true}]},
			{entity:"Custom Object 2",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true},
				{name:"Contact",sodname:"Contact",enabled:0,entity_name:"Contact",syncable:false},
				{name:"Attachment",sodname:"Attachment",enabled:0,entity_name:"Attachment",syncable:true}]
			},
			{entity:"Custom Object 3",sub:[{name:"Attachment",sodname:"Attachment",enabled:0,entity_name:"Attachment",syncable:true}]
			},
			{entity:"CustomObject14",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]
			},
			{entity:"CustomObject7",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]},
			{entity:"CustomObject4",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]},
			{entity:"CustomObject5",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]},
			{entity:"CustomObject6",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]},
			{entity:"CustomObject8",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]},
			{entity:"CustomObject9",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]},
			{entity:"CustomObject11",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true},
				{name:"CustomObject12",sodname:"CustomObject12",enabled:0,entity_name:"CustomObject12",syncable:false}]},
			{entity:"CustomObject12",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]},
			{entity:"CustomObject13",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]},
			{entity:"CustomObject15",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]},
			{entity:"CustomObject10",sub:[{name:"Activity",sodname:"Activity",enabled:0,entity_name:"Activity",syncable:true}]}
			//{entity:"Asset",sub:[{name:"Activity",enabled:0}]},
			//{entity:"Territory",sub:[{name:"Activity",enabled:0}]},
		];
		
		public static function getSyn_order(entity:String):String{
			for each (var obj:Object in TRANSACTIONS){
				if(obj.entity==entity){
					return String(obj.sync_order);
				}
			}
			return "0";
		}
		
		public static function getDefatultRank(entity:String):String{
			for each (var obj:Object in TRANSACTIONS){
				if(obj.entity==entity){
					return String(obj.rank);
				}
			}
			return "0";
		}
		
		
		private function YcheckTransaction():void {
			//VAHI check the objects individually
			for each (var transaction:Object in TRANSACTIONS) {
				var transExist:Object=_transactionDao.find(transaction.entity);
				if (transExist!=null){
					if(transExist.sync_order==null ||transExist.sync_order==''||transExist.sync_order==0){
						transExist.sync_order=transaction.sync_order;
						_transactionDao.updateSyncOrder(transExist);
					}
					if(transExist.display==null){
						transExist.display = transExist.enabled;
						_transactionDao.updateSyncOrder(transExist);
					}
					
					continue;	//VAHI or: delete for recreate?
				}
				
				//var objFilter:Object = _filterDao.getObjectFilter(transaction.entity, -1);
				_transactionDao.insert({
					entity:			transaction.entity,
					display_name:	("display_name" in transaction) ? transaction.display_name : transaction.entity,
					enabled:		("enabled" in transaction) ? transaction.enabled : false,
					filter_id:		-1,	// My
					parent_entity: null,
					default_filter:	-1,
					sync_order:transaction.sync_order,
					rank:			transaction.rank,
					filter_disable : false, // #311: hange request - Diversey sales - Prefernces
					read_only_disable: false,
					authorize_deletion_disable: false,
					sync_activities_disable: false,
					sync_attachments_disable: false,
					entity_disable: false,
					advanced_filter: 0,
					hide_relation: false,
					display: ("enabled" in transaction) ? transaction.enabled : false,
					column_order: null,
					order_type:null
					
				});
			}
		}
		
		private function YcheckFeeds():void {
			for each (var transaction:Object in TRANSACTIONS) {
				var transExist:Object = _feedDAO.find(transaction.entity);
				if (transExist != null){
					continue;
				}
				_feedDAO.insertFeed({
					entity:			transaction.entity,
					display_name:	("display_name" in transaction) ? transaction.display_name : transaction.entity,
					enabled:		("enabled" in transaction) ? transaction.enabled : false
				});
			}
		}
		
		
		//		private function YCheckAssessmentMappingTableColumns():void{
		//			var DEFAULT_COLUMNS:Array = [
		//				{"ColProperty":'Question',"Title":'Question',"OrderNum":1,'IsCheckbox':false,'IsDefault':true,'Visible':true},
		//				{"ColProperty":'AnswerMapToField',"Title":'Answer Map To Field',"OrderNum":2,'IsCheckbox':false,'IsDefault':true,'Visible':true},
		//				{"ColProperty":'QuestionMapToField',"Title":'Question Map To Field',"OrderNum":3,'IsCheckbox':false,'IsDefault':true,'Visible':false},
		//				{"ColProperty":'CommentMapToField',"Title":'Comment Map To Field',"OrderNum":4,'IsCheckbox':false,'IsDefault':true,'Visible':true},					
		//			
		//			];
		//			
		//			for each(var col:Object in DEFAULT_COLUMNS){
		//				var existCol:Object = Database.mappingTableSettingDao.selectByColProperty(col.ColProperty);
		//				if(existCol==null){
		//					Database.mappingTableSettingDao.insert(col);
		//				}
		//				
		//			}
		//			
		//			
		//			
		//		}
		
		
		private function YcheckSubTransaction():void{
			for each (var subTransaction:Object in SUB_TRANSACTIONS) {
				for each(var sub:Object in (subTransaction.sub as Array)){
					var subTransExist:Object=_subSyncDao.find(subTransaction.entity,sub.name);					
					if (subTransExist==null){ 
						var obj:Object = new Object();					
						obj["sub"] = sub.name;
						obj["enabled"] = sub.enabled;
						obj["entity"] = subTransaction.entity;
						obj["sodname"]= sub.sodname;
						obj["entity_name"]= sub.entity_name;
						obj["syncable"]=sub.syncable;
						_subSyncDao.insert(obj);
					}else{					
//						if(StringUtils.isEmpty(subTransExist["entity_name"])){
							var cri:Object = new Object();
							cri["entity"] = subTransaction.entity;
							cri["sub"]= sub.name;
							subTransExist["sodname"]= sub.sodname;
							subTransExist["entity_name"]= sub.entity_name;
							subTransExist["syncable"]=sub.syncable;
							_subSyncDao.update(subTransExist,cri);
							
//						}
					}
				}				
			}
			//delete sub objects which is not entity name
			_subSyncDao.clean();
		}
		
		private function YcheckDefaultFilter():void {
			var stdFilters:Array = [
				//CRO 17.01.2011 Bug #69
				{type:0, name:'GLOBAL_ALL'},
				{type:-1, name:'GLOBAL_MY'},
				{type:-2, name:'GLOBAL_RECENT'},
				{type:Database.FAVORITE, name:'GLOBAL_FAVORITE'},
				{type:Database.IMPORTANT, name:'GLOBAL_IMPORTANT'}
			];
			
			for each (var filt:Object in _transactionDao.getStdTransactions()) {
				if (WSProps.isWS20filter(filt.nr)) {
					stdFilters.push({type:filt.nr,name:filt.name});
				}
			}
			
			//VAHI check the objects individually and add missing default filters
			for each (var transaction:Object in TRANSACTIONS) {
				
				var filters:Array = [];
				
				// Add standard filters
				for each (filt in stdFilters) {
					filters.push({type:filt.type, name:filt.name});
				}
				
				for each (filt in ("filter" in transaction) ? filters.concat(transaction.filter) : filters) {
					// Test for filter and add it if missing
					var filterObj:Object = _filterDao.getObjectFilter(transaction.entity,filt.type);
					if (filterObj!=null && filterObj.name == filt.name)
						continue;	//VAHI or delete for recreate?
					
					if (filterObj!=null) {
						_filterDao.delete_(filterObj);
					}
					
					_filterDao.insert({
						name:	filt.name,
						entity:	transaction.entity,
						predefined: 1,
						type:	filt.type
					});
				}
			}
		}
	}
}
