package gadget.util {
	import com.adobe.utils.DateUtil;
	import com.adobe.utils.StringUtil;
	import com.assessment.DtoColumn;
	import com.assessment.DtoConfiguration;
	import com.crmgadget.eval.Evaluator;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.symmetric.CBCMode;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.IPad;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.hurlant.crypto.symmetric.PKCS5;
	import com.hurlant.util.Hex;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.errors.IllegalOperationError;
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import flashx.textLayout.formats.Float;
	
	import gadget.control.AutoComplete;
	import gadget.control.CalculatedField;
	import gadget.control.LoadingIndicator;
	import gadget.dao.AllUsersDAO;
	import gadget.dao.BaseDAO;
	import gadget.dao.BaseSQL;
	import gadget.dao.DAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.dao.SimpleTable;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.dao.TransactionDAO;
	import gadget.i18n.i18n;
	import gadget.lists.List;
	import gadget.service.LocaleService;
	import gadget.service.PicklistService;
	import gadget.service.SupportService;
	import gadget.service.UserService;
	import gadget.sync.WSProps;
	import gadget.window.WindowManager;
	
	import mx.collections.ArrayCollection;
	import mx.containers.utilityClasses.IConstraintLayout;
	import mx.controls.Alert;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.core.UIComponent;
	import mx.core.Window;
	import mx.utils.ObjectProxy;
	import mx.utils.StringUtil;
	
	import org.igniterealtime.xiff.data.Message;
	
	
	public class Utils {
		public static var updChildSyncStatus:Boolean = false; // refresh sub tab ListDetail
		private static var ENTITY:String = "{ENTITY}";
		private static var Plant_LOCATION_UK:String = "GB01"
		private static var Plant_LOCATION_NL:String = "NL01"
		private static var Plant_LOCATION_BG:String = "BE01"
		private static var Plant_LOCATION_DE:String = "DE20"
		private static var Plant_LOCATION_PT:String = "PT21"
		private static var PLANT_LOCATION_SE:String = "SE02";
		private static var PLANT_LOCATION_DK:String = "DK05";
		private static const cryptoKey:String  = "TgJBaPGLa1WIjR20kbrJ9sGw3";
		private static const cryptName:String = "aes-ecb";
		public static const charUpperGermanAccents:Array =['ß','Ä','Ö','Ü']; 
		public static const charLowerGermanAccents:Array =['ß','ä','ö','ü'];
		public static const charGerman:Array =['SS','AE','OE','UE'];
		private static var iv:ByteArray;
		/**
		 *  @private
		 *  Char codes for 0123456789ABCDEF
		 */
		private static const ALPHA_CHAR_CODES:Array = [48, 49, 50, 51, 52, 53, 54, 
			55, 56, 57, 65, 66, 67, 68, 69, 70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90];
		
		public static const MAP_HEADER_COLOR_PDF:Object = {
			"Dark Blue":[[44,62,80],[236,240,241]],
			"Light Blue":[[159,175,185],[217,207,201]],
			"Yellow":[[255,206,44],[192,192,192]],
			"Black":[[0,0,0],[192,192,192]],
			"Light Green":[[153,204,0],[192,192,192]],
			"Red":[[204,0,0],[192,192,192]],
			"White":[[255,255,255],[192,192,192]]
			
		} 
		//some child field update to parent field using custom field
		//CR #1911 CRO
		public static function updateFieldByChild(childEntity:String ,item:Object,detailItem:Object=null):void{
			for each(var obj:Object in Database.customFieldDao.selectCustomFieldsSum(childEntity)){
				if(obj.field_copy != null && item[obj.relation_id] != null && item[obj.relation_id] != ""){
					var objSum:Object = new Object();
					objSum.sql = obj.value
					objSum["childEntity"] = childEntity;
					objSum["entityId"] = obj.relation_id;
					objSum[obj.relation_id] = item[obj.relation_id];
					
					var sumObj:Object = Database.getDao(obj.sum_entity_name).sumFields(objSum);
					var v:Number = sumObj == null ? 0 : sumObj.sumFields;
					if(detailItem!=null){
						detailItem[obj.field_copy] = v;
					}
					
					var itemUpdate:Object = new Object();
					var oracleId:String = DAOUtils.getOracleId(obj.entity);
					itemUpdate[oracleId] = item[obj.relation_id];
					itemUpdate[obj.field_copy] = v;
					itemUpdate['local_update'] = null;
					itemUpdate['deleted'] =false;
					itemUpdate['error'] = null;
					itemUpdate['sync_number'] = null;
					itemUpdate['ood_lastmodified']=item.ood_lastmodified;
					Database.getDao(obj.entity).updateByFieldRelation([obj.field_copy],itemUpdate,oracleId);
					
				}
			}
		}
		public static function getMapDirection(from:String,to:String,getDirection:Function):void{
			
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest();
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var str:String = e.target.data;
				getDirection(new XML(str));
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				//requestFaultHandler.call(self, soapAction, xml, loader, e);
			});
			
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			request.url = "http://maps.googleapis.com/maps/api/directions/xml?origin=" + from + "&destination="+ to +"&OK&sensor=false";
			loader.load(request);
		}
		public static function getTranslatedValidation(strError:String):String{
	
			if(strError == "This field is required."){
				return i18n._("GLOBAL_THIS_FIELD_IS_REQUIRED");
			}else if(strError == "The input contains invalid characters."){
				return i18n._("GLOBAL_THE_INPUT_CONTAINS_INVALID_CHARACTERS");
			}else if(strError == "The decimal separator can occur only once."){
				return i18n._("GLOBAL_THE_DECIMAL_SEPARATOR_CAN_OCCUR_ONLY_ONCE");
			}else if(strError == "The thousands separator must be followed by three digits."){
				return i18n._("GLOBAL_THE_THOUSANDS_SEPARATOR_MUST_BE_FOLLOWED_BY_THREE_DIGITS");
			}else if(strError == "An at sign (@) is missing in your e-mail address."){
				return i18n._("GLOBAL_AN_AT_SIGN_IS_MISSING_IN_YOUR_E_MAIL_ADDRESS");
			}else if(strError == "The domain in your e-mail address is missing a period."){
				return i18n._("GLOBAL_THE_DOMAIN_IN_YOUR_E_MAIL_ADDRESS_IS_MISSING_A_PERIOD");
			}else if(strError== "The number must be an integer."){
				return i18n._("GLOBAL_THE_NUMBER_MUST_BE_AN_INTEGER");
			}
				
			return 	strError;
		}
		//replace German Character for searching both AE or Ä
		public static function replaceGermanCharacter(str:String,oldChars:Array,newChars:Array):String{
			
			str = str.toUpperCase();
			
			for(var i:int = 0 ;i<oldChars.length;i++){
				var reg:RegExp = new RegExp(oldChars[i] , "gi");
				str = str.replace(reg, newChars[i]);
			}
			var strTwo:String = str;
			for(var j:int = 0 ;j<newChars.length;j++){
				var reg2:RegExp = new RegExp(newChars[j] , "gi");
				strTwo = strTwo.replace(reg2, oldChars[j]);
			}
			return str +' OR ' + strTwo;
			
		}
		// Bug #1840 CRO
		public static function replaceGermanChar(str:String,oldUpperChars:Array,oldLowerChars:Array,newChars:Array):Array{
			str = str!=null? str.toUpperCase():"";
			for(var i:int = 0 ;i<oldUpperChars.length;i++){
				var reg:RegExp = new RegExp(oldUpperChars[i] , "gi");
				str = str.replace(reg, newChars[i]);
			}
			
			var strTwo:String = str;
			for(var j:int = 0 ;j<newChars.length;j++){
				var reg2:RegExp = new RegExp(newChars[j] , "gi");
				strTwo = strTwo.replace(reg2, oldUpperChars[j]);
			}
			var strTHREE:String = str;
			for(var k:int = 0 ;k<newChars.length;k++){
				var reg3:RegExp = new RegExp(newChars[k] , "gi");
				strTHREE = strTHREE.replace(reg3, oldLowerChars[k]);
			}
			return [str,strTwo,strTHREE];
		}
		//get formula from custom object to do evaluate
		public static  function getFormulaValue(entity:String,userOwner:Object,item:Object,formulaField:String,fieldName:String):String{
			
			var columns:ArrayCollection = new ArrayCollection([{element_name:"value"}]);
			var filter:String = "entity='"+ entity + "' And fieldName='"+ formulaField +"'";
			var obj:Object = Database.customFieldDao.selectByFieldName(entity,formulaField);
			if(obj == null || obj.value == null){
				return "";
			}
			var value:String = Utils.doEvaluate(obj.value,userOwner,entity,null,item,null);
			if(value == null || value == ""){
				value = "";
			}
			return value;
		}
		//#977 and #974 CRO
		//To change field AccountType to Type for get data from Field_management and picklist_Service object
		public static function convertFldAccTypeToType(entity:String,field:String):String{
		
			if(field.indexOf('AccountType') != -1){
				return 'Type';
			}else if(field.indexOf('CloseDate') != -1){
				return 'PrimaryRevenueCloseDate';
			}
			return field;
		}
		//#934 CRO 
		public static function checkWarningServiceRequest():ArrayCollection{
			if( UserService.DIVERSEY==UserService.getCustomerId() && Database.preferencesDao.getBooleanValue("tcs_closing_enable")){
				var message:String = "";
				var columns:ArrayCollection = new ArrayCollection([{element_name:"gadget_id"}]);   //#1390 filename like '%.doc' or filename like '%.docx'
				var filter:String = "(CustomPickList10='SUSP' OR CustomPickList10='AWPT' OR CustomPickList11='TECO') And gadget_id Not In (Select gadget_id from attachment where entity='Service Request' And gadget_id is not null and filename like '%.pdf' or filename like '%.doc' or filename like '%.docx')";  // AND CustomText1='On Site'
				var data:ArrayCollection = Database.getDao(Database.serviceDao.entity).findAll(columns,filter);				
				return data;
			}
			return null;
		}
		//Count sql list CRO
		public static function getSqlListCounts(item:Object,fields:ArrayCollection):ArrayCollection{
			var lstCounts:ArrayCollection= new ArrayCollection();
			if(!fields) return new ArrayCollection();
			for (var i:int = 0; i < fields.length; i++) {					
				if (fields[i].custom != null) {
					if (fields[i].column_name.indexOf(CustomLayout.SQLLIST_CODE)>-1) {
						var objectSQLQuery:Object = SQLUtils.checkQueryGrid(fields[i].custom, item);
						objectSQLQuery['column_name'] = fields[i].column_name;
						if (objectSQLQuery.error) {
							continue;
						}else{
							try{
								var count:int = Database.queryDao.executeQuery(objectSQLQuery.sqlString).length;
								lstCounts.addItem(Utils.createNewObject(["key","count"],[objectSQLQuery.column_name,count<0?0:count]));
								
							}catch(e:SQLError){
								continue;
							}
						}
					}
				}
			}
			return lstCounts;
		}
		
		
		private static var MAP_PLANT_LOCATION:Object={
			"USA":Plant_LOCATION_UK,
			"United Kingdom":Plant_LOCATION_UK,
			"Germany":Plant_LOCATION_DE,
			"Netherlands":Plant_LOCATION_NL,
			"Portugal":Plant_LOCATION_PT,
			"Sweden": PLANT_LOCATION_SE,
			"Denmark": PLANT_LOCATION_DK
		};	
		
		
		public static function getFieldNameFromIntegrationTag(entity:String, integrationName:String):Object {
			integrationName = integrationName.replace("_ITAG", "");
			// First step : we find the corresponding field name in field managament
			// eg. dtCall_Recieved_Time => PICK_005
			var fieldMgmtNames:Object = Database.fieldManagementServiceDao.getByIntegrationTag(entity,integrationName);
//			var tmpName:String = integrationName;
//			for each (var tmp:Object in fieldMgmtNames) {
//				if (tmp.IntegrationTag == integrationName) {
//					return tmp;
//				}
//			}
			if(fieldMgmtNames!=null){
				return fieldMgmtNames;
			}
			
			var fieldInfo:Object = FieldUtils.getField(entity, integrationName);
			if(fieldInfo!=null){
				fieldInfo.Name = integrationName;
			 	fieldInfo.FieldType = fieldInfo.data_type;
				return fieldInfo;
			}
			//for nestle name is the element name
//			if (tmpName == null) return integrationName;
//			// Second step : we find the field name in the field table
//			// eg. PICK_005 => CustomPickList5
//			var fields:ArrayCollection = Database.fieldDao.listFields(entity);
//			for each (var tmp2:Object in fields) {
//				if (SupportService.match(tmpName, tmp2.element_name)) {
//					return tmp2.element_name;
//				}
//			} 
			return {'Name':integrationName};
		}
		//JoinFieldValue('<Account>',[<AccountId>],'<IndexedShortText1>')
		public static function doJoninFieldValue(entity:String,filterQuery:String,fieldName:String):String{
			var dao:DAO = Database.getDao(entity);
			//var fieldNames:Array = Database.fieldManagementServiceDao.readAll(entity);
			var daoFieldName:Object = getFieldNameFromIntegrationTag(entity,fieldName);
			if(daoFieldName != null){
				var records:ArrayCollection = dao.findAll(new ArrayCollection([{element_name:daoFieldName.Name}]), filterQuery);
				if(records.length>0){
					return records[0][daoFieldName.Name] ;
				}
			}
			return "";
		}
		
		public static function doFomulaField(entity:String,enityObject:Object ,afterSave:Boolean=false , subtype:int = 0):void {
			var fields:ArrayCollection = Database.layoutDao.selectLayout(entity, subtype);
			executeFomulaFields(entity,enityObject,fields,afterSave,subtype);
		}
		public static function checkValidationFields(this_:Window,entity:String,enityObject:Object,fields:ArrayCollection):Boolean {
			var fieldsManagement:Dictionary = Database.fieldManagementServiceDao.readAll(entity);
			var langCode:String = LocaleService.getLanguageInfo().LanguageCode;
			var ownerUser:Object = Database.allUsersDao.ownerUser();
			
			for each (var tmpField:Object in fields) { 
				if (tmpField.custom == null) {
					var fieldName:String = Utils.convertFldAccTypeToType(entity,tmpField.column_name);
					var fieldManagement:Object = fieldsManagement[fieldName];
					if(fieldManagement!=null){
						var fieldInfo:Object = FieldUtils.getField(entity, tmpField.column_name);						
						if(!fieldInfo) continue;
						if( !StringUtils.isEmpty(fieldManagement.FieldValidation )){
							var validationValue:String = fieldManagement.FieldValidation;
							//var checkRule:String = Evaluator.evaluate(validationValue,ownerUser, entity, null, enityObject, PicklistService.getValue,PicklistService.getId,null,false,null,null,null); //object[objectSQLQuery.displayName];
							var checkRule:String =Utils.doEvaluate(validationValue,ownerUser,entity,null,enityObject,null);
							if(checkRule=='false'){
								var valTran:Object = Database.fieldTranslationDataDao.selectField(entity,fieldInfo.element_name,langCode);
								var errorMsg:String = "";
								if(valTran != null){
									errorMsg = valTran.ValidationErrorMsg;
								}
								Alert.show(errorMsg,i18n._("GLOBAL_CHECK_VALIDATION_RULE"), Alert.OK, this_);
								return true;
							}
						}
					}
				}
			}
			
			return false;
		}
		public static function executeFomulaFields(entity:String,enityObject:Object,fields:ArrayCollection ,afterSave:Boolean=false,subtype:int=0):void {
			
			var fieldsManagement:Dictionary = Database.fieldManagementServiceDao.readAllDefaultValueFields(entity);
			var userData:Object = Database.allUsersDao.ownerUser();
			var currentUser:Object = Database.userDao.read();
//			for each (var tmpField:Object in fields) { 
//				if (tmpField.custom == null) {
			for(var tempField:String in fieldsManagement){//should execute all default field
					var fieldInfo:Object = FieldUtils.getField(entity, tempField);
					if(!fieldInfo) continue;
					var fieldName:String = fieldInfo.element_name;
					var fieldManagement:Object = fieldsManagement[fieldName];
					if(fieldManagement==null){
						fieldName = Utils.convertFldAccTypeToType(entity,fieldInfo.element_name);	
						fieldManagement = fieldsManagement[fieldName];
					}
					if(fieldManagement!=null){
						if(!StringUtils.isEmpty( fieldManagement.DefaultValue )){
							var defaultValue:String = fieldManagement.DefaultValue;
							if(fieldManagement.PostDefault=='true' && !afterSave){
								continue;
							}
							
							if(afterSave && (fieldManagement.PostDefault=='false'||StringUtils.isEmpty(fieldManagement.PostDefault))){
								continue;
							}
							if (defaultValue.indexOf("(") == -1 && defaultValue.indexOf("{") == -1 && defaultValue.indexOf("[") == -1) {
								if( defaultValue.indexOf("CreatedDate")!=-1 ){
									enityObject[fieldInfo.element_name] =new Date();
								}else{
									enityObject[fieldInfo.element_name] = defaultValue;
								}
								
							} else {
								// functions
								var val:String = doEvaluate( defaultValue,userData,entity ,fieldInfo.element_name,enityObject,null);
								if (fieldInfo.data_type == "Picklist") {
									var v:String = PicklistService.getId(entity,fieldInfo.element_name,val,userData==null?"":userData.LanguageCode);
									if(v==null){
										v = PicklistService.getValue(entity,fieldInfo.element_nam,val);
										if(v==null){
											val = null;
										}
									}else{
										val = v;
									}
																		
								}else if (fieldInfo.data_type == "Date/Time") {
									if(!StringUtils.isEmpty(val)){
										var dateTimeObject:Date = DateUtils.guessAndParse(val);	
										if(dateTimeObject!=null){
											dateTimeObject=new Date(dateTimeObject.getTime()-(DateUtils.getCurrentTimeZone(dateTimeObject)*GUIUtils.millisecondsPerHour));
											val = DateUtils.format(dateTimeObject, DateUtils.DATABASE_DATETIME_FORMAT);
										}
									}
									
								}else if(fieldInfo.data_type == "Date"){
									if(!StringUtils.isEmpty(val)){
										var dateObj:Date = DateUtils.guessAndParse(val);	
										if(dateObj!=null){											
											val = DateUtils.format(dateObj, DateUtils.DATABASE_DATE_FORMAT);
										}
									}
								}
								if(val=='-1' && entity==Database.customObject1Dao.entity && fieldInfo.element_name=='CustomInteger0'){
									val="";
								}
								if(afterSave){
									var tempVal:String = val==null?'':val;
									while(tempVal.charAt(tempVal.length-1)=='-'){
										tempVal = tempVal.substr(0,tempVal.length-1);
									}
									while(tempVal.charAt(0)=='-'){
										tempVal = tempVal.substr(1);
									}
									if(tempVal=="No Match Row Id"){
										tempVal ="";//
									}	
									if(entity==Database.activityDao.entity && fieldInfo.element_name=='CompletedDatetime'){
										
										if(StringUtils.isEmpty(tempVal)){										
											enityObject[fieldInfo.element_name] = "";										
										}else{
											var oldVal:String = enityObject[fieldInfo.element_name];
											if(StringUtils.isEmpty(oldVal)){
												enityObject[fieldInfo.element_name] = tempVal;
											}
											
											
										}
										
									}else{
										//always set the value with the post default value
										enityObject[fieldInfo.element_name] = tempVal;
									}
									
									
								}else{
									enityObject[fieldInfo.element_name] = val;
								}
								
							}
							
							
							
							
						}
					
					
					//#975 and #977 CRO
					if(UserService.SIEMEN==UserService.getCustomerId() && entity==Database.opportunityDao.entity && enityObject['SalesStage'] == null){
						enityObject['SalesStage'] = "0 Lead Management";
					}
					if(userData!=null && !afterSave){	
						if(entity == Database.activityDao.entity && enityObject['DueDate'] == null &&Detail.APPOINTMENT!=subtype ){
							enityObject['DueDate'] =  DateUtils.format(new Date(),"YYYY-MM-DD"); //CRO #1086
						}
						
						if(entity==Database.contactDao.entity){
							if(enityObject["AlternateCountry"]==null&& fieldInfo.element_name=='AlternateCountry')
								enityObject["AlternateCountry"]=userData.PersonalCountry;
							if(enityObject["PrimaryCountry"]==null && fieldInfo.element_name=='PrimaryCountry')
								enityObject["PrimaryCountry"]=userData.PersonalCountry;
						}else if(entity==Database.leadDao.entity ){
							if(fieldInfo.element_name=='Status'){
								enityObject['Status']='Qualifying';
							}else if(fieldInfo.element_name=='LeadOwner'){
								enityObject['LeadOwner']=currentUser.full_name;									
							}
							
						}else if(entity==Database.accountDao.entity){
							if(fieldInfo.element_name=='PrimaryShipToCountry' && enityObject["PrimaryShipToCountry"]==null){
								enityObject["PrimaryShipToCountry"]=userData.PersonalCountry;
							}else if(fieldInfo.element_name=='PrimaryBillToCountry' && enityObject["PrimaryBillToCountry"]==null){
								enityObject["PrimaryBillToCountry"]=userData.PersonalCountry;
							}else if(enityObject["PrimaryBillToCounty"]==null && fieldInfo.element_name=='PrimaryBillToCounty'){ //#974 CRO
								enityObject["PrimaryBillToCounty"]=userData.PersonalCountry;
							}
						}
					}
				}
			}
		}
		//do for evaluate Filter 
		public static function doEvaluateForFilter(criteria:Object,entity:String):String{
			
			if(criteria.param != null && criteria.param != ""){
				var param:String =  Evaluator.evaluate(criteria.param, Database.allUsersDao.ownerUser(), entity, null, null, PicklistService.getValue,PicklistService.getId,Database.preferencesDao.getValue,true,null,getFieldNameFromIntegrationTag,null,DAOUtils.getOracleId);
				//if(param == "<ERROR>") return null;
				return param;
			}
			
			return "";	
		}
		//do for evaluate create object 
		public static function doEvaluate(defaultValue:String,userData:Object,entity:String,element_name:String,entityOject:Object,sqlList:ArrayCollection):String{
			
			return Evaluator.evaluate(defaultValue, userData, entity, element_name, entityOject, PicklistService.getValue,PicklistService.getId,null,false,Utils.doJoninFieldValue,getFieldNameFromIntegrationTag,sqlList,DAOUtils.getOracleId);
			
		}
		
		public static function getDisableColorLayout(readOnly:Boolean):uint {
			if(readOnly == true) return 0x0000FF;
			return 0xEEEEEE;
		}
		
		public static function getAppInfo():Object {
			// Retrieve data from the app descriptor
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace(); 
			var appVersion:String = appXml.ns::version[0]; 
			var appName:String = appXml.ns::filename[0]; 
//			var appName:String = Database.preferencesDao.getValue("application_name","") as String;
//			if(""==appName){
//				appName = appXml.ns::filename[0]; 
//			}
			return {version:appVersion, name:appName};		
		}
		
		public static function osIsMac():Boolean{
			var os:String = flash.system.Capabilities.os.substr(0, 3);
			if(os=='Mac'){
				return true;
			}
			return false;
		}
		
//		public static const letterData:ArrayCollection = new ArrayCollection(
//			[ i18n._("ALL"), "#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R",
//				"S", "T", "U", "V", "W", "X", "Y", "Z"]);
		public static function letterData():ArrayCollection{
			return new ArrayCollection(
				[ i18n._("ALL"), "#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R",
					"S", "T", "U", "V", "W", "X", "Y", "Z"]);
		}
		public static function getComboIndex(combo:ComboBox, value:String, field:String='data'):int 
		{
			for (var i: int = 0; i < combo.dataProvider.length; i++) {
				if ( value == combo.dataProvider[i][field]) {
					return i;
				} 			
			}
			// AM - should not be done here - this function is for getting the combo index
			// if we want to add some values to the picklist, do it somewhere else
			
			/*			if(!StringUtils.isEmpty(value) && value != "null"){
			// (combo.dataProvider as ArrayCollection).addItem();
			var obj:Object = new Object();
			obj.data = value;
			obj.label = value;
			(combo.dataProvider as ArrayCollection).addItem(obj);
			return i+1;
			}*/
			return 0;
		}
		
		public static function createNewObject(fieldNames:Array,fieldValues:Array):Object{
			var obj:Object = new Object();
			if(fieldNames && fieldValues){
				for(var i:int;i<fieldNames.length;i++){
					obj[fieldNames[i]] = fieldValues[i];
				}
			}
			return obj;
		}
		
		
		
		public static const operatorData:ArrayCollection = new ArrayCollection(
			
			[ {label:"", data:""},
				{label:"equals", data:"="},
				{label:"different", data:"!="}, 
				{label:"contains", data:"LIKE"},
				{label:"less than", data:"<"},
				{label:"greater than", data:">"},
				{label:"is empty", data:"is null"},
				{label:"is not empty", data:"is not null"},	
				{label:"begins with", data:"LIKE%"}	
			]);
		
		
		private static const MAP_OPERATION:Object = {
		"!=":"&lt;>",
		"<":"&lt;",
		"is null":"IS NULL",
		"is not null":"IS NOT NULL"
		};
		
		public static function getOODOperation(localOperation:String):String{
			var oodOperation:String = MAP_OPERATION[localOperation];
			if(oodOperation==null){
				return localOperation;
			}
			return oodOperation;
		}
		
		public static function getComboOpIndex(value:String):int {
			for (var i: int = 0; i < operatorData.length; i++) {
				if ( value == operatorData[i].data) {
					return i;
				}    
			}
			return 0;
		}
		
		public static function isEmptyOrIsNotEmptyUnselected(filterOpComboBox:ComboBox):Boolean {
			var bUnselected:Boolean = true ;
			if( filterOpComboBox.selectedItem != null && (filterOpComboBox.selectedItem.data == "is null" || filterOpComboBox.selectedItem.data == "is not null") ) 
				bUnselected = false;
			return bUnselected;
		}			
		
		public static function getAutoCompleteIndex(combo:AutoComplete, value:String):int 
		{
			for (var i: int = 0; i < combo.dataProvider.length; i++) {
				if ( value == combo.dataProvider[i].data) {
					return i;
				}    
			}
			return 0;
		}
		
		
		
		
		/**
		 * Returns the name of an item. Maybe this should be removed and we rather use DAO's data.
		 * @param item Item.
		 * @return Item's name.
		 * 
		 */
		public static function getName(item:Object):String {
			// Change Request #747
			var name_column:String = Database.customLayoutDao.readSubtype(item.gadget_type, LayoutUtils.getSubtypeIndex(item)).custom_layout_title;
			
			if(name_column) return item[name_column] ? item[name_column] : "";
			
			var oData:Array = DAOUtils.getNameColumns(item.gadget_type);
			var nData:Array = new Array();
			for(var i:int = 0; i < oData.length; i++) {
				nData[i] = item[oData[i]];
			}
			return nData.join(" ");
		}
		
		
		public static function updateRelationFields(dest:Object,entity:String):void{
			var relations:ArrayCollection = Relation.getReferencers(entity);
			if(relations.length>0){
				Database.begin();
				for each(var obj:Object in relations){
					var criteria:Object={};
					criteria[obj.keySrc]=dest[obj.keyDest];						
					var values:Object={};
					var labelDest:Array=obj.labelDest;
					var labelSrc:Array=obj.labelSrc;
					for (var i:int=0 ;i<labelDest.length;i++){
						values[labelSrc[i]]=dest[labelDest[i]]
						
					}
					var dao:BaseDAO=Database.getDao(obj['entitySrc'])
					dao.updateRelationFields(values,criteria);
				}
				Database.commit();
			}
		}
		
		public static function removeRelation(dest:Object,entity:String,isCommit:Boolean = true):void{
			var relations:ArrayCollection = Relation.getReferencers(entity);
			if(relations.length>0){
				if(isCommit){
					Database.begin();
				}
				
				for each(var obj:Object in relations){
					var criteria:Object={};
					criteria[obj.keySrc]=dest[obj.keyDest];					
					var dao:BaseDAO=Database.getDao(obj['entitySrc'])
					var fields:Array = 	obj.labelSrc;
					fields.push(obj.keySrc);
					dao.removeRelationFields(fields,criteria);
				}
				if(isCommit){
					Database.commit();
				}
				
			}
		}
		
		public static function deleteChild(dest:Object,entity:String):void{
			var oracleId:String = DAOUtils.getOracleId(entity);
			for each (var sub:String in SupportRegistry.getSubObjects(entity)) {						
				
				var subDao:SupportDAO = SupportRegistry.getSupportDao(entity,sub);
				
				if(!subDao.isSyncWithParent){					
					var criteria:Object = {};
					criteria[oracleId] = dest[oracleId];
					subDao.deleteByParentId(criteria);
				}
				
			}
			
			if(entity == Database.accountDao.entity){
				var criteria:Object = {};
				criteria[oracleId] = dest[oracleId];
				Database.contactAccountDao.deleteByParentId(criteria);
				Database.accountCompetitorDao.deleteByCompetitorId(dest[oracleId]);
				Database.accountPartnerDao.deleteByPartnerId(dest[oracleId]);
				
			}else if(entity == Database.contactDao.entity){
				Database.relatedContactDao.deleteByRelatedContactId(dest[oracleId]);
			}else if(entity == Database.opportunityDao.entity){
				Database.opportunityPartnerDao.deleteByPartnerId(dest[oracleId]);				
			}
			
			
			
		}
		
		
		
		public static function getTitle(entity:String,subtype:int,item:Object,create:Boolean):String {
			//MOny--hack title....
		/*
			if(entity == Database.accountCompetitorDao.entity){
				return "Account Competitor";	
			}
			if(entity==Database.accountPartnerDao.entity){
				return "Account Partner";
			}
			
			if(entity==Database.opportunityPartnerDao.entity){
				return "Opportunity Partner";
			}
			
			if(entity==Database.opportunityProductRevenueDao.entity){
				return "Opportunity Product Revenue";
			}
			
			if(entity ==Database.relatedContactDao.entity){
				return "Contact Relationships";
			}
			
			if(entity.indexOf("Note")!=-1 && entity.indexOf(".")!=-1){
				var note:String = i18n._("GLOBAL_NOTE");//{ENTITY} note
				var entities:Array = entity.split(".");//entity
				var parentName:String = i18n._("GLOBAL_" +entities[0].toUpperCase());//account, contai
				note = note.replace('{ENTITY}',parentName);
				
				return note;
			}
			if(entity.indexOf(".")!=-1){
				//PRODUCT_DETAIL,PRODUCT_REVENUE
				
				var subEntity:Array = entity.split(".");//entity
				var parentKey:String =subEntity[0].toUpperCase();
				var childKey:String = subEntity[1].toUpperCase();
				if(entity==Database.activityProductDao.entity){
					childKey = "PRODUCT_DETAIL";
				}
				if(entity==Database.opportunityProductRevenueDao.entity){
					childKey = "PRODUCT_REVENUE";
				}
				var parentEntity:String = i18n._("GLOBAL_" + parentKey);//account, contact ...
				var childEntity:String = i18n._("GLOBAL_" + childKey + "_PLURAL");//exm: Competitor,Partner,Team,...
				
				return parentEntity + " " + childEntity;
			}
				var layoutName:String = Database.customLayoutDao.getDisplayName(entity, subtype);
				if (create) {
				return layoutName ; //+ " " + i18n._('GLOBAL_CREATION');  //CRO #872
				} else {
				return layoutName ;//+ ": " + getName(item); //CRO #872 
				}	
			*/
			return Database.customLayoutDao.getDisplayName(entity, subtype);
						
		}		
		
		
		public static function getEntityDisplayName(entity:String,subtype:int=0):String{
			return Database.customLayoutDao.getDisplayName(entity, subtype);
		}
		
		public static function styleFunction(item:Object, column:AdvancedDataGridColumn):Object {
			if(item==null){
				return {};
			}
			if (item.modified == i18n._("NEW")) {
				if (item.fromsync) {
					return { color:0xFF0000, fontWeight:"bold" };
				} else {
					return { color:0x008000, fontWeight:"bold" }
				}
			} 
			if (item.modified == i18n._("UPD")) return { color:0x0000FF, fontWeight:"bold" };
			if (item.modified == i18n._("ERR")) return { color:0xFF0000, fontWeight:"bold" };
			return {};
		}
		
		public static function getColumns(entity:String, addEmptyLabel:Boolean=true, customField:Boolean=true):ArrayCollection {
			var columns:ArrayCollection = new ArrayCollection();
			if(addEmptyLabel) columns.addItem({label:''});
			/*for each( var field:Object in Database.fieldDao.listFields(entity) ){
			columns.addItem({entity:field.entity, label:field.display_name, column:field.element_name, type:field.data_type });
			}*/
			for each( var field:Object in FieldUtils.allFields(entity,false,customField) ){
				columns.addItem({entity:field.entity, label:field.display_name, column:field.element_name, type:field.data_type, data:field.element_name });
			}
			return columns;
		}		
		
		public static function getStartDateByType(type:Number):Date{
			var currentDate:Date = new Date();
			var number:Number = 0;
			if(type == TransactionDAO.ONE_YEAR_TYPE){				
				return calculateDate(-1,currentDate,"fullYear");
			}else if(type == TransactionDAO.SIX_MONTH_TYPE){
				return calculateDate(-6,currentDate,"month");
				
			}else if(type == TransactionDAO.THREE_MONTH_TYPE){
				return calculateDate(-3,currentDate,"month");
				
			}else if(type == TransactionDAO.ONE_MONTH_TYPE){
				return calculateDate(-1,currentDate,"month");
				
			}else if(type == TransactionDAO.SEVEN_DAY_TYPE){
				return calculateDate(-7,currentDate,"date");				
			}
			
			return null;
		}
		public static function calculateStartTime(type:Number):Number{			
			var startDate:Date = getStartDateByType(type);
			if(startDate==null){
				return -1;
			}
			
			return startDate.getTime();
		}
		
		
		private static function calculateDate(number:Number, date:Date, datepart:String ):Date {
			if (date == null) {
				/* Default to current date. */
				date = new Date();
			}
			
			var returnDate:Date = new Date(date.time);;
			
			switch (datepart.toLowerCase()) {
				case "fullyear":
				case "month":
				case "date":				
					returnDate[datepart] += number;
					break;
				default:
					/* Unknown date part, do nothing. */
					break;
			}
			return returnDate;
		}
		
		
		public static function isSRHasPdfAtt(srObj:Object, entity:String):Boolean{
			if(UserService.DIVERSEY == UserService.getCustomerId() && entity == Database.serviceDao.entity){
				if( srObj.CustomPickList11=="TECO" || "AWPT" == srObj.CustomPickList10 
					||srObj.CustomPickList10 =="SUSP"){
					var isHasPdfAtt:Boolean = Database.serviceDao.isHasPdfAtt(srObj);
					
					return isHasPdfAtt;
					
				}
			}
			return true;
		}
		
		
		public static function bindValueToGridPicklist(value:String, cols:Array):ArrayCollection{
			var bindList:ArrayCollection = new ArrayCollection();
			if(!StringUtils.isEmpty(value)){
				value = value.substr(value.indexOf(":") + 1);
				var arrValue:Array = value.split(";");
				for each(var str:String in arrValue){
					var obj:Object = new Object();
					var strArr:Array = str.split("=");
					for (var i:int=0;i<cols.length;i++){
						obj[cols[i]] = i<=strArr.length?strArr[i]:"";
					}
					obj.crmLabel = obj.crmData;
					bindList.addItem(obj);
				}
			}	
			return bindList;
		}
		
		
		public static function openURL(url:String, target:String):void{
			navigateToURL(new URLRequest(url), target);	
		}
		
		public static function getContentFile(file:File):ByteArray{
			var data:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(data,0,file.size);
			fileStream.close();
			return data;
		}
		
		public static function upload(file:File, entity:String, gadget_id:String, fnRefresh:Function=null, fnModifiedItem:Function=null,filename:String=null):void {
			var attachment:Object = new Object();
			attachment.entity = entity;
			attachment.gadget_id = gadget_id;
			attachment.data = getContentFile(file);
			if(StringUtils.isEmpty(filename)){
				attachment.filename = file.name;
			}else{
				attachment.filename = filename;	
			}
			  
			attachment.AttachmentId = null;			
			Database.attachmentDao.replaceAttachment(attachment);
			if(fnModifiedItem!=null) fnModifiedItem();
			if(fnRefresh!=null) fnRefresh();
		}
		
		public static function upload_(fileName:String, content:Object, entity:String, gadget_id:String, fnRefresh:Function, fnModifiedItem:Function):void {
			var attachment:Object = new Object();
			attachment.entity = entity;
			attachment.gadget_id = gadget_id;
			attachment.filename = fileName;  
			attachment.data = content;
			attachment.AttachmentId = null;
			attachment.include_in_report = false; //CRO bug fixing 59 02.02.2011
			attachment.deleted = false;
			Database.attachmentDao.replaceAttachment(attachment);
			fnModifiedItem();
			fnRefresh();
		}		
		
		public static function openFile(obj:Object):void {
			var byteArray:ByteArray = new ByteArray();
			var data:Object = obj.data;
			data.position = 0;
			data.readBytes(byteArray, 0, data.length);
			var file:File = writeFile(obj.filename, byteArray);
			if(file!=null) file.openWithDefaultApplication();
		}
		
		public static function writeStringFile(fileName:String, data:String):File {
			try{
				var file:File = File.documentsDirectory.resolvePath(Database.tempFolder.nativePath + "/" + fileName);
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeMultiByte(data, 'utf-8');
				fileStream.close();
				return file;
			}catch(e:Error){
				trace(e.message);
			}
			return null;
		}
		
		public static function instanceAttachmentXML(attachment:Object, operation:String=null):XML{
			var attachmentXML:XML = <Attachment/>;
			if (operation!=null) {
				attachmentXML = <Attachment operation={operation}/>;
			}
			var fileName:String= StringUtils.removeExtension(attachment.filename);
			attachmentXML.appendChild(new XML("<FileNameOrURL>" + fileName+ "</FileNameOrURL>"));
			attachmentXML.appendChild(new XML("<DisplayFileName>" + fileName + "</DisplayFileName>"));
			attachmentXML.appendChild(new XML("<FileExtension>" + StringUtils.getExtension(attachment.filename) + "</FileExtension>"));
			attachmentXML.appendChild(new XML("<Attachment>" + StringUtils.encodeByteArrayToString(attachment.data) + "</Attachment>"));
			return attachmentXML;
		}
		/*		
		public static function instanceUserXML(user:Object):XML{
		var userXML:XML = new XML("<User></User>");
		//userXML.appendChild(new XML("<UserId>" + user.UserId + "</UserId>"));
		userXML.appendChild(new XML("<UserAlias>" + user.Alias + "</UserAlias>"));
		userXML.appendChild(new XML("<UserFirstName>" + user.FirstName + "</UserFirstName>"));
		userXML.appendChild(new XML("<UserLastName>" + user.LastName + "</UserLastName>"));
		userXML.appendChild(new XML("<UserEmail>" + user.EMailAddr + "</UserEmail>"));
		return userXML;
		}		
		*/		
		/*VAHI now in sync.incoming.IncomingInterface.as for new components*/
		public static function incomingAttachment(xml:XML, entity:String, object:Object):void{
			var listAttachment:XML = xml.child("ListOfAttachment")[0];
			var gadget_id:String = Database.getDao(entity).findByOracleId(object[DAOUtils.getOracleId(entity)]).gadget_id;
			
			for each(var attachment:XML in listAttachment.Attachment){
				var attachId:String = attachment.child("Id")[0].toString();
				if(Database.attachmentDao.findByOracleId(attachId,entity)==null){
					if (attachment.child("Attachment").length() > 0) {
						var obj:Object = new Object();
						obj.data = StringUtils.decodeStringToByteArray(attachment.child("Attachment")[0].toString());
						obj.entity = entity;
						obj.gadget_id = gadget_id;
						obj.filename = attachment.child("DisplayFileName")[0].toString();
						// GET Attacment Id do it later
						obj.AttachmentId = attachId;
						Database.attachmentDao.insert(obj);
					}
					
				}
			}
		}
		//*/
		public static function outgoingAttachment(xml:XML, entity:String, array:ArrayCollection):void {
			var listAttachment:XML = xml.child("ListOfAttachment")[0];
			if (listAttachment != null) {
				var i:int=0;
				for each(var attachment:XML in listAttachment.Attachment){
					var object:Object = new Object();
					object.entity = entity;
					object.gadget_id = array[i].gadget_id;
					object.filename = array[i].filename;
					object.AttachmentId = attachment.child("Id")[0].toString();
					Database.attachmentDao.updateAttachmentID(object);
					i += 1;
				}
			}
		}
		
		public static function columnNameIsPickList(value:String, entity:String):Boolean{
			if(value==null) return false;
			var params:ArrayCollection = getColumns(entity);
			for (var i: int = 0; i < params.length; i++) {
				if (value == params[i].column && "Picklist" == params[i].type) {
					return true;
				}
			}
			return false;
		}
		
		public static function getComboColIndex(value:String, entity:String):int {
			var columns:ArrayCollection = getColumns(entity);
			for (var i: int = 0; i < columns.length; i++) {
				if (value == columns[i].column) {
					return i;
				}    
			}
			return 0;
		}
		
		public static function getComboParamIndex(field:String, recordType:String, value:String):int {
			var params:ArrayCollection = PicklistService.getPicklist(recordType, field);
			for (var i: int = 0; i < params.length; i++) {
				if (value == params[i].data) {
					return i;
				}    
			}
			return 0;
		}
		
		public static function isCriteriaCompleted(filterCol:ComboBox, filterOper:ComboBox, filterParam:TextInput, cboFilterParam:ComboBox):Boolean {
			var colName:String = filterCol.selectedItem.column;
			var operator:String = filterOper.selectedItem.data;
			var param:String = filterParam.visible ? filterParam.text : cboFilterParam.selectedItem.data;
			var bParamNotRequired:Boolean = StringUtils.startsWith(operator,"is");
			if(bParamNotRequired){
				if(
					StringUtils.isEmpty(colName) || 
					StringUtils.isEmpty(operator)
				) {
					return false;	
				}else{
					return true;
				}
			}else{
				if(
					StringUtils.isEmpty(colName) || 
					StringUtils.isEmpty(operator) || 
					StringUtils.isEmpty(param)
				){
					return false;
				}else{
					return true;
				}
			}
		}	
		
		/*use this one to write binary file*/
		public static function writeFile(fileName:String, data:ByteArray):File {
			try{
				var file:File = File.documentsDirectory.resolvePath(Database.tempFolder.nativePath + "/" + fileName);
				var f:FileStream = new FileStream();
				f.open( file, FileMode.WRITE );
				f.writeBytes(data);
				f.close();
				return file;
			}catch(e:Error){
				trace(e.message);
			}
			return null;
		}
		
		public static function writeToFile(file:File, data:String):void {
			try{
				var byteArr:ByteArray = new ByteArray();
				byteArr.writeUTFBytes(data);											
				var log:FileStream = new FileStream();
				log.open( file, FileMode.WRITE );
				log.writeBytes(byteArr);
				log.close();
			}catch(e:Error){
				trace(e.message);
			}
		}
		
		public static function writeUTFBytes(file:File, data:String,mode:String =FileMode.WRITE):void {
			try {
				var fs:FileStream = new FileStream();
				fs.open(file, mode);
				fs.writeUTFBytes(data);
				fs.close();
			}catch(e:Error) {
				trace(e.message);
			}
		}
		
		public static function readUTFBytes(file:File):String {
			try {
				var fs:FileStream = new FileStream();
				if(file.exists) {
					fs.open(file, FileMode.READ);
					var data:String = fs.readUTFBytes(fs.bytesAvailable);
					fs.close();
					return data;
				}
			}catch(e:Error) {
				trace(e.message);
			}
			return null;
		}
		
	
		public static function writeObject(file:File, obj:Object):void {
			try {
				var fs:FileStream = new FileStream();
				fs.open(file, FileMode.WRITE);
				fs.writeObject(obj);
				fs.close();
			}catch(e:Error) {
				trace(e.message);
			}
		}
		
		public static function readObject(file:File):Object {
			try {
				var fs:FileStream = new FileStream();
				if(file.exists) {
					fs.open(file, FileMode.READ);
					var obj:Object = fs.readObject();
					fs.close();
					return obj;
				}
			}catch(e:Error) {
				trace(e.message);
			}
			return null;
		}
		
		/**
		 * To show progress bar before loading window, export or import
		 * 
		 * @param handlerFunction
		 * @param title
		 * @param progressLabel
		 * 
		 */
		public static function showLoadingProgressWindow(handlerFunction:Function, progressLabel:String="", title:String="",pwidth:int=200,closeFunction:Function=null):void{
			var loadingIndicator:LoadingIndicator = new LoadingIndicator();
			loadingIndicator.actionFunction = handlerFunction;
			loadingIndicator.title = title;
			loadingIndicator.proWidth=pwidth;
			loadingIndicator.progressLabel = progressLabel;
			loadingIndicator.closeFunction = closeFunction;
			WindowManager.openModal(loadingIndicator);
		}
		
		public static function openDetail(item:Object, mainWindow:MainWindow):void {
			if (item == null) return;
			var entity:String = item.gadget_type;
			//Bug #1728 CRO    //visible task list instead when list show hometask
			var tmpList:List = mainWindow.selectList(entity);
			if(entity == Database.activityDao.entity){
				tmpList.showListTasks();
			}
			
			tmpList.selectItem(Database.getDao(entity).findByGadgetId(item.gadget_id));
		}
		
		public static function htmlEscape(s:String):String {
			return s.replace(/</g, "&lt;").replace(/>/g, "&gt;");
		}
		
		public static function formatEvent(event:Event):String {
			if (event is IOErrorEvent) {
				return htmlEscape((event as IOErrorEvent).text.toString());
			} else if (event is HTTPStatusEvent) { 
				return htmlEscape("HTTP Error " + (event as HTTPStatusEvent).status.toString());
			} else {
				return event.toString();
			}				
		}	
		
		public static function getColumn(entity:String):ArrayCollection {
			var columns:ArrayCollection = Database.columnsLayoutDao.fetchColumns(entity);
			// columns required for the small detail
			var field:Object;
			for each (var element_name:String in FieldUtils.getFieldsDetailAsList(entity)) {
				if (!checkColumn(columns, element_name)) {
					field = new Object();
					field.element_name = element_name;
					columns.addItem(field);
				}
			}	
			// specific columns for Account
			if (entity == 'Account') {
				field = new Object();
				field.element_name = "AccountType";
				columns.addItem(field);
			}
			// specific columns for Contact
			if (entity == 'Contact') {
				field = new Object();
				field.element_name = "ContactType";
				columns.addItem(field);
				field = new Object();
				field.element_name = "picture";
				columns.addItem(field);
			}
			// TILI - ensure ParentActivityId is selected when working on Activities
			if (entity == 'Activity') {
				field = new Object();
				field.element_name = "ParentActivityId";
				
				// remove following line when DB really contains ParentActivityId
				field.element_name = "CustomText31";
				columns.addItem(field);
			}	
			return columns;
		}
		
		private static function checkColumn(columns:ArrayCollection, element_name:String):Boolean{
			var found:Boolean = false;
			for each (var col:Object in columns) {
				if (col.element_name == element_name) {
					found = true;
					break;
				}
			}
			return found;
		}
		
		public static function getNoneLimitedRecords(entity:String, filter:Object, selectedId:String):ArrayCollection {
			var filterQuery:String = FieldUtils.computeFilter(filter);
			var columns:ArrayCollection = getColumn(entity);
			// limited change follow bug 1360
			var noneLimitedRecords:ArrayCollection = Database.getDao(entity).findAll(columns, filterQuery, selectedId, 1000); // zero means no limit
			trace( '>>>>>>>>>>>>>>>>>>>>>>>none limited records: ', (noneLimitedRecords as ArrayCollection).length );
			return noneLimitedRecords;
		}
		
		/**
		 * Used to suppress warning: Unable to bind to property 
		 * @param items
		 * 
		 */
		public static function suppressWarning(items:ArrayCollection):void {
			for(var i:int=0; i<items.length; i++)
			{
				items[i] = new ObjectProxy(items[i]);
			}
		}	
		
		public static function getLabelCountry(countries:ArrayCollection, target:String):String {
			for(var i:int = 0; i < countries.length; i++){
				if(countries.getItemAt(i).data == target || countries.getItemAt(i).label == target) return countries[i].label;
			}
			return "";
		}
		
		public static function copyModel(model:Object):Object {
			var obj:Object = new Object();
			// we copy the values from the a model
			if(model!=null){
				for (var field:String in model) {
					obj[field] = model[field];
				}
			}
			if(obj.ModifiedDate==null){
				//add field modifieddate to obj on creattion
				obj.ModifiedDate = DateUtils.toIsoDate(new Date());//now
			}
			return obj;
		}
		
		public static function copyObject(source:Object,target:Object):void{
			for(var f:String in target){
				source[f]=target[f];
			}
		}
		
		/**
		 * to copy all properties from obj2 to obj1 
		 * @param obj1 is an object which holds all properties
		 * @param obj2 is an object which contains a property to add to obj1
		 * 
		 */
		public static function mergeModel(obj1:Object, obj2:Object):void {
			if(obj1 == null) return;
			if(obj2 == null) return;
			for(var field:String in obj2){
				obj1[field] = obj2[field];
			} 
		}
		
		public static function addRecentlyViewed(item:Object):void
		{
			if(item.gadget_id != null){
				var recentObj:Object = {'entity':item.gadget_type, 'id':item.gadget_id};
				Database.recentDao.insert_recently(recentObj);
			}
		}
		
		public static function getAllFilters(entity:String):ArrayCollection{
			var userOwner:Object =  Database.allUsersDao.ownerUser();
			
			var filterList:ArrayCollection = Database.filterDao.listFiltersCriteria(entity);
			filterList.filterFunction = function (item:Object):Boolean {
				if(item.type == 0) return true; //show All {Entity} predefined filter
				
				// VM --- >  bug #55
				if(item.type == -3 && entity == Database.serviceDao.entity){
					if(UserService.DIVERSEY == UserService.getCustomerId() ){
						return true;
					}else{
						return false;
					}
				}
				if(!Database.preferencesDao.getBooleanValue(PreferencesDAO.ENABLE_MISSING_PDF) && entity == Database.serviceDao.entity){
					if(item.type==Database.MISSING_PDF){
						return false;
					}
				}
				
				if(item.type == Database.FAVORITE){
					return Database.preferencesDao.isEnableFavorite();
				}
				if(item.type == Database.IMPORTANT){
					return Database.preferencesDao.isEanableImportant();
				}
				
				if(item.type == Database.CUSTOMERS){
					return Database.preferencesDao.isEnableCustomers();
				}
				
				if(item.type == Database.COMPETITORS){
					return Database.preferencesDao.isEnableCompetitors();
				}
				
				if(item.predefined == true){
					var bPredefinedFilters:Boolean = Database.preferencesDao.getValue('predefined_filters') == 1 ? true : false; 
					return (bPredefinedFilters && !WSProps.isWS20filter(item.type)); //show predefined filter depend on the value in the prefs table
				}else{
					return true; //show all user filters
				}
			}
			filterList.refresh();
			var filters:ArrayCollection=new ArrayCollection();
			var defaultFilter:Object = Database.filterDao.getDefaultFilter(entity);
			for each (var filter:Object in filterList) {
				var filterName:String = filter.name;
				//CRO #1345
				var translate:Object = userOwner == null ? null : Database.customFilterTranslatorDao.selectFT(filter.entity,filter.name,userOwner.LanguageCode);
				if(translate != null && !StringUtils.isEmpty(translate.displayName)){
					filterName = translate.displayName;
				}
				
				//hid call
				if('GLOBAL_CALLS'==filterName && !Database.preferencesDao.getBooleanValue(PreferencesDAO.ENABLE_BUTTON_ACTIVITY_CREATE_CALL)){
					continue;
				}
				
				filterName = filterName.indexOf('GLOBAL') == -1 ? filterName : i18n._(filterName);
				filter.displayName = filterName.replace(ENTITY, Database.customLayoutDao.getPlural(entity));
				if(filter.type==defaultFilter.type){
					filter.isDefault=true;
				}else{
					filter.isDefault=false;
				}
				filters.addItem(filter);
			}
			suppressWarning(filters);
			return filters;
		}
		public static function parseCurrency(currencyCode:String, cols:Object, datasource:ArrayCollection):void{
			
			for each(var objectField:Object in cols.fields){
				if(objectField.data_type.indexOf("Currency") != -1){
					for each(var obj:Object in datasource){
						var value:String = obj[objectField.element_name];
						if( value != null && currencyCode != null && currencyCode != ""){
							//obj[objectField.element_name] = currencyCode + " " + value;
							obj[objectField.element_name] = CurrencyUtils.format(value, currencyCode);
						} 
						if(objectField.element_name == "Cost")
						obj["CostValue"] = value;
					}
				}
			}
		}
		public static function parseDateTime(entity:String, columns:ArrayCollection, datasource:ArrayCollection):void {
			var parseColumns:ArrayCollection = new ArrayCollection();
			for each(var column:Object in columns){
				var fieldInfo:Object = FieldUtils.getField(entity,column.element_name);
				if (fieldInfo != null) {
					if(fieldInfo.data_type == 'Date'){
						parseColumns.addItem({'ColumnName':column.element_name, 'isDateTime': false});
					}else if(fieldInfo.data_type == 'Date/Time'){
						parseColumns.addItem({'ColumnName':column.element_name, 'isDateTime': true});
					}
					
				}
				
			}
			
			if (parseColumns.length == 0) {
				return;
			}
			
			//{locale: "Chinese - Singapore", dateFormat: "DD/M/YYYY", timeFormat: "KK:NN:SS A"} 
			var currentUserDatePattern:Object = DateUtils.getCurrentUserDatePattern();
			for each(var record:Object in datasource){
				if(record.modified != null){
				   record.modified = i18n._(record.modified);
				}
				//Generate new field (Currency + Revenue) #1253 CRO
				if( entity == Database.opportunityDao.entity && !StringUtils.isEmpty(record.Revenue) && record.CurrencyCode != null){
					record.Revenue_sorting = record.Revenue;
					record.Revenue =  record.CurrencyCode + " " + record.Revenue;
				}
				for each(var parseColumn:Object in parseColumns){
					var fieldValue:String = record[parseColumn.ColumnName];	
					var date:Date = DateUtils.guessAndParse(fieldValue);
					if(date!=null){
						date = new Date(date.getTime()+DateUtils.getCurrentTimeZone(date)*GUIUtils.millisecondsPerHour);
						var format:String = currentUserDatePattern.dateFormat + ( parseColumn.isDateTime ? ' ' + currentUserDatePattern.timeFormat : '' );
						var displayValue:String = DateUtils.format(date, format);
						record[parseColumn.ColumnName] = displayValue;
					}else{
						record[parseColumn.ColumnName] = '';
					}
						
				}
			}
		}
		
		public static function parsePicklistValues(entity:String, columns:ArrayCollection, datasource:ArrayCollection):void {
			var parseColumns:ArrayCollection = new ArrayCollection();
			var piclistServiceAll:Object = new Object();
			for each(var column:Object in columns){
				var fieldInfo:Object = FieldUtils.getField(entity,column.element_name);
				if (fieldInfo != null) {
					if(fieldInfo.data_type == 'Picklist' || fieldInfo.data_type == 'Multi-Select Picklist'){ // Change Request #460
						parseColumns.addItem({'ColumnName':column.element_name});
						//var piclistService:ArrayCollection = PicklistService.getPicklist(entity,column.element_name);
						var piclistService:ArrayCollection;
						if(fieldInfo.element_name == "Industry")
							piclistService = Database.industryDAO.getIndustrylists(LocaleService.getLanguageInfo().LanguageCode);
						else 
							piclistService = PicklistService.getPicklist(entity,column.element_name);
						if (piclistService.length > 1) {
							for each(var obj:Object in piclistService){
								piclistServiceAll[column.element_name + "/" + obj.data] = obj.label;
							}
						}
					}
				}
			}
			if (parseColumns.length > 0) {
				for each(var record:Object in datasource){
					for each(var parseColumn:Object in parseColumns){
						var displayValue:String = piclistServiceAll[parseColumn.ColumnName + "/" + record[parseColumn.ColumnName]];
						if (displayValue == null || displayValue=="") {
							// Change Request #460
							if((parseColumn.ColumnName as String).indexOf("CustomMultiSelectPickList") != -1 && record[parseColumn.ColumnName]) {
								var i:int = 0; displayValue = "";
								var str_split:String = record[parseColumn.ColumnName].toString().indexOf(";") !=-1 ? ";" : ",";
								for each(var data:String in record[parseColumn.ColumnName].toString().split(str_split)) {
									displayValue += i==0 ? piclistServiceAll[parseColumn.ColumnName + "/" + com.adobe.utils.StringUtil.trim(data)] : "," + piclistServiceAll[parseColumn.ColumnName + "/" + com.adobe.utils.StringUtil.trim(data)];
									i++;
								}
							}else {
								// bug #329
								displayValue = record[parseColumn.ColumnName];
							}
						};
						//Mony Change Request #226
						if((String(record[oidName]).indexOf("#")==-1) && (entity=="Service Request")&& Database.preferencesDao.getBooleanValue(PreferencesDAO.ENABLE_SR_SYNC_ORDER_STATUS)){
							var oidName:String = DAOUtils.getOracleId(entity);
							//if(record.CustomPickList10 == "STND" || record.CustomPickList10 == "ACPT"){
							if(!record.isAccept){
								record.isAccept=true;
							}
							
							//} 							
						}
						record[parseColumn.ColumnName + "Value" ] = displayValue;
					}
				}
			}
			
		}
		
		public static function copyToClipboard(text:String, mainWindow:MainWindow):void {
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, text, false);
			Alert.show(i18n._('UTILS_ALERT_TEXT_ACCOUNT_ADDRESS_HAS_BEEN_COPY_TO_CLIPBOARD'), "", 4, mainWindow);
		}
		
		public static function sendContactEmail(email:String, subject:String, body:String, subtype:int=0):void {
			var url:String = "mailto:" + email + "?subject=" + (subject == "" ? " " : encodeURI(subject)) + "&body=" + (body == "" ? " " : encodeURI(body));
			switch(subtype) {
				case 0: // Without Template
					openURL(url, '_blank');
					break;
				case 1: // All Template
					break;
				case 2: // Sales
					break;
				default: // Marketing
					break;
			}
		}
		
		public static function importConfig(xml:XML,prefsXMLList:Function=null,mapValueWithControls:Function=null,reload:Function=null,dialog:Window=null):void{
			var strV:String = checkNullValue(xml.elements("application-version"),"0");
			strV = strV.replace(".","");
			var vN:int = parseInt(strV);
			if(vN<=1322){//old xml if version less than 1.322
				importOldConfig(xml,prefsXMLList,mapValueWithControls,reload,dialog);
				return;
			}
			
			
			if(dialog != null)dialog.close();
			Database.begin();
			//xml.toString()
			// Industry
			Database.industryDAO.delete_all(); // delete all industry
			// insert new industry
			var industriesList:XMLList = xml.elements("industries");
			for each(var industries:XML in industriesList) {
				var language_code:String = industries.@language;
				for each(var industry:XML in industries.industry) {
					var industryObject:Object = new Object();
					industryObject.enable = checkNullValue(industry.elements("enable"), "");
					industryObject.display_name = checkNullValue(industry.elements("display_name"), "");
					industryObject.sic_code = checkNullValue(industry.elements("sic_code"), "");
					industryObject.language_code = checkNullValue(language_code, "");
					Database.industryDAO.insert(industryObject);
				}
			}
			
			//---------------------- TCS Report Admin ----------------------------------------
			if(UserService.getCustomerId() == UserService.DIVERSEY) {				
				var reportAdminList:XMLList = xml.elements("report_admins");
				Database.reportAdminChildDao.delete_all();
				for each(var reportXML:XML in reportAdminList) {
					var report:Object = new Object();
					report.report_path = checkNullValue(reportXML.elements("report_path"), "");
					report.type = checkNullValue(reportXML.elements("type"), "");
					Database.reportAdminDao.insert(report);
					for each(var childReportXML:XML in reportXML.report) {
						var childReport:Object = new Object();
						childReport.report_name = checkNullValue(childReportXML.elements("report_name"), "");
						childReport.report_code = checkNullValue(childReportXML.elements("report_code"), "");
						Database.reportAdminChildDao.insert(childReport);
					}
				}
			}
			
			var app_name:String ="";
			for each(var app:XML in xml.children()){
				if(app.localName() != null && "application-name"==app.localName().toString()){
					app_name = checkNullValue(app.children()[0],"");
					Database.preferencesDao.setValue("application_name",app_name,false);
					break;
				}
				
			}
			var encriptPWD:String = "";
			// Preference
			var prefs:XMLList = xml.elements("prefs");
			for each(var pref:XML in prefs.pref){
				// bug # 183 
				//var prefValue:String = checkNullValue(pref.children()[0], "");
				// Change Request #184
				
				var prefValue:String = checkNullValue(pref.children()[0], pref.@key!="update_url" ? "" : "http://desktop.crm-gadget.com/update.xml");
				//update password database from xml file
				if(pref.@key == PreferencesDAO.DATABASE_PASSWORD ) {
					encriptPWD = prefValue;
				}
				if(pref.@key == "start_at_login") Utils.setStartAtLogin(prefValue == "true" ? true : false);
				Database.preferencesDao.setValue(pref.@key, prefValue=="true"? 1: prefValue=="false"? 0 : prefValue,false);
			}
			
			var relatedBtns:XMLList = xml.elements(Preferences.RELATED_BUTTONS_DISABLE);
			for each(var trans:XML in relatedBtns.related_disable_button){
				var relatedBtn:Object = new Object();
				relatedBtn.parent_entity = checkNullValue(trans.elements("parent_entity").children()[0].toString(),"");
				relatedBtn.entity = checkNullValue(trans.elements("entity").children()[0].toString(),"");
				relatedBtn.disable = "true" == checkNullValue(trans.elements("disable").children()[0].toString(),"") ? 1 : 0;
				Database.relatedButtonDao.upsert(relatedBtn);
			}
			
			var transactions:XMLList = xml.elements("transactions");
			var isDelete:Boolean=true;
			for each(var transaction:XML in transactions.transaction){
				var transactionObject:Object = new Object();
				transactionObject.entity = transaction.id.children()[0].toString();
				transactionObject.enabled = transaction.enabled.children()[0].toString()=="true"?1:0;
				transactionObject.display_name = "";
				transactionObject.filter_id = checkNullValue(transaction.filter.children()[0],"");
				transactionObject.parent_entity = checkNullValue(transaction.elements("parent_entity").children()[0],"");
				transactionObject.default_filter = checkNullValue(transaction.elements("default-filter").children()[0],"-1"); //CRO 1588
				// transactionObject.sync_ws20 = transaction.elements("sync-ws20").children()[0].toString()=="true"? 1 : 0;
				if(transaction.hasOwnProperty("sync-activities") || transaction.hasOwnProperty("sync-attachments") ){
					transactionObject.sync_activities = checkNullValue(transaction.elements("sync-activities").children()[0],"")=="true"? 1 : 0;
					transactionObject.sync_attachments = checkNullValue(transaction.elements("sync-attachments").children()[0],"")=="true"? 1 : 0;
					Database.subSyncDao.updateEnabledAll( transactionObject.entity,0);
					var objChildAct:Object = new Object();
					var enabled:int = transactionObject.sync_activities;
					objChildAct["entity"] = transactionObject.entity;
					objChildAct["sub"] = "Activity";
					objChildAct["sodname"] = "Activity";
					objChildAct["enabled"] = enabled;
					Database.subSyncDao.updateEnabled(objChildAct);
					
					var objChild:Object = new Object();
					objChild["entity"] = transactionObject.entity;
					objChild["sub"] = "Attachment";
					objChild["sodname"] = "Attachment";
					objChild["enabled"] = transactionObject.sync_attachments;
					Database.subSyncDao.updateEnabled(objChild);
				}
				if(transaction.hasOwnProperty("sync-children")){
					if(isDelete){
						Database.subSyncDao.delete_all();
						isDelete = false;
					}
					var listSyncChildren:XMLList = transaction.elements("sync-children");
					commitObjects(Database.subSyncDao,listSyncChildren.children(),false,function(subObj:Object):void{
						if(subObj.entity_name=='Account.Objectives'){//may be use old xml 
							subObj.entity_name = 'Objectives';
						}else {
							subObj.entity_name = Database.getSubEntityName(subObj.entity,subObj.sub,subObj.sodname);
						}
						subObj.syncable=Database.getSubSyncable(subObj.entity,subObj.entity_name);
						if(StringUtils.isEmpty(subObj.entity_name)){
							subObj.entity_name = Database.getSubEntityName(subObj.entity,subObj.sub,subObj.sodname);
						}
						
					});
					
//					Database.subSyncDao.updateEnabledAll( transactionObject.entity,0);
//					for each(var childSync:XML in listSyncChildren.children()){
//						var objSyncChld:Object = new Object();
//						objSyncChld["entity"] = transactionObject.entity;
//						objSyncChld["sub"] = childSync.toString();
//						objSyncChld["enabled"] = 1;
//						Database.subSyncDao.updateEnabled(objSyncChld);
//					}					
				}
				transactionObject.hide_relation = checkNullValue(transaction.elements("hide-relation").children()[0],"")=="true"? 1 : 0;
				transactionObject.read_only = checkNullValue(transaction.elements("read-only").children()[0],"")=="true"? 1 : 0;
				transactionObject.display = checkNullValue(transaction.elements("display").children()[0],"true")=="true"? 1 : 0;
				transactionObject.authorize_deletion = checkNullValue(transaction.elements("authorize-deletion").children()[0],"")=="true"? 1 : 0;
				
				// #311: hange request - Diversey sales - Prefernces -> #41: Cannot load VETO.XML
				transactionObject.filter_disable = checkNullValue(transaction.elements("filter-disable").children()[0], "")=="true"? 1 : 0;
				transactionObject.read_only_disable = checkNullValue(transaction.elements("read-only-disable").children()[0], "")=="true"? 1 : 0;
				
				//transactionObject.sync_activities_disable = checkNullValue(transaction.elements("sync-activities-disable").children()[0], "")=="true"? 1 : 0;
				//transactionObject.sync_attachments_disable = checkNullValue(transaction.elements("sync-attachments-disable").children()[0], "")=="true"? 1 : 0;
				
				transactionObject.authorize_deletion_disable = checkNullValue(transaction.elements("authorize-deletion-disable").children()[0], "")=="true"? 1 : 0;
				transactionObject.entity_disable = checkNullValue(transaction.elements("entity-disable").children()[0], "")=="true"? 1 : 0;				
				transactionObject.sync_order=checkNullValue(transaction.elements("sync_order").children()[0], getDefaultSyncOrder(transactionObject.entity));
				transactionObject.rank=checkNullValue(transaction.elements("rank").children()[0], Database.getDefatultRank(transactionObject.entity));
				transactionObject.advanced_filter = checkNullValue(transaction.elements("advanced_filter").children()[0],'1');
				Database.transactionDao.updateAllFields(transactionObject);
				if(mapValueWithControls!=null)
					mapValueWithControls(transactionObject);
			}
			
//			var tagCustomName:String = "custom-layout";
//			if(xml.toString().indexOf("detail-layout")>0) tagCustomName = "detail-layout";
//			var customLayoutXMLList:XMLList = xml.elements(tagCustomName +  "s");
//			// var customLayoutXMLList:XMLList = xml.elements("custom-layouts");
//			// delete all entity on custom layout
//			for each(var obj:Object in Database.customLayoutDao.readAll()){
//				if(obj.deletable){
//					//Database.layoutDao.deleteLayout(obj.entity,obj.subtype);
//					Database.customLayoutDao.delete_(obj.entity,obj.subtype);
//					Database.customLayoutConditionDAO.deleted(obj.entity,obj.subtype);
//				}
//			}
//			for each(var customLayoutXML:XML in customLayoutXMLList.elements(tagCustomName)){
//				var customLayout:Object = new Object();
//				var customLayoutEntity:String = customLayoutXML.elements("entity").children()[0];
//				var subtype:int = int(customLayoutXML.elements("subtype").children()[0]);
//				// Delete records detail layout by entity
//				//Database.layoutDao.deleteLayout(customLayoutEntity, subtype);
//				Database.customLayoutDao.delete_(customLayoutEntity, subtype);
//				Database.customLayoutConditionDAO.deleted(customLayoutEntity, String(subtype));
//				
//				customLayout.entity = customLayoutEntity;
//				customLayout.subtype = subtype;
//				
//				customLayout.background_color = customLayoutXML.elements("color").children()[0]==null? 0xEEEEEE :customLayoutXML.elements("color").children()[0];
//				customLayout.custom_layout_icon = customLayoutXML.elements("icon").children()[0];
//				customLayout.layout_name = checkNullValue(customLayoutXML.elements("layout-name").children()[0],customLayoutEntity);
//				customLayout.display_name = checkNullValue(customLayoutXML.elements("display-name").children()[0], ""); // Bug #73
//				customLayout.display_name_plural = checkNullValue(customLayoutXML.elements("display-name-plural").children()[0], "");
//				customLayout.deletable = customLayoutXML.elements("deletable").children()[0].toString() == 'true' ? 1 : 0;
//				customLayout.field = customLayoutXML.elements("field").children()[0];
//				customLayout.operator = checkNullValue(customLayoutXML.elements("operator").children()[0], "");
//				customLayout.value = checkNullValue(customLayoutXML.elements("value").children()[0],"");
//				customLayout.layout_depend_on = checkNullValue(customLayoutXML.elements("layout_depend_on").children()[0],"");
//				customLayout.custom_layout_title = checkNullValue(customLayoutXML.elements("custom-layout-title").children()[0], ""); // Change Request #747
//				
//				var objectCondition:Object;
//				// specific code to handle v1.080 condition format
//				if (customLayout.field != null && customLayout.deletable == true) {
//					objectCondition = new Object();
//					objectCondition.entity = customLayoutEntity;
//					objectCondition.subtype = String(subtype);
//					objectCondition.num = "1";
//					objectCondition.column_name = customLayout.field;
//					objectCondition.operator = customLayout.operator;
//					objectCondition.params = customLayout.value;
//					
//					Database.customLayoutConditionDAO.insert(objectCondition);
//				}
//				
//				Database.customLayoutDao.insert(customLayout);
//				
//				// layout fields
////				for each(var fieldDetail:XML in customLayoutXML.fields.children()){
////					var detailLayout:Object = new Object();
////					
////					detailLayout.entity = customLayoutEntity;
////					detailLayout.subtype = subtype;
////					detailLayout.col = int(fieldDetail.col.children()[0].toString());
////					detailLayout.row = int(fieldDetail.row.children()[0].toString());
////					detailLayout.column_name = fieldDetail.elements("column-name")[0].children()[0].toString();
////					detailLayout.custom = fieldDetail.custom.children()[0];
////					detailLayout.readonly = fieldDetail.readonly.children()[0]==null?0:fieldDetail.readonly.children()[0].toString()=="true"?1:0;
////					detailLayout.mandatory = fieldDetail.mandatory.children()[0]==null?0:fieldDetail.mandatory.children()[0].toString()=="true"?1:0;
////					var val:String=checkNullValue(fieldDetail.elements("max_chars").children()[0]);
////					detailLayout.max_chars =  val;
////					Database.layoutDao.insert(detailLayout);
////					
////					/*var customFieldXML:XML = fieldDetail.elements("custom-field")[0];
////					if(customFieldXML && (detailLayout.column_name.indexOf(CustomLayout.CALCULATED_CODE)>-1)){
////					var customField:Object = new Object();
////					customField["entity"] = customLayoutEntity;
////					customField["column_name"] = detailLayout.column_name;
////					customField["subtype"] = detailLayout.subtype;
////					customField["fieldName"] = checkNullValue(customFieldXML.fieldName.children()[0],"");
////					customField["displayName"] = checkNullValue(customFieldXML.displayName.children()[0],"");
////					customField["fieldType"] = checkNullValue(customFieldXML.fieldType.children()[0],"");
////					customField["value"] = checkNullValue(customFieldXML.value.children()[0],"");
////					Database.customFieldDao.insert(customField);								
////					}*/
////				}
//				
//				// custom fields
//				// var customFieldXMLList:XML = customLayoutXML.elements("custom-fields").children();
//				var _cache_cascading_crm:CacheUtils = new CacheUtils("cascading_crm");
//				var _cache_customField:CacheUtils = new CacheUtils("customField");
//				_cache_customField.del(customLayoutEntity);
//				_cache_cascading_crm.del(customLayoutEntity);
//				for each(var customFieldXML:XML in customLayoutXML.elements("custom-fields").children()){
//					var columnName:String = checkNullValue(customFieldXML.elements("column-name")[0],"");					
//					var objCustomField:Object = new Object();
//					var currentEntity:String = customLayoutEntity;
//					if(customFieldXML.entity!=null && customFieldXML.entity.children()!=null){
//					      var et:String = 	checkNullValue(customFieldXML.entity.children()[0]);
//						  if(!StringUtils.isEmpty(et)){
//							  currentEntity = et;
//						  }
//					}
//					objCustomField["entity"] = currentEntity;
//					objCustomField["column_name"] = columnName;
//					objCustomField["subtype"] = checkNullValue(customFieldXML.subtype.children()[0]);
//					objCustomField["fieldName"] = checkNullValue(customFieldXML.fieldName.children()[0]);
//					objCustomField["displayName"] = checkNullValue(customFieldXML.displayName.children()[0]);
//					objCustomField["fieldType"] = checkNullValue(customFieldXML.fieldType.children()[0]);
//					objCustomField["value"] = checkNullValue(customFieldXML.value.children()[0]);
//					objCustomField["defaultValue"] = checkNullValue(customFieldXML.defaultValue.children()[0])=="true"?1:0;
//					objCustomField["bindField"] = checkNullValue(customFieldXML.bindField.children()[0]);
//					objCustomField["bindValue"] = checkNullValue(customFieldXML.bindValue.children()[0]);
//					objCustomField["parentPicklist"] = checkNullValue(customFieldXML.parentPicklist.children()[0]);
//					
//					objCustomField["field_copy"] = checkNullValue(customFieldXML.fieldCopy.children()[0]);
//					objCustomField["sum_field_name"] = checkNullValue(customFieldXML.sumFieldName.children()[0]);
//					objCustomField["sum_entity_name"] = checkNullValue(customFieldXML.sumEntityName.children()[0]);
//					objCustomField["relation_id"] = checkNullValue(customFieldXML.relationId.children()[0]);
//					
//					Database.customFieldDao.deleteCustomField(objCustomField);
//					Database.customFieldDao.insert(objCustomField);
//					// create new column on table entity
//					if(objCustomField.column_name.indexOf(CustomLayout.CUSTOMFIELD_CODE)>-1){
//						Database.customFieldDao.addTableColumn(objCustomField.entity,objCustomField.fieldName,"TEXT");
//					}
//					
//					
//					// var translatorXML:XML = customFieldXML.elements("translators")[0];
//					Database.customFieldTranslatorDao.deleteFieldByColumnName(customLayoutEntity,columnName);
//					for each(var translator:XML in customFieldXML.translators.children()){
//						var objTranslator:Object = new Object();
//						objTranslator.entity = customLayoutEntity;
//						objTranslator.column_name = objCustomField.column_name;
//						objTranslator.fieldName = objCustomField.fieldName;
//						objTranslator.displayName = checkNullValue(translator.displayName.children()[0],"");
//						objTranslator.languageCode = checkNullValue(translator.languageCode.children()[0],"");
//						objTranslator.value = checkNullValue(translator.value.children()[0],"");
//						objTranslator.bindValue = checkNullValue(translator.bindValue.children()[0],"");
//						
//						Database.customFieldTranslatorDao.insert(objTranslator);
//					}
//					
//					if(objCustomField.column_name.indexOf(CustomLayout.BINDPICKLIST_CODE)>-1){
//						PicklistService.getPicklist(objCustomField.entity,objCustomField.fieldName,true,true,true);
//						PicklistService.getBindPicklist(objCustomField.entity,objCustomField.fieldName,true,true);			
//					}
//				}
//				
//				// import table sql_filter_criteria
//				// {entity_src: "", list_name: "", entity_dest: "", column_name: "", operator: "", param: "", conjunction: "", columns: "", num: ""}
//				Database.sqlListDAO.delete_({entity_src: customLayoutEntity});
//				for each(var iCriteriaXML:XML in customLayoutXML.elements("sql-filter-criterias").children()){			
//					var iCriteria:Object = new Object();
//					iCriteria.entity_src = checkNullValue(iCriteriaXML.entity_src.children()[0]);
//					iCriteria.list_name = checkNullValue(iCriteriaXML.list_name.children()[0]);
//					iCriteria.entity_dest = checkNullValue(iCriteriaXML.entity_dest.children()[0]);
//					iCriteria.column_name = checkNullValue(iCriteriaXML.column_name.children()[0]);
//					iCriteria.operator = checkNullValue(iCriteriaXML.operator.children()[0]);
//					iCriteria.param = checkNullValue(iCriteriaXML.param.children()[0]);
//					iCriteria.conjunction = checkNullValue(iCriteriaXML.conjunction.children()[0]);
//					iCriteria.columns = checkNullValue(iCriteriaXML.columns.children()[0]);
//					iCriteria.num = checkNullValue(iCriteriaXML.num.children()[0]);
//					Database.sqlListDAO.insert(iCriteria);
//				}				
//				
//				// layout conditions
//				for each(var condition:XML in customLayoutXML.conditions.children()){
//					objectCondition = new Object();
//					objectCondition.entity = customLayoutEntity;
//					objectCondition.subtype = String(subtype);
//					objectCondition.num = int(condition.num.children()[0].toString());
//					objectCondition.column_name = checkNullValue(condition.elements("column-name")[0].children()[0],"");
//					objectCondition.operator = checkNullValue(condition.operator.children()[0],"");
//					objectCondition.params = checkNullValue(condition.param.children()[0],"");
//					
//					Database.customLayoutConditionDAO.insert(objectCondition);
//				}
//			}
			
			// List Layout
			// entity, num, element_name
			var listLayouts:XMLList = xml.elements("list-layouts");
			for each(var listLayout:XML in listLayouts.elements("list-layout")){
				var entityListLayout:String = listLayout.children()[0];
				// Delete records list layout by entity
				//VAHI: done
				Database.columnsLayoutDao.deleteEntity(entityListLayout);
				for each(var fieldList:XML in listLayout.fields.children()){
					var objectList:Object = new Object();
					objectList.entity = entityListLayout;
					objectList.num = int(fieldList.num.children()[0].toString());
					objectList.element_name = checkNullValue(fieldList.elements("element-name")[0].children()[0],"");
					objectList.filter_type = "Default";
					if (fieldList.elements("filter-type").length()>0) {
						objectList.filter_type = checkNullValue(fieldList.elements("filter-type")[0].children()[0],"");	
					}
					Database.columnsLayoutDao.insert(objectList);
				}
			}
			
			// View Layout
			// entity, num, element_name
			var viewLayouts:XMLList = xml.elements("view-layouts");
			for each(var viewLayout:XML in viewLayouts.elements("view-layout")){
				var entityViewLayout:String = viewLayout.children()[0];
				// Delete records view layout by entity
				Database.viewLayoutDAO.deleteEntity(entityViewLayout);
				for each(var fieldView:XML in viewLayout.fields.children()){
					var objectView:Object = new Object();
					objectView.entity = entityViewLayout;
					objectView.num = int(fieldView.num.children()[0].toString());
					objectView.element_name = checkNullValue(fieldView.elements("element-name")[0].children()[0],"");
					Database.viewLayoutDAO.insert(objectView);
				}
			}
			
			// Validation Rule
			// entity, num, rule_name, field, operator, value, message
			var validationRules:XMLList = xml.elements("validationRules");
			for each(var validationRule:XML in validationRules.elements("validationRule")){
				var entityValidationRule:String = validationRule.children()[0];
				Database.validationDao.deleteAll(entityValidationRule);
				for each(var fieldValidation:XML in validationRule.fields.children()){
					var objectValidation:Object = new Object();
					objectValidation.entity = entityValidationRule;
					objectValidation.num = int(fieldValidation.num.children()[0].toString());
					objectValidation.rule_name = checkNullValue(fieldValidation.elements("rule-name")[0].children()[0],"");
					objectValidation.field = fieldValidation.field.children()[0].toString();
					objectValidation.operator = checkNullValue(fieldValidation.operator.children()[0],"");
					objectValidation.value = checkNullValue(fieldValidation.value.children()[0],"");
					objectValidation.message = fieldValidation.message.children()[0];
					Database.validationDao.insertValidation(objectValidation);
				}
			}
			
			// Validation Rule_ 2
			var validationRules_2:XMLList = xml.elements("validation-rules_2");
			for each(var valRule2:XML in validationRules_2.elements("validation-rule")){
				var entityValRule2:String = valRule2.children()[0];
				for each(var rule:XML in valRule2.rules.children()){
					var objValRule2:Object = new Object();
					objValRule2.entity = entityValRule2;
					objValRule2.ruleName = checkNullValue(rule.ruleName.children()[0],"");
					objValRule2.active = checkNullValue(rule.active.children()[0],"")=="true"?1:0;
					objValRule2.value = checkNullValue(rule.value.children()[0],"");
					objValRule2.message = checkNullValue(rule.message.children()[0]);
					objValRule2.errorMessage = checkNullValue(rule.errorMessage.children()[0]);
					objValRule2.orderNo = parseInt(checkNullValue(rule.orderNo.children()[0]));
					
					Database.validationRuleDAO.upSert(objValRule2);
				}
			}
			// Validation rule translator //
			var validationTranslator:XMLList = xml.elements('validation-rules_translator');
			for each(var tranXML:XML in validationTranslator.elements('validation-translator')){
				var entityTran:String = tranXML.children()[0];
				for each(var valTran:XML in tranXML.translators.children()){
					var objTrans:Object = new Object();
					objTrans.entity = entityTran;
					objTrans.ruleName = checkNullValue(valTran.ruleName.children()[0],"");
					objTrans.errorMessage = checkNullValue(valTran.errorMessage.children()[0]);
					objTrans.languageCode = checkNullValue(valTran.languageCode.children()[0]);
					Database.validationRuleTranslotorDAO.updateField(objTrans);
				}
			}
			
			// Filter and Filter Criteria
			// id, name, entity
			//id, num, column_name, operator, param, conjunction
			var filters:XMLList = xml.elements("filters");
			var first:Boolean = true;
			for each(var filter:XML in filters.elements("filter")){
				var entityFilter:String = filter.children()[0];
				//restrict delete no object filter in transactions
				Database.filterDao.deleteByEntity(entityFilter);
				if (first) {
					//VAHI moved this here to be able to import incomplete XML
					//restrict delete no object filter in transactions
					//Database.filterDao.deleteAll();
					Database.criteriaDao.deleteAll();
					first	= false;
				}
				
				for each(var fieldFilter:XML in filter.elements("field")){
					var objectFilter:Object = new Object();
					objectFilter.entity = entityFilter;
					objectFilter.name = fieldFilter.children()[0].toString();
					objectFilter.predefined = fieldFilter.predefined.children()[0].toString()=="true"? 1 : 0;
					objectFilter.type = fieldFilter.type.children()[0];
					var filterId:Number = Database.filterDao.insert(objectFilter);
					
					for each(var criteria:XML in fieldFilter.elements("criteria-field")){
						var objectCriteria:Object = new Object();
						objectCriteria.id = filterId;
						objectCriteria.num = int(criteria.num.children()[0].toString());
						objectCriteria.column_name = checkNullValue(criteria.elements("column-name")[0],"");
						// if(criteria.operator.children()[0]!=null)
						// objectCriteria.operator = criteria.operator.children()[0].toString()=="&gt;"?">":criteria.operator.children()[0].toString()=="&lt;"? "<":criteria.operator.children()[0].toString();
						objectCriteria.operator = checkNullValue(criteria.operator.children()[0],"");
						objectCriteria.param = checkNullValue(criteria.param.children()[0],"");
						objectCriteria.conjunction = checkNullValue(criteria.conjunction.children()[0],"");
						//objectCriteria.param_display = checkNullValue(criteria.elements("param-display")[0],"");
						
						Database.criteriaDao.insert(objectCriteria);
					}
				}
			}
			//refreshMainWindow = true;
			Database.commit();
			
			//Update database password and config file
		    var pwd:String = Database.preferencesDao.getValue(PreferencesDAO.DATABASE_PASSWORD) as String;
			
			if(Utils.decryptPassword(encriptPWD) != pwd){
				Database.changePasswordDatabase(pwd);
				InitDbLocation.writeToConfigFile(Database.getCustomDatabasePathFromFile(),Utils.encryptPassword(pwd));
			}
			if(prefsXMLList!=null)
				prefsXMLList(prefs);
			//import role and access profile
			var dao:SimpleTable=Database.accessProfileServiceDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("access_profiles").children());			
			
			
			dao=Database.accessProfileServiceEntryDao;
			dao.delete_all();
//			var root:XMLList=xml.elements("access_profiles_entrys").children();
//			for each(var child:XML in root){
//				commitObjects(dao,child.children());
//			}
			
			commitObjects(dao,xml.elements("access_profiles_entrys").children());
			
			dao=Database.accessProfileServiceTransDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("access_profiles_trans").children());
			
			dao=Database.subColumnLayoutDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("sublist-layouts").children());
			
			dao = Database.roleServiceDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("role_services").children());			
			
			dao = Database.roleServiceAvailableTabDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("role_services_avail_tab").children());
			
			
			dao = Database.roleServiceLayoutDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("role_services_layout").children());
			
			dao = Database.roleServicePageLayoutDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("role_services_page").children());			
			
			dao = Database.roleServicePrivilegeDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("role_services_priv").children());
			
			dao = Database.roleServiceSelectedTabDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("role_services_sel_tab").children());
			
			dao = Database.roleServiceTransDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("role_services_trans").children());
			
			
			dao = Database.roleServiceRecordTypeAccessDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("role_services_type").children());
			
			dao=Database.customRecordTypeTranslationsDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("custom_records_type_trans").children());
			
			dao=Database.fieldManagementServiceDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("field_managements").children());
			
			dao=Database.fieldTranslationDataDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("field_translations").children());
			
			//---------------------- Territory Tree ---------------------------------------
			dao=Database.territoryTreeDAO;
			dao.delete_all();
			commitObjects(dao,xml.elements("territorytree").children());
			
			//---------------------- Depthstructure Tree ----------------------------------------
			dao=Database.depthStructureTreeDAO;
			dao.delete_all();
			commitObjects(dao,xml.elements("depthstructuretree").children());
			//Filter Translation
			//---------------------- Depthstructure Tree ----------------------------------------
			dao=Database.customFilterTranslatorDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("filter_translations").children());
			
			dao=Database.assessmentDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("assessments").children());
			
			
			dao=Database.answerDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("answers").children());
			dao=Database.assessmentConfigDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("assessment_configs").children());
			
			dao = Database.assessmentPageDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("assessmentPages").children());
				
			dao = Database.mappingTableSettingDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("assessmentMappingColumns").children());
			
			
			dao = Database.assessmentMappingDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("assessmentMappings").children());
			
			//------------ assessment script
			dao=Database.questionDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("questions").children());
			
			dao = Database.sumFieldDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("assessmentsumfields").children());
			
			
			dao = Database.assessmentSplitterDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("assessmentspliters").children());
			
			
			dao = Database.assessmentPDFHeaderDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("assessmentpdfheaders").children())
				
			//detail layou
			dao = Database.layoutDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("detail_layouts").children());
			
			dao = Database.customLayoutDao;
			dao.delete_all();
			new CacheUtils("Custom_Layout").clear();
			commitObjects(dao,xml.elements("custom_layouts").children());
			//clear cache
			new CacheUtils("cascading_crm").clear();
			new CacheUtils("customField").clear();
			dao = Database.customFieldDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("custom_fields").children(),true,function(obj:Object):void{
				if(obj.column_name.indexOf(CustomLayout.CUSTOMFIELD_CODE)>-1){
						Database.customFieldDao.addTableColumn(obj.entity,obj.fieldName,"TEXT");
						if(obj.fieldType=='Formula') CalculatedField.refreshFormulaField(obj,false);
				}
				
				if(obj.column_name.indexOf(CustomLayout.BINDPICKLIST_CODE)>-1){
					PicklistService.getPicklist(obj.entity,obj.fieldName,true,true,true);
					PicklistService.getBindPicklist(obj.entity,obj.fieldName,true,true);			
				}
				
			});			
			dao = Database.customFieldTranslatorDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("custom_field_trans").children());
			
			dao = Database.sqlListDAO;
			dao.delete_all();
			commitObjects(dao,xml.elements("sql_filter_criterias").children());
			
			
			dao = Database.customLayoutConditionDAO;
			dao.delete_all();
			commitObjects(dao,xml.elements("conditions").children());
			
			dao = Database.dailyAgendaColumnLayoutDao;
			dao.delete_all();
			commitObjects(dao,xml.elements("dailyAgendaLayouts").children());
				
			if(reload!=null) reload();
			
		}
		private static function getDefaultSyncOrder(entity:String):String {
			return Database.getSyn_order(entity);
		}
		
		
		public static function generateXML(rootElememt:XMLList,tag:String,list:Array,defaultVal:Object=null):void{
			var subRoot:XMLList = rootElememt;
			if(list.length>4000){
				subRoot = new XMLList(<child_spliter/>);
				rootElememt.appendChild(subRoot);
			}
			var i:int=0;
			for each(var obj:Object in list){
				var rootEach:XML=<{tag}/>;
				for(var field:String in obj){
					var val:String="";
					if(obj[field] is Boolean){
						if(obj[field]){
							val = "1";
						}else{
							val = "0";
						}
					}else{
						val = obj[field];
					}
					
					if(val==null||val.length<1){
						if(defaultVal!=null){
							val = defaultVal[field];
						}
					}
					
					if(val!=null && val.length>0){
						rootEach.appendChild(<{field}>{val}</{field}>);
					}				
				}
				if(i>=4000){
					i=0;
					subRoot = new XMLList(<child_spliter/>);
					rootElememt.appendChild(subRoot);
				}
				subRoot.appendChild(rootEach);
				i++;
			} 
		}	
		
		public static function commitObjects(dao:BaseSQL,xmlList:XMLList, isCommite:Boolean = true,initEach:Function=null):void{
			if(xmlList==null) return;
			if(isCommite){
				Database.begin();
			}
			
			
			for each(var child:XML in xmlList){
				var name:String = child.name().localName;
				if(name=='child_spliter' || StringUtils.startsWith(name,'access_profiles_entrys_')){
					commitObjects(dao,child.children(),false,initEach);
					continue;
				}
				var obj:Object=new Object();
				
				for each(var field:XML in child.children()){
					var val:String = checkNullValue(field.children()[0]);
					if(val == "0"){
						obj[field.name().localName]=0;//can be boolean
					}else if(val=="1"){
						obj[field.name().localName]=1 // can be boolean;
					}else{
						obj[field.name().localName]=checkNullValue(field.children()[0]);
					}
					
				}
				try{
					if(initEach!=null){
						initEach(obj);
					}
					if(dao is BaseDAO){
						BaseDAO(dao).insert(obj);
					}else if(dao is SimpleTable){
						SimpleTable(dao).insert(obj);
					}
					
				}catch(e:SQLError){
					//may contrain error
					trace(e.getStackTrace());
				}
				
			}
			
			if(isCommite){
				Database.commit();
			}
			
		}	
		
		
		
		public static function checkNullValue(value:Object,nullValue:String=""):String{
			return(value==null? nullValue : StringUtils.xmlUnEscape(value.toString()));	
		}	
		//		public static function checkNullValue(value:Object,defaultValue:String=""):String{
		//			return(value==null? defaultValue : value.toString());	
		//		}
		public static function checkNullValueNoEscape(value:Object,nullValue:String=""):String{
			return(value==null? nullValue : value.toString());	
		}		
		
		
		public static function getGPlantLocation():String{
			var currentUser:Object =Database.allUsersDao.ownerUser();
			var langCode:String = currentUser.LanguageCode;
			var country:String = currentUser.PersonalCountry;
			var g_plant:String="";
			if(langCode==null || langCode==''){
				langCode='EN';
			}else{
				langCode=langCode.substr(0,2);
			}
			
			
			if(country.toLocaleLowerCase()=='belgium' &&  (langCode=='FR'||langCode=='NL')){
				return Plant_LOCATION_BG;
			}
			g_plant = MAP_PLANT_LOCATION[country];
			
			if(g_plant=='' || g_plant==null){
				g_plant=Plant_LOCATION_UK;
			}
			return g_plant;
			
			
			
		}
		
		/* The application will not launch when the computer system starts.
		It launches when the user logs in. The setting only applies to the current user.
		Also, the application must be installed to successfully set the startAtLogin property to true. 
		An error is thrown if the property is set when an application is not installed (such as when it is launched with ADL). */
		public static function setStartAtLogin(startAtLogin:Boolean = false):void {
			if(!Capabilities.isDebugger)
				NativeApplication.nativeApplication.startAtLogin = startAtLogin;
		}
		
		public static function getSalesStage():ArrayCollection {
			var roleName:String = Database.rightDAO.getRole();
			var picklist:ArrayCollection = new ArrayCollection();
			var tmp:ArrayCollection ;
			picklist.addItem({data:"", label:""});
			if(!StringUtils.isEmpty(roleName)){
				var saleProId:String = Database.salesProcDao.getSalesProId(Database.roleServiceDao.getDefaultSaleProcess(roleName));
				if(!StringUtils.isEmpty(saleProId)){
					tmp= Database.salesStageDao.findBySalesProId(saleProId); 
					
				}
			}
			if(tmp == null || tmp.length  == 0 ){
				tmp = Database.salesStageDao.findAll();
			}
			for each (var stage:Object in tmp) {
				picklist.addItem({data: stage.name, other: "SalesStageId", key: stage.id, label: stage.name, probability: stage.probability, category: stage.sales_category_name});
			}
			return picklist;
		}
		
		public static function getCboSalesStageParamIndex(value:String):int {
			var params:ArrayCollection = Utils.getSalesStage();
			for(var i:int = 0; i < params.length; i++) {
				if(value == params[i].data)
					return i;
			}
			return 0;
		}
		
		public static function encryptPassword(pwd:String):String{
			if(StringUtils.isEmpty(pwd)){
				return '';
			}
			var pad:IPad = new PKCS5();
			var cipher:ICipher = Crypto.getCipher(cryptName,Hex.toArray(Hex.fromString(cryptoKey)),pad);
			pad.setBlockSize(cipher.getBlockSize());
			var data:ByteArray = Hex.toArray(Hex.fromString(pwd));			
			cipher.encrypt(data);			
			return Hex.fromArray(data);
		}
		
		public static function decryptPassword(pwd:String):String{
			if(StringUtils.isEmpty(pwd)){
				return '';
			}
			var pad:IPad = new PKCS5();
			var cipher:ICipher = Crypto.getCipher(cryptName,Hex.toArray(Hex.fromString(cryptoKey)),pad);
			pad.setBlockSize(cipher.getBlockSize());
			var data:ByteArray = Hex.toArray(pwd);
			cipher.decrypt(data);
			return Hex.toString(Hex.fromArray(data));;
		}
		
		
		public static const dateFormulaFn:ArrayCollection = new ArrayCollection(
			
			[ 	{label:"", data:""},
				{label:"Today", data:"Today()"},
				{label:"LastWeek", data:"LastWeek()"}, 
				{label:"ThisWeek", data:"ThisWeek()"},
				{label:"NextWeek", data:"NextWeek()"},
				{label:"LastMonth", data:"LastMonth()"}, 
				{label:"ThisMonth", data:"ThisMonth()"},
				{label:"NextMonth", data:"NextMonth()"},
				{label:"LastYear", data:"LastYear()"}, 
				{label:"ThisYear", data:"ThisYear()"},
				{label:"NextYear", data:"NextYear()"}
			]);
		
		private static const accountChildren:ArrayCollection = new ArrayCollection(["Activity","Attachment","Note"]);
		public static function getChildObject(entity:String):ArrayCollection{
			switch (entity){
				case "Account": return Utils.accountChildren;	
				default: return new ArrayCollection();
			}
		}
		
		public static function exportSurveyPDF(item:Object,window:UIComponent):int{
			
			
			var acc:Object = Utils.getAccount(item);
			var assPDF:AssessementPDF =new AssessementPDF(item,pdfSize);
			var error:String='';
			if(acc != null && assPDF.hasSurvey()){
				var pdfSize:String = Database.preferencesDao.getValue(PreferencesDAO.PDF_SIZE)as String ;				
				showLoadingProgressWindow(function():void{
					try{
				  		assPDF.generatePDF();
					}catch(e:Error){
						error = e.message;
					}
				},i18n._("GLOBAL_EXPORTING@Exporting..."),i18n._("GLOBAL_EXPORTING@Exporting..."),200,function(dialog:LoadingIndicator):void{
					var loadTimer:Timer = new Timer(10, 0); 
					loadTimer.addEventListener(TimerEvent.TIMER, function():void{
						var showError:Boolean = false;
						if(assPDF==null){
							dialog.close();
							loadTimer.stop();
							showError=true;						 
						}else if(assPDF.openned){
							dialog.close();
							loadTimer.stop();
							showError=true;
						}
						if(showError && !StringUtils.isEmpty(error)){
							Alert.show(error, "", Alert.OK, window);
						}
					
					}); 
					loadTimer.start();
				
				});
				
				return 1;
				
			}
			return 0;
		}
		public static function getModelName(task:Object):DtoConfiguration{
			return Database.assessmentConfigDao.getAssessmentConfigByName(String(task.ActivitySubType));
		}
		public static function getAccount(appItem:Object):Object{
			
			if(!StringUtils.isEmpty(appItem.AccountId)){
				return appItem;
			}
			
//			else{
//				var con:Object = Database.contactDao.findByOracleId(appItem.PrimaryContactId);
//				var acc:Object ;
//				if(con != null){
//					acc = new Object();
//					acc.AccountName = con.AccountName;
//					acc.AccountId = con.AccountId;
//				}
//				return acc;
//			}
			return null;//right now we don't need to check account of the contact
			
		}	
		private static function bindMappingField(item:Object,ques:Object,modelId:String):void{
			
			var mapCols:ArrayCollection = Database.assessmentMappingDao.selectByQuestionId(ques.QuestionId,modelId);
			for each(var col:Object in mapCols){
				if( col.ColumnProperty != 'Question' ) {
					ques[col.ColumnProperty] = item[col.Oraclefield];
				}
			}
		}

		
	
	
	private static function importOldConfig(xml:XML,prefsXMLList:Function=null,mapValueWithControls:Function=null,reload:Function=null,dialog:Window=null):void{
		if(dialog != null)dialog.close();
		Database.begin();
		//xml.toString()
		// Industry
		Database.industryDAO.delete_all(); // delete all industry
		// insert new industry
		var industriesList:XMLList = xml.elements("industries");
		for each(var industries:XML in industriesList) {
			var language_code:String = industries.@language;
			for each(var industry:XML in industries.industry) {
				var industryObject:Object = new Object();
				industryObject.enable = checkNullValue(industry.elements("enable"), "");
				industryObject.display_name = checkNullValue(industry.elements("display_name"), "");
				industryObject.sic_code = checkNullValue(industry.elements("sic_code"), "");
				industryObject.language_code = checkNullValue(language_code, "");
				Database.industryDAO.insert(industryObject);
			}
		}
		
		//---------------------- TCS Report Admin ----------------------------------------
		if(UserService.getCustomerId() == UserService.DIVERSEY) {				
			var reportAdminList:XMLList = xml.elements("report_admins");
			Database.reportAdminChildDao.delete_all();
			for each(var reportXML:XML in reportAdminList) {
				var report:Object = new Object();
				report.report_path = checkNullValue(reportXML.elements("report_path"), "");
				report.type = checkNullValue(reportXML.elements("type"), "");
				Database.reportAdminDao.insert(report);
				for each(var childReportXML:XML in reportXML.report) {
					var childReport:Object = new Object();
					childReport.report_name = checkNullValue(childReportXML.elements("report_name"), "");
					childReport.report_code = checkNullValue(childReportXML.elements("report_code"), "");
					Database.reportAdminChildDao.insert(childReport);
				}
			}
		}
		
		var app_name:String ="";
		for each(var app:XML in xml.children()){
			if(app.localName() != null && "application-name"==app.localName().toString()){
				app_name = checkNullValue(app.children()[0],"");
				Database.preferencesDao.setValue("application_name",app_name,false);
				break;
			}
			
		}
		// Preference
		var prefs:XMLList = xml.elements("prefs");
		for each(var pref:XML in prefs.pref){
			// bug # 183 
			//var prefValue:String = checkNullValue(pref.children()[0], "");
			// Change Request #184
			var prefValue:String = checkNullValue(pref.children()[0], pref.@key!="update_url" ? "" : "http://desktop.crm-gadget.com/update.xml");
			if(pref.@key == "start_at_login") Utils.setStartAtLogin(prefValue == "true" ? true : false);
			Database.preferencesDao.setValue(pref.@key, prefValue=="true"? 1: prefValue=="false"? 0 : prefValue,false);
		}
		
		
		
		var transactions:XMLList = xml.elements("transactions");
		var isDelete:Boolean=true;
		for each(var transaction:XML in transactions.transaction){
			var transactionObject:Object = new Object();
			transactionObject.entity = transaction.id.children()[0].toString();
			transactionObject.enabled = transaction.enabled.children()[0].toString()=="true"?1:0;
			transactionObject.display_name = "";
			transactionObject.filter_id = checkNullValue(transaction.filter.children()[0],"");
			transactionObject.parent_entity = checkNullValue(transaction.elements("parent_entity").children()[0],"");
			transactionObject.default_filter = checkNullValue(transaction.elements("default-filter").children()[0],"-1"); //CRO 1588
			// transactionObject.sync_ws20 = transaction.elements("sync-ws20").children()[0].toString()=="true"? 1 : 0;
			if(transaction.hasOwnProperty("sync-activities") || transaction.hasOwnProperty("sync-attachments") ){
				transactionObject.sync_activities = checkNullValue(transaction.elements("sync-activities").children()[0],"")=="true"? 1 : 0;
				transactionObject.sync_attachments = checkNullValue(transaction.elements("sync-attachments").children()[0],"")=="true"? 1 : 0;
				Database.subSyncDao.updateEnabledAll( transactionObject.entity,0);
				var objChildAct:Object = new Object();
				var enabled:int = transactionObject.sync_activities;
				objChildAct["entity"] = transactionObject.entity;
				objChildAct["sub"] = "Activity";
				objChildAct["sodname"] = "Activity";
				objChildAct["enabled"] = enabled;
				Database.subSyncDao.updateEnabled(objChildAct);
				
				var objChild:Object = new Object();
				objChild["entity"] = transactionObject.entity;
				objChild["sub"] = "Attachment";
				objChild["sodname"] = "Attachment";
				objChild["enabled"] = transactionObject.sync_attachments;
				Database.subSyncDao.updateEnabled(objChild);
			}
			if(transaction.hasOwnProperty("sync-children")){
				if(isDelete){
					Database.subSyncDao.delete_all();
					isDelete = false;
				}
				var listSyncChildren:XMLList = transaction.elements("sync-children");
				commitObjects(Database.subSyncDao,listSyncChildren.children(),false,function(subObj:Object):void{
					if(subObj.entity_name=='Account.Objectives'){//may be use old xml 
						subObj.entity_name = 'Objectives';
					}else if(subObj.entity_name=='Contact'){
						subObj.entity_name = 'Activity.Contact';
					}
					subObj.syncable=Database.getSubSyncable(subObj.entity,subObj.entity_name);
					if(StringUtils.isEmpty(subObj.entity_name)){
						subObj.entity_name = Database.getSubEntityName(subObj.entity,subObj.sub,subObj.sodname);
					}
					
				});
				
				
				//commitObjects(Database.subSyncDao,listSyncChildren.children(),false);
				
				//					Database.subSyncDao.updateEnabledAll( transactionObject.entity,0);
				//					for each(var childSync:XML in listSyncChildren.children()){
				//						var objSyncChld:Object = new Object();
				//						objSyncChld["entity"] = transactionObject.entity;
				//						objSyncChld["sub"] = childSync.toString();
				//						objSyncChld["enabled"] = 1;
				//						Database.subSyncDao.updateEnabled(objSyncChld);
				//					}					
			}
			transactionObject.hide_relation = checkNullValue(transaction.elements("hide-relation").children()[0],"")=="true"? 1 : 0;
			transactionObject.read_only = checkNullValue(transaction.elements("read-only").children()[0],"")=="true"? 1 : 0;
			transactionObject.display = checkNullValue(transaction.elements("display").children()[0],"true")=="true"? 1 : 0;
			transactionObject.authorize_deletion = checkNullValue(transaction.elements("authorize-deletion").children()[0],"")=="true"? 1 : 0;
			
			// #311: hange request - Diversey sales - Prefernces -> #41: Cannot load VETO.XML
			transactionObject.filter_disable = checkNullValue(transaction.elements("filter-disable").children()[0], "")=="true"? 1 : 0;
			transactionObject.read_only_disable = checkNullValue(transaction.elements("read-only-disable").children()[0], "")=="true"? 1 : 0;
			
			//transactionObject.sync_activities_disable = checkNullValue(transaction.elements("sync-activities-disable").children()[0], "")=="true"? 1 : 0;
			//transactionObject.sync_attachments_disable = checkNullValue(transaction.elements("sync-attachments-disable").children()[0], "")=="true"? 1 : 0;
			
			transactionObject.authorize_deletion_disable = checkNullValue(transaction.elements("authorize-deletion-disable").children()[0], "")=="true"? 1 : 0;
			transactionObject.entity_disable = checkNullValue(transaction.elements("entity-disable").children()[0], "")=="true"? 1 : 0;				
			transactionObject.sync_order=checkNullValue(transaction.elements("sync_order").children()[0], getDefaultSyncOrder(transactionObject.entity));
			transactionObject.rank=checkNullValue(transaction.elements("rank").children()[0], Database.getDefatultRank(transactionObject.entity));
			transactionObject.advanced_filter = checkNullValue(transaction.elements("advanced_filter").children()[0],'1');
			Database.transactionDao.updateAllFields(transactionObject);
			if(mapValueWithControls!=null)
				mapValueWithControls(transactionObject);
		}
		
		var tagCustomName:String = "custom-layout";
		if(xml.toString().indexOf("detail-layout")>0) tagCustomName = "detail-layout";
		var customLayoutXMLList:XMLList = xml.elements(tagCustomName +  "s");
		// var customLayoutXMLList:XMLList = xml.elements("custom-layouts");
		// delete all entity on custom layout
		for each(var obj:Object in Database.customLayoutDao.readAll()){
			if(obj.deletable){
				Database.layoutDao.deleteLayout(obj.entity,obj.subtype);
				Database.customLayoutDao.delete_one(obj.entity,obj.subtype);
				Database.customLayoutConditionDAO.deleted(obj.entity,obj.subtype);
			}
		}
		for each(var customLayoutXML:XML in customLayoutXMLList.elements(tagCustomName)){
			var customLayout:Object = new Object();
			var customLayoutEntity:String = customLayoutXML.elements("entity").children()[0];
			var subtype:int = int(customLayoutXML.elements("subtype").children()[0]);
			// Delete records detail layout by entity
			Database.layoutDao.deleteLayout(customLayoutEntity, subtype);
			Database.customLayoutDao.delete_one(customLayoutEntity, subtype);
			Database.customLayoutConditionDAO.deleted(customLayoutEntity, String(subtype));
			
			customLayout.entity = customLayoutEntity;
			customLayout.subtype = subtype;
			
			customLayout.background_color = customLayoutXML.elements("color").children()[0]==null? 0xEEEEEE :customLayoutXML.elements("color").children()[0];
			customLayout.custom_layout_icon = customLayoutXML.elements("icon").children()[0];
			customLayout.layout_name = checkNullValue(customLayoutXML.elements("layout-name").children()[0],customLayoutEntity);
			customLayout.display_name = checkNullValue(customLayoutXML.elements("display-name").children()[0], ""); // Bug #73
			customLayout.display_name_plural = checkNullValue(customLayoutXML.elements("display-name-plural").children()[0], "");
			customLayout.deletable = customLayoutXML.elements("deletable").children()[0].toString() == 'true' ? 1 : 0;
			customLayout.field = customLayoutXML.elements("field").children()[0];
			customLayout.operator = checkNullValue(customLayoutXML.elements("operator").children()[0], "");
			customLayout.value = checkNullValue(customLayoutXML.elements("value").children()[0],"");
			customLayout.layout_depend_on = checkNullValue(customLayoutXML.elements("layout_depend_on").children()[0],"");
			customLayout.custom_layout_title = checkNullValue(customLayoutXML.elements("custom-layout-title").children()[0], ""); // Change Request #747
			
			var objectCondition:Object;
			// specific code to handle v1.080 condition format
			if (customLayout.field != null && customLayout.deletable == true) {
				objectCondition = new Object();
				objectCondition.entity = customLayoutEntity;
				objectCondition.subtype = String(subtype);
				objectCondition.num = "1";
				objectCondition.column_name = customLayout.field;
				objectCondition.operator = customLayout.operator;
				objectCondition.params = customLayout.value;
				
				Database.customLayoutConditionDAO.insert(objectCondition);
			}
			
			Database.customLayoutDao.insert(customLayout);
			
			// layout fields
			for each(var fieldDetail:XML in customLayoutXML.fields.children()){
				var detailLayout:Object = new Object();
				
				detailLayout.entity = customLayoutEntity;
				detailLayout.subtype = subtype;
				detailLayout.col = int(fieldDetail.col.children()[0].toString());
				detailLayout.row = int(fieldDetail.row.children()[0].toString());
				detailLayout.column_name = fieldDetail.elements("column-name")[0].children()[0].toString();
				detailLayout.custom = fieldDetail.custom.children()[0];
				detailLayout.readonly = fieldDetail.readonly.children()[0]==null?0:fieldDetail.readonly.children()[0].toString()=="true"?1:0;
				detailLayout.mandatory = fieldDetail.mandatory.children()[0]==null?0:fieldDetail.mandatory.children()[0].toString()=="true"?1:0;
				var val:String=checkNullValue(fieldDetail.elements("max_chars").children()[0]);
				detailLayout.max_chars =  val;
				Database.layoutDao.insert(detailLayout);
				
				/*var customFieldXML:XML = fieldDetail.elements("custom-field")[0];
				if(customFieldXML && (detailLayout.column_name.indexOf(CustomLayout.CALCULATED_CODE)>-1)){
				var customField:Object = new Object();
				customField["entity"] = customLayoutEntity;
				customField["column_name"] = detailLayout.column_name;
				customField["subtype"] = detailLayout.subtype;
				customField["fieldName"] = checkNullValue(customFieldXML.fieldName.children()[0],"");
				customField["displayName"] = checkNullValue(customFieldXML.displayName.children()[0],"");
				customField["fieldType"] = checkNullValue(customFieldXML.fieldType.children()[0],"");
				customField["value"] = checkNullValue(customFieldXML.value.children()[0],"");
				Database.customFieldDao.insert(customField);								
				}*/
			}
			
			// custom fields
			// var customFieldXMLList:XML = customLayoutXML.elements("custom-fields").children();
			var _cache_cascading_crm:CacheUtils = new CacheUtils("cascading_crm");
			var _cache_customField:CacheUtils = new CacheUtils("customField");
			_cache_customField.del(customLayoutEntity);
			_cache_cascading_crm.del(customLayoutEntity);
			for each(var customFieldXML:XML in customLayoutXML.elements("custom-fields").children()){
				var columnName:String = checkNullValue(customFieldXML.elements("column-name")[0],"");					
				var objCustomField:Object = new Object();
				var currentEntity:String = customLayoutEntity;
				if(customFieldXML.entity!=null && customFieldXML.entity.children()!=null){
					var et:String = 	checkNullValue(customFieldXML.entity.children()[0]);
					if(!StringUtils.isEmpty(et)){
						currentEntity = et;
					}
				}
				objCustomField["entity"] = currentEntity;
				objCustomField["column_name"] = columnName;
				objCustomField["subtype"] = checkNullValue(customFieldXML.subtype.children()[0]);
				objCustomField["fieldName"] = checkNullValue(customFieldXML.fieldName.children()[0]);
				objCustomField["displayName"] = checkNullValue(customFieldXML.displayName.children()[0]);
				objCustomField["fieldType"] = checkNullValue(customFieldXML.fieldType.children()[0]);
				objCustomField["value"] = checkNullValue(customFieldXML.value.children()[0]);
				objCustomField["defaultValue"] = checkNullValue(customFieldXML.defaultValue.children()[0])=="true"?1:0;
				objCustomField["bindField"] = checkNullValue(customFieldXML.bindField.children()[0]);
				objCustomField["bindValue"] = checkNullValue(customFieldXML.bindValue.children()[0]);
				objCustomField["parentPicklist"] = checkNullValue(customFieldXML.parentPicklist.children()[0]);
				
				objCustomField["field_copy"] = checkNullValue(customFieldXML.fieldCopy.children()[0]);
				objCustomField["sum_field_name"] = checkNullValue(customFieldXML.sumFieldName.children()[0]);
				objCustomField["sum_entity_name"] = checkNullValue(customFieldXML.sumEntityName.children()[0]);
				objCustomField["relation_id"] = checkNullValue(customFieldXML.relationId.children()[0]);
				
				Database.customFieldDao.deleteCustomField(objCustomField);
				Database.customFieldDao.insert(objCustomField);
				// create new column on table entity
				if(objCustomField.column_name.indexOf(CustomLayout.CUSTOMFIELD_CODE)>-1){
					Database.customFieldDao.addTableColumn(objCustomField.entity,objCustomField.fieldName,"TEXT");
				}
				
				
				// var translatorXML:XML = customFieldXML.elements("translators")[0];
				Database.customFieldTranslatorDao.deleteFieldByColumnName(customLayoutEntity,columnName);
				for each(var translator:XML in customFieldXML.translators.children()){
					var objTranslator:Object = new Object();
					objTranslator.entity = customLayoutEntity;
					objTranslator.column_name = objCustomField.column_name;
					objTranslator.fieldName = objCustomField.fieldName;
					objTranslator.displayName = checkNullValue(translator.displayName.children()[0],"");
					objTranslator.languageCode = checkNullValue(translator.languageCode.children()[0],"");
					objTranslator.value = checkNullValue(translator.value.children()[0],"");
					objTranslator.bindValue = checkNullValue(translator.bindValue.children()[0],"");
					
					Database.customFieldTranslatorDao.insert(objTranslator);
				}
				
				if(objCustomField.column_name.indexOf(CustomLayout.BINDPICKLIST_CODE)>-1){
					PicklistService.getPicklist(objCustomField.entity,objCustomField.fieldName,true,true,true);
					PicklistService.getBindPicklist(objCustomField.entity,objCustomField.fieldName,true,true);			
				}
			}
			
			// import table sql_filter_criteria
			// {entity_src: "", list_name: "", entity_dest: "", column_name: "", operator: "", param: "", conjunction: "", columns: "", num: ""}
			Database.sqlListDAO.delete_({entity_src: customLayoutEntity});
			for each(var iCriteriaXML:XML in customLayoutXML.elements("sql-filter-criterias").children()){			
				var iCriteria:Object = new Object();
				iCriteria.entity_src = checkNullValue(iCriteriaXML.entity_src.children()[0]);
				iCriteria.list_name = checkNullValue(iCriteriaXML.list_name.children()[0]);
				iCriteria.entity_dest = checkNullValue(iCriteriaXML.entity_dest.children()[0]);
				iCriteria.column_name = checkNullValue(iCriteriaXML.column_name.children()[0]);
				iCriteria.operator = checkNullValue(iCriteriaXML.operator.children()[0]);
				iCriteria.param = checkNullValue(iCriteriaXML.param.children()[0]);
				iCriteria.conjunction = checkNullValue(iCriteriaXML.conjunction.children()[0]);
				iCriteria.columns = checkNullValue(iCriteriaXML.columns.children()[0]);
				iCriteria.num = checkNullValue(iCriteriaXML.num.children()[0]);
				Database.sqlListDAO.insert(iCriteria);
			}				
			
			// layout conditions
			for each(var condition:XML in customLayoutXML.conditions.children()){
				objectCondition = new Object();
				objectCondition.entity = customLayoutEntity;
				objectCondition.subtype = String(subtype);
				objectCondition.num = int(condition.num.children()[0].toString());
				objectCondition.column_name = checkNullValue(condition.elements("column-name")[0].children()[0],"");
				objectCondition.operator = checkNullValue(condition.operator.children()[0],"");
				objectCondition.params = checkNullValue(condition.param.children()[0],"");
				
				Database.customLayoutConditionDAO.insert(objectCondition);
			}
		}
		
		// List Layout
		// entity, num, element_name
		var listLayouts:XMLList = xml.elements("list-layouts");
		for each(var listLayout:XML in listLayouts.elements("list-layout")){
			var entityListLayout:String = listLayout.children()[0];
			// Delete records list layout by entity
			//VAHI: done
			Database.columnsLayoutDao.deleteEntity(entityListLayout);
			for each(var fieldList:XML in listLayout.fields.children()){
				var objectList:Object = new Object();
				objectList.entity = entityListLayout;
				objectList.num = int(fieldList.num.children()[0].toString());
				objectList.element_name = checkNullValue(fieldList.elements("element-name")[0].children()[0],"");
				objectList.filter_type = "Default";
				if (fieldList.elements("filter-type").length()>0) {
					objectList.filter_type = checkNullValue(fieldList.elements("filter-type")[0].children()[0],"");	
				}
				Database.columnsLayoutDao.insert(objectList);
			}
		}
		
		// View Layout
		// entity, num, element_name
		var viewLayouts:XMLList = xml.elements("view-layouts");
		for each(var viewLayout:XML in viewLayouts.elements("view-layout")){
			var entityViewLayout:String = viewLayout.children()[0];
			// Delete records view layout by entity
			Database.viewLayoutDAO.deleteEntity(entityViewLayout);
			for each(var fieldView:XML in viewLayout.fields.children()){
				var objectView:Object = new Object();
				objectView.entity = entityViewLayout;
				objectView.num = int(fieldView.num.children()[0].toString());
				objectView.element_name = checkNullValue(fieldView.elements("element-name")[0].children()[0],"");
				Database.viewLayoutDAO.insert(objectView);
			}
		}
		
		// Validation Rule
		// entity, num, rule_name, field, operator, value, message
		var validationRules:XMLList = xml.elements("validationRules");
		for each(var validationRule:XML in validationRules.elements("validationRule")){
			var entityValidationRule:String = validationRule.children()[0];
			Database.validationDao.deleteAll(entityValidationRule);
			for each(var fieldValidation:XML in validationRule.fields.children()){
				var objectValidation:Object = new Object();
				objectValidation.entity = entityValidationRule;
				objectValidation.num = int(fieldValidation.num.children()[0].toString());
				objectValidation.rule_name = checkNullValue(fieldValidation.elements("rule-name")[0].children()[0],"");
				objectValidation.field = fieldValidation.field.children()[0].toString();
				objectValidation.operator = checkNullValue(fieldValidation.operator.children()[0],"");
				objectValidation.value = checkNullValue(fieldValidation.value.children()[0],"");
				objectValidation.message = fieldValidation.message.children()[0];
				Database.validationDao.insertValidation(objectValidation);
			}
		}
		
		// Validation Rule_ 2
		var validationRules_2:XMLList = xml.elements("validation-rules_2");
		for each(var valRule2:XML in validationRules_2.elements("validation-rule")){
			var entityValRule2:String = valRule2.children()[0];
			for each(var rule:XML in valRule2.rules.children()){
				var objValRule2:Object = new Object();
				objValRule2.entity = entityValRule2;
				objValRule2.ruleName = checkNullValue(rule.ruleName.children()[0],"");
				objValRule2.active = checkNullValue(rule.active.children()[0],"")=="true"?1:0;
				objValRule2.value = checkNullValue(rule.value.children()[0],"");
				objValRule2.message = checkNullValue(rule.message.children()[0]);
				objValRule2.errorMessage = checkNullValue(rule.errorMessage.children()[0]);
				objValRule2.orderNo = parseInt(checkNullValue(rule.orderNo.children()[0]));
				
				Database.validationRuleDAO.upSert(objValRule2);
			}
		}
		// Validation rule translator //
		var validationTranslator:XMLList = xml.elements('validation-rules_translator');
		for each(var tranXML:XML in validationTranslator.elements('validation-translator')){
			var entityTran:String = tranXML.children()[0];
			for each(var valTran:XML in tranXML.translators.children()){
				var objTrans:Object = new Object();
				objTrans.entity = entityTran;
				objTrans.ruleName = checkNullValue(valTran.ruleName.children()[0],"");
				objTrans.errorMessage = checkNullValue(valTran.errorMessage.children()[0]);
				objTrans.languageCode = checkNullValue(valTran.languageCode.children()[0]);
				Database.validationRuleTranslotorDAO.updateField(objTrans);
			}
		}
		
		// Filter and Filter Criteria
		// id, name, entity
		//id, num, column_name, operator, param, conjunction
		var filters:XMLList = xml.elements("filters");
		var first:Boolean = true;
		for each(var filter:XML in filters.elements("filter")){
			var entityFilter:String = filter.children()[0];
			//restrict delete no object filter in transactions
			Database.filterDao.deleteByEntity(entityFilter);
			if (first) {
				//VAHI moved this here to be able to import incomplete XML
				//restrict delete no object filter in transactions
				//Database.filterDao.deleteAll();
				Database.criteriaDao.deleteAll();
				first	= false;
			}
			
			for each(var fieldFilter:XML in filter.elements("field")){
				var objectFilter:Object = new Object();
				objectFilter.entity = entityFilter;
				objectFilter.name = fieldFilter.children()[0].toString();
				objectFilter.predefined = fieldFilter.predefined.children()[0].toString()=="true"? 1 : 0;
				objectFilter.type = fieldFilter.type.children()[0];
				var filterId:Number = Database.filterDao.insert(objectFilter);
				
				for each(var criteria:XML in fieldFilter.elements("criteria-field")){
					var objectCriteria:Object = new Object();
					objectCriteria.id = filterId;
					objectCriteria.num = int(criteria.num.children()[0].toString());
					objectCriteria.column_name = checkNullValue(criteria.elements("column-name")[0],"");
					// if(criteria.operator.children()[0]!=null)
					// objectCriteria.operator = criteria.operator.children()[0].toString()=="&gt;"?">":criteria.operator.children()[0].toString()=="&lt;"? "<":criteria.operator.children()[0].toString();
					objectCriteria.operator = checkNullValue(criteria.operator.children()[0],"");
					objectCriteria.param = checkNullValue(criteria.param.children()[0],"");
					objectCriteria.conjunction = checkNullValue(criteria.conjunction.children()[0],"");
					//objectCriteria.param_display = checkNullValue(criteria.elements("param-display")[0],"");
					
					Database.criteriaDao.insert(objectCriteria);
				}
			}
		}
		//refreshMainWindow = true;
		Database.commit();
		if(prefsXMLList!=null)
			prefsXMLList(prefs);
		//import role and access profile
		var dao:SimpleTable=Database.accessProfileServiceDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("access_profiles").children());			
		
		
		dao=Database.accessProfileServiceEntryDao;
		dao.delete_all();
		var root:XMLList=xml.elements("access_profiles_entrys").children();
		for each(var child:XML in root){
			commitObjects(dao,child.children());
		}
		dao=Database.accessProfileServiceTransDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("access_profiles_trans").children());
		
		dao=Database.subColumnLayoutDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("sublist-layouts").children());
		
		dao = Database.roleServiceDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("role_services").children());			
		
		dao = Database.roleServiceAvailableTabDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("role_services_avail_tab").children());
		
		
		dao = Database.roleServiceLayoutDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("role_services_layout").children());
		
		dao = Database.roleServicePageLayoutDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("role_services_page").children());			
		
		dao = Database.roleServicePrivilegeDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("role_services_priv").children());
		
		dao = Database.roleServiceSelectedTabDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("role_services_sel_tab").children());
		
		dao = Database.roleServiceTransDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("role_services_trans").children());
		
		
		dao = Database.roleServiceRecordTypeAccessDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("role_services_type").children());
		
		dao=Database.customRecordTypeTranslationsDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("custom_records_type_trans").children());
		
		dao=Database.fieldManagementServiceDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("field_managements").children());
		
		dao=Database.fieldTranslationDataDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("field_translations").children());
		
		//---------------------- Territory Tree ---------------------------------------
		dao=Database.territoryTreeDAO;
		dao.delete_all();
		commitObjects(dao,xml.elements("territorytree").children());
		
		//---------------------- Depthstructure Tree ----------------------------------------
		dao=Database.depthStructureTreeDAO;
		dao.delete_all();
		commitObjects(dao,xml.elements("depthstructuretree").children());
		//Filter Translation
		//---------------------- Depthstructure Tree ----------------------------------------
		dao=Database.customFilterTranslatorDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("filter_translations").children());
		
		dao=Database.assessmentDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("assessments").children());
		
		
		dao=Database.answerDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("answers").children());
		dao=Database.assessmentConfigDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("assessment_configs").children());
		
		dao = Database.assessmentPageDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("assessmentPages").children());
		
		dao = Database.mappingTableSettingDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("assessmentMappingColumns").children());
		
		
		dao = Database.assessmentMappingDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("assessmentMappings").children());
		
		//------------ assessment script
		dao=Database.questionDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("questions").children());
		
		dao = Database.sumFieldDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("assessmentsumfields").children());
		
		
		dao = Database.assessmentSplitterDao;
		dao.delete_all();
		commitObjects(dao,xml.elements("assessmentspliters").children());
		
		dao = Database.assessmentPDFHeaderDao;
		dao.delete_all();
		Utils.commitObjects(dao,xml.elements("assessmentpdfheaders").children(),false)
		
		if(reload!=null) reload();
		
	}
	
	
	public static function generateId():String
	{
		var uid:Array = new Array(13);
		var index:int = 0;
		
		var i:int;		
		
		for (i = 0; i < 4; i++)
		{
			uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  36)];
			
		}
		
		uid[index++] = 45; // charCode for "-"
		
		var time:Number = new Date().getTime();
		// Note: time is the number of milliseconds since 1970,
		// which is currently more than one trillion.
		// We use the low 8 hex digits of this number in the UID.
		// Just in case the system clock has been reset to
		// Jan 1-4, 1970 (in which case this number could have only
		// 1-7 hex digits), we pad on the left with 7 zeros
		// before taking the low digits.
		var timeString:String = ("0000000" + time.toString(36).toUpperCase()).substr(-8);
		
		for (i = 0; i < 8; i++)
		{
			uid[index++] = timeString.charCodeAt(i);
		}
		
		return String.fromCharCode.apply(null, uid);
	}
	
	}
}
