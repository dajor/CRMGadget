package gadget.dao
{
	import flash.data.SQLConnection;
	
	import mx.collections.ArrayCollection;

	public class AnswerDAO extends SimpleTable
	{
		private var textColumns:Array = ["AnswerId","AssessmentName","QuestionOrder","Ordering", "Answer", "Score","Description","label","field"];
		
		public function AnswerDAO(sqlConnection:SQLConnection, work:Function)
		{
			super( sqlConnection,work, {
				table: 'answer',
				oracle_id: 'AnswerId',
				name_column: [ 'AssessmentName' ],
				search_columns: [ 'AssessmentName' ],
				display_name : "answers",
				unique:['AssessmentName,AnswerId,QuestionOrder'],				
				columns: { 'TEXT' : textColumns }
			});
			
		}
		
		public function getByQuestion(assName:String,queOrder:String):ArrayCollection{
			var where:String = "WHERE AssessmentName='"+assName+"' And QuestionOrder='" + queOrder + "'";
			return new ArrayCollection(select_order("*", where, null, "Ordering",null));
		}
		
		override public function delete_all():void {
			del(null);
			
		}
		
		public function getFields():Array{
			var fields:Array = [
			{ "local":"AnswerId","server":"Answer"},
			{ "local":"AssessmentName","server":"AssessmentName",isparentField:true}, 
			{ "local":"QuestionOrder","server":"Ordering",isparentField:true}, 
			{ "local":"Ordering","server":"Order"},
			{ "local":"Answer","server":"Answer"},
			{ "local":"Score","server":"Score"},
			{ "local":"Description","server":"Description"},
			{ "local":"label","server":"Answer"},  // label and field use for add to dataprovider combox
			{ "local":"field","server":"Answer"}
			];
			return fields;
			
		}
	}
}