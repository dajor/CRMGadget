package gadget.util {
	/** OOPStrace(line,...) like trace, adds it to the OOPS window, too.
	 */
	public function OOPStrace(...args):void {
		var s:String = args.join(" ");
		trace(s);
		if (s.substr(0,1)=="=")
			OOPSwindow.OOPS(s);
		else
			OOPSwindow.OOPS("=trace\n"+s);
	}
}
