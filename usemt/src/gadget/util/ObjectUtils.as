package gadget.util
{
	
	/**  Some pythonic Object-iterables.  Sadly missing in JavaScript.
	 * @author VAHI
	 * @see keys(ob)
	 * @see values(ob)
	 * @see kv(ob)
	 * @see kvString(ob)
	 * @see getString(ob,i)
	 * @see DUMPOBJECT(ob)
	 */
	public class ObjectUtils
	{
		//VAHI we could add this to the protoype of Object as well.
		// But I do not know how to make FlashBuilder grok this.

		/** Get some more elaborate type name.
		 * @param ob  Object to test
		 * @return String  Object type like String, Array, Boolean, etc.
		 */
		public static function type(ob:Object):String {
			if (ob is String) return "String";
			if (ob is Array) return "Array";
			if (ob is Boolean) return "Boolean";
			if (ob is Function) return "Function";
			if (ob is Object) return "Object";
			if (ob == null) return "null";
			//if (ob === undefined) return "undefined";
			return "Unknown";
		}
		
		/** Shallow copy of object
		 */
		public static function shallow_copy(ob:Object):Object {
			if (ob==null)
				return {};
			var ret:Object = {};
			for (var s:String in ob) {
				ret[s]=ob[s];
			}
			return ret;
		}
		
		/** Merge in the second object, overwriting the first object entries
		 */
		public static function merge(ob:Object, plus:Object):Object {
			if (ob==null)
				ob = {};
			for (var s:String in plus) {
				ob[s]=plus[s];
			}
			return ob;
		}

		/** Flatten an object.
		 * This creates a key-value representation of the complete object.
		 * Currently only works for simple objects with no loops in it.
		 *
		 * flatten({a:[1,2,3],b:{c:['abc'],d:4}}) returns
		 * {".a[0]":1,".a[1]":2,".a[2]":3,".b.c[0]":'abc',".b.d":4}
		 * 
		 * @param ob Object
		 * @return Object with flattened representation of ob
		 */
		public static function flatten(ob:Object, key:String="", parent:Object=null):Object {
			if (parent==null)
				parent = {};
			function simple(s:String):String {
				if (s.search(/^[_a-zA-Z0-9]*$/)>=0)
					return s;
				return "'"+s.replace(/'/g,"''")+"'";
			}
			if (ob is int || ob is Number || ob is String || ob is Boolean) {
				parent[key]=ob;
			} else if (ob is Array) {
				for (var i:String in ob) {
					flatten(ob[i], key+'['+i+']', parent);
				}
			} else if (ob is Object) {
				if (key!="")
					key += ".";
				for (var k:String in ob) {
					flatten(ob[k], key+simple(k), parent);
				}
			} else {
				throw Error("object contains unusable type: "+type(ob));
			}
			return parent;
		}

		private static function toStringsArrayForSpeedup(ob:Object):Array {
			var flattened:Object = flatten(ob);
			// The important part is this sort here
			var keys:Array = keys(flattened).sort();
			var r:Array = [];
			for each (var k:String in keys) {
				r.push(k);
				r.push(':');
				var v:Object = flattened[k];
				if (v is String) {
					r.push('"');
					r.push(v.replace(/\\/g,"\\").replace(/"/g,"\""));
					r.push('"');
				} else {
					r.push(v.toString());
				}
				r.push('\n');
			}
			return r;
		}
		
		/** Object to String
		 * Two objects have the same contents and content structure
         * iff toString(ob1)==toString(ob2).
		 * So regardless of memory layout, the string always is the same.
		 * 
		 * @param ob Object
		 * @return String the serialized object
		 */
		public static function toString(ob:Object):String {
			return toStringsArrayForSpeedup(ob).join("");
		}
		
		/*VAHI not yet easy to create
		/** Object from String
		 * For now e use JSON, but perhaps in future we need more.
		 * @param s String
		 * @return Object the deserialized object
		 */
/*		public static function fromString(s:String):Object {
			return JSON.decode(s);
		}
*/		
		/** Get the keys of an Object as Array.
		 * Example: keys(ob).join(", ")
		 *
 		 * @param ob  Object to get keys from
		 * @return Array of Strings, the keys
		 * @see gadget.util.ObjectUtils
		 * @see kv
		 * @see String
		 */
		public static function keys(ob:Object):Array {
			var a:Array = [];
			for (var s:String in ob) {
				a.push(s);
			}
			return a;
		}

		/** Get the values of an Object as Array.
		 *
 		 * @param ob  Object to get values from
		 * @return Array of Objects, the values
		 * @see keys
		 * @see kv
		 */
		public static function values(ob:Object):Array {
			var a:Array = [];
			for each (var o:Object in ob) {
				a.push(o);
			}
			return a;
		}
		
		/** Get [key,value] pairs of an Object as Array.
		 *
		 * @param ob  Object to get values from
		 * @return Array of [key,value] pairs
		 * @see keys
		 * @see values
		 */
		public static function kv(ob:Object):Array {
			var a:Array = [];
			for (var s:String in ob) {
				a.push([s,ob[s]]);
			}
			return a;
		}

		/** Get key="value" Strings of an Object as Array.
		 * In "value" the characters &amp;, &lt; and &quot; are XML escaped.
		 *
		 * @param ob  Object to get values from
		 * @return Array of [key,value] pairs
		 * @see keys
		 * @see values
		 * @see kv
		 */
		public static function kvString(ob:Object):Array {
			var a:Array = [];
			for (var s:String in ob) {
				a.push(s+'="'+XmlUtils.escapeXML(getString(ob,s))+'"');
			}
			return a;
		}
		
		/** Get an object index as String ignoring nulls and other errors.
		 *
		 * @param on  Object (may be null)
		 * @param index  String to ob[index]
		 * @return String  value of ob[string].toString() or "(errortext)"
		 */
		public static function getString(ob:Object, index:String):String {
			if (ob == null)	return "(null object)";
			if (index == null) return "(null index)";
			if (!(index is String)) return "(nonstring index)";
			if (ob[index] == null)	return "(null)";
			try {
				return ob[index].toString();
			} catch(e:Object) {}
			return "(exception)";
		}

		/** For debugging purpose: Dump Object into a string, readable.
		 *
		 * @param on  Object (may be null)
		 * @return String  dumped object
		 */
		public static function DUMPOBJECT(ob:Object):String {
			return kvString(ob).join(",\n");
		}
		
		/** Return true if the object is something which can not be considered "false".
		 * This works for Booleans, Numbers, Strings, empty Arrays or Objects.
		 *
		 * @param ob Object which can be Boolean, Number, String, Array or Object
		 * @return Boolean true if it is something reasonable which can be considered "not false".
		 */
		public static function isTrue(ob:Object):Boolean {
			if (ob==null)
				return false;
			if (ob is Boolean)
				return ob as Boolean;
			if (ob is String)
				return StringUtils.isTrue(ob as String);
			if (ob is Array)
				return (ob as Array).length>0;
			if (ob is Number)
				return (ob as Number)==0;
			for (var a:String in ob)	return true;
			return false;
		}

		/** Helper to extract values from an object using and Array for list of keys.
		 * 
		 * @param ob Object to fetch values from
		 * @param arr Array list of keys (Strings) to lookup in Object
		 * @return Array list of values
		 * @see joinFields()
		 */
		public static function extractFields(ob:Object, arr:Array):Array {
			return arr.map(function (ent:Object, i:int, a:Array):String { return ob[ent as String]; });
		}
		
		/** Helper to extract values from an object and join them as strings.
		 *
		 * @param ob Object to fetch values from
		 * @param arr Array list of keys (Strings) to lookup in Object
		 * @param joiner String default " " (one single blank)
		 * @see extractFields()
		 */
		public static function joinFields(ob:Object, arr:Array, joiner:String = " "):String {
			return extractFields(ob, arr).join(joiner);
		}

		/** Create an object from an Array.
		 *
		 * The Array must have Array entries with a name-column at a fixed
		 * position to define the object properties.
		 * Also you need a creator function to create the property values.
		 *
		 * The Array must look like:
		 * [ ObjectDefiniton, [ "property1", val, val, val ], ["prop2", val, val, val], ... ]
		 *
		 * ObjectDefiniton is something like [ "name",{name:function}, ... ]
		 * denoting the creation function of the parameters which gets the parameter passed.
		 * If a function is missing, the parameter is just copied as is.
		 *
		 * The class must have following properties:
		 * It must have an empty constructor.
		 * And all properties must be public read/writeable.
		 * 
		 * @see SodUtils.transactionProperties
		 *
		 * @param arr Array which contains arrays for each object member.
		 * @param class Class which must have a public static generator() function creating itself.
		 * @param index offset into the sub-arrays for the names, default 0
		 * @return Object with properties of type class initialized to the Array data.
		 */
		public static function objectFromArray(arr:Array, cls:Class, index:int=0):Object {
			var ob:Object = {};
			var first:Boolean;
			var sample:Object;
			
			first = true;
			for each (var a:Array in arr) {
				if (first) {
					sample = a;
					first = false;
					continue;
				}

				var o:Object = new cls();
				ob[a[index]] = o;

				var i:int = 0;
				for each (var t:Object in sample) {
					var p:Object = a[i];
					if (t is String)
						o[t as String] = p;
					else
						for (var n:String in t) {
							var f:Object = t[n];
							//VAHI black magic
							// Actually "f.call(o,p)" and "new f(p)" are not exactly what
							// I want, but keep this to the future, as it works for the
							// normal cases.
							o[n] = f==null ? p : (f is Function) ? f.call(o, p) : new f(p);
						}
					i++;
				}
			}
			return ob;
		}
	}
}
