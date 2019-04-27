package gadget.dao {
	
	import flash.data.SQLConnection;
	import flash.utils.Dictionary;
	
	import gadget.service.LocaleService;
	import gadget.util.FieldUtils;
	
	import mx.collections.ArrayCollection;
	
	public class LayoutDAO extends SimpleTable {		
		public function LayoutDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'detail_layout',
				index: ["entity", "subtype"],
				unique : ["entity, subtype, col, row"],
				columns: { 'TEXT' : textColumns, "INTEGER": integerColumns, "BOOLEAN" : booleanColumns, 'TEXT' : "max_chars"}
			});
		}
		
		private var textColumns:Array = [
			"entity", 
			"column_name", 
			"custom" // ,
			// "max_chars"
			
		];
		
		private var integerColumns:Array = [
			"subtype",
			"col", 
			"row"
		];
		
		private var booleanColumns:Array = [
			"readonly", 
			"mandatory"
		];
		
		private var vars:String = "entity, subtype, col, row, column_name, custom, readonly, mandatory,max_chars";
		
		public function selectLayout(entity:String, subtype:int):ArrayCollection {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, subtype:subtype}));
			var languageCode:String = LocaleService.getLanguageInfo().LanguageCode;
			var customTrans:Dictionary = Database.customFieldDao.selectCustomFieldWithSubTypeAsDic(entity,subtype,languageCode);
			for each(var obj:Object in list){
				var col_name:String = obj.column_name;
				if (col_name.indexOf(CustomLayout.CALCULATED_CODE) > -1 || col_name.indexOf("#") > -1){
					// if(col_name.indexOf("#") > -1) col_name += "_" + obj.col;
					var objCustomField:Object = customTrans[col_name];
					obj["customField"] = objCustomField;
				}if (obj.column_name.indexOf(CustomLayout.SQLLIST_CODE) > -1){
					var criterias:ArrayCollection = Database.sqlListDAO._select(obj.entity, obj.column_name);
					obj["criterias"] = criterias;
				}
			}
			return list;
		}
		
		public function existLayout(entity:String, subtype:int):Boolean {
			var result:Array = select("Count(*) AS total",null,{entity:entity, subtype:subtype});
			return parseInt(result[0].total)>0;
		}
		
		public function selectCustomFields(entity:String):ArrayCollection {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity}));
			var customFieldlist:ArrayCollection = new ArrayCollection();
			for each(var obj:Object in list){
				if (obj.column_name.indexOf(CustomLayout.CUSTOMFIELD_CODE) > -1){
					// var objCustomField:Object = Database.customFieldDao.selectCustomField(obj.entity,obj.column_name);
					var customFieldInfo:Object = FieldUtils.getField(obj.entity, obj.column_name,true);
					if(customFieldInfo){
						customFieldlist.addItem(customFieldInfo);
					} 
				}
			}
			return customFieldlist;
		}
		
		public function deleteLayout(entity:String, subtype:int):void{
			Database.customFieldDao.deleteLayout(entity, subtype);
			Database.sqlListDAO.delete_({entity_src: entity});
			delete_({entity:entity, subtype:subtype});
		}
		
		public function getReadOnlyField(entity:String):Dictionary{
			var where:String = " Where entity='" + entity + "' and readonly=true";
			var result:Array = select_order("*", where, null, null,null);
			var dic:Dictionary = new Dictionary();
			if(result!=null && result.length>0){
				for each(var obj:Object in result){
					dic[obj.column_name]=obj;
				}
			}
			
			return dic;
		}
		/*public function selectAll(entity:String):ArrayCollection {
			return new ArrayCollection(select_order(vars, "", {entity: entity}, "col, row", null));
		}
	
		public function updateLayout(detailLayout:Object):void {
			update(detailLayout, "", {entity:detailLayout.entity, subtype:detailLayout.subtype}); 
		}*/
		
	}
}