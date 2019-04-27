package gadget.dao
{
	import com.assessment.DtoAssessmentPDFHeader;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	public class AssessmentPDFHeaderDAO extends SimpleTable
	{
		private var stmtDelete:SQLStatement = new SQLStatement();
		private var stmtSelect:SQLStatement = new SQLStatement();
		private var stmtSelectByGadgetId:SQLStatement = new SQLStatement();
		private var stmtSelectByCustomText:SQLStatement = new SQLStatement();
		private var stmtSelectByAssName:SQLStatement = new SQLStatement();
		public function AssessmentPDFHeaderDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			super(sqlConnection, workerFunction, {
				table:"assessment_pdf_header",
				unique: [ 'entity, modelId, element_name' ],
				columns: {
					gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT",
					'ordering' : 'INTEGER',
					'TEXT' : [ 'entity','element_name','modelId','customText', 'display_name'],
					'BOOLEAN':['isCustomText']
				}
			});		
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM assessment_pdf_header where gadget_id=:gadget_id";	
			stmtSelect.sqlConnection = sqlConnection;
			stmtSelect.text = "Select * from assessment_pdf_header where modelId=:modelId and isCustomText=false order by ordering";		
			stmtSelectByGadgetId.sqlConnection = sqlConnection;
			stmtSelectByGadgetId.text = "Select * from assessment_pdf_header where gadget_id=:gadget_id";	
			stmtSelectByCustomText.sqlConnection = sqlConnection;
			stmtSelectByCustomText.text = "Select * from assessment_pdf_header where  isCustomText=true and modelId=:modelId";
			stmtSelectByAssName.sqlConnection = sqlConnection;
			stmtSelectByAssName.text = "Select * from assessment_pdf_header where modelId=:modelId order by ordering";
		}
		public function deleteAssPDFHeader(gadget_id:String):void{
			stmtDelete.parameters[":gadget_id"]=gadget_id;
			exec(stmtDelete);
		}
		
		public function getAssPDFHeader(modelId:String):ArrayCollection{
			stmtSelect.parameters[":modelId"] =  modelId;
			exec(stmtSelect);
			return new ArrayCollection(convertResult(stmtSelect.getResult().data));
		}
		
		public function getAssPDFHeaderByGadgetId(gadget_id:String):DtoAssessmentPDFHeader{
			stmtSelectByGadgetId.parameters[":gadget_id"] =  gadget_id;
			exec(stmtSelectByGadgetId);
			var result:SQLResult =  stmtSelectByGadgetId.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return convertResult(result.data)[0];
			
		}
		public function getCustomTextPDFHeader(modelId:String):DtoAssessmentPDFHeader{
			stmtSelectByCustomText.parameters[":modelId"] =  modelId;
			exec(stmtSelectByCustomText);
			var result:SQLResult =  stmtSelectByCustomText.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return convertResult(result.data)[0];
		}
		
		protected function convertResult(result:Array):Array{
			var listHeader:Array = new Array();
			if(result!=null){
				for each(var obj:Object in result){
					var dto:DtoAssessmentPDFHeader  = new DtoAssessmentPDFHeader();
					dto.gadget_id = obj.gadget_id;
					dto.entity = obj.entity;
					dto.ordering = obj.ordering;
					dto.modelId = obj.modelId;
					dto.elementName = obj.element_name;
					dto.isCustomText = obj.isCustomText;
					dto.customText = obj.customText;
					dto.display_name = obj.display_name;
					listHeader.push(dto);
				}
			}
			return listHeader;
		}
		
		public function getAllPDFHeader(modelId:String):ArrayCollection{
			
			stmtSelectByAssName.parameters[":modelId"] =  modelId;
			exec(stmtSelectByAssName);
			return new ArrayCollection(convertResult(stmtSelectByAssName.getResult().data));
		}
	}
}
