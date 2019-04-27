package gadget.util
{
	import mx.formatters.Formatter;

	
	/**
	 * Pattern formatter.
	 * 
	 * How to use :
	 * <code>var formatter:PatternFormatter = new PatternFormatter();</code>
	 * <code>formatter.pattern = "internal error in component {1} at {2}";</code>
	 * <code>return formatter.format(["myComp", 0]);</code>
	 * 
	 * Pattern syntax:
	 * <code>internal error in component {1} at {2}</code>
	 * <code>internal error in component {1.comp} at %{1.line}</code>
	 * <code>internal error in component {1.{2}}</code>
	 * <code>print first arg in braces {}{1}}</code>
	 */
	public class PatternFormatter extends Formatter
	{
		public var pattern:String = "";
		
		public function PatternFormatter()
		{
			super();
			
		}
		
		/**
		 * Formats an array according to the pattern. 
		 * @param value Array of values.
		 * @return Formatted string.
		 */
		override public function format(value:Object):String {
			if (!(value is Array)) {
				return "";
			}
			var args:Array = value as Array;
			var spl:Array = pattern.split('{');
			var ret:String= "";
			for (var i:int=spl.length;; ) {
				
				i--;
				ret=spl[i]+ret;
				if (i<=0)
					break;
				var idx:int	= ret.indexOf("}");
				if (idx<0) {
					trace("translate: missing } at",spl[i],"in",pattern);
					ret = "{"+ret;
					continue;
				}
				if (idx==0) {
					ret = "{"+ret.substr(1);
					continue;
				}
				var arg:String=ret.substr(0,idx);
				ret	= ret.substr(idx+1);
				
				var nr:int	= parseInt(arg);
				if (nr<1 || nr>args.length) {
					trace("translate: wrong arg index",arg,"in",pattern);
					ret = "(null)"+ret;
					continue;
				}
				//VAHI perhaps add support for 1.first.second.third...
				var o:Object = args[nr-1];
				var off:int=arg.indexOf(".");
				if (off>0) {
					try {
						o=o[arg.substr(off+1)];
					} catch (e:Error) {
						trace("translate: cannot expand index",arg,"in",pattern);
						ret="(null)"+ret;
						continue;
					}
				}
				try {
					ret=o.toString()+ret;
				} catch (e:Error) {
					trace("translate: cannot .toString()",arg,"in",pattern);
					ret="(null)"+ret;
				}
			}
			return ret;			
		}	
			
		
	}
}