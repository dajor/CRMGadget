package
{
	
	
	
	import com.assessment.DtoAssessmentPDFHeader;
	import com.assessment.DtoColumn;
	import com.assessment.DtoConfiguration;
	import com.assessment.DtoPage;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import gadget.assessment.AssessmentModelTotal;
	import gadget.assessment.AssessmentPageTotal;
	import gadget.assessment.AssessmentSectionTotal;
	import gadget.assessment.IAssessmentTotal;
	import gadget.control.CustomPurePDF;
	import gadget.dao.ActivityDAO;
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.service.PicklistService;
	import gadget.util.DateUtils;
	import gadget.util.FieldUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.formatters.DateFormatter;
	import mx.utils.StringUtil;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.pdf.PdfDocument;
	
	public class AssessementPDF 
	{
		[Embed(source="/assets/check.png",mimeType="application/octet-stream")]
		private var checkEmbed:Class;
		[Embed(source="/assets/uncheck.png",mimeType="application/octet-stream")]
		private var uncheckEmbed:Class;
		[Embed(source="/assets/TRiggmat_header_pic.png",mimeType="application/octet-stream")]
		private var triggmatHeaderPicEmbed:Class;
		[Embed(source="/assets/Miljö_header_pic.png",mimeType="application/octet-stream")]
		private var miljoHeaderPicEmbed:Class;
		
		private var checkImg: ImageElement ;
		private var uncheckImg: ImageElement ;
		private var triggmatHeaderPic: ImageElement ;
		private var miljoHeaderPic: ImageElement ;
		private var lstTask:ArrayCollection;
		private var appItem:Object;
		private var document:PdfDocument;
		private var colorHeaderGrid:org.purepdf.colors.RGBColor = new org.purepdf.colors.RGBColor();
		private var colorROW:org.purepdf.colors.RGBColor = new org.purepdf.colors.RGBColor();
		private var colorBGPage:org.purepdf.colors.RGBColor = new org.purepdf.colors.RGBColor();
		private var colorBGData:org.purepdf.colors.RGBColor = new org.purepdf.colors.RGBColor();
		private var arrColorData:Array = new Array();
		private var arrColorPage:Array = new Array();
		private var arrColorHeaderGrid:Array = new Array();
		private var pdf:CustomPurePDF;
		private var bgColorHeaderGrid:Object = Preferences.BLACK;
		private var bgColorPage:Object = Preferences.WHITE;	
		private var bgColorData:Object = Preferences.RED;
		private var lstColumn:Array = new Array();
		private var colQuestionWidth:int = 16;
		private var colAnswerWidth:int = 2;
		private var colComment:int = 6;
		private var mapTask:Dictionary=null;
		private var model:DtoConfiguration;
		private var modelTotal:AssessmentModelTotal;
		private var accName:String ;
		private var amountShowedSection:int = 14;
		private var quesLimit:int = 35;
		private var maxline:int=38;
		private var paddingSecName:int = 8;
		
		private var colCheckboxWidth:int = 2;
		private var lstSumField:Array;
		private var gadgetId2Col:Dictionary = new Dictionary();
		private var xmlModel:XML = <model/>	;
		
		public function AssessementPDF(apptItem:Object,pdfSize:String = "PORTRAIT")
		{  
			var pdfHeader:String = " ";
			var rotat:Boolean = false;
			this.appItem = apptItem;
			accName = getAccountName(appItem);
			lstTask = Database.activityDao.findSurveyByParentSurveyId(appItem.ActivityId,Survey.ACTIVITY_TYPE);
			if(lstTask.length >0){
				model = getModel(lstTask[0]);
				if(model != null){
					//loadImage();
					var tempCol:Array= Database.mappingTableSettingDao.getColumnByModelId(model.recordId,false);
					lstColumn = new Array();
					for each(var obj:Object in tempCol){
						if(obj.Visible && obj.ColProperty != "Question"){
							gadgetId2Col[obj.gadget_id]=obj;
							lstColumn.push(obj);
						}
					}
					lstSumField =  Database.sumFieldDao.getAllSumField(model.recordId);
					//Utils.generateXML(xmlModel.child("surveyColumns"),"column",lstColumn);
				
				}
			}
			
		}
		
		public function hasSurvey():Boolean{
			return lstTask!=null && lstTask.length>0;
		}
		private function getAccountName(appItem:Object,replaceSpace:Boolean=true):String{
			var name:String = "";
			var acc:Object = Utils.getAccount(appItem);
			if(acc!=null){
				name = Utils.getAccount(appItem).AccountName;
				if(replaceSpace){
					name =  name.replace(/ /gi,"_") + "_";
				}
				return name;
			}
			return "";
		}
		
		
		
		
		
		
		public function generatePDF():int{
			
			var isFirstPage:Boolean = true;
			if(model==null || lstTask.length <= 0) return 0;			
			modelTotal = new AssessmentModelTotal(model);
			xmlModel.@title = model.assessmentModel;
			xmlModel.@isCreateSum = model.isCreateSum;
			xmlModel.@sumType = model.sumType==null?"":model.sumType;			
			for each(var pageName:String in model.pageSelectedIds){	
				var xmlPage:XML  = <page/>;
				xmlModel.appendChild(xmlPage);				
				//model add page
				var page:DtoPage = Database.assessmentPageDao.selectByPageName(pageName);	
				xmlPage.@title = page.pageName;
				xmlPage.@isCreateSum = page.isCreateSum;
				xmlPage.@assessmentType = page.assessmentType;
				
				var pageTotal:AssessmentPageTotal = new AssessmentPageTotal(page);	
				modelTotal.addPageTotal(pageTotal);
				if(page!=null){
					var first:Boolean = true;
					for each(var assId:String in page.assessmentSelectedIds){//page add section
						bindListQuestion(assId,xmlPage,pageTotal,first);
						if((model.assessmentModel=="KiB Miljö" || model.assessmentModel=="KiB Tryggmat")){
							first=false;//add header column at the first secion of the page
						}
					}
					
				}
				var xmlPageTotal:XML = <pageTotal/>;
				xmlPage.appendChild(xmlPageTotal);
				createTotalTable(i18n._("ASSESSMENT_PAGE_TOTAL@Page Total"),pageTotal,xmlPageTotal);
			}
			var xmlModelTotal:XML = <modelTotal/>;
			xmlModel.appendChild(xmlModelTotal);
			createTotalTable(i18n._("MODEL_TOTAL@Model Total"),modelTotal,xmlModelTotal);
			HeaderDataTable();
			var xmlByte:ByteArray = new ByteArray();
			xmlByte.writeUTFBytes(xmlModel.toString());
			
			
			
//			//call java
			exportToExcel(xmlByte);
			
			
//			newLine();
//			
//			
//			if(modelTotal.listPageTotal.length>0){
//				//show grand total
//				newLine();
//				document.addElement(createTotalTable(i18n._("MODEL_TOTAL@Model Total"),modelTotal,true));
//				newLine();
//			}
//						
//			var pageIndex:int =0;
//			
//			for each(var pageTotalA:AssessmentPageTotal in modelTotal.listPageTotal){
//				drawPageModel(pageTotalA);
//				if(pageIndex < modelTotal.listPageTotal.length-1){
//					lineNumber=0;
//					document.newPage();
//				}
//				pageIndex ++ ;
//			}
//			
//			
//			
//			
//			document.close();
//			///removeAttachment(model.assessmentModel ,appItem.gadget_id);
//			var file:File =Utils.writeFile( model.assessmentModel + "_" + accName + DateUtils.getCurrentDateAsSerial() +".pdf", pdf.getByteArray() ); // generate pdf
//			file.openWithDefaultApplication();
//			
//			attachPDFToAppointment(file,model.assessmentModel + "_" + accName +  DateUtils.format(new Date(), "MM.YYYY") +".pdf");
			return lstTask.length;
		}
		private var xlsName:String="";
		protected function exportToExcel(xmlByte:ByteArray):void{
			try{			
				var name:String = model.assessmentModel + "_" + accName + DateUtils.getCurrentDateAsSerial();

				//var xmlFile:File =Utils.writeFile( model.assessmentModel + "_" + accName + DateUtils.getCurrentDateAsSerial() +".xml",xmlByte); // generate pdf
				var xmlFile:File =Utils.writeFile( name +".xml",xmlByte); // generate pdf
				xlsName = xmlFile.nativePath.replace(".xml" , ".xls");

				
				// java jdk
				var file:File = null;
//				file = file.resolvePath("bin/javaw.exe");
				var os:String = flash.system.Capabilities.os.substr(0, 3);
				
				
				//
				var jarFile:File =null;
				var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				var arg:Vector.<String> = new Vector.<String>;
				if (os == "Win") {					
					//var batFile:File = File.applicationDirectory.resolvePath("exportexcel.bat");
					file = new File("c:\\Windows\\System32\\cmd.exe");
//					jarFile =File.applicationDirectory.resolvePath("export_excel.jar");
//					arg.push("-Djava.library.path="+jarFile.parent.nativePath);
					arg.push("/k");
					arg.push("exportexcel.bat");	
					npInfo.workingDirectory=File.applicationDirectory;
				} else {
					file = File.applicationDirectory.resolvePath("exportexcel.sh");
					arg.push(File.applicationDirectory.resolvePath("export_excel.jar").nativePath);
					
				}
				
				arg.push(xmlFile.nativePath);
				
				
				npInfo.executable = file;
				npInfo.arguments = arg;				
				nativeProcess = new NativeProcess();
				
				
				
				nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputData);
				nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, exportErrorHandler);
				nativeProcess.start(npInfo);
			
			}catch(e:Error){
				openned = true;
				//Alert.show(e.message, "", Alert.OK);
				throw new RuntimeError(e.message);
				
			}
			
		}
		
		
		
		
		private function exportErrorHandler(e:ProgressEvent):void
		{
			var error:String = StringUtil.trim(nativeProcess.standardError.readUTFBytes(nativeProcess.standardError.bytesAvailable));
			openned = true;
			//Alert.show("Error while saving Excel file!", "", Alert.OK, this);
			throw new RuntimeError(error);
			
			
		}
		private var nativeProcess:NativeProcess = null;
		public var openned:Boolean = false;
		private function onStandardOutputData(e:ProgressEvent):void{
			try
			{
				//var fileName:String = StringUtil.trim(nativeProcess.standardOutput.readUTFBytes(nativeProcess.standardOutput.bytesAvailable));
				//trace(content);
				//var file:File = new File(fileName);
				var file:File = new File(xlsName);
				if(!openned && file.exists){
					
					//	var file:File =new File(content); // generate pdf
					file.openWithDefaultApplication();
					var attName:String = model.assessmentModel + "_" + accName +  DateUtils.format(new Date(), "MM.YYYY") +".xls";
					attName = attName.replace(/ /g,"_");
					attachPDFToAppointment(file,attName);
					openned = true;
				}
			} 
			catch(error:Error) 
			{
				throw new RuntimeError(error.message);
			}
			

			
		}
		
	
		private function getModel(task:Object):DtoConfiguration{
			return Database.assessmentConfigDao.getAssessmentConfigByName(String(task.ActivitySubType));
		}
		private function bindListQuestion(assId:String,xmlPage:XML,pageTotal:AssessmentPageTotal,addHeaderRow:Boolean):void{
			
			var ass:Object = Database.assessmentDao.getById(assId);			
			if(ass==null){
				return ;//missing assessment in the db
			}
			var lstQues:Array = Database.questionDao.getByAssessmentName(ass.Name);
			var task:Object = getTask(ass.Name,xmlPage.@title);				
			
			var xmlSection:XML = <Section/>;
			xmlPage.appendChild(xmlSection);
			xmlSection.@title = ass.Name;			
			
			var sectionTotal:AssessmentSectionTotal = new AssessmentSectionTotal(ass);
			pageTotal.addSectionTotal(sectionTotal);					
			var odd:Boolean = false;
			if(lstQues!=null && lstQues.length>0){
				//var listColumns:Array = Database.mappingTableSettingDao.getColumnByModelId(model.recordId);
				if(addHeaderRow){
					var headerRow:XML =<row/>;
					headerRow.@isheader=true;
					xmlSection.appendChild(headerRow);
					if((model.assessmentModel=="KiB Miljö" || model.assessmentModel=="KiB Tryggmat")){
						headerRow.@title="";
					}else{
						headerRow.@title=ass.Name;
					}
					for each(var dtoCol:Object in lstColumn){
						var headerCol:XML = <col/>;
						headerRow.appendChild(headerCol);
						headerCol.@value=dtoCol.Title;
					}
				}
				
				for each(var quest:Object in lstQues){
					
					if((model.assessmentModel=="KiB Miljö" || model.assessmentModel=="KiB Tryggmat") && (quest["backgroundColor"]=="1" ||quest["isHeader"]=="1")){
						var sectionHeader:XML = <row/>;
						sectionHeader.@title=quest.Question;
						sectionHeader.@colspan=lstColumn.length;
						xmlSection.appendChild(sectionHeader);
					}
					if(quest["isHeader"]=="1"){
						continue;
					}
					var xmlQuestion:XML = <row/>;
					xmlSection.appendChild(xmlQuestion);
					
					xmlQuestion.@odd =  odd ? false : true;
					//xmlQuestion.@gadget_id = task == null ? null : task.gadget_id;
					xmlQuestion.@title = quest.Question;
					odd = !odd;
					var mapCols:ArrayCollection = Database.assessmentMappingDao.selectByQuestionId(quest.QuestionId,model.recordId);
					
					//clear question default value
					for each(var dtoCol:Object in lstColumn){
						if (dtoCol.ColProperty != "Question" ){
							delete quest[dtoCol.ColProperty];
						}
					}
					
					if(task!=null){
						for each(var map:Object in mapCols){							
							if (map.ColumnProperty != "Question" ){		
								
								quest[map.ColumnProperty] = task[map.Oraclefield];
								
							}
						}
						for each(var col:Object in lstColumn){
							if(!col.Visible || col.ColProperty == "Question") continue;
							var xmlCol:XML = <col/>;
							//xmlCol.@colProperty = col.ColProperty;
							var colVal:String = quest[col.ColProperty]==null?"":quest[col.ColProperty];
							 if(col.IsCheckbox || col.dataType ==DtoColumn.RADIO_TYPE){
								colVal = (quest[col.ColProperty] == 1 || quest[col.ColProperty] == "true")? "1":"0";
							 }
							xmlCol.@value = colVal;							
							xmlQuestion.appendChild(xmlCol);
						}
					}
					
				}		
				
				sectionTotal.listQuestion =new ArrayCollection(lstQues);
				if(sectionTotal.listQuestion.length > 1){ // don't show total percent equal one question
					var totalRow:XML = <row/>;
					totalRow.@odd =  odd ? false : true;
					totalRow.@title=i18n._("Total@Total");
					xmlSection.appendChild(totalRow);
					for each(var obj:Object in lstColumn){
						var col1:DtoColumn = Database.mappingTableSettingDao.convertToDtoColumn(obj);
					
						var sumCol:XML =<col/>;
						totalRow.appendChild(sumCol);
						if(col1.isHasSumField){
							sumCol.@value=getDisplayTotal(sectionTotal.getPercentTotal(col1),model.sumType);
						}else {
							sumCol.@value='';
						}
						
					}
				}			
			}
			
			
			
		}
		
		private function getTask(assementName:String,pagename:String):Object{
			var task:Object = null;
			if(mapTask==null){
				mapTask = new Dictionary();
				
				for each(task in lstTask){		
					var key:String = task.Subject;
					if(task[ActivityDAO.ASS_PAGE_NAME]){
						key =key+task[ActivityDAO.ASS_PAGE_NAME];
					}
					mapTask[key] = task;
				}
			}
			
			task =  mapTask[assementName+pagename];
			
			if(task==null){
				//maybe get from ood so pagname is empty
				//try get task with assname
				task = mapTask[assementName];
			}
			
			return task;
		}
		
		private function removeAttachment(fileName:String,parentId:String):void{
			Database.attachmentDao.deleteByFileName(fileName,parentId);
		}
		
		
		
		
		private function HeaderDataTable():void{
			var modelHeader:XML = <header/>;			
			xmlModel.appendChild(modelHeader);
			var listHeader:ArrayCollection = Database.assessmentPDFHeaderDao.getAllPDFHeader(model.recordId);
			var account:Object = Database.accountDao.getAccountById(appItem.AccountId);
			var contact:Object = Database.contactDao.getContactById(appItem.PrimaryContactId);
			for each(var obj:DtoAssessmentPDFHeader in listHeader){
				if(obj.isCustomText){
					if(!StringUtils.isEmpty(obj.customText)){
						modelHeader.@title=obj.customText;
					}
					
					
				}
				else
				{
					var field:Object = Database.fieldDao.findFieldByPrimaryKey(obj.entity,obj.elementName);
					var item:Object
					
					if(field != null){
						if(obj.entity == Database.accountDao.entity){
							item = account;
						}else if(obj.entity == Database.contactDao.entity){
							item = contact;
						}else{
							item = appItem;
						}
						
						
						
						
						if(item != null){	
							if(field.data_type == "Picklist"){
								var picklist:ArrayCollection = PicklistService.getPicklist(field.entity, field.element_name);
								var val:String = getSelectedItem(item[field.element_name], picklist);
								if(!StringUtils.isEmpty(val)){
									item[field.element_name] = val;
								}
							}
							var headerRow:XML = <row/>;
							modelHeader.appendChild(headerRow);
							headerRow.@title=StringUtils.isEmpty(obj.display_name) ? field.display_name : obj.display_name;
							headerRow.@value=item[field.element_name] == null ? "" : getValue(item,field);
						}
					}
				}
			}
			
		}
		
		private function getSelectedItem(value:String, arrayCollection:ArrayCollection, property:String="data", propertyResult:String="label", defaultResult:String=""):String{
			for each(var item:Object in arrayCollection){
				if(item[property] == value){
					return item[propertyResult];
				}
			}
			return defaultResult;
		}
		
		private function getValue(item:Object,field:Object):String{
			var val:String = item[field.element_name];
			var dformater:DateFormatter = new DateFormatter();
			var datePattern:Object = DateUtils.getCurrentUserDatePattern();
			dformater.formatString = datePattern.dateFormat;
			if(field.data_type=="Date" ||field.data_type=="Date/Time"){
				
				if(!StringUtils.isEmpty(val)){
					var	tmpDateTime:Date=DateUtils.guessAndParse(val);
					val = dformater.format(tmpDateTime);
					if(field.data_type=="Date/Time" && field.element_name!="StartTime"){
						val += " "+tmpDateTime.getHours() + ":"+tmpDateTime.getMinutes();
					}
				}
				
			}
			
			return val;
			
		}
		
		
		private function createTotalTable(title:String,dto:IAssessmentTotal,xml:XML):void{		
			
			var isModelTotal:Boolean = dto is AssessmentModelTotal;
			
			if(lstSumField != null && lstSumField.length > 0){
				var row:XML = <row/>;
				xml.appendChild(row);
				if(!isModelTotal){
					row.@title=title;
				}else{
					row.@title="";
				}
				var description:String='';
				for each(var dtoSumCol:Object in lstSumField){
					var mappingObject:Object = gadgetId2Col[dtoSumCol.ColId];
					if(mappingObject!=null){
						var col:XML = <col/>;
						col.@value=mappingObject.Title;
						row.appendChild(col);
						if(description.length>0){
							description+=', ';
						}
						description+=(mappingObject.Title+":"+(mappingObject.description==null?"":mappingObject.description));
					}
				}
				if(model.assessmentModel=="KiB Miljö"||model.assessmentModel=="KiB Tryggmat"){
					if(isModelTotal && description.length>0){
						description+='.';
						var colDesc:XML = <col/>;
						colDesc.@value=description;
						row.appendChild(colDesc);
					}
				}
				row = <row/>;
				xml.appendChild(row);
				
				if(isModelTotal){
					row.@title=i18n._("GLOBAL_TOTAL_MODEL");
				}
				
				
				
				for each(var dtoSum:Object in lstSumField){
					var mappingObj:Object = gadgetId2Col[dtoSum.ColId];
					if(mappingObj!=null){
						var dtoCol:DtoColumn = Database.mappingTableSettingDao.convertToDtoColumn(mappingObj);
						var colv:XML = <col/>;
						colv.@value=getDisplayTotal(dto.getPercentTotal(dtoCol),model.sumType);
						row.appendChild(colv);						
					}
				}
				if(isModelTotal){
					
					var isAddAccount:Boolean = false;
					var accTitle:String = '';
					var accValue:String = '';
					var acc:Object = Database.accountDao.getAccountById(appItem.AccountId);
					if(model.assessmentModel=="KiB Miljö"){
						accTitle = FieldUtils.getField(Database.accountDao.entity,"IndexedPick5").display_name;
						if(acc!=null){
							accValue = PicklistService.getValue(Database.accountDao.entity,'IndexedPick5', acc["IndexedPick5"]);
						}
						isAddAccount = true;
					}else if(model.assessmentModel=="KiB Tryggmat"){
						accTitle = FieldUtils.getField(Database.accountDao.entity,"CustomPickList6").display_name;
						if(acc!=null){
							accValue = PicklistService.getValue(Database.accountDao.entity,'CustomPickList6', acc["CustomPickList6"]);
						}
						isAddAccount = true;				
					}
					if(isAddAccount){
						row = <row/>;
						xml.appendChild(row);
						row.@title= accTitle;
						var cola:XML = <col/>;
						cola.@value=accValue;
						row.appendChild(cola);
					}			
					
					
				}
				
				
			}
			
		}
		private function getDisplayTotal(total:Number,typ:String):String{
			if(model.assessmentModel=="KiB Miljö" || model.assessmentModel=="KiB Tryggmat"){
				return total+"";
			}
			
			if( StringUtils.isEmpty(typ)){
				return total.toFixed(2)+"";
			}
			return total.toFixed(2);
		} 
		
		
		
		private function attachPDFToAppointment(file:File,filename:String = null):void{
			var obj:Object = Database.getDao(Database.activityDao.entity).findByOracleId(appItem.ActivityId);
			if(obj != null){
				Utils.upload(file, Database.activityDao.entity, obj.gadget_id,null,null,filename);
				//Bug #6458: 1.303 Survey Sync Issue
				//obj.Status = "Completed";
				obj.local_update = new Date().getTime();
				Database.getDao(Database.activityDao.entity).update(obj);
				
			}
		}
		
		
		
	}
}