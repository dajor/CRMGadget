package gadget.util {
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	public class TreeUtil {
		
		public static var territoryField:ArrayCollection = new ArrayCollection([
				{label: "id", data: "id"},
				{label: "cluster", data: "cluster"},
				{label: "region", data: "region"},
				{label: "subregion", data: "subregion"},
				{label: "sector", data: "sector"},
				{label: "salesoffice", data: "salesoffice"},
				{label: "vbez", data: "vbez"}
			]);
		
		public static var depthStructureField:ArrayCollection = new ArrayCollection([
			{label: "division", data: "division"},
			{label: "sector", data: "sector"},
			{label: "business_unit", data: "business_unit"},
			{label: "lang_text", data: "lang_text"},
			{label: "gbk", data: "gbk"}
		]);
		
		public function TreeUtil() { }
		
		public static function getTerritoryTree(tree:XML):ArrayCollection {
			var list:ArrayCollection = new ArrayCollection();
			for each(var child:XML in tree.children()) {
				processTerritoryChild(child, list);
			}
			return list;
		}
		
		private static function processTerritoryChild(process:XML, list:ArrayCollection, pObj:Object = null):void {			
			var currentObj:Object = new Object();			
			currentObj.id = process.@["id"][0].toString();			
			list.addItem(currentObj);			
			var o:Object = new Object();
			var y:Object = new Object();	
			if(pObj != null) {
				//set data from parent node
				for (var fld:String in pObj) {
					if(!currentObj.hasOwnProperty(fld)) {
						currentObj.pid = pObj.id;
						currentObj[fld] = pObj[fld];	
					}
				}
			}
			for each(var c:XML in process.children()) {
				if(c.name() == "territorynode") {
					processTerritoryChild(c, list, currentObj);
				}else {
					var i:int = c.children().length();
					if(i > 1) {
						var leaf:Object = new Object(); 
						for (var fd:String in currentObj) {
							if(!leaf.hasOwnProperty(fd)) {								
								leaf[fd] = currentObj[fd];	
							}
						}
						for each(var x:XML in c.children()) {							
							y[x.name()] = x.text().toString();
							if(y.hasOwnProperty("gid") && y.hasOwnProperty("lastname") && y.hasOwnProperty("firstname")) {
								leaf["vbez"] = y["lastname"] + " " + y["firstname"];
								
							}
								
						}
						leaf.display_name = leaf.vbez;
						leaf.id = y.gid;						
						leaf.pid = currentObj.id;
						leaf.vbez_value =leaf["vbez"];
						list.addItem(leaf);						
					}else {
						o[c.name()] = c.text().toString();
						if(o.hasOwnProperty("levelname") && o.hasOwnProperty("levelvalue"))
							currentObj[o["levelname"]] = o["levelvalue"];
						if(o.hasOwnProperty("shorttext")){
							currentObj.display_name = o.shorttext;
							currentObj[o["levelname"]+"_value"] = o.shorttext;
						} 
					}
				}
			}
		}
		
		public static function getDepthStructureTree(tree:XML):ArrayCollection {
			var list:ArrayCollection = new ArrayCollection();
			for each(var child:XML in tree.children()) {
				processDepthStructureChild(child, list);
			}
			return list;
		}
		
		private static function processDepthStructureChild(process:XML, list:ArrayCollection, pObj:Object = null):void {		
			var currentObj:Object = new Object();		
			var id:String = process.@["id"][0].toString();
			var type:String = process.@["type"][0].toString();
			currentObj.id = id;
			currentObj[type.replace(/\s+/, "_").toLowerCase()] = id;
			currentObj[type.replace(/\s+/, "_").toLowerCase()+"_value"] = id;
			list.addItem(currentObj);
			if(pObj != null) {
				//set data from parent node
				for (var fld:String in pObj) {
					if(!currentObj.hasOwnProperty(fld)) {
						currentObj.pid = pObj.id;
						currentObj[fld] = pObj[fld];	
					}
				}
			}
			var o:Object = new Object();
			for each(var c:XML in process.children()) {
				if(c.name() == "dsnode") {
					if(type=="Business Segment" || type=="Business Subsegment") continue;
					processDepthStructureChild(c, list, currentObj);
				}else {
					if(c.localName() == "GBK") {
						currentObj.gbk = c.text().toString();
						currentObj.gbk_value = c.text().toString();
					}else if(c.localName() == "text") {
						currentObj.lang_text = c.children()[3].toString(); // GE text germany
						currentObj.lang_text_value = c.children()[3].toString(); // GE text germany
						currentObj.display_name = c.children()[3].toString();
					}
				}
			}
		}
		
	}
}