package gadget.util
{
	import gadget.dao.AccountDAO;
	import gadget.dao.CampaignDAO;
	import gadget.dao.Database;
	import gadget.dao.OpportunityDAO;
	import gadget.dao.ServiceDAO;
	import gadget.i18n.i18n;
	import gadget.service.UserService;
	
	public class Validation {
		
		public function Validation() {
		}

		/**
		 * Performs some business controls on a given item. 
		 * @param entity Type of entity being modified.
		 * @param item Item being modified.
		 * @return Error message or null if everything is ok.
		 * 
		 */
		public static function checkItem(entity:String, item:Object):String {
			
//			if (entity == 'Activity') {
//				item['Activity'] = 'Task';
//			}
			//11865----------no need check duplicate for opportunity
//			if (entity == 'Opportunity') {
//				var opportunityDao:OpportunityDAO = Database.opportunityDao;
//				if (opportunityDao.findDuplicateByColumn('OpportunityName', item.OpportunityName, item.gadget_id == null ? '' : item.gadget_id)!=null) {
//					return "Opportunity '" + item.OpportunityName + "' already exists.";
//				}
//			}	
			
			if (entity == 'Account') {
				var accountDao:AccountDAO = Database.accountDao;
				if (accountDao.findDuplicateByColumn('AccountName', item.AccountName, item.gadget_id == null ? '' : item.gadget_id)!=null){
					// now all user need to check accountName and Location
					//if(UserService.getCustomerId()==UserService.JD){
						if(accountDao.findDuplicateByColumn('Location', item.Location, item.gadget_id == null ? '' : item.gadget_id)!=null) {
							return "Account '" + item.AccountName + " and Location '" + item.Location + "' already exists.";
						}
					//}else{
					//	return "Account '" + item.AccountName + "' already exists.";
					//}
				}
			}
			
			if (entity == 'Campaign') {
				var campaignDao:CampaignDAO = Database.campaignDao;
				if (campaignDao.findDuplicateByColumn('SourceCode', item.SourceCode, item.gadget_id == null ? '' : item.gadget_id)!=null) {
					return "Campaign '" + item.SourceCode + "' already exists.";
				}				
			}

			//VAHI added
			if (entity == 'Service Request') {
				return checkFields(item, {
					Subject:	maxLen(250),
					Description:maxLen(2000),
					OpenedTime:	validSodDateTime
				});
			}

			if (entity == 'Activity') {
				var errorText:String = checkFields(item, {
					Subject:	maxLen(100),
					Description:maxLen(1999),
					StartTime: validSodDateTime,
					EndTime: validSodDateTime,
					DueDate:	validSodDate
				});
				if (errorText == null){
					errorText = checkStartDateEndDate(item);
				} else {
					errorText = checkStartDateEndDate(item) == null ? errorText : errorText + "\n" + checkStartDateEndDate(item);
				}
				return errorText;
			}
			if (entity == 'Contact') {
				return checkFields(item, {
					ContactEmail:	validemail
				});
			}
			return null;		
		}		
		
		//VAHI added for contraint checking
		private static function maxLen(len:int):Function {
			return function(s:String):String {
				return s.length<=len ? null : i18n._("{1} characters long.  Max. allowed {2} characters.", s.length, len);
			} 
		}

		private static function validemail(s:String):String {
			return s=="" || null!=s.match(/^[^@[:space:]]+@[a-zA-Z0-9][a-zA-Z0-9-]*\.[a-zA-Z0-9][a-zA-Z0-9-.]*[a-zA-Z0-9]$/) ? null : i18n._("not a valid email");
		}


		private static function validSodDateTime(s:String):String {
			return s==""
				//|| null!=s.match(/^[0-1][0-9]\/[0-3][0-9]\/[0-9][0-9][0-9][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]$/)
				|| null!=s.match(/^[1-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]Z$/)
				? null : i18n._("not a valid date time");
		}

		private static function validSodDate(s:String):String {
			return s==""
				//|| null!=s.match(/^[0-1][0-9]\/[0-3][0-9]\/[0-9][0-9][0-9][0-9]$/)
				|| null!=s.match(/^[1-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]$/)
				? null : i18n._("not a valid date");
		}

		private static function checkFields(item:Object, validate:Object):String {
			var s:String = "";
			for (var i:String in validate) {
				if (item[i]!=null) {
					var tmp:String = validate[i](item[i].toString());
					if (tmp!=null)
						s+=i18n._("Field {1} is {2}\n", i, tmp);
				}
			}
			return s=="" ? null : s;
		}
		
		private static function checkStartDateEndDate(item:Object):String{
			var s:String = null;
			var startTime:Date;
			var endTime:Date;
			if(item["StartTime"]!=null){
				startTime = DateUtils.guessAndParse(item["StartTime"]);
			}
			
			if(item["EndTime"]!=null){
				endTime = DateUtils.guessAndParse(item["EndTime"]);
			}
			trace(startTime);
			trace(endTime);
			if(startTime && endTime){
				var due:int = endTime.getTime() - startTime.getTime();
				if(due<0){
					s = i18n._("END_DATE_MUST_AFTER_START_DATE");
				}
			}
			return s;
		}
	}
}
