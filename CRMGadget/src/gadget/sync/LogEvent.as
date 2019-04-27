package gadget.sync {
	
	import flash.events.Event;
	
	import gadget.dao.DAOUtils;
	
	public class LogEvent {

		public static const INFO:int = 0;
		public static const ERROR:int = 1;
		public static const SUCCESS:int = 2;
		public static const WARNING:int = 3;
		public static const FATAL:int = 4;

		private var _type:int;
		private var _text:String;
		private var _event:Event;
		private var _date:Date;
		public static const LOGTYPE:Array = ["INFO","ERROR","SUCCESS","WARNING","FATAL"];
		private var _error_record:Object;
		
		public function LogEvent(type:int, text:String, event:Event = null,error_recorde:Object = null) {
			_type = type;
			_text = text;
			_event = event;
			_error_record=error_recorde;
			_date = new Date();
		}
		
		public function get errorRecord():Object{
			
			return _error_record;
		}
		
		public function get text():String {
			return _text;
		}
		
		public function get event():Event {
			return _event;
		}
		
		public function get type():int {
			return _type;
		}
		
		public function get date():Date {
			return _date;
		}

	}
}