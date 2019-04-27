package gadget.util
{
	import flexlib.scheduling.util.DateUtil;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DateChooser;
	import mx.formatters.DateFormatter;

	public class CalendarUtils
	{
		
		public static const ACTIVITY_CALL_COLOR:Object = 0x009999;
		public static const ACTIVITY_APPOINTMENT_COLOR:Object = 0xDFD22C;
		public static const ACTIVITY_TASK_COLOR:Object = 0xFF8080;
		public static const ACTIVITY_GOOGLE_COLOR:Object = 0x668CD9;
		
		public static const SELECTED_DAY:int = 0;
		public static const SELECTED_WEEK:int = 1;
		public static const SELECTED_5DAYS:int = 2;
		public static const SELECTED_MONTH:int = 3;
		
		public function CalendarUtils(){}
		
		public static function generateFilter(paramStartDate:String, paramEndDate:String):String{
			var filter:String = "(StartTime >= '" + paramStartDate + "T00:00:00Z'" +
				" AND StartTime<= '" + paramEndDate + "T00:00:00Z'" + 
				" AND Activity = 'Appointment'" +
				")";
			
			filter += " OR ";
			
			filter += "(DueDate>= '" + paramStartDate + "'" +
				" AND DueDate <= '" + paramEndDate + "'" + 
				" AND Activity = 'Task'" +
				")";
			
			//bug#8044--show only owner calender
			filter ="("+filter+ ") AND ( OwnerId='" +Database.allUsersDao.ownerUser().Id+"' OR ActivityId IN (SELECT ActivityId from  activity_user WHERE UserId='" +Database.allUsersDao.ownerUser().Id+"'))";
			return filter;
		} 
		
		public static function getActivities(dateChooser:DateChooser, selectBy:int = SELECTED_WEEK):ArrayCollection {
			
			var resultList:ArrayCollection;
			var columns:ArrayCollection = new ArrayCollection([
								{element_name:"Activity"},
								{element_name:"StartTime"}, {element_name:"EndTime"},
								{element_name:"DueDate"}, {element_name:"Subject"},
								{element_name:"GUID"},
				{element_name:'AccountId'},{element_name:"CallType"},
				//{element_name:"*"},
				{element_name:"substr(Priority,1,1) PriorityIndex"},
				{element_name:"PrimaryContact"}
			]);
			
			var startDate:Date;
			var endDate:Date;
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYYMMDD";
			
			switch(selectBy){
				case SELECTED_DAY:
					startDate =  getSelectedDate(dateChooser);
					endDate = new Date(startDate.getTime() + DateUtil.DAY_IN_MILLISECONDS * 1);
					break;
				case SELECTED_5DAYS:
					startDate =  getMondayOfWeek(getSelectedDate(dateChooser));
					endDate = new Date(startDate.getTime() + DateUtil.DAY_IN_MILLISECONDS * 5);
					break;
				case SELECTED_WEEK:
					startDate =  getMondayOfWeek(getSelectedDate(dateChooser));
					endDate = new Date(startDate.getTime() + DateUtil.DAY_IN_MILLISECONDS * 7);
					break;
				case SELECTED_MONTH:
					startDate =  getFirstDateOfMonth(dateChooser);
					endDate = new Date(startDate.getFullYear(),startDate.getMonth()+1,0);//set max date of the month
					break;
			}
			var filter:String = CalendarUtils.generateFilter(DateUtils.format(startDate,DateUtils.DATABASE_DATE_FORMAT),DateUtils.format(endDate,DateUtils.DATABASE_DATE_FORMAT));
			
			
			return Database.activityDao.findAll(columns, "(" + filter + ")", null, 1001, "PriorityIndex");			   
		}	
		
		public static function getSelectedDate(dateChooser:DateChooser):Date {
			return dateChooser.selectedDate == null ? new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate(), 0, 0, 0, 0) : dateChooser.selectedDate;
		}	
		
		public static function getFirstDateOfMonth(dateChooser:DateChooser):Date {
			var currentDate:Date = dateChooser.selectedDate == null ? new Date() : dateChooser.selectedDate;
			return new Date(currentDate.getFullYear(), currentDate.getMonth(), 1, 0, 0, 0, 0);
		}

		public static function getMondayOfWeek(selectedDate:Date):Date {
			return new Date(selectedDate.getTime() - DateUtil.DAY_IN_MILLISECONDS * (selectedDate.getDay() == 0 ? 6 : selectedDate.getDay()-1));
		}	
		

		public static function getSpecialDays(dateCh:DateChooser):ArrayCollection {
			var resultList:ArrayCollection;
			var columns:ArrayCollection = new ArrayCollection([
				{element_name:"DueDate,StartTime,EndTime,Activity"}
			]);			
			
			var startDate:String = DateUtils.format(new Date(dateCh.displayedYear,dateCh.displayedMonth,1),DateUtils.DATABASE_DATE_FORMAT);
			var tempEndDate:Date = new Date(dateCh.displayedYear,dateCh.displayedMonth+1,0);
			var endDate:String = DateUtils.format(tempEndDate,DateUtils.DATABASE_DATE_FORMAT);
			
			return Database.activityDao.findAll(columns, "(" + generateFilter(startDate, endDate) + ")");
		}
		
		public static function setSpecialDays(dateChooser:DateChooser): void {
			var specialDayData:Array = [];
			for each(var activity:Object in getSpecialDays(dateChooser)){		
				var startDate:Date = null;
				var endDate:Date = null;
				var cDateObject:Object = null;
				if (activity.Activity == 'Task') { 
					startDate = DateUtils.guessAndParse(activity.DueDate);
					cDateObject = {rangeStart:startDate, rangeEnd:startDate};
				} else {
					startDate = DateUtils.guessAndParse(activity.StartTime);
					endDate = DateUtils.guessAndParse(activity.EndTime);
					if(startDate && endDate ){
						cDateObject = {rangeStart:startDate, rangeEnd:endDate};
					}
				}
				
				if (cDateObject != null && !itemExist(specialDayData, cDateObject)) {
					specialDayData.push(cDateObject);
				}
			}
			dateChooser.selectedRanges = specialDayData;
		}	
		
		private static function itemExist(specialDayData:Array, item:Object):Boolean {
			for each(var object:Object in specialDayData){
				var startDate:Date = object.rangeStart;
				var endDate:Date = object.rangeEnd;
				
				if(startDate.getTime() == item.rangeStart.getTime() && endDate.getTime() == item.rangeEnd.getTime()) return true;
			}
			return false;
		}
		
	}
}