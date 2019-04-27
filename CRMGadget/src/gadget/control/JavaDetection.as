package gadget.control
{
	import com.aaronhardy.javaUtils.install.JavaInstallEvent;
	import com.aaronhardy.javaUtils.install.JavaInstallUtil;
	import com.aaronhardy.javaUtils.version.JavaValidationEvent;
	import com.aaronhardy.javaUtils.version.JavaValidationUtil;
	
	import flash.events.ErrorEvent;
	import flash.system.Capabilities;
	
	import gadget.window.WindowManager;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;

	public class JavaDetection
	{
		
		
		protected const WHEREIS_PATH:String = 'assets/whereis/whereis.exe';
		protected const INSTALLER_PATH:String = 'assets/whereis/jre-6u20-windows-i586-iftw-rv.exe';
		
		protected const REQUIRED_MAJOR:uint = 1;
		protected const REQUIRED_MINOR:uint = 6;
		protected const REQUIRED_REVISION:uint = 0;
		protected const REQUIRED_UPDATE:uint = 20;
		
		protected var javaValidation:JavaValidationUtil;
		protected var javaInstallation:JavaInstallUtil;
		private var mainWindown:MainWindow;
		
		public function JavaDetection(mainWindown:MainWindow)
		{
			this.mainWindown = mainWindown;
			creationCompleteHandler();
		}
		
		public function creationCompleteHandler():void
		{
			var os:String = flash.system.Capabilities.os.substr(0, 3);
			var touchscreenType:String = flash.system.Capabilities.touchscreenType;
			flash.system.Capabilities.touchscreenType.length;
			if(touchscreenType=="none"){
				if (!(os == "Win")) {
					openSignatureWindow(true);
				} else {
					validateJava();
				}
			}else{
				openSignatureWindow(true);
			}
			
			
		}
		
		/**
		 * Start off by determining if the user has the required JRE or newer installed.
		 */
		protected function validateJava():void
		{
			javaValidation = new JavaValidationUtil();
			javaValidation.addEventListener(
				JavaValidationEvent.JAVA_VALIDATED, javaValidatedHandler);
			javaValidation.addEventListener(
				JavaValidationEvent.JAVA_INVALIDATED, javaInvalidatedHandler);
			javaValidation.addEventListener(
				JavaValidationEvent.JAVA_NOT_FOUND, javaNotFoundHandler);
			javaValidation.validate(
				WHEREIS_PATH, 
				REQUIRED_MAJOR,
				REQUIRED_MINOR,
				REQUIRED_REVISION,
				REQUIRED_UPDATE);
		}
		
		protected function javaValidatedHandler(event:JavaValidationEvent):void
		{
//			Alert.show('Congrats, your java runtime version (' + event.major + '.' + 
//				event.minor + '.' +	event.revision + '_' + event.update + ') is ' +
//				'sufficient for this application.','Congrats',Alert.YES,this.mainWindown);
			//cleanJavaValidation();
			openSignatureWindow();
		}
		
		protected function javaInvalidatedHandler(event:JavaValidationEvent):void
		{
			Alert.show('This application requires java runtime ' + 
				formatVersion(REQUIRED_MAJOR, REQUIRED_MINOR, REQUIRED_REVISION, REQUIRED_UPDATE) +  
				' or newer but version ' + 
				formatVersion(event.major, event.minor, event.revision, event.update)+ 
				' is currently installed. Would you like to install a newer runtime now?',
				'Java not found', Alert.YES|Alert.NO, this.mainWindown, alertCloseHandler);
			//cleanJavaValidation();
			//openSignatureWindow();
		}
		
		protected function javaNotFoundHandler(event:JavaValidationEvent):void

			Alert.show('No java runtime was found. Would you like to install the runtime now?',
				'Java not found', Alert.YES|Alert.NO, this.mainWindown, alertCloseHandler);
			//cleanJavaValidation();
			//openSignatureWindow();
		}
		
		private function openSignatureWindow(isTouch:Boolean=false):void{
			var signature:EpadSignatureWindow = new EpadSignatureWindow();
			signature.isTouch=isTouch;
			WindowManager.openModal(signature);
		}
		
		protected function cleanJavaValidation():void
		{
			javaValidation.removeEventListener(
				JavaValidationEvent.JAVA_VALIDATED, javaValidatedHandler);
			javaValidation.removeEventListener(
				JavaValidationEvent.JAVA_INVALIDATED, javaInvalidatedHandler);
			javaValidation.removeEventListener(
				JavaValidationEvent.JAVA_NOT_FOUND, javaNotFoundHandler);
			javaValidation = null
		}
		
		protected function alertCloseHandler(event:CloseEvent):void
		{
			if (event.detail == Alert.YES)
			{
				installJava();
			}
			else if (event.detail == Alert.NO)
			{
				//exit();
				openSignatureWindow(true);
				
			}
		}
		
		/**
		 * If the user doesn't have an adequate JRE installed and chooses to install an
		 * adequate JRE, start the installation process.
		 */
		protected function installJava():void
		{
			javaInstallation = new JavaInstallUtil();
			javaInstallation.addEventListener(JavaInstallEvent.COMPLETE, installCompleteHandler);
			javaInstallation.addEventListener(ErrorEvent.ERROR, installErrorHandler);
			javaInstallation.install(INSTALLER_PATH, WHEREIS_PATH);
		}
		
		protected function installCompleteHandler(event:JavaInstallEvent):void
		{
			Alert.show('The java runtime was successfully installed.');
			cleanJavaInstallation()
		}
		
		protected function installErrorHandler(event:ErrorEvent):void
		{
			Alert.show('An error occurred while installing the java runtime:\n\n' + event.text);
			cleanJavaInstallation()
		}
		
		protected function cleanJavaInstallation():void
		{
			javaInstallation.removeEventListener(JavaInstallEvent.COMPLETE, installCompleteHandler);
			javaInstallation.removeEventListener(ErrorEvent.ERROR, installErrorHandler);
			javaInstallation = null;
		}
		
		/**
		 * Formats version segments into a string according to java specs.
		 * 
		 * @see http://java.sun.com/j2se/versioning_naming.html
		 */
		protected function formatVersion(major:uint, minor:uint, revision:uint, update:uint):String
		{
			return major + '.' + minor + '.' + revision + '_' + update;
		}	
	}
}