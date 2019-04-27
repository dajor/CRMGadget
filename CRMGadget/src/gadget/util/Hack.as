package gadget.util {

	/** Place a hack-marker into the code which shows up when debugging.
	 * You do not need to tell where, this is shown automatically.
	 *
	 * @see OOPS()
	 * @param s String to tell what's wrong.
	 */
	public function Hack(s:String):void {
		try {
			throw Error("x");
		} catch (e:Error) {
			var t:String = e.getStackTrace();
			if (t) {
				//VAHI this only works when debugging.
				// that's exactly where it shall work.
				var a:Array = t.split("\n");
				t = a[2].replace(/^[[:space:]]*at /,"").replace(/\[[^\]]*[\\\/]/g,"[");
				if (new CacheUtils("Hack").put(t,s)) {
					trace("################################################################################################");
					trace("### Hack at",t);
					trace("### ",s);
					trace("################################################################################################");
				}
			}
		}
	}
}
