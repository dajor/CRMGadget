package gadget.dao
{
	import com.assessment.DtoConfiguration;
	import com.fellow.license.DtoMail;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class AssessmentConfigDAO extends SimpleTable
	{
		
		
		private var stmtSelectByGadgetId:SQLStatement;
		
		private var textColumns:Array = [
			"ModelName",
			"AssessmentType",
			"entity",
			"SelectedPages",
			"TotalStoreToField",
			"SumType",
			"Type"
		];
		public function AssessmentConfigDAO(sqlConnection:SQLConnection, work:Function)
		{
			super( sqlConnection,work, {
				table: 'assessmentconfiguration',			
				name_column: [ 'ModelName' ],
				search_columns: [ 'ModelName' ],
				display_name : "ModelName",
				drop_table:false,
				unique:['ModelName'],				
				columns: {gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT", 'TEXT' : textColumns,'BOOLEAN':['iscreatesum'] }
			});
			
			
			stmtSelectByGadgetId = new SQLStatement();
			stmtSelectByGadgetId.sqlConnection = sqlConnection;
			stmtSelectByGadgetId.text = "SELECT  * FROM assessmentconfiguration where gadget_id=:gadget_id";
			
			
		}
		public function getAssessmentConfigByEnitty(entity:String,roleName:String):Array{
			
			var where:String = "WHERE entity='" + entity +"'" ;
			if(!StringUtils.isEmpty(roleName)){
				where = where + " And ModelName Like '" + roleName + "%'"
			}
			var result:Array = select_order("*", where, null, "ModelName",null);
			
			return convertResult(result);
		}
		
		
		public function getByGadgetId(gadgetId:String):DtoConfiguration{
			stmtSelectByGadgetId.parameters[":gadget_id"]=gadgetId;
			exec(stmtSelectByGadgetId);
			var records:Array = convertResult(stmtSelectByGadgetId.getResult().data);
			
			if(records.length>0){
				return records[0];
			}
			return null;
		}
		
	
	
		
		public function getAssessmentConfigByName(modelName:String):DtoConfiguration{
			
			var where:String = "WHERE ModelName LIKE '"+modelName+"'";
			var result:Array = select_order("*", where, null, "ModelName",null);
			var records:Array = convertResult(result);
			if(records.length>0){
				return DtoConfiguration(records[0]);
			}
			return null;
		}
		
		
		
		protected function convertResult(result:Array):Array{
			var listConfig:Array = new Array();
			if(result!=null){
				for each(var obj:Object in result){
					var selectedids:String = obj.SelectedPages as String;
					var dto:DtoConfiguration = new DtoConfiguration(obj.AssessmentType,
						obj.ModelName,obj.Type, new ArrayCollection(selectedids.split(";")));
					dto.recordId = obj.gadget_id;
					dto.totalStoreToField = obj.TotalStoreToField;
					dto.isCreateSum = obj.iscreatesum;
					dto.sumType=obj.SumType;
					listConfig.push(dto);
				}
			}
			return listConfig;
		}
		
		public function readAll():Array{
			var where:String = "";
			var result:Array =  select_order("*", where, null, "ModelName",null);
			var listConfig:Array = new Array();
			return convertResult(result);
		}
		
	
	}
}