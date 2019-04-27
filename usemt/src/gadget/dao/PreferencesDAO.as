package gadget.dao
{
	import com.adobe.utils.StringUtil;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.service.UserService;
	import gadget.util.CacheUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	public class PreferencesDAO extends BaseSQL {
		
		private var stmtRead:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtGetAll:SQLStatement;
		public static const ENABLE_DOUBLE_CLICK_NEW_CALL:String = "enable_double_click_new_call";
		public static const ENABLE_AUTO_SYNC:String = "enable_auto_sync";
		public static const DAILY_AGENDA_NAME:String = "daily_agenda_name";
		public static const ENABLE_CALL_COPY_SUBJECT:String = "enable_call_copy_subject";
		public static const BACK_GROUND_COLOR_PDF:String = "back_ground_color_pdf";
		public static const HEADER_COLOR_PDF:String = "header_color_pdf";
		public static const MODERN_ICON:String = "modern_icon";
		public static const HIDE_ACTIVITY_TYPE:String = "hide_activity_type";
		public static const BEGIN_OF_WEEK:String = "begin_of_week";
		public static const TIME_FORMAT:String = "time_format";
		public static const ERROR_EMAIL:String = "error_email";
		public static const ENABLE_ASSESSMENT_SCRIPT:String = "enable_assessment_script";
		public static const ENABLE_APPLICATION_UPDATE:String = "enable_application_update";
		public static const ENABLE_DASHBOARD:String = "enable_dashboard";
		public static const ENABLE_REVENUE_REPORT:String = "enable_revenue_report";
		public static const EXPORT_CUSTOM_LAYOUT:String = "export_custom_layout";
		public static const EXPORT_LIST_LAYOUT:String = "export_list_layout";
		public static const EXPORT_VIEW_LAYOUT:String = "export_view_layout";
		public static const ENABLE_CUSTOM_LAYOUT:String = "enable_custom_layout";
		public static const ENABLE_LIST_LAYOUT:String = "enable_list_layout";
		public static const ENABLE_VIEW_LAYOUT:String = "enable_view_layout";
		public static const ENABLE_FILTER:String = "enable_filter";
		public static const ENABLE_CONNECTION_INFORMATION:String = "enable_connection_information";
		public static const ENABLE_TRANSACTION:String = "enable_transaction";
		public static const ENABLE_USER_INTERFACE:String = "enable_user_interface";
		public static const ENABLE_OPTION:String = "enable_option";
		public static const ENABLE_AUTO_CONFIGURATION:String = "enable_auto_configuration";
		public static const ENABLE_HOME_TASK:String = "enable_home_task";
		public static const ENABLE_MISSING_PDF:String = "enable_missing_pdf";
		public static const DISABLE_EXPORT_PDF_BUTTON:String = "disable_export_pdf_button";
		public static const PDF_LOGO:String = "pdf_logo";
		public static const PDF_HEADER:String = "pdf_header";
		public static const WINDOW_LOGO:String = "window_logo";
		public static const BACKGROUND_COLOR:String = "background_color";
		//		public static const DISABLE_CUSTOM_LAYOUT:String = "disable_custom_layout";
		public static const HIDE_USER_INTERFACE:String = "hide_user_interface";
		public static const DISABLE_SYNCHRONIZATION_INTERVAL:String = "disable_synchronization_interval";
		public static const DISABLE_CRM_ONDEMAND_URL:String = "disable_crm_ondemand_url";
		public static const USER_SIGNATURE:String = "user_signature";
		public static const HIDE_USER_SIGNATURE:String = "hide_user_signature";
		public static const HIDE_TASK_LIST:String = "hide_task_list";
		public static const ENABLE_SR_SYNC_ORDER_STATUS:String = "enable_sr_sync_order_status";
		//public static const DISABLE_PDF_CVS_EXPORT:String = "disable_pdf_cvs_export";
		public static const FRAME_RATE:String="frame_rate";
		public static const ENABLE_CHECK_CONFLICTS:String="enable_check_conflict";
		//public static const ACCOUNT_DELETE:String = "account_delete";
		//public static const CONTACT_DELETE:String = "contact_delete";
		//public static const LEAD_DELETE:String = "lead_delete";
		//public static const OPPORTUNITY_DELETE:String = "opportunity_delete";
		//public static const DISABLE_AUTORIZE_DELETION:String = "disable_authorize_deletion";
	
		public static const ENABLE_COMPETITORS:String = "enable_competitors";
		public static const ENABLE_CUSTOMERS:String="enable_customers";
		public static const COMPANY_NAME:String = "company_name";
		public static const PDF_SIZE:String ="pdf_size";
		public static const ENABLE_BUTTON_ACTIVITY_CREATE_CALL:String = "enable_button_activity_create_call";
		public static const UPDATE_URL:String = "update_url";
		public static const START_AT_LOGIN:String = "start_at_login";	
		public static const ENABLE_FAVORITE:String = "enable_favorite";
		public static const ENABLE_IMPORTANT:String = "enable_important";
		public static const ENABLE_FUZZY:String = "enable_fuzzy";
		public static const ENABLE_CONVERT_LAED:String = "enable_convert_lead";
		public static const HIDE_TECH_USER:String = "hide_sso_tech_user";
		public static const ENABLE_FACEBOOK:String = "enable_facebook";
		public static const ENABLE_LINKEDIN:String = "enable_linkedin";
		public static const ENABLE_VISITIT_CUSTOMER:String = "enable_visit_customer";
		public static const ENABLE_FEED:String = "enable_feed";
		public static const ENABLE_DAILY_AGENDA:String = "enable_daily_agenda";
		
		public static const FEED_URL:String = "feed_url";
		public static const FEED_PORT:String = "feed_port";
		public static const AUTHOR:String = "";
		
		public static const DISABLE_PDF_EXPORT:String = "disable_pdf_export";
		public static const DISABLE_CVS_EXPORT:String = "disable_cvs_export";
		public static const DISABLE_LAYOUT_MANAGER:String = "disable_layout_manager";
		public static const DISABLE_LIST_LAYOUT:String = "disable_list_layout";
		public static const ENABLE_PDF_SIGNATURE:String = "enable_pdf_signature";
		
		public static const ADMIN_PASSWORD:String = "admin_password";
		
		public static const DATABASE_PASSWORD:String = "database_password";
		
		public static const DISABLE_CUSTOM_LAYOUT:String = "disable_custom_layout";
		
		
		public static const CACHE_PREFERENCE_OBJ_KEY:String = "prefsobjectCache";
		
		
		public static const ENABLE_GOOGLE_CALENDAR:String = "enable_google_calendar";
		
		public static const PREDEFINED_FILTERS:String = "predefined_filters";
		
		public static const ENABLE_NETBREEZE:String = "netbreeze_tab";

		public static const VISIT_CUSTOMER_GREATER_DAYS:String = "visit_customer_greater_days";
		
		public static const VISIT_CUSTOMER_LOWER_DAYS:String 	= "visit_customer_lower_days";
		
		public static const SYNC_FIELD_MANAGMENT:String = "sync_field_managment";
		public static const SYNC_ASSESSMENTSCRIPT:String = "sync_assessmentscript";
		public static const SYNC_ACCESSPROFILE:String ="sync_accessprofile";
		public static const SYNC_ROLE:String = "sync_role";
		public static const SYNC_CASCADINGPICKLIST:String = "sync_cascadingpicklist";
		public static const SYNC_PICKLISTSERVICE:String = "sync_picklistservice";
		
		public static const GOOGLE_MAP_DISTANCE:String = "google_map_distance";
		public static const ENABLE_AUTO_SET_PRIMARY_CONTACT:String = "enable_set_primary_contact";
		
		public static const ENABLE_SAMPLE_ORDER:String = 'enable_sample_order';
		public static const ENABLE_CHECKBOX_INLIST:String ='enable_checkbox_inlist';
		public static const CHECKBOX_READONLY_WHEN_TRUE:String = 'checkbox_readonly_when_true';
		
		public static const LOG_FILES:String = "log_files";
		import gadget.util.TableFactory;
		
		
		// CH 24-July-2013
		public static const ENABLE_DASHBOARD_REPORT:String = "enable_dashboard_report";
		
		public function PreferencesDAO(sqlConnection:SQLConnection) {
			
			// perhaps get this rid in favor of GadgetDAO?
			
			// NO, THIS IS NOT YET THE RIGHT THING
			// But this hack is needed to get the app started
			TableFactory.create(function (text:String, fn:Function, args:Object=null):void { fn(args); },
				sqlConnection, {
					table: "prefs",
					unique: [ 'key' ],
					columns: {
						key:"TEXT",
						value:"TEXT"
					}
				});
			
			stmtRead = new SQLStatement();
			stmtRead.sqlConnection = sqlConnection;
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			
			stmtGetAll = new SQLStatement();
			stmtGetAll.sqlConnection = sqlConnection;
			stmtGetAll.text = "SELECT * FROM prefs";
		}
		
		public var fieldsCrypt:Object = {
			"ms_password":"ms_password",
			"im_password":"im_password",
			"gmail_password":"gmail_password",
			"tech_password":"tech_password",
			"sodpass":"sodpass",
			"admin_password":"admin_password",
			"database_password":"database_password"
			
		}
		
		// CH 09.05.2011
		private var fields:Array = [
			"ms_exchange_enable",
			"ms_url", 
			"ms_user", 
			"ms_password", 
			"sodhost", 
			"sodlogin",
			"sodpass",
			"last_sync",
			"config_url",
			"interface_style",
			"sync_startup",
			"disable_gzip",
			"verbose", 
			"syn_interval",
			"im_room_url",
			"im_protocol",
			"im_user",
			"im_password",
			"im_auto_sing_in",
			"editableList",
			"showDebug",
			"netbreeze_tab",
			"log_files",
			"log_fileName",
			"use_sso", 
			"usegzip",
			"company_sso_id", 
			"pdf_Page_Size",
			"window_resize",
			"gmail_username",
			"gmail_password",
			"tech_username",
			"tech_password",
			"cvs_separator", 
			"google_map_address", 
			"tcs_closing_enable",
			"important_length",
			"recent_filter",
			ENABLE_FAVORITE,
			ENABLE_IMPORTANT,
			ENABLE_FUZZY,
			HIDE_TECH_USER,
			ENABLE_CONVERT_LAED,
			ENABLE_HOME_TASK,
			EXPORT_CUSTOM_LAYOUT,
			EXPORT_LIST_LAYOUT,
			EXPORT_VIEW_LAYOUT,
			ENABLE_CUSTOM_LAYOUT,
			ENABLE_LIST_LAYOUT,
			ENABLE_VIEW_LAYOUT,
			ENABLE_FILTER,
			ENABLE_CONNECTION_INFORMATION,
			ENABLE_TRANSACTION,
			ENABLE_USER_INTERFACE,
			ENABLE_OPTION,
			ENABLE_AUTO_CONFIGURATION,
			ENABLE_FACEBOOK,
			ENABLE_LINKEDIN,
			ENABLE_FEED,
			ENABLE_DASHBOARD,
			ENABLE_REVENUE_REPORT,
			ENABLE_DAILY_AGENDA,
			FEED_URL,
			FEED_PORT,
			ENABLE_APPLICATION_UPDATE,
			
			DISABLE_PDF_EXPORT,
			DISABLE_CVS_EXPORT,
			DISABLE_LAYOUT_MANAGER,
			DISABLE_LIST_LAYOUT,
			ADMIN_PASSWORD,
			DATABASE_PASSWORD,
			ENABLE_ASSESSMENT_SCRIPT,
			ENABLE_PDF_SIGNATURE,
			ERROR_EMAIL,
			HEADER_COLOR_PDF,
			BACK_GROUND_COLOR_PDF,
			HIDE_ACTIVITY_TYPE,
			TIME_FORMAT,
			BEGIN_OF_WEEK,
			ENABLE_BUTTON_ACTIVITY_CREATE_CALL,
			ENABLE_DASHBOARD_REPORT,
			ENABLE_VISITIT_CUSTOMER,
			VISIT_CUSTOMER_GREATER_DAYS,
			VISIT_CUSTOMER_LOWER_DAYS,
			SYNC_FIELD_MANAGMENT,
			SYNC_ASSESSMENTSCRIPT,
			SYNC_ACCESSPROFILE,
			SYNC_ROLE,
			SYNC_CASCADINGPICKLIST,
			SYNC_PICKLISTSERVICE,
			COMPANY_NAME,
			ENABLE_COMPETITORS,
			ENABLE_CUSTOMERS,
			ENABLE_CALL_COPY_SUBJECT,
			DAILY_AGENDA_NAME,
			ENABLE_AUTO_SYNC,
			ENABLE_DOUBLE_CLICK_NEW_CALL,
			GOOGLE_MAP_DISTANCE,
			ENABLE_SAMPLE_ORDER,
			ENABLE_CHECKBOX_INLIST,
			CHECKBOX_READONLY_WHEN_TRUE,
			MODERN_ICON
		];
		
		public function getGoolgeMapDistance():String{
			return getStrValue(GOOGLE_MAP_DISTANCE,"metric");
		}
		
		public function isModernIcon():Boolean{
			return getBooleanValue(MODERN_ICON) as Boolean;
		}
		public function isEnableCheckBoxInList():Boolean{
			return getBooleanValue(ENABLE_CHECKBOX_INLIST);
		}
		
		public function isChkReadonlyWhenTrue():Boolean{
			return getBooleanValue(CHECKBOX_READONLY_WHEN_TRUE);
		}
		
		public function isEnableSampleOrder():Boolean{
			return getBooleanValue(ENABLE_SAMPLE_ORDER);
		}
		
		public function isEnableDoubleClickNewCall():Boolean{
			return getBooleanValue(ENABLE_DOUBLE_CLICK_NEW_CALL);
		}
		public function isEnableRevenueReport():Boolean{
			return getBooleanValue(ENABLE_REVENUE_REPORT);
		}
		
		public function isAutoSetPrimaryContact():Boolean{
			
			return getBooleanValue(ENABLE_AUTO_SET_PRIMARY_CONTACT,1);
		}
		
		public function isEnableAUTO_SYNC():Boolean{
			return getBooleanValue(ENABLE_AUTO_SYNC);
		}
		
		public function isEnableCallCopySubject():Boolean{
			return getBooleanValue(ENABLE_CALL_COPY_SUBJECT);
		}
		public function isEnableCompetitors():Boolean{
			return getBooleanValue(ENABLE_COMPETITORS);
		}
		public function isEnableCustomers():Boolean{
			return getBooleanValue(ENABLE_CUSTOMERS);
		}
		public function isSync_cascadingpicklist():Boolean{
			
			return getBooleanValue(SYNC_CASCADINGPICKLIST);			
		}
		public function isSync_picklistservice():Boolean{
			
			return getBooleanValue(SYNC_PICKLISTSERVICE);			
		}
		public function isSync_role():Boolean{
			
			return getBooleanValue(SYNC_ROLE);			
		}
		public function isSync_accessprofile():Boolean{
			
			return getBooleanValue(SYNC_ACCESSPROFILE);			
		}
		
		public function isSync_assessmentscript():Boolean{
			
			return getBooleanValue(SYNC_ASSESSMENTSCRIPT);			
		}
		public function isSync_field_managment():Boolean{
			
			return getBooleanValue(SYNC_FIELD_MANAGMENT);			
		}
		
		
		
		public function getBeginOfWeek():int{
			return getIntValue(BEGIN_OF_WEEK,1);
		}
		public function isLongTimeFormate():Boolean{
			if(getValue(TIME_FORMAT) == "24"){
				return true;
			}
			return false;
		}
		public function update(preferences:Object):void
		{
			// CH 09.05.2011
			for each(var field:String in fields){
				setValue(field, preferences[field]);
			}
			setValue(BACKGROUND_COLOR, preferences.background_color);
			setValue(ENABLE_CHECK_CONFLICTS,preferences.enable_check_conflict);
			setValue(FRAME_RATE,preferences.frame_rate);
			
			setValue("enable_google_calendar",preferences.enable_google_calendar);
			setValue(START_AT_LOGIN,preferences.start_at_login);
			
			// CH 09.05.2011
			// bug sso
			if(preferences.enabled_technical_user){
				setValue("enabled_technical_user", preferences.enabled_technical_user);
			}else{
				setValue("enabled_technical_user", 1);
			}
			
			//setValue("parallel_processing",preferences.parallel_processing);
			//---------------------------
		}
		
		public function updateAcceptedLicense(accepted_license:Boolean):void
		{
			setValue("accepted_license", accepted_license);
		}
		
		public function read():Object
		{
			var object:Object = new Object();
			
			// CH 09.05.2011
			for each(var field:String in fields){
				object[field] = getValue(field);			
				
				
			}
			
			object.accepted_license = getValue("accepted_license");
			
			object.background_color = getValue(BACKGROUND_COLOR);
			
			//object.parallel_processing=getValue("parallel_processing");
			object.window_width=getValue("window_width");
			object.window_height=getValue("window_height");
			
			object.frame_rate = getValue(FRAME_RATE);
			object.enable_check_conflict=getValue(ENABLE_CHECK_CONFLICTS);
			
			object.google_calendar_tab = getValue("enable_google_calendar");
			object.start_at_login = getValue(START_AT_LOGIN);
			
			// CH 09.05.2011
			object.enabled_technical_user = getValue("enabled_technical_user", null);
			//---------------------------
			Utils.suppressWarning(new ArrayCollection([object]));
			return object;
		}
		
		public function getValue(key:String, defaultValue:Object=""):Object {
			
			var cache:CacheUtils = new CacheUtils("Preferences_DAO");
			
			var objectPref:Object = cache.get(CACHE_PREFERENCE_OBJ_KEY); 
			if(objectPref==null){
				stmtRead.text = "SELECT * FROM prefs";
				//stmtRead.parameters[":key"] = key;
				exec(stmtRead);
				var result:SQLResult = stmtRead.getResult();
				var datas:Array = result.data;
				if(datas==null || datas.length==0){
					return defaultValue;
				}
				objectPref = new Object();
				cache.set(CACHE_PREFERENCE_OBJ_KEY, objectPref);
				for each(var prop:Object in datas){
					if(fieldsCrypt[prop.key]!=null){
						try{
							objectPref[prop.key] = Utils.decryptPassword(String(prop.value));
						}catch(e:Error){
							//ignore 
						}
						
					}else{
						objectPref[prop.key]=prop.value;
					}	
					
				}		
				
			}
			return objectPref[key]==null?defaultValue:objectPref[key];
		}
		public function getValueSelectedActivityType():ArrayCollection{
			var vals:String = getStrValue(HIDE_ACTIVITY_TYPE);
			var arr:ArrayCollection = new ArrayCollection();
			if(!StringUtils.isEmpty(vals)){
				var spl:Array = vals.split(",");
				if(spl != null && spl.length>0){
					arr = new ArrayCollection(spl);
				}else{
					arr.addItem(vals);
				}
			}
			return arr;
		}
		//VAHI added
		public function getStrValue(key:String, defaultValue:String=""):String {
			return getValue(key,defaultValue).toString();
		}
		//VAHI added
		public function getIntValue(key:String, defaultValue:int=0):int {
			return parseInt(getStrValue(key,defaultValue.toString()));
		}
		
		public function getBooleanValue(key:String, defaultValue:int=0):Boolean {
			return getIntValue(key,defaultValue)==1;
		}
		
		
		public static function enableSyncSRStatus():Boolean{
			return Database.preferencesDao.getBooleanValue(ENABLE_SR_SYNC_ORDER_STATUS);
		}
		public function enableCutomLayout():Boolean{
			return getBooleanValue(PreferencesDAO.ENABLE_CUSTOM_LAYOUT) as Boolean;
		}
		public function enableListyout():Boolean{
			return getBooleanValue(PreferencesDAO.ENABLE_LIST_LAYOUT) as Boolean;
		}
		public function enableViewLayout():Boolean{
			return getBooleanValue(PreferencesDAO.ENABLE_VIEW_LAYOUT) as Boolean;
		}
		public function setValue(key:String, value:Object,isEncrypt:Boolean = true):void{
			//VAHI changed such that adding preferences using XML works
			var encryptValue:Object = value;
			if(fieldsCrypt[key]!=null ){
				try{
					if(isEncrypt){
						encryptValue = Utils.encryptPassword(value.toString());
					}else{
						value = Utils.decryptPassword(value.toString());
					}
					
				}catch(e:Error){
					//nothing to do
				}
				
			}
			
			
			stmtUpdate.text = "INSERT OR REPLACE INTO prefs ( key, value ) VALUES ( :key, :value )";
			stmtUpdate.parameters[":key"] = key;
			stmtUpdate.parameters[":value"] = encryptValue;
			exec(stmtUpdate);
			var cache:CacheUtils = new CacheUtils("Preferences_DAO");
			var prefsObject:Object = cache.get(CACHE_PREFERENCE_OBJ_KEY);
			if(prefsObject==null){//cannot happend
				prefsObject = new Object();
				cache.set(CACHE_PREFERENCE_OBJ_KEY,prefsObject);
			}
			prefsObject[key]=value;			
			
		}
		
		public function getCompanyName():String {
			return getStrValue("company_name", UserService.UNKNOWN);
		}
		
		public function isUsedSSO():Boolean{
			return getBooleanValue("use_sso");
		}
		public function getTechUserSignInId():String{
			return getStrValue("tech_username");
		}
		
		public function isEnableFavorite():Boolean{
			return getBooleanValue(ENABLE_FAVORITE);
		}
		
		public function isEanableImportant():Boolean{
			return getBooleanValue(ENABLE_IMPORTANT);
		}
		public function isEanableFuzzy():Boolean{
			return getBooleanValue(ENABLE_FUZZY);
		}
		public function isHideSSOTechUser():Boolean{
			return getBooleanValue(HIDE_TECH_USER);
		}
		public function isEanableConvertLead():Boolean{
			return getBooleanValue(ENABLE_CONVERT_LAED);
		}
		public function isEanableHomeTask():Boolean{
			return getBooleanValue(ENABLE_HOME_TASK);
		}
		public function getPrefs(isDecrypt:Boolean=true):ArrayCollection{
			exec(stmtGetAll);
			var result:ArrayCollection =new ArrayCollection(stmtGetAll.getResult().data); 
			if(isDecrypt){
				for each(var obj:Object in result){
					if(fieldsCrypt[obj.key]!=null){
						try{
							obj.value = Utils.decryptPassword(obj.value);
						}catch(e:Error){
							//nothing to do
						}
					}
				}		
			}			
			
			return result;
		}
		
		
	}
}
