package gadget.dao
{
	import com.assessment.DtoConfiguration;
	import com.assessment.DtoPage;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class AssessmentDAO extends SimpleTable
	{
		private var stmtSetDefault:SQLStatement;
		private var stmtSelectDefault:SQLStatement;		
		
		private var textColumns:Array = ["AssessmentId",
			"Name",			
			"RemoveCommentBox",
			"Type",
			"FieldtoMapScoreTo",
			"FieldtoMapOutcomeValueTo",
			"Description",
			"Active",
			"TemplateType",
			"TotalStoreToField"];
		public function AssessmentDAO(sqlConnection:SQLConnection, work:Function)
		{
			super( sqlConnection, work, {
				table: 'assessment',
				oracle_id: 'AssessmentId',
				name_column: [ 'Name' ],
				search_columns: [ 'Name' ],
				display_name : "assessments",
				unique:['AssessmentId', "Name"],								
				columns: {'BOOLEAN':['IsDefault','iscreatesum'], 'TEXT' : textColumns }
			});
			stmtSetDefault = new SQLStatement();
			stmtSetDefault.sqlConnection = sqlConnection;
			
			stmtSelectDefault = new SQLStatement();
			stmtSelectDefault.sqlConnection = sqlConnection;
			stmtSelectDefault.text = "Select * from AssessmentDAO where";
		}
		
		public function getAllType():Array{
			var where:String = "";
			return select_order("distinct Type", where, null, "Name",null);
		}
		
		public function getById(id:String):Object{
			var where:String = "WHERE AssessmentId='"+id+"'";
			var result:Array =  select_order("*", where, null, "Name",null);
			if(result!=null && result.length>0){
				return result[0];
			}
			return null;
		}
		public function getAssessmentByType(type:String):Array{
			var where:String = "WHERE Type='"+type+"'";
			return select_order("*", where, null, "Name",null);
		}
		
		
		public function selectAssessmentByModelId(modelId:String):Array{
			var dto:DtoConfiguration = Database.assessmentConfigDao.getByGadgetId(modelId);
			if(dto!=null){
			var pages:Array = Database.assessmentPageDao.getByIds(dto.pageSelectedIds);
			var assIds:ArrayCollection = new ArrayCollection();
				if(pages!=null && pages.length>0){					
					for each(var page:DtoPage in pages){
						assIds.addAll(page.assessmentSelectedIds);
					}
					return getByIds(assIds);
					
				}
			}
			return null;
		}
		
		public function getByIds(ids:ArrayCollection):Array{
			var where:String = " where AssessmentId in('" + ids.source.join("','") + "')";
			var result:Array =  select_order("*", where, null, "Name",null);					
			return result;
		}
		
		
		public function readAll():Array{
			var where:String = "";
			return select_order("*", where, null, "Name",null);
		}
		override public function delete_all():void {
			del(null);
			
		}
		
		public function setAsDefault(assName:String,assType:String):void{
			stmtSetDefault.text = "Update assessment set IsDefault=false where Type='"+assType+"'";
			exec(stmtSetDefault);
			stmtSetDefault.text = "Update assessment set IsDefault=true where Type='"+assType+"' AND Name='"+assName+"'";
			exec(stmtSetDefault);
		}
		
		public function getFields():Array{
			var fields:Array = [
			{ "local":"AssessmentId","server":["Name"]},
			{ "local":"Name","server":"Name"}, 			
			{ "local":"Type","server":"Type"},
			{ "local":"FieldtoMapScoreTo","server":"FieldtoMapScoreTo"},
			{ "local":"FieldtoMapOutcomeValueTo","server":"FieldtoMapOutcomeValueTo"},
			{ "local":"Description","server":"Description"},
			{ "local":"Active","server":"Active"},
			{ "local":"TemplateType","server":"TemplateType"},
			{ "local":"RemoveCommentBox","server":"RemoveCommentBox"}
			];
			return fields;
			
		}
		public function getMapAssessmentEntities():Object
		{
			var obj:Object = new Dictionary(true); 
			obj ={ "Service Request - Script":"Service Request",
					 "Service Request - Survey":"Service Request",
					 "Lead Qualification":"Lead",
					 "Contact Script":"Contact",
					 "Opportunity Assessment":"Opportunity",
					 "Activity Assessment":"Activity"};
			return obj;
		}
		
		public function getEntityByType(assessmentType:String):String{
			return getMapAssessmentEntities()[assessmentType];
		}
	}
}