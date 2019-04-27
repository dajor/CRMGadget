package
{
	import com.assessment.DtoAssessment;
	import com.assessment.DtoAssessmentPDFHeader;
	import com.assessment.DtoAssessmentSplitter;
	import com.assessment.DtoColumn;
	import com.assessment.DtoConfiguration;
	import com.assessment.DtoPDFColorTheme;
	import com.assessment.DtoPage;
	import com.assessment.IAssessment;
	
	import flash.errors.SQLError;
	
	import gadget.dao.AssessmentPDFHeaderDAO;
	import gadget.dao.BaseDAO;
	import gadget.dao.BaseSQL;
	import gadget.dao.DAO;
	import gadget.dao.Database;
	import gadget.dao.SimpleTable;
	import gadget.i18n.i18n;
	import gadget.util.FieldUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	import gadget.window.WindowManager;
	
	import mx.collections.ArrayCollection;
	import mx.core.IWindow;
	
	import org.purepdf.utils.pdf_core;
	
	public class AssessmentController implements IAssessment
	{
		public function AssessmentController()
		{
		}
		
		public function getAllAssessmentType():ArrayCollection
		{
			var lstEntity:ArrayCollection = new ArrayCollection();
			lstEntity.addItem("");
		    for(var key:String in Database.assessmentDao.getMapAssessmentEntities()){
				lstEntity.addItem(key);
			}
			
			return lstEntity;
		}
		
		public function getAssessmentByType(type:String):ArrayCollection
		{
			var result:Array  = Database.assessmentDao.getAssessmentByType(type);
			return convertAssessmentToDto(result);
		}
		
		public function getFields(assessmentType:String):ArrayCollection
		{
			var entity:String = Database.assessmentDao.getEntityByType(assessmentType);
			if(entity==null){
				entity = assessmentType;
			}
			var result:ArrayCollection = Database.fieldDao.getAllElementName(entity);
			result.addItemAt("",0);
			
			return result;
		}
		
		public function getQuestionsByAssessment(assessment:String,modelId:String):ArrayCollection
		{
			var listQuest:ArrayCollection = new ArrayCollection(Database.questionDao.getByAssessmentName(assessment));
			var listCol:Array = Database.mappingTableSettingDao.getColumnByModelId(modelId);
			for each(var quest:Object in listQuest){				
				var mappings:ArrayCollection = Database.assessmentMappingDao.selectByQuestionId(quest.QuestionId,modelId);
				//delete mapping data come from ood
				for each(var dtoCol:DtoColumn in listCol){
					if(dtoCol.colProperty!="Question"){
						delete quest[dtoCol.colProperty];
					}
				}
				
				if(mappings!=null && mappings.length>0){
					for each(var map:Object in mappings){
						quest[map.ColumnProperty]=map.Oraclefield;
					}
				}
			}
			
			return listQuest;
		}
		
		public function getAllConfiguration():ArrayCollection
		{
			return new ArrayCollection(Database.assessmentConfigDao.readAll());
		}
		
		public function saveAssessmentConf(dtoConfig:DtoConfiguration,isupdate:Boolean=false):void
		{
			var obj:Object = new Object();
			obj.ModelName = dtoConfig.assessmentModel;
			obj.Type = dtoConfig.type;
			obj.AssessmentType = dtoConfig.assessmentType;
			obj.SelectedPages = getSelectedAssessments(dtoConfig.pageSelectedIds);
			obj.entity= Database.assessmentDao.getEntityByType(dtoConfig.assessmentType);
			obj.iscreatesum = dtoConfig.isCreateSum;
			obj.TotalStoreToField = dtoConfig.totalStoreToField;
			obj.SumType = dtoConfig.sumType;
			if(isupdate){
				Database.assessmentConfigDao.update(obj,{"gadget_id":dtoConfig.recordId});
			}else{
				Database.assessmentConfigDao.insert(obj);
				obj = Database.assessmentConfigDao.selectLastRecord();
				dtoConfig.recordId = obj.gadget_id;
			}
			
		}
		
		public function saveSumField(sumFields:ArrayCollection):void{
			for each(var dto:Object in sumFields){
				Database.sumFieldDao.replace(dto);
			}
			
		}
		public function getFieldDisplayName(assessmentType:String,elementname:String):String{
			if(!StringUtils.isEmpty(elementname)){
				var entity:String = Database.assessmentDao.getEntityByType(assessmentType); 
				if(entity==null){
					entity = assessmentType;
				}
				var obj:Object = FieldUtils.getField(entity,elementname);
				if(obj!=null){
					return obj.display_name;
				}
			}
			return "";
		}
		
		public function getAllPages():ArrayCollection
		{
			return new ArrayCollection(Database.assessmentPageDao.readAll());
		}
		
		public function getPageByType(assessmentType:String):ArrayCollection
		{
			
			return new ArrayCollection(Database.assessmentPageDao.readByType(assessmentType));
		}
		
		public function savePage(dtoConfig:DtoPage, isupdate:Boolean=false):void
		{
			var obj:Object = new Object();
			obj.PageName = dtoConfig.pageName;
			obj.AssessmentType = dtoConfig.assessmentType;
			obj.SelectedAssessments = getSelectedAssessments(dtoConfig.assessmentSelectedIds);
			obj.entity= Database.assessmentDao.getEntityByType(dtoConfig.assessmentType);
			obj.iscreatesum = dtoConfig.isCreateSum;
			obj.TotalStoreToField = dtoConfig.totalStoreToField;
			if(isupdate){
				Database.assessmentPageDao.update(obj,{"gadget_id":dtoConfig.recordId});
			}else{
				Database.assessmentPageDao.insert(obj);
				obj = Database.assessmentPageDao.selectLastRecord();
				dtoConfig.recordId = obj.gadget_id;
			}
			
		}
		public function deleteSumField(colId:String):void{
			if(!StringUtils.isEmpty(colId)){
				var obj:Object = {"ColId":colId};
				Database.sumFieldDao.delete_(obj);
			}
		}
		public function deleteAssessmentModel(dto:DtoConfiguration):void
		{
			if(!StringUtils.isEmpty(dto.recordId)){
				var obj:Object = {"gadget_id":dto.recordId};
				Database.assessmentConfigDao.delete_(obj);
			}
			
			
		}
		
		public function deleteAssessmentPage(dto:DtoPage):void
		{
			if(!StringUtils.isEmpty(dto.recordId)){
				var obj:Object = {"gadget_id":dto.recordId};
				Database.assessmentPageDao.delete_(obj);
			}
			
		}
		
		
		
		private function getSelectedAssessments(lst:ArrayCollection):String{			
			return lst.source.join(";");
		}
		public function saveQuestionMapping(question:ArrayCollection,listAss:ArrayCollection,modelId:String):void
		{			
			var columns:Array = Database.mappingTableSettingDao.getColumnByModelId(modelId);
			Database.begin();
			try{
//				for each(var dtoAss:DtoAssessment in listAss){
//					Database.assessmentDao.update({'TotalStoreToField':dtoAss.totalStoreToField,'iscreatesum':dtoAss.isCreateSum},{'AssessmentId':dtoAss.assessmentId});
//				}
				for each(var ques:Object in question){
					Database.questionDao.update({"backgroundColor" : ques["backgroundColor"],"isHeader":ques['isHeader']},{"QuestionId":ques['QuestionId']});
					Database.assessmentMappingDao.deleteByQuestionId(String(ques['QuestionId']),modelId);
					for each(var col:DtoColumn in columns){
						if(col.colProperty!='Question'){
							Database.assessmentMappingDao.insert(
								{	'Oraclefield':ques[col.colProperty],
									'ColumnProperty':col.colProperty,
									'QuestionId':ques['QuestionId'],
									'AssessmentId':ques['AssessmentId'],
									'ModelId':modelId,
									'isCheckbox':col.isCheckbox,
									'CanSum':col.isHasSumField,
									'visible':col.visible
								});
						}
					}
				}
				Database.commit();
			}catch(e:SQLError){
				Database.rollback();
			}
			
			
		}
		
		public function saveMappingTableColumn(col:DtoColumn):void{
			var obj:Object = {
				"ModelId":col.modelId,
				"ColProperty":col.colProperty,
				"Title":col.title,
				"IsHasSumField":col.isHasSumField,
				"OrderNum":col.order,
				'dataType':col.dataType,
				'IsDefault':col.isDefault,
				'description':col.description,
				'Visible':col.visible};
			
			if(StringUtils.isEmpty(col.recordId)){
				Database.mappingTableSettingDao.insert(obj);
				obj = Database.mappingTableSettingDao.selectLastRecord();
				col.recordId = obj.gadget_id;
				//add column to table Question
				//Database.questionDao.checkColumn(col.colProperty);
				
			}else{
				Database.mappingTableSettingDao.update(obj,{"gadget_id":col.recordId});
			}
			
			
		}
		
		public function deleteMappingTableColumn(col:DtoColumn):void{
			if(!StringUtils.isEmpty(col.recordId)){
				try{
				var obj:Object = {"gadget_id":col.recordId};
				Database.begin();
				Database.mappingTableSettingDao.delete_(obj);
				deleteSumField(col.recordId);
				Database.assessmentMappingDao.deleteByColProperty(col.colProperty,col.modelId);
				Database.commit();
				}catch(e:Error){
					Database.rollback();
				}
			}
		}
		
		/**
		 * return all cols as list of DtoColumn
		 * 
		 * */
		public function getMappingTableSetting(modelId:String):ArrayCollection{
			return new ArrayCollection(Database.mappingTableSettingDao.getColumnByModelId(modelId));
		}
		
		
		public function translate(key:String):String
		{
			return i18n._(key);
		}
		
		public function openWindow(window:IWindow):void{
			WindowManager.openModal(window);
		}
		
//		public function setDefaultMapping(modelId:String):void{
//			Database.mappingTableSettingDao.delete_({ModelId:modelId});
//		}
		
		public function getAllSumFieldByModelId(modelId:String):ArrayCollection{
			return new ArrayCollection(Database.sumFieldDao.getAllSumField(modelId));
		}
		
		private function convertAssessmentToDto(result:Array):ArrayCollection{
			var lst:ArrayCollection = new ArrayCollection();
			if(result!=null){
				for each(var obj:Object in result){
					var dtoAss:DtoAssessment = new DtoAssessment();
					dtoAss.assessmentId = obj.AssessmentId;
					dtoAss.assessmentType = obj.Type;
					dtoAss.assessementName = obj.Name;
					dtoAss.isCreateSum = obj.iscreatesum;
					dtoAss.totalStoreToField = obj.TotalStoreToField;
					lst.addItem(dtoAss);
				}
			}
			return lst;
		}
		public function getAssessmentByModel(modelId:String):ArrayCollection{
			var result:Array = Database.assessmentDao.selectAssessmentByModelId(modelId);
			return convertAssessmentToDto(result);
			
		}
		
		public function getConfigurationById(modelId:String):DtoConfiguration{
			return Database.assessmentConfigDao.getByGadgetId(modelId);
		}
		
		// CH
		public function getAllAssessmentSplitter():ArrayCollection{
			return new ArrayCollection(Database.assessmentSplitterDao.readAll());
		}
		
		public function deleteAssessmentSplitter(dto:DtoAssessmentSplitter):void{
			if(!StringUtils.isEmpty(dto.recordId)){
				var obj:Object = {"gadget_id":dto.recordId};
				Database.assessmentSplitterDao.delete_(obj);
			}
		}
		
		public function importConfiguration(xml:XML):void{
			if(xml.name()=='assessment_configuration'){
				try{
					Database.begin();
					var dao:SimpleTable=Database.assessmentDao;
					dao.delete_all();
					Utils.commitObjects(dao,xml.elements("assessments").children(),false);				
					
					dao=Database.answerDao;
					dao.delete_all();
					Utils.commitObjects(dao,xml.elements("answers").children(),false);
					dao=Database.assessmentConfigDao;
					dao.delete_all();
					Utils.commitObjects(dao,xml.elements("assessment_models").children(),false);
					
					dao = Database.assessmentPageDao;
					dao.delete_all();
					Utils.commitObjects(dao,xml.elements("assessmentPages").children(),false);
					
					dao = Database.mappingTableSettingDao;
					dao.delete_all();
					Utils.commitObjects(dao,xml.elements("assessmentMappingColumns").children(),false);
					
					
					dao = Database.assessmentMappingDao;
					dao.delete_all();
					Utils.commitObjects(dao,xml.elements("assessmentMappings").children(),false);
					
					//------------ assessment script
					dao=Database.questionDao;
					dao.delete_all();
					Utils.commitObjects(dao,xml.elements("questions").children(),false);
					
					dao = Database.sumFieldDao;
					dao.delete_all();
					Utils.commitObjects(dao,xml.elements("assessmentsumfields").children(),false);
					
					
					dao = Database.assessmentSplitterDao;
					dao.delete_all();
					Utils.commitObjects(dao,xml.elements("assessmentspliters").children(),false);
					
					dao = Database.assessmentPDFHeaderDao;
					dao.delete_all();
					Utils.commitObjects(dao,xml.elements("assessmentpdfheaders").children(),false)
						
					Database.commit();
				}catch(e:Error){
					Database.rollback();
				}
			}else{
				throw new Error(i18n._("INVALIDE_XML_FORMART@invalid xml format."));
					}
			
		}
		public function exportConfiguration():XML{
			var configXml:XML = 
				<assessment_configuration>
						<assessments/>
						<questions/>
						<answers/>
						<assessmentMappingColumns/>
						<assessment_models/>
						<assessmentPages/>
						<assessmentMappings/>
						<assessmentsumfields/>
						<assessmentspliters/>
						<assessmentpdfheaders/>
				</assessment_configuration>;
			var assessment:Array = Database.assessmentDao.fetch();
			Utils.generateXML(configXml.elements("assessments") , "assessment", assessment);
			var question:Array = Database.questionDao.fetch();
			Utils.generateXML(configXml.elements("questions") , "question", question);
			var answer:Array = Database.answerDao.fetch();
			Utils.generateXML(configXml.elements("answers") , "answer", answer);
			var assessmentConfigs:Array = Database.assessmentConfigDao.fetch();
			Utils.generateXML(configXml.elements("assessment_models") , "assessment_model", assessmentConfigs);
			
			var assessmentPage:Array = Database.assessmentPageDao.fetch();
			Utils.generateXML(configXml.elements("assessmentPages"),"assessmentPage",assessmentPage);
			
			var assessmentMappingColumns:Array = Database.mappingTableSettingDao.fetch();
			Utils.generateXML(configXml.elements("assessmentMappingColumns"),"assessmentMappingColumn",assessmentMappingColumns);
			var assessmentMapping:Array = Database.assessmentMappingDao.fetch();
			Utils.generateXML(configXml.elements("assessmentMappings"),"assessmentMapping",assessmentMapping);	
			
			var assSumfields:Array = Database.sumFieldDao.fetch();
			Utils.generateXML(configXml.elements("assessmentsumfields"),"assessmentsumfield",assSumfields);	
			
			var assspliter:Array = Database.assessmentSplitterDao.fetch();
			Utils.generateXML(configXml.elements("assessmentspliters"),"assessmentspliter",assspliter);	
			
			
			var pdfHeader:Array =Database.assessmentPDFHeaderDao.fetch();
			Utils.generateXML(configXml.elements("assessmentpdfheaders"),"assessmentpdfheader",pdfHeader);	
			return configXml;
		}
		
		public function saveSplitter(dto:DtoAssessmentSplitter, isUpdate:Boolean = false):void{
			var obj:Object = new Object();
			obj.Delimater = dto.delimiter;
			obj.ModelId = dto.modelId;			
			obj.SelectedFields = getSelectedAssessments(dto.selectedFields);
			if(isUpdate){
				Database.assessmentSplitterDao.update(obj,{"gadget_id":dto.recordId});
			}else{
				Database.assessmentSplitterDao.insert(obj);
				obj = Database.assessmentSplitterDao.selectLastRecord();
				dto.recordId = obj.gadget_id;
			}
		}
		
		public function getAssPDFHeaderByAssName(assessmentName:String):ArrayCollection{
			return Database.assessmentPDFHeaderDao.getAssPDFHeader(assessmentName);
		}
		
		public function upsertAssPDFHeader(dto:DtoAssessmentPDFHeader):void{
			var obj:Object = new Object();
			obj.entity = dto.entity;
			obj.element_name = dto.elementName;			
			obj.customText = dto.customText;
			obj.isCustomText = dto.isCustomText;
			obj.modelId = dto.modelId;
			obj.ordering = dto.ordering;
			obj.display_name = dto.display_name;
			if(StringUtils.isEmpty(dto.gadget_id)){
				Database.assessmentPDFHeaderDao.insert(obj);
				obj = Database.assessmentPDFHeaderDao.selectLastRecord();
				dto.gadget_id = obj.gadget_id;
			}else{
				Database.assessmentPDFHeaderDao.update(obj,{"gadget_id":dto.gadget_id});
				
				
			}
		}
		public function deletePDFHeader(gadget_id:String):void{
			Database.assessmentPDFHeaderDao.deleteAssPDFHeader(gadget_id);
		}
		public function getAssPDFHeaderByGadgetId(gadget_id:String):DtoAssessmentPDFHeader{
			return Database.assessmentPDFHeaderDao.getAssPDFHeaderByGadgetId(gadget_id);
		}
		
		public function getCustomTextPDFHeader(assName:String):DtoAssessmentPDFHeader{
			return Database.assessmentPDFHeaderDao.getCustomTextPDFHeader(assName);
		}
		public function getDisplayNameEntity(entity:String):String{
			return Database.customLayoutDao.getDisplayName(entity);
		}
		
		public function getAllAssPDFColorTheme():ArrayCollection{
			return Database.assessmentPDFColorThemeDao.getAllPDFColorTheme();
		}
		
		public function upsertAssPDFColorTheme(dto:DtoPDFColorTheme):void{
			var obj:Object = new Object();
			obj.color = dto.color;
			obj.colorType = dto.colorType;	
			obj.ordering = dto.ordering;
			if(StringUtils.isEmpty(dto.gadget_id)){
				Database.assessmentPDFColorThemeDao.insert(obj);
				obj = Database.assessmentPDFColorThemeDao.selectLastRecord();
				dto.gadget_id = obj.gadget_id;
			}else{
				Database.assessmentPDFColorThemeDao.update(obj,{"gadget_id":dto.gadget_id});
				
				
			}
		}
	}
}