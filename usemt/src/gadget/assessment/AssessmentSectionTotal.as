package gadget.assessment
{
	import com.assessment.DtoAssessment;
	import com.assessment.DtoColumn;
	import com.assessment.DtoConfiguration;
	import com.assessment.DtoPage;
	
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class AssessmentSectionTotal implements IAssessmentTotal
	{
		private var _assessment:Object;
		private var _listQuestion:ArrayCollection;
		private var _Question:String = i18n._("Total");
		private var _isFooter:Boolean = true;
		
		private var _isHeader:Boolean = false;
		
		private var _assPageTotal:AssessmentPageTotal;
	
		
		
		public function AssessmentSectionTotal(ass:Object)
		{
			this._assessment = ass;				
			
		}
		public function getMapTotalField():String{
			return assessment.TotalStoreToField;
		}
		
		
		
		public function get modelTotal():AssessmentModelTotal{
			return assPageTotal.modelTotal;
		}
		
		public function getDtoModel():DtoConfiguration{
			if(_assPageTotal!=null){
				return this._assPageTotal.getDtoModel();
			}
			return null;
		}
		
		public function set assPageTotal(pageTotal:AssessmentPageTotal):void{
			this._assPageTotal = pageTotal;
		}
		
		public function get assPageTotal():AssessmentPageTotal{
			return this._assPageTotal;
		}
		
		public function get isHeader():Boolean{
			return this._isHeader;
		}
		
		public function get assessment():Object{
			return this._assessment;
		}
		
		
		public function get Question():String{
			return this._Question;
		}
		
		public function isFooter():Boolean{
			return this._isFooter;
		}
		
		public function set listQuestion(questions:ArrayCollection):void{
			this._listQuestion = questions;
		}
		
		public function get listQuestion():ArrayCollection{
			return this._listQuestion;
		}
		
		public function getName():String{
			return this.assessment.Name;
		}
		
		public function saveTotalToObject(item:Object):void{
			//item[getMapTotalField()] = getAverageTotal().toFixed(2);
			for each(var dtoSumCol:Object in modelTotal.listSumField){
				var mappingObject:DtoColumn =modelTotal.getColumnById(dtoSumCol.ColId);
				if(mappingObject!=null){	
					if(StringUtils.isEmpty(getDtoModel().sumType)){
						item[dtoSumCol.SectionTotal] = this.getPercentTotal(mappingObject);
					}else{
						item[dtoSumCol.SectionTotal] = this.getPercentTotal(mappingObject).toFixed(2);
					}
										
				}
			}
		}
		
		public function getAverageTotal():Number{
			var model:DtoConfiguration = getDtoModel();
			if(model!=null){
				var listRealSumColumns:ArrayCollection = new ArrayCollection();
				var listColumn:Array = modelTotal.listColumns;
				if(listColumn!=null){
					for each (var map:DtoColumn in listColumn){						
						if(map.visible && map.isHasSumField){
							listRealSumColumns.addItem(map);
						}
					}
					if(listRealSumColumns.length>0){
						var total:Number =0;
						
							
							for each(var col:DtoColumn in listRealSumColumns){
								
								total+=getLocalPercentTotal(col,true);
								
							}	
						
						
						return total/listRealSumColumns.length;
						
					}
					
				}
			}
			return 0;
		}
		public function getPercentTotal(col:DtoColumn):Number{
			return getLocalPercentTotal(col);
		}
		
		public function getModel():DtoConfiguration{
			return this.getDtoModel();
		}
		
		private function getLocalPercentTotal(col:DtoColumn,isPercent:Boolean=false):Number{
		
			if(_listQuestion!=null && _listQuestion.length>0){
				var total:Number =0;
				if(col!=null){
					
					for each(var quest:Object in _listQuestion){
						if(col.dataType==DtoColumn.CHECK_BOX_TYPE || col.dataType==DtoColumn.RADIO_TYPE){
							total+=((quest[col.colProperty] == '1'||quest[col.colProperty]=='true')?1:0);
						}else{
							total+=(StringUtils.isEmpty(String(quest[col.colProperty]))?0:1);
						}
					}	
					
				}
				if(StringUtils.isEmpty(getDtoModel().sumType) && !isPercent ){//type as number
					return total;
				}else{
					return (total/_listQuestion.length)*100;	
				}
				
			}
			
			return 0;
			
		}
		
	}
}