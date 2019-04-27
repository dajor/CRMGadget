//VAHI added

package gadget.util
{
	import flash.display.Screen;
	import flash.system.Capabilities;

	import mx.core.Window;
	
	import gadget.dao.Database;

	public class PreferenceUtils
	{
		public static function WindowScreenBounds(ob:Window):Boolean {
			var w:int, h:int;
			var changed:Boolean;
			
			w	= Database.preferencesDao.getIntValue("MaxWidth"+ob.className, -1);
			h	= Database.preferencesDao.getIntValue("MaxHeight"+ob.className, -1);
			if (w<0)
				w	= Database.preferencesDao.getIntValue("MaxScreenWidth", -1);
			if (h<0)
				h	= Database.preferencesDao.getIntValue("MaxScreenHeight", -1);
			if (w<0)
				w	= Screen.mainScreen.visibleBounds.width;
			if (h<0)
				h	= Screen.mainScreen.visibleBounds.height;
			if (w<=0 || w>Capabilities.screenResolutionX)
				w	= Capabilities.screenResolutionX;
			if (h<=0 || h>Capabilities.screenResolutionY)
				h	= Capabilities.screenResolutionY;

			changed = false;
			if (ob.width > w) {
				ob.width = w;
				//ob.x = 0;
				//ob.nativeWindow.x = 0;
				changed = true;
			}
			if (ob.height > h) {
				ob.height = h;
				//ob.y = 0;
				//ob.nativeWindow.y = 0;
				changed = true;
			}
			return changed;
		}
	}
}