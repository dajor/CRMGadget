package gadget.util {
	/** OOPSthrow(line,...) throw error including it as OOPS
	 */
	public function OOPSthrow(...args):void {
		var s:String = args.join("\n");
		trace(s);
		OOPSwindow.OOPS("=throw "+s);
		throw new Error(s);
	}
}
