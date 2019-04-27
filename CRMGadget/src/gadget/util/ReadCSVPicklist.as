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
    

    public class ReadCSVPicklist {
		
		import com.as3xls.xls.Sheet;
		
		import mx.collections.ArrayCollection;
		import mx.controls.Alert;
		
		private var xls:Class;
		private var sheet:Sheet;
		
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
			// get Picklist value Index.
			var columnRow:String = lines[0]; 
			if(lines.length>1 && checkValidCSV(columnRow)){
				var columns:Array = columnRow.split(',');
				var piclistIndex:int = 0;
				for (var i:int=0; i<columns.length; i++){
					if(columns[i] ==  "PicklistValue"){
						piclistIndex = i;
					}
				}
				
				for( var row:int=1; row<lines.length; row++ ) {
					var record:String = lines[row]; 
					record = record.replace("\r","");
					var values:Array = record.split(',');
					if(values.length >= 0 && !StringUtils.isEmpty(values[piclistIndex])){
						listImport.addItem(values[piclistIndex]);
					}
				}
				createImportCustomField_(listImport);
				refreshListDataGrid_();
				Alert.show(i18n._("GLOBAL_IMPORT_SUCCESSFULLY"),i18n._("GLOBAL_IMPORT_CSV"), Alert.OK, window_);
			}
			trace(listImport.length);
		}	
		
		private function checkValidCSV(header:String):Boolean{
			header = header.replace("\r","");
			var csvHeaders:Array = header.split(","); 
			/*for(var col:int=0; col< csvHeaders.length; col++) {
				var cellValue:String = StringUtil.trim(Utils.checkNullValue(csvHeaders[col]));
				if(cellValue == "PicklistValue"){
					return true;
				}
			}*/
			if(header.length>0){
				return true;
			}else{
				Alert.show(i18n._('GLOBAL_INVALID_COLUMN'), i18n._('Import Picklist Value'), Alert.OK, window_);			
				return false;
			}
		}
    }
	
	
	
	

}
