package gadget.util {
	/** POOPS(line,...) - Output strings to OOPS window alone.
	 *
	 * Convenience alternative to OOPS(), see there.
	 * 
	 * @see OOPS()
	 * @param Strings - all arguments will be joined as strings with LF between 
	 */
	public function POOPS(...args):void {
		OOPSwindow.OOPS("=info\n"+args.join("\n"));
	}
}
