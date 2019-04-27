package gadget.dao {
	import com.assessment.DtoAssessmentSplitter;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class AssessmentSplitterDAO extends SimpleTable{
		
		private var textColumns:Array = [
			"Delimater",
			"ModelId",			
			"SelectedFields"
		];
		
		
		public function AssessmentSplitterDAO(sqlConnection:SQLConnection, work:Function){
			super( sqlConnection,work, {
				table: 'assessmentsplitter',			
				name_column: [ 'ModelId' ],
				search_columns: [ 'ModelId' ],
				display_name : "ModelId",
				drop_table:true,
				unique:['ModelId'],				
				columns: {gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT", 'TEXT' : textColumns }
			});
		
		}
		
		public function readAll():Array{
			var where:String = "";
			var result:Array =  select_order("*", where, null, "gadget_id",null);
			var listConfig:Array = new Array();
			return convertResult(result);
		}
		
		public function getByAssModel(modelId:String):DtoAssessmentSplitter{
			var where:String = " WHERE ModelId='"+modelId+"'";
			var result:Array = select_order("*",where,null,null,null);
			
			result = convertResult(result);
			if(result.length>0){
				return result[0];
			}
			
			return null;
			
		}
		
		protected function convertResult(result:Array):Array{
			var listConfig:Array = new Array();
			if(result!=null){
				for each(var obj:Object in result){
					var selectedFields:String = obj.SelectedFields as String;
					var dto:DtoAssessmentSplitter = new DtoAssessmentSplitter();
					dto.modelId = obj.ModelId;
					dto.selectedFields = new ArrayCollection(selectedFields.split(";"));
					dto.delimiter = obj.Delimater;
					dto.recordId = obj.gadget_id;
					listConfig.push(dto);
				}
			}
			return listConfig;
		}
		
		
	}
}