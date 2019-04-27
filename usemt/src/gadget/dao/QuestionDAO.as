package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;

	public class QuestionDAO extends SimpleTable
	{
		private var stmtUpdate:SQLStatement = null;
		private var stmtCheckColumn:SQLStatement = new SQLStatement();
		private var textColumns:Array = ["QuestionId",
			"AssessmentName",
			"AssessmentId",
			"Ordering", 
			"Question", 
			"Weight",
			"AnswerMapToField",			
			"ParentType",
			"CriteriaName",
			"ChildNumber",
			"ChildOrder",
			"ChildScore",
			"MaxChild",			
			"isHeader",
			"WeightxScore",
		    "QuestionMapToField",
			"CommentMapToField",
			"backgroundColor",
		    "RemoveComment"];
		
		public function QuestionDAO(sqlConnection:SQLConnection, work:Function)
		{
			super(sqlConnection, work, {
				table: 'question',
				oracle_id: 'QuestionId',
				name_column: [ 'AssessmentName' ],
				search_columns: [ 'AssessmentName' ],
				unique:['AssessmentName,QuestionId'],
				display_name : "questions",				
				columns: { 'TEXT' : textColumns }
			});
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			
			stmtCheckColumn = new SQLStatement();
			stmtCheckColumn.sqlConnection = sqlConnection;
			//stmtCheckColumn.text = "SELECT " + params.column + " FROM " + params.table + " LIMIT 0";
			
		}
		
		
		public function getByAssessmentName(name:String):Array{
			var where:String = "WHERE AssessmentName='"+name+"'";
			return select_order("*", where, null, "Ordering",null);
		}
		
		public function getByQuestion(question:String):Object{
			var where:String = "WHERE Question='"+question+"'";
			var result:Array =  select_order("*", where, null, "Ordering",null);
			
			if(result!=null && result.length>0){
				return result[0];
			}
			
			return null;
		}
		
		override public function delete_all():void {
			del(null);
			
		}
		public function checkColumn(column:String):void {
	
				stmtCheckColumn.text = "SELECT " + column + " FROM question LIMIT 0";
				try {
					exec(stmtCheckColumn);
				} catch (e:SQLError) {
					// column is missing
					stmtCheckColumn.text = "ALTER TABLE question ADD " + column + " TEXT";
					exec(stmtCheckColumn);					
				}
			
		}
		
		
		
		public function getFields():Array{
			var fields:Array = [
				{ "local":"QuestionId","server":["Question","AssessmentId"]},
				{ "local":"AssessmentName","server":"Name",isparentField:true},
				{ "local":"AssessmentId","server":"AssessmentId",isparentField:true},
				{ "local":"RemoveComment","server":"RemoveCommentBox",isparentField:true},				
				{ "local":"Ordering","server":"Order"}, 
				{ "local":"Question","server":"Question"}, 
				{ "local":"Weight","server":"Weight"},
				{ "local":"AnswerMapToField","server":"AnswerMapToField"},
				{ "local":"ParentType","server":"ParentType"},
				{ "local":"CriteriaName","server":"CriteriaName"},
				{ "local":"ChildNumber","server":"ChildNumber"},
				{ "local":"ChildOrder","server":"ChildOrder"},
				{ "local":"ChildScore","server":"ChildScore"},
				{ "local":"MaxChild","server":"MaxChild"},				
				{ "local":"WeightxScore","server":"WeightxScore"}
			];
			return fields;
		}
		
	}
}