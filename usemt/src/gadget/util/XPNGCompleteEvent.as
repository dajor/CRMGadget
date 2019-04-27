package gadget.util {
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	/**
	 * XPNGCompleteEvents are dispatched when PNG encoding is done or when progress is noted
	 **/
	public class XPNGCompleteEvent extends Event
	{
		public static const PNG_COMPLETE:String = "pngComplete";
		
		private var _data:ByteArray; // PNG data
		
		/*
		* Constructor
		*      @type: The type of the event. Event listeners can
		*      access this information through the inherited type property.
		*
		*      @data: PNG data
		*
		*      @bubbles: Determines whether the Event object participates
		*      in the bubbling stage of the event flow. Event listeners can
		*      access this information through the inherited bubbles property.
		*
		*      @cancelable: Determines whether the Event object can be
		*      canceled. Event listeners can access this information through
		*      the inherited cancelable property.
		*/
		public function XPNGCompleteEvent( type:String, data:ByteArray, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
			
			_data = data;
		}
		
		/*
		* Retrieve PNG data
		*      @returns PNG data
		*/
		public function get data():ByteArray
		{
			return _data;
		}
		
		/*
		* Clone XPNGCompleteEvent
		*      @returns A new XPNGCompleteEvent object with property values that
		*                       match those of the original.
		*/
		override public function clone():Event
		{
			return new XPNGCompleteEvent( type, data, bubbles, cancelable );
		}
		
	}
}

