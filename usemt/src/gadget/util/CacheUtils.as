package gadget.util
{
	import flash.utils.Dictionary;

	public class CacheUtils
	{
		private static var root:CacheUtils = new CacheUtils(null);

		protected var cache:Object;
		protected var childs:Object;
		protected var name:String;
		protected var parent:CacheUtils;

		public function CacheUtils(name:String, parent:CacheUtils=null) {
			this.name = name;
			this.cache = {};
			if (root==null) {
				if (name==null)
					return;
				root = new CacheUtils(null);
			}
			if (parent==null)
				parent = root;
			this.parent = parent;
			parent.child(this);	// calls init() with the empty cache
		}

		protected function child(chi:CacheUtils):void {
			if (childs==null)
				childs = {};
			if (!(chi.name in childs))
				childs[chi.name] = new Dictionary(true);
			childs[chi] = null;	//VAHI WTF?
			chi.init(def(chi.name,{}));
		}

		protected function init(cache:Object):void {
			this.cache = cache;
			revalidate_all();
		}

		protected function revalidate_all():void {
			if (childs!=null)
				for (var name:String in childs)
					revalidate(name);
		}
		
		protected function revalidate(child:String):void {
			var cache:Object=null;
			for (var chi:Object in childs[child]) {
				if (cache==null)
					cache = def(child,{});
				(chi as CacheUtils).init(cache);
			}
		}
		
		public function clear():void {
			parent.set(name,{});
		}

		public static function clear_all():void {
			if (root!=null)
				root.init({});
		}

		public function del(key:String):Boolean {
			if (!(key in cache))
				return false;
			delete cache[key];
			if (childs!=null && key in childs)
				revalidate(key);
			return true;
		}

		public function def(key:String, value:Object):Object {
			if (key in cache)
				return cache[key];
			cache[key] = value;
			return value;
		}

		public function put(key:String, value:Object):Boolean {
			if (key in cache && cache[key]===value)
				return false;
			cache[key] = value;
			if (childs!=null && key in childs)
				revalidate(key);
			return true;
		}

		public function get(key:String, def:Object=null):Object {
			if (!(key in cache))
				return def;
			return cache[key];
		}
		
		public function get_into(key:String, ret:Object, index:String=null, def:Object=null):CacheUtils {
			ret[index==null ? key : index] = get(key,def);
			return this;
		}
		
		public function has(key:String):Boolean {
			return key in cache;
		}

		public function set(key:String, value:Object):CacheUtils {
			put(key, value);
			return this;
		}

		public function unset(key:String):CacheUtils {
			del(key);
			return this;
		}
	}
}
