//VAHI this name conflicts with com.adobe.coreUI.util.StringUtils;

package com.assessment {
	

	
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import mx.utils.StringUtil;
	
	public class StringUtils {
        //CRO 05.01.2011
		public static const ATTACHMENTS_STR:String = 'GLOBAL_ATTACHMENTS';
		public static const LOADING_STR:String = 'STRING_UTILS_LOADING_STR';
		public static const SAVING_DATA_STR:String = 'STRING_UTILS_SAVING_DATA_STR';
		public static const SAVING_PREF_STR:String = 'STRING_UTILS_SAVING_PREF_STR';
		
		/** null-aware version of ob.toString()
		 */
		public static function toString(ob:Object):String {
			return ob==null ? null : ob.toString();
		}
		
		
		public static function toBytes(str:String ):ByteArray{
			if(str==null){
				return null;
			}
			var bytes: ByteArray = new ByteArray();
			bytes.writeUTF(str);
			return bytes;
		}

		/** null-aware version of ob.toString().toUpperCase()
		 */
		public static function toUpperCase(ob:Object):String {
			return ob==null ? null : toString(ob).toUpperCase();
		}
		
		

		public static function reduceTextLength(value:String, len:int):String {
			//VAHI !=null as workaround to hinder continuous error popups
			if (value!=null && value.length > len) {
				return value.substr(0, len) + '...';
			}
			return value;
		}

 		public static function isEmpty(s:String):Boolean {
 			return s == null || StringUtil.trim(s) == '';
 		}
		
		public static function unNull(ob:Object):String {
			return ob==null ? '' : ob.toString();
		}
 		
 		public static function startsWith(s:String, start:String):Boolean {
 			if (s == null) return false;
 			if (start.length > s.length) return false;
 			return s.substr(0, start.length) == start;
 		}
 		
 		public static function endsWith(s:String, end:String):Boolean {
 			if (s == null) return false;
 			if (end.length > s.length) return false;
 			return s.substr(s.length - end.length) == end;
 		}
 		
 		/**
 		 * Modifies the value so that it can be included in an XML document.
 		 * "Lesser than" characters are replaced with "&lt;" 
 		 * @param s Value to modify.
 		 * @return XML escaped value.
  		 */
 		public static function xmlEscape(s:String):String {
			if (s==null)	//VAHI bugfix
				return "";
 			return s.replace(/&/g,"&amp;").replace(/</g, "&lt;");	//VAHI bugfix.  XML needs & and < escaped at minimum.
 		}
		
		public static function xmlUnEscape(s:String):String {
			if (s==null)
				return "";
				s = s.replace("/&amp;/g","&").replace("/&lt;/g","<").replace("/&gt;/g",">");
			return s;
		}
		
		//VAHI for SQL arguments: Embed the argument in doubled single quotes
		public static function sqlStrArg(s:String):String {
			if(s==null)
				return "''";
			return "'"+s.replace(/'/g,"''")+"'";
		}
 		
		public static function getExtension(s:String):String{
			if(s.lastIndexOf(".") == -1) return "";
			return s.substring(s.lastIndexOf(".")+1, s.length);
		}
		
		public static function removeExtension(s:String):String{
			return s.replace("." + getExtension(s),"");
		}
		
		

		/** Return true if the string contains a true value, false else.
		 * A "false" is a null or empty string, the number 0, "false" or "off".
		 * 
		 * @param str String or null
		 * @return Boolean false if string is something which should be false.
		 */
		public static function isTrue(s:String):Boolean {
			if (s==null || s=="" || s=="0" || s=="0." || s=="0.0")
				return false;
			s = s.toLocaleLowerCase();
			return s!="false" && s!="off";
		}
		
		public static function checkQuote(str:String):String{
			if((startsWith(str, "'") || startsWith(str, "\"")) 
					&& (endsWith(str, "'") || endsWith(str, "\""))) {
				return str.substring(1, str.length-1);
			}
			return str;
		}
		
		public static function replaceAll(str:String,pattern:String,replace:String):String {
			if(str==null) return "";
			var r:RegExp = new RegExp(pattern,"g");
			return str.replace(r, replace);
		}
		
		public static function replaceAll_(str:String,pattern:String,replace:String):String {
			if(str==null) return "";
			while(str.indexOf(pattern)!=-1){
				str = str.replace(pattern, replace);
			}
			return str;
		}
		
		
		public static function replaceStartEndBracket(str:String):String {
			return str.replace(/^\[+/, "").replace(/\]+$/, "");
		}
	
		public static function isNumber(s:String):Boolean {
			return !(/[^\d+]/.test(s));
		}

		
	}
}