package gadget.util {
	import com.adobe.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	
	import gadget.dao.CustomFieldDAO;
	import gadget.i18n.i18n;
	
	import mx.core.Window;
	import mx.core.WindowedApplication;
    

    public class ReadCSVFile {
		
		import com.as3xls.xls.Sheet;
		
		import mx.collections.ArrayCollection;
		import mx.controls.Alert;
		
		private var xls:Class;
		private var sheet:Sheet;
		
		private static var colLabels:Array = ["Parent OOD Field Code","Parent OOD Field","Child OOD Field Code","Child OOD Field","Parent OOD Code","Parent OOD Value","Child OOD Code","Child OOD Value","Child Custom Code","Child Custom Value","Language"];
		private static var colKeys:Array = ["ParentOODField_Code","ParentOODField","ChildOODField_Code","ChildOODField","ParentOODCode","ParentOODValue","ChildOODCode","ChildOODValue","ChildCustomCode","ChildCustomValue","Language"];
		private var window_:Window;
		private var createImportCustomField_:Function;
		private var refreshListDataGrid_:Function;
		public function browseFile(window:Window,createImportCustomField:Function,refreshListDataGrid:Function):void{
			window_ = window;
			createImportCustomField_ = createImportCustomField;
			refreshListDataGrid_ = refreshListDataGrid;
			var file:File = new File();
			file.browseForOpen('PREFERENCES_FILE_OPEN_FILE', [new FileFilter("*.CSV", "*.csv")]);
			file.addEventListener(Event.SELECT, uploadFile);
			file.addEventListener(Event.CANCEL, cancelledFile);
			file.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
		}
		
		private function onLoadError(ioError:IOErrorEvent):void {
			Alert.show(i18n._('GLOBAL_IMPORT_FAILT'),i18n._("GLOBAL_IMPORT_CSV"), Alert.OK, window_);
		}
		
		private function cancelledFile(event:Event):void{
			
		}
		private function uploadFile(event:Event):void{
			var file:File = event.target as File;
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			try{
				var content:String = String(fileStream.readUTFBytes(fileStream.bytesAvailable));
				fileStream.close();
				trace('*** File loaded.');
				if(StringUtils.isEmpty(content)){
					Alert.show(i18n._("GLOBAL_DATA_IMPORT_IS_EMPTY"),i18n._("GLOBAL_IMPORT_CSV"), Alert.OK, window_);
				}else{
					processContent(content);
				}
			}catch(e:Error){
				Alert.show(e.message,i18n._("GLOBAL_IMPORT_CSV"), Alert.OK, window_);
				return;
			}
			
		}
		
		private function processContent(content:String):void {
			// Split the whole file into lines
			var listParentAndChild:ArrayCollection = new ArrayCollection();
			var listImport:ArrayCollection = new ArrayCollection();
			var lines:Array = content.split('\n');
			// Split each line into data content – start from 1 instead of 0 as this is a header line.
			if(lines.length>1 && !checkInValidCSV(lines[0])){
				for( var row:int=1;row<lines.length;row++ ) {
					var record:String = lines[row]; 
					record = record.replace("\r","");
					var values:Array = record.split(',');
					if(values.length >= colKeys.length){
						var cellObject:Object = new Object();
						for (var idx:int=0;idx<colKeys.length;idx++){
							cellObject[colKeys[idx]] = values[idx]; 
						}
						cellObject["entity"] = "Service Request";
						cellObject["languageCode"] = cellObject.Language;
						listImport.addItem(cellObject);
						var strParentAndChild:String = cellObject.ParentOODField + ";" + cellObject.ChildOODField + ";" + cellObject.languageCode ;
						if(!listParentAndChild.contains(strParentAndChild)){
							listParentAndChild.addItem(strParentAndChild);
						}
					}
				}
				createImportCustomField_(generateCustomRelatedPicklist(listImport,listParentAndChild));
				refreshListDataGrid_();
				Alert.show(i18n._("GLOBAL_IMPORT_SUCCESSFULLY"),i18n._("GLOBAL_IMPORT_CSV"), Alert.OK, window_);
			}
			trace(listImport.length);
			
		}	
		
		private function checkInValidCSV(header:String):Boolean{
			header = header.replace("\r","");
			var csvHeaders:Array = header.split(","); 
			for(var col:int=0;col<csvHeaders.length;col++) {
				var cellValue:String = StringUtil.trim(Utils.checkNullValue(csvHeaders[col]));
				if(cellValue!=colLabels[col]){
					Alert.show(i18n._('GLOBAL_INVALID_COLUMN') + ' ' + (col+1) + ' ['+ cellValue + '].' + i18n._('GLOBAL_IT_SHOULD_BE') + ' [' + colLabels[col] + '].',i18n._("GLOBAL_IMPORT_CSV"), Alert.OK, window_);
					return true;
				}
			}
			return false;
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
