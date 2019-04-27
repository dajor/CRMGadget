package gadget.sync.incoming
{
	
	
	import flash.events.IOErrorEvent;
	
	import gadget.dao.Database;
	import gadget.sync.task.SyncTask;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class AccessAssessmentScriptService extends SyncTask
	{ 
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/SalesAssessmentTemplate/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/SalesAssessmentTemplate/Data");
		                                           
		
		override protected function doRequest():void {
			if (getLastSync() != NO_LAST_SYNC_DATE){
				successHandler(null);
				return;
			} 
			//			FieldUtils.reset();
			
			sendRequest("\"document/urn:crmondemand/ws/odesabs/accessprofile/:AccessProfileReadAll\"",
				<SalesAssessmentTemplateReadAll_Input xmlns={ns1}/>,
				"admin",
				"Services/cte/SalesAssessmentTemplateService"
			);
			
		}
		private function getDataStr(field:XML, col:String):String {
			var tmp:XMLList = field.child(new QName(ns2.uri,col));
			return tmp.length()==0 ? "" : tmp[0].toString();
		}
		
		private function populate(field:XML, cols:Array):Object {
			var tmpOb:Object = {};
			for each (var col:String in cols) {
				tmpOb[col] = getDataStr(field,col);
			}
			return tmpOb;
		}
		
		protected function createObject(xmlObj:XML,parentObject:Object,fields:Array):Object{
			var obj:Object = new Object();
			for each(var field:Object in fields){
				if(field.server is String){
					if(parentObject!=null && field.isparentField){
						obj[field.local] = parentObject[field.server]
					}else{
						obj[field.local] = getDataStr(xmlObj,field.server);
					}
				}else{
					var serverData:String = "";
					for each(var serverf:String in field.server){
						var str:String = getDataStr(xmlObj,serverf);
						if(StringUtils.isEmpty(str)){
							//try with parentfield
							str = parentObject[serverf];
						}
						if(!StringUtils.isEmpty(str)){
							serverData+=str;
						}
					}
					
					obj[field.local] = serverData;
					
				}
			}
			return obj;
		}
		
		private function checkOldQuestion(objNewQ:Object,listOldQuestion:ArrayCollection):void{
			if(listOldQuestion != null && listOldQuestion.length>0){
				var assName:String = objNewQ['AssessmentName'];
				var quesId:String = objNewQ['QuestionId'];
				// #8766 can not save because of hidden specail charater
				quesId = quesId.replace("﻿﻿4","4");
				quesId = quesId.replace("﻿4","4");
				objNewQ['QuestionId'] = quesId;
				for each(var oldQues:Object in listOldQuestion){
					if(oldQues['AssessmentName'] == assName && oldQues['QuestionId'] == quesId){
						objNewQ['isHeader'] = oldQues['isHeader'];
						objNewQ['backgroundColor'] = oldQues['backgroundColor'];
						break;
					}
				}
			}
			
		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}
			
		
			var assessemtnList:ArrayCollection = new ArrayCollection();
			var questions:ArrayCollection = new ArrayCollection();
			var answers:ArrayCollection = new ArrayCollection();
			
			var listOldQuestions:ArrayCollection = new ArrayCollection(Database.questionDao.fetch());
			
			for each (var objects:XML in result.ns2::ListOfSalesAssessmentTemplate[0].ns2::SalesAssessmentTemplate) {
				
				var indexQues:int = 0;
				try{
					var asseRec:Object =createObject(objects,null, Database.assessmentDao.getFields());
					//Database.assessmentDao.replace(asseRec);
					//var oldRec:Object = Database.assessmentDao.getById(asseRec.AssessmentId);
					//if(oldRec!=null){
					//	asseRec.iscreatesum = oldRec.iscreatesum;
					//	asseRec.TotalStoreToField = oldRec.TotalStoreToField;
					//}
					assessemtnList.addItem(asseRec);
					
					if(indexQues < objects.length()){
						for each (var quesObj:XML in objects.ns2::ListOfSalesAssessmentTemplateAttribute[indexQues].ns2::SalesAssessmentTemplateAttribute) {
							var indexAnswer:int = 0;
							var queRec:Object = createObject(quesObj,asseRec, Database.questionDao.getFields());
							//add old value of isHeader and backgroundColor
							checkOldQuestion(queRec,listOldQuestions);
							questions.addItem(queRec);
							for each(var ansObj:XML in quesObj.ns2::ListOfSalesAssessmentAttributeValue[indexAnswer].ns2::SalesAssessmentAttributeValue){
								var ansRec:Object = createObject(ansObj,queRec, Database.answerDao.getFields());
								//Database.answerDao.replace(ansRec);
								answers.addItem(ansRec);
								indexAnswer ++;
							}
							//Database.questionDao.replace(queRec);
							indexQues ++;
						}
						
					}
					
			
				}catch(e:TypeError){
					//no field name
					//nothing to do
					
				}
			}
			if(isClearData){
				//delete all old data
				Database.assessmentDao.delete_all();
				Database.questionDao.delete_all();
				Database.answerDao.delete_all();
				isClearData=false;
			}
			
			
			Database.begin();
			
			for each (var ass:Object in assessemtnList){
				Database.assessmentDao.replace(ass);
			}
			for each(var quest:Object in questions){
				Database.questionDao.replace(quest);
			}
			for each(var ans:Object in answers){
				Database.answerDao.replace(ans);
			}
			Database.commit();
			isFielChange = true;
			nextPage(true);
			return 1;
		}
		
		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			
			// SINCE Oracle dont return any error code
			// we return true each time there is a faultstring
			/*
			
			<faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns0="urn:crmondemand/ws/odesabs/accessprofile/" xmlns:ns1="urn:/crmondemand/xml/AccessProfile/Query" xmlns:ns2="urn:/crmondemand/xml/AccessProfile/Data">
			SOAP:Server
			</faultcode>
			*/
			if (xml_list.length()<1 || xml_list[0].faultstring.length()!=1)
				return false;
			var str:String = xml_list[0].faultstring[0].toString();
			if (str=="")				
				return false;
			
			optWarn("AccessProfileService unsupported: "+str);
			nextPage(true);
			return true;
		}
		
		override public function getName():String {
			return "Getting AccessAssessmentScriptService..."; 
		}
		
		override public function getEntityName():String {
			return "AccessAssessmentScriptService"; 
		}
	}
}