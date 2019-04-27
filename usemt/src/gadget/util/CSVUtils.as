package gadget.util{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	
	import mx.collections.ArrayCollection;
	import mx.controls.LinkBar;
	
	public class CSVUtils {
		
		public function CSVUtils(){}
		
		public static function listToCSV(entity:String, filter_type:String, records:Object,buttonExportClick:Function, reportFields:Array=null):void{
			
			var fileBrow:File = new File();
			buttonExportClick(false);
			fileBrow.addEventListener(Event.SELECT, function (event:Event):void{
				var file:File = event.currentTarget as File;
				
				if(file.extension ==null || file.extension.toLocaleLowerCase() != 'csv') file = File.applicationStorageDirectory.resolvePath(file.nativePath + ".csv"); 
				
				var strCSV:String = "";
				var seperator:String =  Database.preferencesDao.getStrValue("cvs_separator",",");
				
				var eleNames:ArrayCollection = new ArrayCollection;
				
				var fieldsDB:ArrayCollection
				
				if(reportFields)
					fieldsDB = new ArrayCollection(reportFields);
				else{
					fieldsDB = Database.columnsLayoutDao.fetchColumnLayout(entity, filter_type);
					if(fieldsDB.length==0) fieldsDB = Database.columnsLayoutDao.fetchColumnLayout(entity);
				}
				for each (var field:Object in fieldsDB){
					var obj:Object = FieldUtils.getField(entity, field.element_name);
					if (obj) {
						eleNames.addItem(obj.element_name);
						strCSV += "\"" + obj.display_name + "\"" + seperator ;	
					}		
				}
				strCSV = strCSV.substring(0,strCSV.length-1) + "\n";
				trace("header>>>>>>>>" + strCSV);
				
				for each(var record:Object in records){
					for each(var eleName:String in eleNames){
						strCSV += "\"" + (record[eleName] != null ? record[eleName] : "") + "\"" + seperator;
					}
					strCSV = strCSV.substring(0,strCSV.length-1) + "\n";
				}
				trace("content>>>>>>>>" + strCSV);
				
				//var ba:ByteArray = new ByteArray();
				//ba.writeMultiByte(strCSV, "iso-8859-1");
				
				//var fileName:String = entity + " exported on " +  DateUtils.getCurrentDateAsSerial() + ".csv"; 
//				Utils.writeFile( fileName ,ba ).openWithDefaultApplication();
				Utils.writeToFile(file,strCSV);
				file.openWithDefaultApplication();
				buttonExportClick(true);
			});
			fileBrow.addEventListener(Event.CANCEL, function(event:Event):void{
				buttonExportClick(true);
			});
			fileBrow.browseForSave(i18n._('GLOBAL_SAVE'));
		}
		
	}
}