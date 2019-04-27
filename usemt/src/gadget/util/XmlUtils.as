package gadget.util
{
	/** Some XML helpers.
	 *
	 * @author VAHI
	 */
	public class XmlUtils
	{
		/** Reduce XML string to the pure data contents.
		 * This assumes that the XML does not contain stray &gt; characters.
		 * 
		 * @param data Object to clean up, if not a String the .toString() method is used.  null is ok.
		 * @return String with all &lt;...&gt; sequences removed, multiple spaces/newlines are compressed etc.
		 */
		public static function XMLcleanString(data:Object):String {
			if (data == null || data == "null" || data=="(null)")
				return "";

			var cleaned:String;
			
			cleaned = (data is String) ? (data as String) : data.toString();
			cleaned = cleaned.replace(/<[^>]*>/g," ").replace(/([[:space:]]|&nbsp;)+/g," ").replace(/   */g," ");
			return cleaned;
		}
		
		/** Escape characters &amp;
		 * 
		 * @param s String to escape, null treated as empty string
		 * @return String with &amp; replaced by &amp;amp;
		 */
		public static function escapeXMLamp(s:String):String {
			if (s == null) return "";
			return s.replace(/&/g,'&amp;');
		}
		/** Escape characters &amp; &lt; &gt;
		 * 
		 * @param s String to escape, null treated as empty string
		 * @return String without &amp; &lt; &gt;
		 */
		public static function escapeXML(s:String):String {
			return escapeXMLamp(s).replace(/</g,"&lt;").replace(/>/g,"&gt;");
		}

		/** Escape characters &amp;, &lt; &gt; &quot;
		 * 
		 * @param s String to escape, null treated as empty string
		 * @return String without &amp; &lt; &gt; &quot;
		 */
		public static function escapeXMLquot(s:String):String {
			return escapeXML(s).replace(/"/g,'&quot;');
		}
	}
}
