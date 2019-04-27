package licenses
{
	import flash.desktop.*;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import licenses.TurboActivateEvent;

	public class TurboActivate extends EventDispatcher
	{
		/**
		 * The GUID for this product version. This is found on the LimeLM site on the version overview.
		 */
		public var VersionGUID : String;
		private var process:NativeProcess;

		private var FunctionProcessing:int = -1;
		private var RetCode:int;

		internal const FUNC_Activate:int = 0;
		internal const FUNC_ActivationRequestToFile:int = 1;
		internal const FUNC_ActivateFromFile:int = 2;
		internal const FUNC_CheckAndSavePKey:int = 3;
		internal const FUNC_Deactivate:int = 4;
		internal const FUNC_GetFeatureValue:int = 5;
		internal const FUNC_GetPKey:int = 6;
		internal const FUNC_GracePeriodDaysRemaining:int = 7;
		internal const FUNC_IsActivated:int = 8;
		internal const FUNC_IsGenuine:int = 9;
		internal const FUNC_IsProductKeyValid:int = 10;
		internal const FUNC_SetCustomProxy:int = 11;
		internal const FUNC_TrialDaysRemaining:int = 12;
		internal const FUNC_UseTrial:int = 13;
		internal const FUNC_ExtendTrial:int = 14;
		internal const FUNC_PDetsFromPath:int = 15;

		/**
		 * TurboActivate contructor.
		 */
		public function TurboActivate()
		{
			if (NativeProcess.isSupported)
			{
				// setup the native process
				launchSysta();
			}
			else
			{
				throw new Error("You must add <supportedProfiles>extendedDesktop</supportedProfiles> to your Adobe AIR Application Descriptor File (e.g. AppName-app.xml) before you can use TurboActivate.");
			}

			responseBuffer.endian = Endian.LITTLE_ENDIAN;
		}

		private function launchSysta():void
		{
			var file:File = File.applicationDirectory;

			if (Capabilities.os.toLowerCase().indexOf("win") > -1)
			{
				file = file.resolvePath("Windows/systa.exe");
				//file = file.resolvePath("Windows/TurboActivate.exe");
			}
			else if (Capabilities.os.toLowerCase().indexOf("mac") > -1)
			{
				file = file.resolvePath("Mac/systa");
			}
			else if (Capabilities.os.toLowerCase().indexOf("lin") > -1)
			{
				file = file.resolvePath("Linux/systa");
			}

			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = file;

			process = new NativeProcess();
			process.start(nativeProcessStartupInfo);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			process.addEventListener(NativeProcessExitEvent.EXIT, onExit);
			process.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onIOError);
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);

			// the Input/Output streams must be set to Little_endian
			// (since Adobe Air only runs on little endian machines)
			process.standardInput.endian = Endian.LITTLE_ENDIAN;
			process.standardOutput.endian = Endian.LITTLE_ENDIAN;
		}

		private function onExit(event:NativeProcessExitEvent):void
		{
			if (FunctionProcessing != -1)
			{
				var evt:TurboActivateEvent
				var err:Error = new Error("The systa process ended before the response could be delivered.", 1);

				// show an error for the function we're processing
				switch (FunctionProcessing)
				{
					case FUNC_Activate:
						evt = new TurboActivateEvent(TurboActivateEvent.ACTIVATE, 1, err);
						break;
					case FUNC_ActivationRequestToFile:
						evt = new TurboActivateEvent(TurboActivateEvent.ACTIVATION_REQUEST_TO_FILE, 1, err);
						break;
					case FUNC_ActivateFromFile:
						evt = new TurboActivateEvent(TurboActivateEvent.ACTIVATE_FROM_FILE, 1, err);
						break;
					case FUNC_CheckAndSavePKey:
						evt = new TurboActivateEvent(TurboActivateEvent.CHECK_AND_SAVE_PKEY, 1, err);
						break;
					case FUNC_Deactivate:
						evt = new TurboActivateEvent(TurboActivateEvent.DEACTIVATE, 1, err);
						break;
					case FUNC_GetFeatureValue:
						evt = new TurboActivateEvent(TurboActivateEvent.GET_FEATURE_VALUE, 1, err);
						break;
					case FUNC_GetPKey:
						evt = new TurboActivateEvent(TurboActivateEvent.GET_PKEY, 1, err);
						break;
					case FUNC_GracePeriodDaysRemaining:
						evt = new TurboActivateEvent(TurboActivateEvent.GRACE_PERIOD_DAYS_REMAINING, 1, err);
						break;
					case FUNC_IsActivated:
						evt = new TurboActivateEvent(TurboActivateEvent.IS_ACTIVATED, 1, err);
						break;
					case FUNC_IsGenuine:
						evt = new TurboActivateEvent(TurboActivateEvent.IS_GENUINE, 1, err);
						break;
					case FUNC_IsProductKeyValid:
						evt = new TurboActivateEvent(TurboActivateEvent.IS_PRODUCT_KEY_VALID, 1, err);
						break;
					case FUNC_SetCustomProxy:
						evt = new TurboActivateEvent(TurboActivateEvent.SET_CUSTOM_PROXY, 1, err);
						break;
					case FUNC_TrialDaysRemaining:
						evt = new TurboActivateEvent(TurboActivateEvent.TRIAL_DAYS_REMAINING, 1, err);
						break;
					case FUNC_UseTrial:
						evt = new TurboActivateEvent(TurboActivateEvent.USE_TRIAL, 1, err);
						break;
					case FUNC_ExtendTrial:
						evt = new TurboActivateEvent(TurboActivateEvent.EXTEND_TRIAL, 1, err);
						break;
					case FUNC_PDetsFromPath:
						evt = new TurboActivateEvent(TurboActivateEvent.PDETS_FROM_PATH, 1, err);
						break;
				}

				this.dispatchEvent(evt);

				FunctionProcessing = -1;
				UnfinishedProcessing = false;
			}
		}

		private function onIOError(event:IOErrorEvent):void
		{
			// failed to write/read to/from STDIN or STDOUT
			// kill the bad process (onExit should be called)
			if (process.running)
				process.exit(true);
		}

		private var UnfinishedProcessing:Boolean = false;
		private var responseBuffer: ByteArray = new ByteArray;
		private var remainingResp:int = 0;

		private function ReadString():Boolean
		{
			// read in the string length only on the first call
			if (!UnfinishedProcessing)
			{
				remainingResp = process.standardOutput.readInt();
				responseBuffer.clear();
			}

			// fill the buffer with all available bytes. 
			process.standardOutput.readBytes(responseBuffer, responseBuffer.length);

			remainingResp -= responseBuffer.length;

			// if we're all done, return false
			if (remainingResp == 0)
				return false;

			// we need to read more bytes
			UnfinishedProcessing = true;
			return true;
		}

		/**
		 * The product key is invalid or there's no product key.
		 */
		public const TA_E_PKEY:int = 2;

		/**
		 * Connection to the server failed.
		 */
		public const TA_E_INET:int = 4;

		/**
		 * The product key has already been activated with the maximum number of computers.
		 */
		public const TA_E_INUSE:int = 5;

		/**
		 * The product key has been revoked.
		 */
		public const TA_E_REVOKED:int = 6;

		/**
		 * The version GUID doesn't match that of the product details file. Make sure you set the GUID using TurboActivate.VersionGUID.
		 */
		public const TA_E_GUID:int = 7;

		/**
		 * The product details file "TurboActivate.dat" failed to load. It's either missing or corrupt.
		 */
		public const TA_E_PDETS:int = 8;

		/**
		 * CoInitializeEx failed.
		 */
		public const TA_E_COM:int = 11;

		/**
		 * Failed because your system date and time settings are incorrect. Fix your date and time settings, restart your computer, and try to activate again.
		 */
		public const TA_E_EXPIRED:int = 13;

		private function GetError(retCode:int, fallthroughError:String = null):Error
		{
			switch (retCode)
			{
				case 0:
					return null;
				case TA_E_PKEY:
					return new Error("The product key is invalid or there's no product key.", TA_E_PKEY);
				case TA_E_INET:
					return new Error("Connection to the server failed.", TA_E_INET);
				case TA_E_INUSE:
					return new Error("The product key has already been activated with the maximum number of computers.", TA_E_INUSE);
				case TA_E_REVOKED:
					return new Error("The product key has been revoked.", TA_E_REVOKED);
				case TA_E_GUID:
					return new Error("The version GUID \"" + VersionGUID + "\" doesn't match that of the product details file. Make sure you set the GUID using TurboActivate.VersionGUID.", TA_E_GUID);
				case TA_E_PDETS:
					return new Error("The product details file \"TurboActivate.dat\" failed to load. It's either missing or corrupt.", TA_E_PDETS);
				case TA_E_COM:
					return new Error("CoInitializeEx failed.", TA_E_COM);
				case TA_E_EXPIRED:
					return new Error("Failed because your system date and time settings are incorrect. Fix your date and time settings, restart your computer, and try to activate again.", TA_E_EXPIRED);
				default: // 
					if (fallthroughError == null)
						return null;
					else
						return new Error(fallthroughError, 1);
			}
		}

		private function onOutputData(event:ProgressEvent):void
		{
			var evt:TurboActivateEvent;

			if (!UnfinishedProcessing)
			{
				// get the return code
				RetCode = process.standardOutput.readInt();
			}

			switch (FunctionProcessing)
			{
				case FUNC_Activate:
					evt = new TurboActivateEvent(TurboActivateEvent.ACTIVATE, RetCode, GetError(RetCode, "Failed to activate."));
					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_ActivationRequestToFile:
					evt = new TurboActivateEvent(TurboActivateEvent.ACTIVATION_REQUEST_TO_FILE, RetCode, GetError(RetCode, "Failed to save the activation request file."));
					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_ActivateFromFile:
					evt = new TurboActivateEvent(TurboActivateEvent.ACTIVATE_FROM_FILE, RetCode, GetError(RetCode, "Failed to activate."));
					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_CheckAndSavePKey:
					evt = new TurboActivateEvent(TurboActivateEvent.CHECK_AND_SAVE_PKEY, RetCode, GetError(RetCode));
					evt.boolResponse = RetCode == 0;

					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_Deactivate:
					evt = new TurboActivateEvent(TurboActivateEvent.DEACTIVATE, RetCode, GetError(RetCode, "Failed to deactivate."));
					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_GetFeatureValue:
					// read in the string
					if (RetCode == 0 && ReadString())
						return;

					evt = new TurboActivateEvent(TurboActivateEvent.GET_FEATURE_VALUE, RetCode, GetError(RetCode, "Failed to get feature value. The feature doesn't exist."));

					if (RetCode == 0)
						evt.stringResponse = responseBuffer.readUTFBytes(responseBuffer.length);

					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_GetPKey:
					// read in the string
					if (RetCode == 0 && ReadString())
						return;

					evt = new TurboActivateEvent(TurboActivateEvent.GET_PKEY, RetCode, GetError(RetCode, "Failed to get the product key."));

					if (RetCode == 0)
						evt.stringResponse = responseBuffer.readUTFBytes(responseBuffer.length);

					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_GracePeriodDaysRemaining:
					evt = new TurboActivateEvent(TurboActivateEvent.GRACE_PERIOD_DAYS_REMAINING, RetCode, GetError(RetCode, "Failed to get the activation grace period days remaining."));

					if (RetCode == 0)
					{
						if (process.standardOutput.bytesAvailable == 0)
						{
							UnfinishedProcessing = true;
							return;
						}
						else
							evt.uintResponse = process.standardOutput.readUnsignedInt();
					}

					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_IsActivated:
					evt = new TurboActivateEvent(TurboActivateEvent.IS_ACTIVATED, RetCode, GetError(RetCode));
					evt.boolResponse = RetCode == 0;
					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_IsGenuine:
					evt = new TurboActivateEvent(TurboActivateEvent.IS_GENUINE, RetCode, GetError(RetCode));

					// is genuine if TA_OK or TA_E_REACTIVATE
					evt.boolResponse = RetCode == 0 || RetCode == 10;
					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_IsProductKeyValid:
					evt = new TurboActivateEvent(TurboActivateEvent.IS_PRODUCT_KEY_VALID, RetCode, GetError(RetCode));
					evt.boolResponse = RetCode == 0;
					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_SetCustomProxy:
					evt = new TurboActivateEvent(TurboActivateEvent.SET_CUSTOM_PROXY, RetCode, GetError(RetCode, "Failed to set the custom proxy."));
					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_TrialDaysRemaining:
					evt = new TurboActivateEvent(TurboActivateEvent.TRIAL_DAYS_REMAINING, RetCode, GetError(RetCode, "Failed to get the trial data."));

					if (RetCode == 0)
					{
						if (process.standardOutput.bytesAvailable == 0)
						{
							UnfinishedProcessing = true;
							return;
						}
						else
							evt.uintResponse = process.standardOutput.readUnsignedInt();
					}

					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_UseTrial:
					evt = new TurboActivateEvent(TurboActivateEvent.USE_TRIAL, RetCode, GetError(RetCode, "Failed to save the trial data."));
					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_ExtendTrial:
					evt = new TurboActivateEvent(TurboActivateEvent.EXTEND_TRIAL, RetCode, GetError(RetCode, "Failed to extend trial."));
					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
				case FUNC_PDetsFromPath:
					evt = new TurboActivateEvent(TurboActivateEvent.PDETS_FROM_PATH, RetCode, GetError(RetCode, "Failed to load product details file."));

					FinishedProcessing();
					this.dispatchEvent(evt);
					break;
			}
		}

		private function FinishedProcessing():void
		{
			// we've finished processing the function
			FunctionProcessing = -1;
			UnfinishedProcessing = false;
		}

		private function PreRun():void
		{
			if (process == null || !process.running)
				launchSysta();

			// throw an exception if the version GUID is null or empty
			if (VersionGUID == null || VersionGUID == "")
				throw new Error("You must set the VersionGUID property.");

			// throw an exception if another function is mid-processing
			if (FunctionProcessing != -1)
				throw new Error("Another TurboActivate function is waiting for a response, you must wait for a function to respond before making other function calls.");
		}

		/**
		 * Activates the product on this computer.
		 */
		public function Activate():void
		{
			PreRun();

			FunctionProcessing = FUNC_Activate;
			process.standardInput.writeInt(FUNC_Activate);
		}

		/**
		 * Get the "activation request" file for offline activation.
		 * @param filename The location where you want to save the activation request file.
		 */
		public function ActivationRequestToFile(filename:String):void
		{
			PreRun();

			FunctionProcessing = FUNC_ActivationRequestToFile;
			process.standardInput.writeInt(FUNC_ActivationRequestToFile);
			process.standardInput.writeUTF(filename);
		}

		/**
		 * Activate from the "activation response" file for offline activation.
		 * @param filename The location of the activation response file.
		 */
		public function ActivateFromFile(filename:String):void
		{
			PreRun();

			FunctionProcessing = FUNC_ActivateFromFile;
			process.standardInput.writeInt(FUNC_ActivateFromFile);
			process.standardInput.writeUTF(filename);
		}

		/**
		 * Checks and saves the product key.
		 * @param productKey The product key you want to save.
		 */
		public function CheckAndSavePKey(productKey:String):void
		{
			PreRun();

			FunctionProcessing = FUNC_CheckAndSavePKey;
			process.standardInput.writeInt(FUNC_CheckAndSavePKey);
			process.standardInput.writeUTF(productKey);
		}

		/**
		 * Deactivates the product on this computer.
		 * @param eraseProductKey Erase the product key so the user will have to enter a new product key if they wish to reactivate.
		 */
		public function Deactivate(eraseProductKey:Boolean = false):void
		{
			PreRun();

			FunctionProcessing = FUNC_Deactivate;
			process.standardInput.writeInt(FUNC_Deactivate);
			process.standardInput.writeBoolean(eraseProductKey);
		}

		/**
		 * Gets the value of a feature.
		 * @param featureName The name of the feature to retrieve the value for.
		 */
		public function GetFeatureValue(featureName:String):void
		{
			PreRun();

			FunctionProcessing = FUNC_GetFeatureValue;
			process.standardInput.writeInt(FUNC_GetFeatureValue);
			process.standardInput.writeUTF(featureName);
		}

		/**
		 * Gets the stored product key. NOTE: if you want to check if a product key is valid simply call IsProductKeyValid().
		 */
		public function GetPKey():void
		{
			PreRun();

			FunctionProcessing = FUNC_GetPKey;
			process.standardInput.writeInt(FUNC_GetPKey);
		}

		/**
		 * Get the number of days left in the activation grace period.
		 */
		public function GracePeriodDaysRemaining():void
		{
			PreRun();

			FunctionProcessing = FUNC_GracePeriodDaysRemaining;
			process.standardInput.writeInt(FUNC_GracePeriodDaysRemaining);
			process.standardInput.writeUTF(VersionGUID);
		}

		/**
		 * Checks whether the computer has been activated.
		 */
		public function IsActivated():void
		{
			PreRun();

			FunctionProcessing = FUNC_IsActivated;
			process.standardInput.writeInt(FUNC_IsActivated);
			process.standardInput.writeUTF(VersionGUID);
		}

		/**
		 * Checks whether the computer is genuinely activated by verifying with the LimeLM servers.
		 */
		public function IsGenuine():void
		{
			PreRun();

			FunctionProcessing = FUNC_IsGenuine;
			process.standardInput.writeInt(FUNC_IsGenuine);
			process.standardInput.writeUTF(VersionGUID);
		}

		/**
		 * Checks if the product key installed for this product is valid. This does NOT check if the product key is activated or genuine. Use IsActivated() and IsGenuine() instead.
		 */
		public function IsProductKeyValid():void
		{
			PreRun();

			FunctionProcessing = FUNC_IsProductKeyValid;
			process.standardInput.writeInt(FUNC_IsProductKeyValid);
			process.standardInput.writeUTF(VersionGUID);
		}

		/**
		 * Sets the custom proxy to be used by functions that connect to the internet.
		 * @param proxy The proxy to use. Proxy must be in the form "http://username:password@host:port/".
		 */
		public function SetCustomProxy(proxy:String):void
		{
			PreRun();

			FunctionProcessing = FUNC_SetCustomProxy;
			process.standardInput.writeInt(FUNC_SetCustomProxy);
			process.standardInput.writeUTF(proxy);
		}

		/**
		 * Get the number of trial days remaining.
		 */
		public function TrialDaysRemaining():void
		{
			PreRun();

			FunctionProcessing = FUNC_TrialDaysRemaining;
			process.standardInput.writeInt(FUNC_TrialDaysRemaining);
			process.standardInput.writeUTF(VersionGUID);
		}

		/**
		 * Begins the trial the first time it's called. Calling it again will validate the trial data hasn't been tampered with.
		 */
		public function UseTrial():void
		{
			PreRun();

			FunctionProcessing = FUNC_UseTrial;
			process.standardInput.writeInt(FUNC_UseTrial);
			process.standardInput.writeUTF(VersionGUID);
		}

		/**
		 * Extends the trial using a trial extension created in LimeLM.
		 * @param trialExtension The trial extension generated from LimeLM.
		 */
		public function ExtendTrial(trialExtension:String):void
		{
			PreRun();

			FunctionProcessing = FUNC_ExtendTrial;
			process.standardInput.writeInt(FUNC_ExtendTrial);
			process.standardInput.writeUTF(trialExtension);
		}
	}
}