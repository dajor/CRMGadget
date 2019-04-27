package gadget.dao
{
	import com.assessment.DtoColumn;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;

	public class MappingTableColumnSetting extends SimpleTable
	{
		private var stmtDelete:SQLStatement;
		
		private var stmtSelectByColProp:SQLStatement;		
		private var stmtSelectColumenByModelId:SQLStatement;
		private var stmtSelByGadgetId:SQLStatement;
		protected var textColumns:Array=[
		"ColProperty","Title",'ModelId','dataType', 'description'
		];
		
		public function MappingTableColumnSetting(sqlConnection:SQLConnection, work:Function)
		{
			super( sqlConnection,work, {
				table: 'mappingtablecolumnsetting',			
				name_column: [ 'Title' ],
				search_columns: [ 'Title' ],
				display_name : "Title",
				drop_table:false,
				unique:['Title,ColProperty,ModelId'],				
				columns: {gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT",'INTEGER':['OrderNum'],'BOOLEAN':['IsCheckbox','IsDefault','Visible','IsHasSumField'], 'TEXT' : textColumns }
			});
			
			// Deletes an item
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM mappingtablecolumnsetting WHERE gadget_id = :gadget_id";
			
		
			stmtSelectByColProp = new SQLStatement();
			stmtSelectByColProp.sqlConnection = sqlConnection;
			stmtSelectByColProp.text = "SELECT  * FROM mappingtablecolumnsetting WHERE ColProperty= :ColProperty ORDER BY gadget_id desc limit 1";
			
			
			
			stmtSelectColumenByModelId = new SQLStatement();
			stmtSelectColumenByModelId.sqlConnection = sqlConnection;
			stmtSelectColumenByModelId.text = "SELECT  * FROM mappingtablecolumnsetting WHERE ModelId = :ModelId ORDER BY OrderNum";
			
			stmtSelByGadgetId = new SQLStatement();
			stmtSelByGadgetId.sqlConnection = sqlConnection;
			stmtSelByGadgetId.text = "SELECT  * FROM mappingtablecolumnsetting WHERE gadget_id = :gadget_id";
			
		}	
		
		public function selectByGadgetId(gadget_id:String):DtoColumn{
			stmtSelByGadgetId.parameters[":gadget_id"] = gadget_id;	
			exec(stmtSelByGadgetId);
			var res:Array = stmtSelByGadgetId.getResult().data;
			res = convertResult(res);
			if(res.length>0){
			return res[0];
			}
			return null;
		}
		
		public function deleteByGadgetId(gadgetId:String):void{
			stmtDelete.parameters[":gadget_id"] = gadgetId;
			exec(stmtDelete);
		}
		
		
		public function selectByColProperty(colProperty:String):Object{
			stmtSelectByColProp.parameters[":ColProperty"] = colProperty;
			exec(stmtSelectByColProp);
			var res:Array = stmtSelectByColProp.getResult().data;
			if(res!=null && res.length>0){
				return res[0];
			}
			return null;
		}
		
		
		protected function convertResult(result:Array):Array{
			var listCols:Array = new Array();
			if(result!=null){
				for each(var obj:Object in result){
					
					listCols.push(convertToDtoColumn(obj));
				}
			}
			return listCols;
		}
		
		public function convertToDtoColumn(obj:Object):DtoColumn{
			var selectedids:String = obj.SelectedAssessments as String;
			var dto:DtoColumn = new DtoColumn();
			dto.recordId = obj.gadget_id;
			dto.title = obj.Title;
			dto.colProperty = obj.ColProperty;
			dto.order = obj.OrderNum;
			dto.isDefault = obj.IsDefault;
			dto.description = obj.description;
			var dataType:String = obj.dataType;
			if(dataType==null){
				if(obj.IsCheckbox){
					dataType=DtoColumn.CHECK_BOX_TYPE;//old value
				}else{
					dataType = DtoColumn.TEXT_TYPE;
				}
			}
			dto.dataType = dataType;
			dto.visible = obj.Visible;
			dto.isHasSumField = obj.IsHasSumField;
			dto.modelId = obj.ModelId;
			return dto;
		}
		
		public function getColumnByModelId(modelId:String,convert:Boolean = true):Array{
			stmtSelectColumenByModelId.parameters[":ModelId"] = modelId;			
			
			//var result:Array =  select_order("*", "IsHasSumField", stmtSelectBySumField, "OrderNum",null);
			exec(stmtSelectColumenByModelId);
			
			var result:Array = stmtSelectColumenByModelId.getResult().data;
			if(result==null || result.length<1){
				//create a default column
				for each(var col:Object in DEFAULT_COLUMNS){
						col.ModelId=modelId;
						insert(col);
				}
				//re-selected
				return getColumnByModelId(modelId);
			}else{
				if(convert){
					return convertResult(result);
				}else{
					return result;
				}
			}
		}
		public function readAll():Array{
			var where:String = "";
			var result:Array =  select_order("*", where, null, "OrderNum",null);
			var listConfig:Array = new Array();
			return convertResult(result);
		}
		
	private static	var DEFAULT_COLUMNS:Array = [
			{"ColProperty":'Question',"Title":'Question',"OrderNum":1,'IsCheckbox':false,'IsDefault':true,'Visible':true},
			{"ColProperty":'AnswerMapToField',"Title":'Answer Map To Field',"OrderNum":2,'IsCheckbox':false,'IsDefault':true,'Visible':true},
			{"ColProperty":'QuestionMapToField',"Title":'Question Map To Field',"OrderNum":3,'IsCheckbox':false,'IsDefault':true,'Visible':false},
			{"ColProperty":'CommentMapToField',"Title":'Comment Map To Field',"OrderNum":4,'IsCheckbox':false,'IsDefault':true,'Visible':true},					
			
		];
		
		
	}
}