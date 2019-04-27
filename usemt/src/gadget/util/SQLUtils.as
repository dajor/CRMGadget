package gadget.util {
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;

	public class SQLUtils {
		
		private static var EQUALS_OPERATOR:String = "=";
		private static var DIFFERENT_OPERATOR:String = "!=";
		private static var CONTAINS_OPERATOR:String = "LIKE";
		private static var LESSER_THAN_OPERATOR:String = "<";
		private static var GREATER_THAN_OPERATOR:String = ">";
		private static var IS_EMPTY_OPERATOR:String = "is null";
		private static var IS_NOT_EMPTY_OPERATOR:String = "is not null";
		private static var BEGINS_WITH_OPERATOR:String = "LIKE%";
		
		public static function checkQueryGrid(sqlString:String, item:Object):Object {
			var returnObject:Object = new Object();
			returnObject.error = false;
			
			returnObject.sqlString = setParams(sqlString, item,true);
			sqlString = returnObject.sqlString;
			
			var sqlStringLower:String = sqlString.toLocaleLowerCase();
			var table:String = "";
			//var columns:String = "";
			var fields:Array = new Array();
			
			if (sqlStringLower.indexOf("select ")!=0 || sqlStringLower.indexOf(" from ")==-1 || sqlStringLower.indexOf(" * ")!=-1) {
				// Error
				returnObject.error = true;
			} else {
				var strOrderBy:String = "";
				var start:int = sqlStringLower.indexOf("select ") + 6;
				var end:int = sqlStringLower.indexOf(" from ");
				var whereIndex:int = sqlStringLower.indexOf(" where");
				var orderbyIndex:int = sqlStringLower.indexOf(" order by ");
				
				if (whereIndex!=-1) {
					table = StringUtil.trim(sqlStringLower.substring(end + 6, whereIndex));
				} else {
					table = StringUtil.trim(sqlStringLower.substring(end + 6, sqlStringLower.length));
				}
				
				var columnsStr:String  = sqlString.substring(start, end);
				var arrayColumns:Array = columnsStr.split(",");
				returnObject.entity = DAOUtils.getEntity(table);
				if (returnObject.entity == null) {
					returnObject.error = true;
					return returnObject;
				}
				
				var arrayDefaultValue:Array = new Array();
				
				if(orderbyIndex != -1) {
					strOrderBy = sqlString.substring(orderbyIndex);
					sqlString = sqlString.substring(0, orderbyIndex);
				}				
				
				var myPattern:RegExp = / and /gi;
				sqlString = sqlString.replace(myPattern, " and ");
				var conditions:Array = sqlString.substring(whereIndex + 6).split(" and ");
				
				for each(var condition:String in conditions){
					var tmpArray:Array = checkOperator(condition);
					if(tmpArray != null){
						var defaultValue:Object = new Object();
						defaultValue.key = StringUtil.trim(tmpArray[0]);
						defaultValue.value = StringUtils.checkQuote(StringUtil.trim(tmpArray[1]));
						// if the field is a picklist, its value must be present in picklist values
						var fieldObject:Object = FieldUtils.getField(returnObject.entity, defaultValue.key);
						if (fieldObject != null && fieldObject.data_type == 'Picklist') {
							var pickListObj:Object = new Object();
							pickListObj.record_type = returnObject.entity;
							pickListObj.field_name = defaultValue.key;
							pickListObj.value = defaultValue.value;
							if (Database.picklistDao.findByValue(pickListObj) == null) {
								defaultValue = null;
								returnObject.error = true;
							}
						}
						if (defaultValue != null) {
							arrayDefaultValue.push(defaultValue);
						}
					}
				}

				for each (var column:String in arrayColumns){
					var required:Boolean = StringUtil.trim(column).indexOf("*", 0) != -1;
					var fieldName:String = StringUtil.trim(column.replace(/\*/, "")).replace(/^\./,"");
					fieldObject = FieldUtils.getField(returnObject.entity,fieldName );
					if(!fieldObject) fieldObject = FieldUtils.getField(returnObject.entity,fieldName,false,true);
					if (fieldObject!=null) {
						// vm move it , error found when fieldObject = null
						fieldObject.required = fieldObject.required ? fieldObject.required : required;
						//if(columns != '') columns += ", ";
						//columns += fieldObject.element_name;
						fields.push({
							entity:       fieldObject.entity,
							element_name: fieldObject.element_name,
							display_name: fieldObject.display_name,
							data_type:    fieldObject.data_type,
							hidden:       (column.indexOf(".")>=0),
							required: fieldObject.required
						});	
					}
				}
				
				if(sqlStringLower.indexOf(" order by ")==-1){
					strOrderBy = " ORDER BY " + DAOUtils.getUpperColumn(returnObject.entity);
				}
				returnObject.sqlString = sqlString.substring(0, start) + " * " + sqlString.substring(end) + strOrderBy;
				returnObject.fields = fields;
				returnObject.arrayDefaultObject = arrayDefaultValue;
			}
			return returnObject;
		}
		
		public static function checkQueryField(sqlString:String, item:Object):Object {
			var object:Object = new Object();
			object.error = false;
			object.sqlString = setParams(sqlString, item,true);
			sqlString = object.sqlString;
			
			var sqlStringLower:String = sqlString.toLocaleLowerCase();
			if (sqlStringLower.indexOf("select ")!=0 || sqlStringLower.indexOf(" from ")==-1 || sqlStringLower.indexOf("*")!=-1) {
				// Error
				object.error = true;
			} else {
				var start:int = sqlStringLower.indexOf("select ") + 6;
				var end:int = sqlStringLower.indexOf(" from ");
				var columnsStr:String = sqlString.substring(start, end);
				
				var columnsStrLower:String = columnsStr.toLocaleLowerCase();
				if(columnsStrLower.indexOf(" as ") > -1 && columnsStrLower.indexOf(",") == -1){
					object.displayName = StringUtil.trim(columnsStr.substring(columnsStrLower.indexOf(" as ") + 4, end));
				}else if(columnsStrLower.indexOf(",") > -1){
					// Error
					object.error = true;
				}else{
					var table:int = sqlStringLower.indexOf(" where ");
					if(table == -1){
						table = sqlStringLower.length;
					} 
					var colName:String = StringUtil.trim(columnsStr);
					var entity:String = DAOUtils.getEntity(StringUtil.trim(sqlString.substring((end+5) ,table)).toLocaleLowerCase());
					var fieldInfo:Object= FieldUtils.getField(entity, colName);
					if(!fieldInfo) fieldInfo = FieldUtils.getField(entity, colName, false, true);
					if(fieldInfo == null || StringUtils.isEmpty(fieldInfo.display_name)){
						object.display_name =colName;
						object.column_name = colName;
					}else{
						object.column_name = fieldInfo.element_name ;
						object.display_name = fieldInfo.display_name ;
					}
				}
			}
			return object;
		}
		
		/**
		 * Replace the parameters in the SQLQuery with the item field values.  
		 * @param s String to modify.
		 * @param item Current item.
		 * @param addQuotes Do we add quotes ?
		 * @return Updated query.
		 */
		public static function setParams(s:String, item:Object, addQuotes:Boolean):String {
			// we create a work string where percent sign inside quotes is replaced with space
			var work:String = s;
			var insideQuotes:Boolean = false;
			for (var i:int = 0; i < work.length; i++) {
				if (work.charAt(i) == "'") insideQuotes = !insideQuotes;
				if (work.charAt(i) == "%" && insideQuotes) {
					work = work.substr(0, i) + " " + work.substr(i + 1);
				}
			} 
			while (true) {
				var paramStart:int = work.indexOf("%");
				
				if (paramStart == -1) break;
				var paramEnd:int = work.indexOf("%", paramStart + 1);
				if (paramEnd == -1) break;
				var paramName:String = s.substring(paramStart + 1, paramEnd);
				s = s.replace("%" + paramName + "%", addQuotes ? StringUtils.sqlStrArg(item[paramName]) : item[paramName]);
				work = work.replace("%" + paramName + "%", addQuotes ? StringUtils.sqlStrArg(item[paramName]) : item[paramName]);
			}
			return s;
		}
		
		private static function checkOperator(value:String):Array{
			var array:Array;
			if(value.indexOf("=")>-1){
				array = value.split("=");
			}
			return array;
		}
		
		
		/**
		 * 
		 * @param criteria {column_name: column_name, operator: operator, param: param, conjunction: conjunction}
		 * @return boolean
		 * 
		 */
		private static function isCriteriaCompleted(criteria:Object):Boolean {
			var column_name:String = criteria.column_name;
			var operator:String = criteria.operator;
			var param:String = criteria.param;
			var bParamNotRequired:Boolean = StringUtils.startsWith(operator, "is");
			if(bParamNotRequired){
				if(StringUtils.isEmpty(column_name) || StringUtils.isEmpty(operator)) {
					return false;	
				}else{
					return true;
				}
			}else{
				if(StringUtils.isEmpty(column_name) || StringUtils.isEmpty(operator) || StringUtils.isEmpty(param)){
					return false;
				}else{
					return true;
				}
			}
		}
		
		/**
		 * 
		 * @param criteria {column_name: column_name, operator: operator, param: param, conjunction: conjunction}
		 * @return String conditon eg: AccountName="joke", AccountName is not null, AccountName like '%joke%', ...
		 * 
		 */
		public static function setCondition(criteria:Object, isBindableField:Boolean = false):String {
			switch(criteria.operator) {
				// = / !=
				case EQUALS_OPERATOR:
				case DIFFERENT_OPERATOR:
					return isCriteriaCompleted(criteria) ? (criteria.column_name + criteria.operator + (isBindableField ? "%" + criteria.param + "%" : "'" + criteria.param + "'") + " " + criteria.conjunction + " ") : "";
				// LIKE / LIKE%
				case CONTAINS_OPERATOR:
				case BEGINS_WITH_OPERATOR:
					return isCriteriaCompleted(criteria) ? (criteria.column_name + " like '" + (criteria.operator==CONTAINS_OPERATOR ? "%" + criteria.param + "%" : criteria.param + "%") + "' " + criteria.conjunction + " ") : "";
				// < / >
				case LESSER_THAN_OPERATOR:
				case GREATER_THAN_OPERATOR:
					return isCriteriaCompleted(criteria) ? (criteria.column_name + " " + criteria.operator + " " + (StringUtils.isNumber(criteria.param) ? criteria.param : "'" + criteria.param + "'" ) + " " + criteria.conjunction + " ") : "";
				// is empty / is not empty
				case IS_EMPTY_OPERATOR:
				case IS_NOT_EMPTY_OPERATOR:
					return isCriteriaCompleted(criteria) ? (criteria.column_name + " " + criteria.operator + " " + criteria.conjunction + " ") : "";
				// order column
				default: 
					return criteria.column_name ? criteria.column_name + " " + criteria.param : "";
			}
		}
		
		
	}	
}