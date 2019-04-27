package licenses
{
	import flash.events.Event;

	/**
	 * TurboActivateEvent adds the returned data from TurboActivate along with any error data.
	 */
	public class TurboActivateEvent extends Event 
	{
		/**
		 * Listeners to "ACTIVATE" event are called as a result of call to the TurboActivate.Activate() function. 
		 */
		public static const ACTIVATE:String = "ta_Activate";

		/**
		 * Listeners to "ACTIVATION_REQUEST_TO_FILE" event are called as a result of call to the TurboActivate.ActivationRequestToFile() function. 
		 */
		public static const ACTIVATION_REQUEST_TO_FILE:String = "ta_ActivationRequestToFile";

		/**
		 * Listeners to "ACTIVATE_FROM_FILE" event are called as a result of call to the TurboActivate.ActivateFromFile() function. 
		 */
		public static const ACTIVATE_FROM_FILE:String = "ta_ActivateFromFile";

		/**
		 * Listeners to "CHECK_AND_SAVE_PKEY" event are called as a result of call to the TurboActivate.CheckAndSavePKey() function. 
		 */
		public static const CHECK_AND_SAVE_PKEY:String = "ta_CheckAndSavePKey";

		/**
		 * Listeners to "DEACTIVATE" event are called as a result of call to the TurboActivate.Deactivate() function. 
		 */
		public static const DEACTIVATE:String = "ta_Deactivate";

		/**
		 * Listeners to "GET_FEATURE_VALUE" event are called as a result of call to the TurboActivate.GetFeatureValue() function. 
		 */
		public static const GET_FEATURE_VALUE:String = "ta_GetFeatureValue";

		/**
		 * Listeners to "GET_PKEY" event are called as a result of call to the TurboActivate.GetPKey() function. 
		 */
		public static const GET_PKEY:String = "ta_GetPKey";

		/**
		 * Listeners to "GRACE_PERIOD_DAYS_REMAINING" event are called as a result of call to the TurboActivate.GracePeriodDaysRemaining() function. 
		 */
		public static const GRACE_PERIOD_DAYS_REMAINING:String = "ta_GracePeriodDaysRemaining";

		/**
		 * Listeners to "IS_ACTIVATED" event are called as a result of call to the TurboActivate.IsActivated() function. 
		 */
		public static const IS_ACTIVATED:String = "ta_IsActivated";

		/**
		 * Listeners to "IS_GENUINE" event are called as a result of call to the TurboActivate.IsGenuine() function. 
		 */
		public static const IS_GENUINE:String = "ta_IsGenuine";

		/**
		 * Listeners to "IS_PRODUCT_KEY_VALID" event are called as a result of call to the TurboActivate.IsProductKeyValid() function. 
		 */
		public static const IS_PRODUCT_KEY_VALID:String = "ta_ProductKeyValid";

		/**
		 * Listeners to "SET_CUSTOM_PROXY" event are called as a result of call to the TurboActivate.SetCustomProxy() function. 
		 */
		public static const SET_CUSTOM_PROXY:String = "ta_SetCustomProxy";

		/**
		 * Listeners to "TRIAL_DAYS_REMAINING" event are called as a result of call to the TurboActivate.TrialDaysRemaining() function. 
		 */
		public static const TRIAL_DAYS_REMAINING:String = "ta_TrialDaysRemaining";

		/**
		 * Listeners to "USE_TRIAL" event are called as a result of call to the TurboActivate.UseTrial() function. 
		 */
		public static const USE_TRIAL:String = "ta_UseTrial";

		/**
		 * Listeners to "EXTEND_TRIAL" event are called as a result of call to the TurboActivate.ExtendTrial() function. 
		 */
		public static const EXTEND_TRIAL:String = "ta_ExtendTrial";

		/**
		 * Listeners to "PDETS_FROM_PATH" event are called as a result of call to the TurboActivate.PDetsFromPath() function. 
		 */
		public static const PDETS_FROM_PATH:String = "ta_PDetsFromPath";

		/**
		 * The return code of the TurboActivate function.
		 */
		public var retCode:int;

		/**
		 * The boolean response from a TurboActivate function. This contains the result of calls to CheckAndSavePKey, IsGenuine, IsActivated, and IsProductKeyValid.
		 */
		public var boolResponse:Boolean;

		/**
		 * The uint response from a TurboActivate function. This contains the result of calls to GracePeriodDaysRemaining and TrialDaysRemaining
		 */
		public var uintResponse:uint;

		/**
		 * The String response from a TurboActivate function. This contains the result of calls to GetFeatureValue and GetPKey
		 */
		public var stringResponse:String;

		/**
		 * The Error object is non-null if the function called failed.
		 */
		public var ErrorObj:Error = null;

		/**
		 *  Constructor.
		 *  @param evtType The event listener.
		 *  @param retCode The return code for the called function.
		 *  @param err An error object. If there's no error, pass in null.
		 */
		public function TurboActivateEvent(evtType:String, retCode:int, err:Error)
		{
			super(evtType);

			this.retCode = retCode;
			this.ErrorObj = err;
		}

		/**
		 * Creates and returns a copy of the current instance.
		 * @return	A copy of the current instance.
		 */
		public override function clone():Event
		{
			var ev:TurboActivateEvent = new TurboActivateEvent(this.type, retCode, ErrorObj);

			ev.boolResponse = this.boolResponse;
			ev.uintResponse = this.uintResponse;
			ev.stringResponse = this.stringResponse;

			return ev;
		}

		/**
		 * Returns a String containing all the properties of the current
		 * instance.
		 * @return A string representation of the current instance.
		 */
		public override function toString():String
		{
			return formatToString("TAEvent", "type", "bubbles", "cancelable", "eventPhase", "retCode", "boolResponse", "uintResponse", "stringResponse", "ErrorObj");
		}
	}
}