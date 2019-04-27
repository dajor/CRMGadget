package com.assessment
{
	import mx.collections.ArrayCollection;
	import mx.core.IWindow;

	public interface IAssessment
	{
		/**
		 * 
		 * return all assessment type as list of string
		 * 
		 * */
		 function getAllAssessmentType():ArrayCollection;
		 /**
		  * 
		  * return all assessment name as list of DtoAssessment
		  * 
		  * */
		 function getAssessmentByType(assessmentType:String):ArrayCollection;
		 
		 /**
		  * 
		  * return all page name as list of DtoPage
		  * 
		  * */
		 function getPageByType(assessmentType:String):ArrayCollection;
		 
		 
		 /**
		  * 
		  * return all page name as list of string
		  * 
		  * */
		 function getAllPages():ArrayCollection;
		
		 /**
		  * 
		  * return all  fields by assessmentType as list of object field contain{ field: e}
		  * 
		  * */
		 function getFields(assessmentType:String):ArrayCollection;
		 function getQuestionsByAssessment(assessment:String,modelId:String):ArrayCollection;
		 function getAllConfiguration():ArrayCollection;
		 function getConfigurationById(modelId:String):DtoConfiguration;
		 function saveAssessmentConf(dtoConfig:DtoConfiguration,isupdate:Boolean=false):void;
		 function saveQuestionMapping(question:ArrayCollection,listAss:ArrayCollection,modelId:String):void;
		 function savePage(dtoConfig:DtoPage,isupdate:Boolean=false):void;
		 function translate(key:String):String;
		 function getFieldDisplayName(assessmentType:String,elementname:String):String;
		 function deleteAssessmentModel(dto:DtoConfiguration):void;
		 function deleteAssessmentPage(dto:DtoPage):void;
		 function saveMappingTableColumn(col:DtoColumn):void;
		 function deleteMappingTableColumn(col:DtoColumn):void;
		 function saveSumField(sumfield:ArrayCollection):void;
		 function deleteSumField(colId:String):void;
		 /**
		  * return all cols as list of DtoColumn
		  * 
		  * */
		 function getMappingTableSetting(modelId:String):ArrayCollection;
		 
		 function openWindow(window:IWindow):void;		 
		
		 // table sumfield
		 function getAllSumFieldByModelId(modelId:String):ArrayCollection;
		 //get assessment by selected model
		 function getAssessmentByModel(modelId:String):ArrayCollection;
		 
		 // CH 
		 function getAllAssessmentSplitter():ArrayCollection;
		 function deleteAssessmentSplitter(dto:DtoAssessmentSplitter):void;
		 function saveSplitter(dto:DtoAssessmentSplitter, isUpdate:Boolean = false):void;
		 function importConfiguration(xmlData:XML):void;
		 function exportConfiguration():XML;
		 
		 function getAssPDFHeaderByAssName(assessmentName:String):ArrayCollection;
		 function upsertAssPDFHeader(dto:DtoAssessmentPDFHeader):void;
		 function deletePDFHeader(gadgte_id:String):void;
		 function getAssPDFHeaderByGadgetId(gadgte_id:String):DtoAssessmentPDFHeader;
		 function getCustomTextPDFHeader(assName:String):DtoAssessmentPDFHeader;
		 function getDisplayNameEntity(entity:String):String;
		 function getAllAssPDFColorTheme():ArrayCollection;
		 function upsertAssPDFColorTheme(dto:DtoPDFColorTheme):void;
	}
}