package gadget.util {
	/** OOPS(line,...) - Output strings to OOPS window and trace() log.
	 * Use this to mark things in the source which needs attention in future,
	 * or which are known problems (like the time skew on the Siebel side).
	 * You can use it to mark things which are not yet implemented.
	 *
	 * IT SHALL BE USED LIKE AN ADDITIONAL TRACE IN RUNNING PRODUCTION CODE.
	 * Use "Aufrufhierachie" (dunno the English term.  Caller Hierarchy?)
	 * to locate all active OOPS calls in the code, makes it easy to spot
	 * that needs fixing.
	 *
	 * The idea is to send all type of errors, caches etc. to one text window
	 * which then later can be posted to support for this support to know what
	 * was going on.
	 * 
	 * If you remove an OOPS in the code, please be sure either the thingie is
	 * fixed or the one who introduced the OOPS agrees to it.
	 * 
	 * To "degrade" an OOPS but leave the output to the OOPSwindow, change the
	 * call from OOPS() to POOPS() (change import accordingly)
	 * 
	 * @param Strings - all arguments will be joined as strings with LF between 
	 */
	public function OOPS(...args):void {
//		if (!(new CacheUtil("OOPS").put(s,""))) return;

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
