package gadget.assessment
{
	import com.assessment.DtoColumn;
	import com.assessment.DtoConfiguration;
	import com.assessment.DtoPage;
	
	import gadget.dao.Database;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class AssessmentPageTotal implements IAssessmentTotal
	{
		protected var _page:DtoPage;
		protected var _listSectionTotal:ArrayCollection = new ArrayCollection();
		
		protected var _modelTotal:AssessmentModelTotal;
		
		public function AssessmentPageTotal(page:DtoPage)
		{
			this._page = page;
		}
		
		
		public function getModel():DtoConfiguration{
			return this.getDtoModel();
		}
		
		public function getMapTotalField():String{
			return this.page.totalStoreToField;
		}
		
		public function getDtoModel():DtoConfiguration{
			if(_modelTotal!=null){
				return _modelTotal.assModel;
			}
			return null;
		}
		
		public function set modelTotal(parentTotal:AssessmentModelTotal):void{
			this._modelTotal = parentTotal;
		}
		
		public function get modelTotal():AssessmentModelTotal{
			return this._modelTotal;
		}
		
		public function saveTotalToObject(item:Object):void{
			//item[getMapTotalField()] = getAverageTotal().toFixed(2);
			for each(var dtoSumCol:Object in modelTotal.listSumField){
				var mappingObject:DtoColumn = modelTotal.getColumnById(dtoSumCol.ColId);
				if(mappingObject!=null){
					if(StringUtils.isEmpty(getDtoModel().sumType)){
						item[dtoSumCol.PageTotal] = this.getPercentTotal(mappingObject);	
					}else{
						item[dtoSumCol.PageTotal] = this.getPercentTotal(mappingObject).toFixed(2);	
					}
									
				}
			}
		}
		
		public function getName():String{
			return this.page.pageName;
		}
		
		public function get page():DtoPage{
			return this._page;
		}
		
		public function get listSectionTotal():ArrayCollection{
			
			return _listSectionTotal;
		}
		
		public function addSectionTotal(sectionTotal:AssessmentSectionTotal):void{
			sectionTotal.assPageTotal = this;
			this._listSectionTotal.addItem(sectionTotal);
		}
		
		public function getAverageTotal():Number{
			if(_listSectionTotal.length>0){
				var total:Number =0;				
				for each(var section:AssessmentSectionTotal in _listSectionTotal){
					total+=section.getAverageTotal();
				}				
				return total/_listSectionTotal.length;
				
			}	
			
			return 0;
		}
		
		public function getPercentTotal(col:DtoColumn):Number{
			if(_listSectionTotal.length>0){
				var total:Number =0;
				
				for each(var section:AssessmentSectionTotal in _listSectionTotal){
					total+=section.getPercentTotal(col);
				}
				if(StringUtils.isEmpty(getDtoModel().sumType)){
					return total;
				}
				return total/_listSectionTotal.length;
				
			}	
			
			return 0;
		}
	}
}