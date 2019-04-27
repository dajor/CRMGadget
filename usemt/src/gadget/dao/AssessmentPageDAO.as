package gadget.dao
{
	import com.assessment.DtoConfiguration;
	import com.assessment.DtoPage;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	public class AssessmentPageDAO extends SimpleTable
	{
		
		
		private var textColumns:Array = [
			"PageName",
			"AssessmentType",
			"entity",
			"SelectedAssessments",
			"TotalStoreToField"
		];
		public function AssessmentPageDAO(sqlConnection:SQLConnection, work:Function)
		{
			super( sqlConnection,work, {
				table: 'assessmentpage',			
				name_column: [ 'PageName' ],
				search_columns: [ 'PageName' ],
				display_name : "PageName",
				drop_table:true,
				unique:['PageName'],				
				columns: {gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT", 'TEXT' : textColumns ,'BOOLEAN':['iscreatesum']}
			});
			
			
		}
		public function readByType(typ:String):Array{
			var where:String = " where AssessmentType='" + typ + "'";
			var result:Array =  select_order("*", where, null, "PageName",null);
			var listConfig:Array = new Array();
			return convertResult(result);
		}
		
		
		
		public function selectByPageName(pageName:String):DtoPage{
			var where:String = " where gadget_id='" + pageName + "'";
			var result:Array =  select_order("*", where, null, "PageName",null);
			result = convertResult(result);
			if(result!=null && result.length>0){
				return DtoPage(result[0]);
			}
			return null;
		}
		
		
		
		
		
		public function getByIds(ids:ArrayCollection):Array{
			var where:String = " where gadget_id in(" + ids.source.join(',') + ")";
			var result:Array =  select_order("*", where, null, "PageName",null);
			result = convertResult(result);			
			return result;
		}
		
		
		public function readAll():Array{
			var where:String = "";
			var result:Array =  select_order("*", where, null, "PageName",null);
			var listConfig:Array = new Array();
			return convertResult(result);
		}
		protected function convertResult(result:Array):Array{
			var listConfig:Array = new Array();
			if(result!=null){
				for each(var obj:Object in result){
					var selectedids:String = obj.SelectedAssessments as String;
					var dto:DtoPage = new DtoPage(obj.AssessmentType,
						obj.PageName, new ArrayCollection(selectedids.split(";")));
					dto.recordId = obj.gadget_id;
					dto.isCreateSum = obj.iscreatesum;
					dto.totalStoreToField = obj.TotalStoreToField;
					listConfig.push(dto);
				}
			}
			return listConfig;
		}
		
	}
}