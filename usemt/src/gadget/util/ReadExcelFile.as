package gadget.util {
	
	import com.adobe.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import gadget.dao.CustomFieldDAO;
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	
	import mx.controls.Alert;
	import mx.core.Window;
	import mx.core.WindowedApplication;
    

    public class ReadExcelFile {
		
		
		// =====================================================================
		// import related picklist from excel
		import com.as3xls.xls.Cell;
		import mx.collections.ArrayCollection;		
		import com.as3xls.xls.Sheet;
		import com.as3xls.xls.ExcelFile;
		
		
		
		private var xls:Class;
		private var sheet:Sheet;
		private var fileReference:FileReference;
		private var colLabels:Array = ["Parent OOD Field Code","Parent OOD Field","Child OOD Field Code","Child OOD Field","Parent OOD Code","Parent OOD Value","Child OOD Code","Child OOD Value","Child Custom Code","Child Custom Value","Language"];
		private var colKeys:Array = ["ParentOODField_Code","ParentOODField","ChildOODField_Code","ChildOODField","ParentOODCode","ParentOODValue","ChildOODCode","ChildOODValue","ChildCustomCode","ChildCustomValue","Language"];
		private var window_:Window;
		private var createImportCustomField_:Function;
		private var refreshListDataGrid_:Function;
		
		public function browseAndUpload(window:Window,createImportCustomField:Function,refreshListDataGrid:Function):void{
			window_ = window;
			createImportCustomField_ = createImportCustomField;
			refreshListDataGrid_ = refreshListDataGrid;
			fileReference = new FileReference();				
			fileReference.addEventListener(Event.SELECT,fileReference_Select);				
			fileReference.addEventListener(Event.CANCEL,fileReference_Cancel);
			fileReference.browse();
		}
		private function fileReference_Select(event:Event):void{				
			fileReference.addEventListener(ProgressEvent.PROGRESS,fileReference_Progress);
			fileReference.addEventListener(Event.COMPLETE,fileReference_Complete);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
			fileReference.load();   
		}
		private function fileReference_Cancel(event:Event):void{
			fileReference = null;
		}
		private function fileReference_Progress(event:ProgressEvent):void {
			/*body not implemented*/
		}
		private function onLoadError():void {
			/*body not implemented*/
			Alert.show(i18n._('GLOBAL_IMPORT_FAILT'),i18n._("GLOBAL_IMPORT_EXCEL"), Alert.OK, window_);
		}
		
		private function fileReference_Complete(event:Event):void {
			var fileData:ByteArray  = fileReference.data;
			var excelFile:ExcelFile = new ExcelFile();
			var noOfRows:int;
			var noOfColumns:int;
			var cache:CacheUtils = new CacheUtils("import_customField");	
			var listParentAndChild:ArrayCollection = new ArrayCollection();
			var importList:ArrayCollection = new ArrayCollection();
			try{
				if(fileData!=null && fileData.length > 0){						
					excelFile.loadFromByteArray(fileData);
					var sheet:Sheet = excelFile.sheets[0];
					if(sheet!=null){
						noOfRows=sheet.rows;
						noOfColumns = sheet.cols;
						if(checkInValidExcel(sheet)) return;
						for(var row:int = 1; row<noOfRows;row++){
							var cellObject:Object ={};
							for(var col:int=0;col<noOfColumns;col++) {
								var cell:Cell = new Cell();
								var cellValue:String = new String();
								cell = sheet.getCell(row,col);
								if(cell!=null){
									cellValue =(cell.value).toString();									
									addProperty(cellObject,col,cellValue);
								}
							}// inner for loop ends	
							addFieldCode(cellObject,cache);
							importList.addItem(cellObject);
							var strParentAndChild:String = cellObject.ParentOODField + ";" + cellObject.ChildOODField + ";" + cellObject.languageCode ;
							if(!listParentAndChild.contains(strParentAndChild)){
								listParentAndChild.addItem(strParentAndChild);
							}
						} //for loop ends
					}   
				}				
				createImportCustomField_(generateCustomRelatedPicklist(importList,listParentAndChild));
				cache = null;
				fileReference = null;
				refreshListDataGrid_();
				Alert.show(i18n._("GLOBAL_IMPORT_SUCCESSFULLY"),i18n._("GLOBAL_IMPORT_EXCEL"), Alert.OK, window_);
			}catch(e:Error){
				Alert.show(e.message,i18n._("GLOBAL_IMPORT_EXCEL"), Alert.OK, window_);
				return;
			}
			
		}
		
		private function checkInValidExcel(sheet:Sheet):Boolean{
			for(var col:int=0;col<11;col++) {
				var cell:Cell = sheet.getCell(0,col);
				if(cell==null){
					// Alert.show(i18n._('column ' + (col+1) + ' is Empty.It should be [' + colLabels[col] + '].'),i18n._("GLOBAL_IMPORT_EXCEL"), Alert.OK, window_);
					return true;
				}
				var cellValue:String = StringUtil.trim(Utils.checkNullValue(cell.value));
				if(cellValue!=colLabels[col]){
					Alert.show(i18n._('GLOBAL_INVALID_COLUMN') + ' ' + (col+1) + ' ['+ cellValue + '].' + i18n._('GLOBAL_IT_SHOULD_BE') + ' [' + colLabels[col] + '].',i18n._("GLOBAL_IMPORT_EXCEL"), Alert.OK, window_);
					return true;
				}
			}
			return false;
		}
		
		private function addProperty(cellObject:Object,index:int,cellValue:String):void {
			if(index<colLabels.length) cellObject[colKeys[index]] = cellValue;
		}
		
		private function addFieldCode(cellObject:Object,cache:CacheUtils):void {
			var entity:String = "Service Request"; // CalculatedField.getComboDataField(cboEntitys.text);
			/*var parentField:String = cellObject.ParentOODField;
			var childField:String = cellObject.ChildOODField;
			var objParentField:Object = cache.get(parentField) as Object;
			var objChildField:Object = cache.get(childField) as Object;
			if(!objParentField){
				objParentField = Database.fieldDao.getFieldByDisplayName(entity , parentField);
				cache.put(entity + "/" + parentField, objParentField);
			}
			if(!objChildField){
				objChildField = Database.fieldDao.getFieldByDisplayName(entity,childField);
				cache.put(entity + "/" + childField, objChildField);
			}*/
			cellObject["entity"] = entity;
			cellObject["languageCode"] = cellObject.Language;
			//if(objParentField) cellObject["ParentOODField_Code"] = Utils.checkNullValue(objParentField.element_name);
			//if(objChildField) cellObject["ChildOODField_Code"] = Utils.checkNullValue(objChildField.element_name);
		}
		
		private function generateCustomRelatedPicklist(importList:ArrayCollection,listParentAndChild:ArrayCollection):ArrayCollection {
			var relatedPicklist:ArrayCollection = new ArrayCollection();
			for each(var strParentChildField:String in listParentAndChild){
				var objRelatedPicklist:Object = new Object();
				var listObject:ArrayCollection = new ArrayCollection();
				var listCustomValue:ArrayCollection = new ArrayCollection();
				var listParentCode:ArrayCollection = new ArrayCollection();
				for each(var objImport:Object in importList){
					var strPaC:String = objImport.ParentOODField + ";" + objImport.ChildOODField + ";" + objImport.languageCode;
					if(strPaC==strParentChildField){				
						if(!listParentCode.contains(objImport.ParentOODCode)){
							listParentCode.addItem(objImport.ParentOODCode);
						}
						if(!listCustomValue.contains(objImport.ChildCustomValue)){
							listCustomValue.addItem(objImport.ChildCustomValue);
						}
						listObject.addItem(objImport);
					}
				}
				
				if(listObject.length>0){
					objRelatedPicklist["entity"] = listObject[0].entity;
					objRelatedPicklist["fieldName"] = listObject[0].ChildOODField_Code;
					objRelatedPicklist["displayName"] = listObject[0].ChildOODField;
					objRelatedPicklist["bindField"] = listObject[0].ChildOODField_Code;
					objRelatedPicklist["parentPicklist"] = listObject[0].ParentOODField_Code;
					objRelatedPicklist["languageCode"] = listObject[0].languageCode;
					
					var value:String = "";
					var bindValue:String = "";
					for each(var strCustomValue:String in listCustomValue){
						if(!StringUtils.isEmpty(value)) value +=";";
						value += strCustomValue;
					}
					for each(var strP:String in listParentCode){
						if(!StringUtils.isEmpty(bindValue)) bindValue +="##";
						bindValue += strP + ":";var strBind:String = "";
						for each(var objP:Object in listObject){
							if(strP == objP.ParentOODCode){
								if(!StringUtils.isEmpty(strBind)) strBind +=";";
								if(objP.languageCode==CustomFieldDAO.DEFAULT_LANGUAGE_CODE){
									strBind += objP.ChildCustomCode + "=" + objP.ChildOODCode + "=" + objP.ChildOODValue;
								}else{
									strBind += objP.ChildCustomValue + "=" + objP.ChildOODCode + "=" + objP.ChildOODValue;
								}
							}							
						}
						bindValue += strBind;
					}
					objRelatedPicklist["value"] = value;
					objRelatedPicklist["bindValue"] = bindValue;						
					relatedPicklist.addItem(objRelatedPicklist);
				}
			}
			return relatedPicklist;
		}

    }

}
