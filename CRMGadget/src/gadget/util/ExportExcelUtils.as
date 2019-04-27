package gadget.util
{
	import com.as3xls.xls.ExcelFile;
	import com.as3xls.xls.Sheet;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	
	import mx.collections.ArrayCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.formatters.NumberFormatter;

	public class ExportExcelUtils
	{
		public function ExportExcelUtils()
		{
		}
		
		public static function export(listData:ArrayCollection,headers:ArrayCollection,callback:Function,isCheckAccount:Boolean=false):void{
			
			try
			{
				var xls:ExcelFile = new ExcelFile();
				var sheet:Sheet = new Sheet();
				xls.sheets.addItem(sheet);
				
				if(listData != null && listData.length>0){
					
					var listAccount:ArrayCollection = null;
					if(isCheckAccount){
						sheet.resize(listData.length+1,headers.length+1);
					}else{
						sheet.resize(listData.length+1,headers.length);
					}
					
					
					
					for(var h:int=0 ;h< headers.length;h++){
						var col:Object = headers[h];
						sheet.setCell(0,h,col.label);
					}
					
					if(isCheckAccount){
						listAccount = Database.accountDao.findAll(new ArrayCollection([{element_name:"CustomText35"}]));
						var n:String = "Account in CRM";
						sheet.setCell(0,headers.length,n);
					}
					
					var row:int = 1;
					for each(var obj:Object in listData){
						for(var c:int=0 ;c< headers.length;c++){
							var objCol:Object = headers[c];
							var val:String = obj[objCol.element_name];
							sheet.setCell(row,c,val);
							/*
							var isNum:Boolean = false;
							if(!isNaN(Number(val))){
								val = NumberUtils.format(val);
								isNum = true;
							}
							
						
							
							if(isNum){
								sheet.setCell(row,c,new Number(val));
							}else{
								sheet.setCell(row,c,val);
							}
							*/
						}
						if(isCheckAccount){
							var missingAccount:String = checkMissingAccount(obj["ShipToPrimary"],listAccount);
							sheet.setCell(row,headers.length,missingAccount);
						}
						
						row++;
					}
					var f:File = new File();
					//f.addEventListener(IOErrorEvent.IO_ERROR, exportErrorHandler);
					var bytes: ByteArray = xls.saveToByteArray();
					f.addEventListener(Event.SELECT, function (event:Event):void{
						var file:File = event.currentTarget as File;
						saveExcelFile(file,bytes,callback);
						
					});		
					f.browseForSave(i18n._('GLOBAL_SAVE'));
					
				}else{
					callback("Record is empty");
				}
			} 
			catch(error:Error) 
			{
				callback(error.message);
			}
			
			
		}
		
		private function exportErrorHandler(event:ProgressEvent):void
		{
			trace(event.type);
		}
		private static function checkMissingAccount(extId:String,ls:ArrayCollection):String{
			var val:String = "No";
			if(ls != null && ls.length>0){
				for each(var obj:Object in ls){
					if(extId == obj["CustomText35"]){
						val = "Yes";
						break;
					}
				}
			}
			return val;
		}
		private static function saveExcelFile(file:File,bytes: ByteArray,callback:Function):void{
			try
			{
				if(!file.extension) file = File.applicationStorageDirectory.resolvePath(file.nativePath + ".xls"); 
				
				var showText:String = "SUCCESSFULLY";
				if(file!=null){
					var fileStream:FileStream = new FileStream();
					fileStream.open(file, FileMode.WRITE);
					fileStream.writeBytes(bytes, 0, bytes.length);
					fileStream.close();
				}
			} 
			catch(error:Error) 
			{
				callback(error.message);
			}
			
		}
		
	}
}