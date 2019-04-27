package gadget.dao {
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.utils.Dictionary;
	
	import gadget.service.LocaleService;
	import gadget.util.FieldUtils;
	
	import mx.collections.ArrayCollection;
	
	public class LayoutDAO extends SimpleTable {		
		
		var stmtSelectAllFields:SQLStatement;
		public function LayoutDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'detail_layout',
				index: ["entity", "subtype"],
				unique : ["entity, subtype, col, row"],
				columns: { 'TEXT' : textColumns, "INTEGER": integerColumns, "BOOLEAN" : booleanColumns, 'TEXT' : "max_chars"}
			});
			stmtSelectAllFields = new SQLStatement();
			stmtSelectAllFields.text = "select  entity,column_name, custom, readonly from detail_layout where entity=:entity and custom is NULL or custom ='' group by entity,column_name order by column_name";
			stmtSelectAllFields.sqlConnection = sqlConnection;
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
				}else if(col_name.indexOf(CustomLayout.BLOCK_DYNAMIC_CODE)>-1){
					obj["customField"]=Database.customFieldDao.selectCustomField(entity,col_name);
				}
			}
			return list;
		}
		public function selectAllFields(entity:String):ArrayCollection{
			var lst:ArrayCollection = new ArrayCollection();
			stmtSelectAllFields.parameters[":entity"]=entity;
			exec(stmtSelectAllFields);
			var result:SQLResult = stmtSelectAllFields.getResult();
			if (result.data == null || result.data.length == 0) {
				return new ArrayCollection();
			}
			return new ArrayCollection(result.data);
		}
		
		
		public function copyLayout(entity:String, srcSubType:String,destSubtype:String):void{
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {'entity':entity, 'subtype':srcSubType}));
			for each(var newObj:Object in list){
				newObj.subtype = destSubtype;
				insert(newObj);
			}
			Database.customFieldDao.copyCustomFieldWithSubType(entity, srcSubType,destSubtype);
			
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
		
		public function selectDynamicBlock(entity:String):ArrayCollection{
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity}));
			var result:ArrayCollection = new ArrayCollection();
			for each(var obj:Object in list){
				if (obj.column_name.indexOf(CustomLayout.BLOCK_DYNAMIC_CODE) > -1){
					result.addItem(obj);
				}
			}
			
			return result;
		}
		
		public function deleteLayout(entity:String, subtype:int,deleteCustomField:Boolean=true):void{
			if(deleteCustomField){
				Database.customFieldDao.deleteLayout(entity, subtype);
			}
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