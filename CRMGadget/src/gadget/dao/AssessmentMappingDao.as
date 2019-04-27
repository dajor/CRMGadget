package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class AssessmentMappingDao extends SimpleTable
	{
		protected var stmtSelectByQuestionId:SQLStatement = new SQLStatement();		
	
		private var stmtDeleteByQuestionId:SQLStatement = new SQLStatement();
		private var stmtDeleteByColProperty:SQLStatement = new SQLStatement();
		
		private var stmtCleanMapping:SQLStatement = new SQLStatement();
		
		public function AssessmentMappingDao(sqlConnection:SQLConnection, work:Function)
		{
				super( sqlConnection,work, {
					table: 'assessmentmapping',			
					name_column: [ 'Oraclefield' ],
					search_columns: [ 'Oraclefield' ],
					display_name : "Oraclefield",
					drop_table:false,
					unique:['Oraclefield,AssessmentId,ModelId,QuestionId'],				
					columns: {	'TEXT' : ['Oraclefield','ColumnProperty','QuestionId','AssessmentId'],'INTEGER':['ModelId'],'BOOLEAN':['isCheckbox','CanSum','visible'] }
				});
				
				stmtSelectByQuestionId.sqlConnection = sqlConnection;
				stmtSelectByQuestionId.text = "Select * from assessmentmapping where QuestionId=:QuestionId and ModelId=:ModelId";			
				
				
				
				stmtDeleteByQuestionId.sqlConnection = sqlConnection;
				stmtDeleteByQuestionId.text = "DELETE FROM assessmentmapping where QuestionId=:QuestionId and ModelId=:ModelId";
				
				
				stmtDeleteByColProperty.sqlConnection =sqlConnection;
				stmtDeleteByColProperty.text = "DELETE FROM assessmentmapping where ColumnProperty=:ColumnProperty and ModelId=:ModelId";
				
				stmtCleanMapping.sqlConnection = sqlConnection;
				stmtCleanMapping.text = "DELETE FROM assessmentmapping where QuestionId not in (select questionid from question)";
				
				
			}
		
		public function cleanMapping():void{
			exec(stmtCleanMapping);
		}
		
		public function deleteByColProperty(colProperty:String,modelId:String):void{
			stmtDeleteByColProperty.parameters[":ColumnProperty"]=colProperty;
			stmtDeleteByColProperty.parameters[":ModelId"]=modelId;
			exec(stmtDeleteByColProperty);
		}
		
		
		public function deleteByQuestionId(questId:String,modelId:String):void{
			stmtDeleteByQuestionId.parameters[":QuestionId"]=questId;
			stmtDeleteByQuestionId.parameters[":ModelId"]=modelId;
			exec(stmtDeleteByQuestionId);
		}
		
		
		public function selectByQuestionId(questId:String,modelId:String):ArrayCollection{
			stmtSelectByQuestionId.parameters[":QuestionId"]=questId;
			stmtSelectByQuestionId.parameters[":ModelId"]=modelId;
//			stmtSelectByQuestionId.text = "Select * from assessmentmapping where QuestionId like '%"+questId+"' and ModelId='"+modelId+"'";
			exec(stmtSelectByQuestionId);
			return new ArrayCollection(stmtSelectByQuestionId.getResult().data);
			
		}
		
		
		
	}
}