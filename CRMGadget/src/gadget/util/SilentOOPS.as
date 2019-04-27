package gadget.util {
	/** Like OOPS() but silent to normal users.
	 * 
	 * @see OOPS()
	 * @param Strings - all arguments will be joined as strings with LF between 
	 */
	public function SilentOOPS(...args):void {
		if (Debug.isVerbose())
			OOPSwindow.OOPS(args.join("\n"));

		// Trace the position
		try {
			throw Error("x");
		} catch (e:Error) {
			var t:String = e.getStackTrace();
			if (t) {
				//VAHI this only works when debugging.
				// that's exactly where it shall work.
				var a:Array = t.split("\n");
				t = a[2].replace(/^[[:space:]]*at /,"").replace(/\[[^\]]*[\\\/]/g,"[");
				trace("################################################################################################");
				trace("### OOPS at",t);
				trace("### ",args.join("\n###  "));
				trace("################################################################################################");
			}
		}
	}
}
