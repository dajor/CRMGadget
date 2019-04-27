package gadget.util
{
	import flash.system.Capabilities;
	import flash.filesystem.File;
		
		
	public class CookieUtil
	{
		public function CookieUtil()
		{
		}

	
		/*
		
		The default storage location for Local Shared Objects is operating system-dependent.
		On Microsoft Windows, they are stored in:
		%APPDATA%\Macromedia\Flash Player\#SharedObjects\
		%APPDATA%\Macromedia\Flash Player\macromedia.com\support\flashplayer\sys\
		On Mac OS X, they are stored in:
		~/Library/Preferences/Macromedia/Flash Player/#SharedObjects/
		~/Library/Preferences/Macromedia/Flash Player/macromedia.com/support/flashplayer/sys/
		On Linux or Unix, they are stored in:
		~/.macromedia/Flash_Player/#SharedObjects/
		~/.macromedia/Flash_Player/macromedia.com/support/flashplayer/sys/
		
		
		
		*/
		
		public static function deleteLocalSODCookie():void{
			var dir:File = File.userDirectory;
			
			var os:String = Capabilities.os;
			var sep:String = File.separator;
			var txtCookiePath:String;
			
			switch ( true )
			{
				case os.substr(0, 7) == "Windows":
					dir = File.userDirectory.resolvePath("AppData"+sep+"Roaming");
					if ( !dir.exists )
					{
						dir = File.userDirectory.resolvePath("Application Data");
					}
					
					dir = dir.resolvePath("Macromedia"+sep+"Flash\ Player"+sep+"macromedia.com"+sep+"support"+sep+"flashplayer"+sep+"sys");
					
					break;
				case os.substr(0, 3) == "Mac":
					dir = dir.resolvePath("Library"+sep+"Preferences"+sep+"Macromedia"+sep+"Flash\ Player"+sep+"macromedia.com"+sep+"support"+sep+"flashplayer"+sep+"sys");
					break;
				//Assuming linux
				default:
					dir = dir.resolvePath(".macromedia"+sep+"Flash_Player"+sep+"macromedia.com"+sep+"support"+sep+"flashplayer"+sep+"sys");
					break;
			}
			if ( dir != File.userDirectory && dir.exists )
			{
				txtCookiePath = dir.nativePath;
				
				//Clear previous session if there was a problem
				var f:File = new File(txtCookiePath + sep + "settings.sol");
				if ( f.exists )
				{
					f.deleteFile();
				}
				
			}
			
			
		}
	}
}