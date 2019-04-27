package gadget.util
{
	public class ActivityDataUtils {
		
		public static const TASK_SUBTYPE:int = 0;
		public static const APPOINTMENT_SUBTYPE:int = 1;
		public static const CALL_SUBTYPE:int = 2;
		
		private static const TASK_DATA:Object = {gadget_type:'Activity',Activity:'Task',CallType:'General'};
		private static const APPOINTMENT_DATA:Object = {gadget_type:'Activity',Activity:'Appointment',CallType:'General'};
		private static const CALL_DATA:Object = {gadget_type:'Activity',Activity:'Appointment',Type:'Call',CallType:'Account Call'};
		
		public function ActivityDataUtils(){}
		
		public static function getActivityData(subType:int):Object {
			var model:Object = new Object();
			switch(subType){
				case TASK_SUBTYPE: model = TASK_DATA; break;
				case APPOINTMENT_SUBTYPE: model = APPOINTMENT_DATA; break;
				case CALL_SUBTYPE: model = CALL_DATA; break;
			}
			return Utils.copyModel(model);
		}
		
	}
}