package gadget.dao
{
	
	import com.assessment.DtoPDFColorTheme;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	

	public class AssessmentPDFColorThemeDAO extends SimpleTable
	{
		    public static var IMG_BG_PDF_COLOR_DATA_HEADER:String ="IMG_BG_PDF_COLOR_DATA_HEADER";
			public static var IMG_BG_PDF_HEADER_COLOR_GRID:String ="IMG_BG_PDF_HEADER_COLOR_GRID";
			public static var IMG_BG_PDF_COLOR_PAGE:String ="IMG_BG_PDF_COLOR_PAGE";
			
			private var stmtDelete:SQLStatement = new SQLStatement();
			private var stmtSelect:SQLStatement = new SQLStatement();
			private var stmtSelectByColorType:SQLStatement = new SQLStatement();
			public function AssessmentPDFColorThemeDAO(sqlConnection:SQLConnection, workerFunction:Function)
			{
				super(sqlConnection, workerFunction, {
					table:"assessment_pdf_color_theme",
					index: [ 'colorType' ],
					columns: {
						gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT",
						'ordering' : 'INTEGER',
						'TEXT' : [ 'color','colorType']
					}
				});		
				stmtDelete.sqlConnection = sqlConnection;
				stmtDelete.text = "DELETE FROM assessment_pdf_color_theme where colorType=:colorType";	
				stmtSelect.sqlConnection = sqlConnection;
				stmtSelect.text = "Select * from assessment_pdf_color_theme order by ordering";		
				
				stmtSelectByColorType.sqlConnection = sqlConnection;
				stmtSelectByColorType.text = "Select * from assessment_pdf_color_theme where colorType=:colorType";
			}
			public function deleteAssPDFHeader(colorType:String):void{
				stmtDelete.parameters[":colorType"]=colorType;
				exec(stmtDelete);
			}
			
			
			
			protected function convertResult(result:Array):Array{
				var lstColor:Array = new Array();
				if(result!=null){
					for each(var obj:Object in result){
						var dto:DtoPDFColorTheme  = new DtoPDFColorTheme();
						dto.color = obj.color;
						dto.colorType = obj.colorType;
						dto.ordering = obj.ordering;
						dto.gadget_id = obj.gadget_id;
						lstColor.push(dto);
					}
				}
				return lstColor;
			}
			
			public function getAllPDFColorTheme():ArrayCollection{
				exec(stmtSelect);
				return new ArrayCollection(convertResult(stmtSelect.getResult().data));
			}
			
			public function getPDFColorByColorType(colorType:String):String{
				stmtSelectByColorType.parameters[":colorType"]=colorType;
				exec(stmtSelectByColorType);
				var lst:Array = convertResult(stmtSelectByColorType.getResult().data);
				if(lst != null && lst.length >0){
					var dto:DtoPDFColorTheme = lst[0] as DtoPDFColorTheme;
					return dto.color;
				}else{
					return null;
				}
			}
		}
}