package
{
	import com.assessment.DtoConfiguration;
	
	import gadget.dao.ActivityDAO;
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.i18n.i18n;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	import gadget.window.WindowManager;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;

	public class StartInspection
	{
		
		public function StartInspection()
		{
		
		}
		public function openAssessmentModel(selectedItem:Object):void{
			var tempAccountId:String = selectedItem.AccountId;
			selectedItem = Database.activityDao.findByGadgetId(selectedItem.gadget_id);
			if(StringUtils.isEmpty(selectedItem.AccountId)){//user can save survey when he selected account
				selectedItem.AccountId = tempAccountId;
			}
			if(Database.preferencesDao.getBooleanValue(PreferencesDAO.ENABLE_ASSESSMENT_SCRIPT)){
				var lstSurveyedTask:ArrayCollection = Database.activityDao.findSurveyByParentSurveyId(selectedItem.ActivityId,Survey.ACTIVITY_TYPE);

				if(lstSurveyedTask.length > 0){
					var model:DtoConfiguration = Utils.getModelName(lstSurveyedTask[0]);
					if(model!=null){//edit inspection
						var survey:Survey = new Survey();
						survey.lstSurveyedTask =lstSurveyedTask;
						survey.assModel =model;
						survey.parentItem = selectedItem;
						WindowManager.openModal(survey);
						return;
					}else{
						//maybe model has been change name
						//delete all task survay
//						var criterai:Object = {};
//						criterai[ActivityDAO.PARENTSURVEYID] = selectedItem.ActivityId;
						Database.activityDao.deleteTempSubTaskSuryveyByParent(selectedItem.ActivityId);
						
					}
					
				}
				//start new inspction
				var assessmentModel:AssessmentModel = new AssessmentModel();
				assessmentModel.parentItem = selectedItem;
				WindowManager.openModal(assessmentModel);
			}
		}
		
		
		
		
	}
}