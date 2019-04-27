package gadget.assessment
{
	import com.assessment.DtoColumn;
	import com.assessment.DtoConfiguration;
	
	import gadget.dao.Database;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class AssessmentModelTotal implements IAssessmentTotal
	{
		
		private var _listPageTotal:ArrayCollection = new ArrayCollection();
		private var _assModel:DtoConfiguration;
		private var _listColumns:Array;
		private var _listSumField:Array;
		public function AssessmentModelTotal(model:DtoConfiguration,listCols:Array=null)
		{
			this._listColumns = listCols;
			this._assModel = model;
		}
		
		
		
		public function get assModel():DtoConfiguration{
			return _assModel;
		}
		
		public function get listColumns():Array{
			if(this._listColumns==null){
				this._listColumns = Database.mappingTableSettingDao.getColumnByModelId(assModel.recordId);
			}
			return this._listColumns;
		}
		
		public function get listSumField():Array{
			if(this._listSumField==null){
				this._listSumField = Database.sumFieldDao.getAllSumField(assModel.recordId);	
			}
			return this._listSumField;
		}
		
		public function getColumnById(colId:String):DtoColumn{
			for each(var col:DtoColumn in listColumns){
				if(col.recordId==colId){
					return col;
				}
			}
			return null;
			
		}
		
		public function set listPageTotal(pagesTotal:ArrayCollection):void{
			this._listPageTotal = pagesTotal;
		}
		
		public function getMapTotalField():String{
			return this._assModel.totalStoreToField;
		}
		
		public function get listPageTotal():ArrayCollection{
			return this._listPageTotal;
		}
		
		public function getModel():DtoConfiguration{
			return this.assModel;
		}
		
		public function getAverageTotal():Number{
			if(_listPageTotal!=null && _listPageTotal.length>0){
				var total:Number = 0;
				for each(var pageTotal:AssessmentPageTotal in _listPageTotal){
					total+=pageTotal.getAverageTotal();
				}
				
				return total/_listPageTotal.length;
				
			}
			
			return 0;
		}
		public function getName():String{
			return this._assModel.assessmentModel;
		}
		
		public function saveTotalToObject(item:Object):void{

			//item[getMapTotalField()] = getAverageTotal().toFixed(2);
			
			
			for each(var dtoSumCol:Object in listSumField){
				var mappingObject:DtoColumn = getColumnById(dtoSumCol.ColId);
				if(mappingObject!=null){
					if(StringUtils.isEmpty(assModel.sumType)){
						item[dtoSumCol.ModelTotal] = this.getPercentTotal(mappingObject);		
					}else{
						item[dtoSumCol.ModelTotal] = this.getPercentTotal(mappingObject).toFixed(2);		
					}
									
				}
			}
			
			
		}
		
		public function  addPageTotal(pageTotal:AssessmentPageTotal):void{
			pageTotal.modelTotal = this;
			this._listPageTotal.addItem(pageTotal);
		}
		
		public function getPercentTotal(col:DtoColumn):Number{
			if(_listPageTotal!=null && _listPageTotal.length>0){
				var total:Number = 0;
				for each(var pageTotal:AssessmentPageTotal in _listPageTotal){
					total+=pageTotal.getPercentTotal(col);
				}
				if(StringUtils.isEmpty(assModel.sumType)){
					return total;
				}else{
					return total/_listPageTotal.length;
				}
				
				
			}
			
			return 0;
				
		}
		
	}
}