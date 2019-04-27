package gadget.dao
{
	import com.adobe.protocols.dict.Dict;
	import com.adobe.utils.DateUtil;
	import com.adobe.utils.StringUtil;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.utils.Dictionary;
	
	import flex.lang.reflect.Field;
	
	import gadget.service.UserService;
	import gadget.util.DateUtils;
	import gadget.util.NumberLocaleUtils;
	import gadget.util.OOPS;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	public class OpportunityDAO extends BaseDAO {
		public static const FORECAST_TYPE:String = "forecast"; 
		public static const ACTUAL_TYPE:String = "Actual";
		public static const VARIANCE_TYPE:String = "Variance";
		
		public function OpportunityDAO(sqlConnection:SQLConnection, work:Function) {			
			super(work, sqlConnection, {
				table: 'opportunity',
				oracle_id: 'OpportunityId',
				name_column: [ 'OpportunityName' ],
				search_columns: [ 'OpportunityName' ],
				display_name : "opportunitys",
				index: [ "OpportunityId", "OpportunityType", "OwnerId", "AccountId" ],
				columns: { 'TEXT' : textColumns }
			});
		}
/*		
		override protected function get sortColumn():String {
			return "opportunityname";
		}
*/		
		override public function get entity():String {
			return "Opportunity";
		}
		
		
		
		public override function updateByField(fields:Array,object:Object,fieldCriteria:String = 'gadget_id',addLocalUpdate:Boolean=false):void{
			var isCalImpactC:Boolean = isCalculateImpactCalendar(object,fieldCriteria);
			super.updateByField(fields,object,fieldCriteria,addLocalUpdate);
			if(isCalImpactC){
				calCulateImpactByOppId(object[fieldOracleId]);
			}
		}
		
		protected function calCulateImpactByOppId(optId:String):void{
			var impacs:ArrayCollection = findImpactCalendar(null,null,optId);
			if(impacs!=null && impacs.length>0){
				var recordsChange:ArrayCollection = new ArrayCollection();
				for each(var r:Object in impacs){
					if(!isMandatory(r,true)){
						//mark every row as change
						r.co7Change=true;
						calImpactCalMonth(r);
						recordsChange.addItem(r);
					}
				}
				if(recordsChange.length>0){
					saveImpactCalendar(impacs,OP_IMP_CAL_FIELD,CO7_IMP_CAL_FIELD,recordsChange);
				}
				
			}
		}
		
		public override function update(object:Object):void {
			var isCalImpactC:Boolean = isCalculateImpactCalendar(object,'gadget_id');
			super.update(object);
			if(isCalImpactC){
				calCulateImpactByOppId(object[fieldOracleId]);
			}
			
		}
		
		public override function updateByOracleId(object:Object,updateCustomField:Boolean=false):void {
			var isCalImpactC:Boolean = isCalculateImpactCalendar(object,fieldOracleId);
			super.updateByOracleId(object,updateCustomField);
			if(isCalImpactC){
				calCulateImpactByOppId(object[fieldOracleId]);
			}
		}

		protected function isCalculateImpactCalendar(uObj:Object,fieldCriteria:String):Boolean{
			if(UserService.getCustomerId()==UserService.COLOPLAST && Database.preferencesDao.isEnableImpactCalendar()){
				var dbVal:Object = null;
				if(fieldOracleId==fieldCriteria){
					dbVal = findByOracleId(uObj[fieldCriteria]);
				}else{
					dbVal = findByGadgetId(uObj[fieldCriteria]);
				}
				
				if(dbVal!=null){
					
					var oldCurveType:String = dbVal.CustomPickList7;
					var newCurveType:String = uObj.CustomPickList7;
					if(newCurveType!=oldCurveType){
						return true;
					}
					
					//"CustomDate26",//Stard Dat
					//"CustomDate25",//end date
					var dbStartDate:Date =DateUtils.parse(dbVal.CustomDate26,DateUtils.DATABASE_DATE_FORMAT);					
					var uStartDate:Date =DateUtils.parse(uObj.CustomDate26,DateUtils.DATABASE_DATE_FORMAT);
					var dbEndDate:Date =DateUtils.parse(dbVal.CustomDate25,DateUtils.DATABASE_DATE_FORMAT);
					var uEndDate:Date =DateUtils.parse(uObj.CustomDate25,DateUtils.DATABASE_DATE_FORMAT);
					if(dbStartDate==null 
						|| uStartDate==null 
						||dbEndDate==null 
						||uEndDate==null){
						
						return true;
					}
					
					
					return  (dbStartDate.getMonth()!=uStartDate.getMonth() 
						|| dbStartDate.getFullYear()!=uStartDate.getFullYear()
						|| dbEndDate.getMonth()!=uEndDate.getMonth()
						|| dbEndDate.getFullYear()!=uEndDate.getFullYear());
					
					
				}
			}
			
			return false;
		}
		
		
		
		public static const CO7_PREFIX:String = "co7_";
		override public function getIgnoreCopyFields():ArrayCollection{
			return new ArrayCollection(
					[
					'SalesStage',
					'SalesStageId',
					'CloseDate',
					'OpportunityId',
					'gadget_id',
					'local_update',
					'delete',
					'error',
					'ood_lastmodified',
					'sync_number',
					'important',
					'favorite'
					]);
		}
		
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return INGNORE_FIELDS;
		}
		
		
		private static const INGNORE_FIELDS:ArrayCollection=new ArrayCollection(
			[
				"AccountLocation",
				"AccountExternalSystemId",
				"AccountName",
				"CustomObject1ExternalSystemId",
				"CustomObject1Name",
				"CustomObject2ExternalSystemId",
				"CustomObject2Name",
				"CustomObject3ExternalSystemId",
				"CustomObject3Name",
				"CustomObject5ExternalSystemId",
				"CustomObject5Name",
				"CustomObject6ExternalSystemId",
				"CustomObject6Name",
				'Owner',
				'OwnerFullName',				
				'OwnerPartnerAccount',
				'OwnerPartnerExternalSystemId',
				'OwnerPartnerIntegrationId',
				'OwnerPartnerLocation',
				'OwnerPartnerName',
				'OwnershipStatus',
				'SalesProcess',
				'SalesStage'
			
			]);
		
		//TODO will change when get field from simone
		private static const CO7_CURRENT_YEAR_FIELD:String = "CustomNumber1";
		public static const MONTH_FIELD_FOR_EACH_Q:Array=[
			"co7_CustomCurrency0",//Monthly Revenue 1
			"co7_CustomCurrency2",//Monthly Revenue 2
			"co7_CustomCurrency1",//Monthly Revenue 3
		];
		
		//for impact calendar
		public static const ENTITY_CHECKS:Array = ['Opportunity','CustomObject7']
		public static const MANDATORY_FIELD:Object ={Opportunity:["CustomPickList7","CustomDate26","CustomDate25"],CustomObject7:["CustomPickList31",//Category
			"CustomPickList34",//unit
			"CustomNumber0",//Quantity
			"CustomCurrency4"//value
		]};
		public static const CO7_IMP_CAL_FIELD:Array =[
			"CustomPickList31",//Category
			"CustomPickList34",//unit
			"CustomNumber0",//Quantity
			"CustomCurrency4",//value
			"CustomPickList33",//Quarter
			"CustomCurrency0",//Monthly Revenue 1
			"CustomCurrency2",//Monthly Revenue 2
			"CustomCurrency1",//Monthly Revenue 3
			"CustomCurrency3",//quater total
			"Name",
			"CustomCurrency6",//Last FY Impact 
			"Type",//product type
			"CustomCurrency5",//Current FY Impact
			"CustomCurrency7",//Change vs last FY 
			"CustomCurrency8",//Next FY Impact
			"CustomCurrency9",//Annualized Impact
			CO7_CURRENT_YEAR_FIELD
			
			
		]; 
		
		public static const OP_IMP_CAL_FIELD:Array=[
			"OwnerFullName",
			"OpportunityId",
			"OpportunityName",
			"AccountName",
			"AccountId",
			"SalesStage",
			"SalesStageId",
			"Probability",
			"CloseDate",
			"CustomDate9",//Original Close Date
			"CustomPickList0",//Business Area (CP)
			"CustomPickList7",//Curve Type
			"CustomDate26",//Stard Date
			"CustomDate25",//end date
			"CustomCurrency0",//Annualized Impact
			"CustomCurrency1",//Current FY Impact
			"CustomCurrency3",//Previous FY Impact
			"CustomCurrency4",//Next FY Impact
			"CustomText37",//Total Calls Current Quarter
			"CustomCurrency2",//Expenses
			"ModifiedDate",	
			"Status"
			
		];
		
		private var textColumns:Array = [
			'AccountExternalSystemId',
			'AccountId',
			'AccountLocation',
			'AccountName',
			'ApprovalStatus',
			'ApprovedDRExpiresDate',
			'ApprovedDRId',
			'ApprovedDRPartnerId',
			'ApprovedDRPartnerLocation',
			'ApprovedDRPartnerName',
			'ApproverAlias',
			'AssessmentFilter1',
			'AssessmentFilter2',
			'AssessmentFilter3',
			'AssessmentFilter4',
			'AssignmentStatus',
			'ChannelAccountManager',
			'CloseDate',
			'CreatedBy',
			'CreatedByEmailAddress',
			'CreatedById',
			'CreatedDate',
			'CurrencyCode',
			'Dealer',
			'DealerExternalSystemId',
			'DealerId',
			'Description',
			'ExpectedRevenue',
			'ExternalSystemId',
			'Forecast',
			'FuriganaAccountName',
			'IntegrationId',
			'KeyContactExternalSystemId',
			'KeyContactId',
			'KeyContactLastName',
			'LastAssessmentDate',
			'LastAssignmentCompletionDate',
			'LastAssignmentSubmissionDate',
			'LastUpdated',
			'LeadSource',
			'Make',
			'ModId',
			'Model',
			'ModifiedBy',
			'ModifiedByEmailAddress',
			'ModifiedById',
			'ModifiedDate',
			'NextStep',
			'OpportunityConcatField',
			'OpportunityId',
			'OpportunityName',
			'OpportunityType',
			'OriginatingPartnerExternalSystemId',
			'OriginatingPartnerIntegrationId',
			'OriginatingPartnerLocation',
			'OriginatingPartnerName',
			'Owner',
			'OwnerFullName',
			'OwnerId',
			'OwnerPartnerAccount',
			'OwnerPartnerExternalSystemId',
			'OwnerPartnerIntegrationId',
			'OwnerPartnerLocation',
			'OwnerPartnerName',
			'OwnershipStatus',
			'PrimaryGroup',
			'PrincipalPartnerExternalSystemId',
			'PrincipalPartnerIntegrationId',
			'PrincipalPartnerLocation',
			'PrincipalPartnerName',
			'Priority',
			'Probability',
			'ProductInterest',
			'ProgramProgramName',
			'ReasonWonLost',
			'ReassignOwnerFlag',
			'RegistrationStatus',
			'Revenue',
			'SalesProcess',
			'SalesProcessId',
			'SalesStage',
			'SalesStageId',
			'SourceCampaign',
			'SourceCampaignExternalSystemId',
			'SourceCampaignId',
			'StageStatus',
			'Status',
			'Territory',
			'TerritoryId',
			'TotalAssetValue',
			'TotalPremium',
			'Type',
			'Year',
			'CustomBoolean0',
			'CustomBoolean1',
			'CustomBoolean2',
			'CustomBoolean3',
			'CustomBoolean4',
			'CustomBoolean5',
			'CustomBoolean6',
			'CustomBoolean7',
			'CustomBoolean8',
			'CustomBoolean9',
			'CustomBoolean10',
			'CustomBoolean11',
			'CustomBoolean12',
			'CustomBoolean13',
			'CustomBoolean14',
			'CustomBoolean15',
			'CustomBoolean16',
			'CustomBoolean17',
			'CustomBoolean18',
			'CustomBoolean19',
			'CustomBoolean20',
			'CustomBoolean21',
			'CustomBoolean22',
			'CustomBoolean23',
			'CustomBoolean24',
			'CustomBoolean25',
			'CustomBoolean26',
			'CustomBoolean27',
			'CustomBoolean28',
			'CustomBoolean29',
			'CustomBoolean30',
			'CustomBoolean31',
			'CustomBoolean32',
			'CustomBoolean33',
			'CustomBoolean34',
			'CustomCurrency0',
			'CustomCurrency1',
			'CustomCurrency2',
			'CustomCurrency3',
			'CustomCurrency4',
			'CustomCurrency5',
			'CustomCurrency6',
			'CustomCurrency7',
			'CustomCurrency8',
			'CustomCurrency9',
			'CustomCurrency10',
			'CustomCurrency11',
			'CustomCurrency12',
			'CustomCurrency13',
			'CustomCurrency14',
			'CustomCurrency15',
			'CustomCurrency16',
			'CustomCurrency17',
			'CustomCurrency18',
			'CustomCurrency19',
			'CustomCurrency20',
			'CustomCurrency21',
			'CustomCurrency22',
			'CustomCurrency23',
			'CustomCurrency24',
			'CustomDate0',
			'CustomDate1',
			'CustomDate2',
			'CustomDate3',
			'CustomDate4',
			'CustomDate5',
			'CustomDate6',
			'CustomDate7',
			'CustomDate8',
			'CustomDate9',
			'CustomDate10',
			'CustomDate11',
			'CustomDate12',
			'CustomDate13',
			'CustomDate14',
			'CustomDate15',
			'CustomDate16',
			'CustomDate17',
			'CustomDate18',
			'CustomDate19',
			'CustomDate20',
			'CustomDate21',
			'CustomDate22',
			'CustomDate23',
			'CustomDate24',
			'CustomDate25',
			'CustomDate26',
			'CustomDate27',
			'CustomDate28',
			'CustomDate29',
			'CustomDate30',
			'CustomDate31',
			'CustomDate32',
			'CustomDate33',
			'CustomDate34',
			'CustomDate35',
			'CustomDate36',
			'CustomDate37',
			'CustomDate38',
			'CustomDate39',
			'CustomDate40',
			'CustomDate41',
			'CustomDate42',
			'CustomDate43',
			'CustomDate44',
			'CustomDate45',
			'CustomDate46',
			'CustomDate47',
			'CustomDate48',
			'CustomDate49',
			'CustomDate50',
			'CustomDate51',
			'CustomDate52',
			'CustomDate53',
			'CustomDate54',
			'CustomDate55',
			'CustomDate56',
			'CustomDate57',
			'CustomDate58',
			'CustomDate59',
			'CustomInteger0',
			'CustomInteger1',
			'CustomInteger2',
			'CustomInteger3',
			'CustomInteger4',
			'CustomInteger5',
			'CustomInteger6',
			'CustomInteger7',
			'CustomInteger8',
			'CustomInteger9',
			'CustomInteger10',
			'CustomInteger11',
			'CustomInteger12',
			'CustomInteger13',
			'CustomInteger14',
			'CustomInteger15',
			'CustomInteger16',
			'CustomInteger17',
			'CustomInteger18',
			'CustomInteger19',
			'CustomInteger20',
			'CustomInteger21',
			'CustomInteger22',
			'CustomInteger23',
			'CustomInteger24',
			'CustomInteger25',
			'CustomInteger26',
			'CustomInteger27',
			'CustomInteger28',
			'CustomInteger29',
			'CustomInteger30',
			'CustomInteger31',
			'CustomInteger32',
			'CustomInteger33',
			'CustomInteger34',
			'CustomMultiSelectPickList0',
			'CustomMultiSelectPickList1',
			'CustomMultiSelectPickList2',
			'CustomMultiSelectPickList3',
			'CustomMultiSelectPickList4',
			'CustomMultiSelectPickList5',
			'CustomMultiSelectPickList6',
			'CustomMultiSelectPickList7',
			'CustomMultiSelectPickList8',
			'CustomMultiSelectPickList9',
			'CustomNumber0',
			'CustomNumber1',
			'CustomNumber2',
			'CustomNumber3',
			'CustomNumber4',
			'CustomNumber5',
			'CustomNumber6',
			'CustomNumber7',
			'CustomNumber8',
			'CustomNumber9',
			'CustomNumber10',
			'CustomNumber11',
			'CustomNumber12',
			'CustomNumber13',
			'CustomNumber14',
			'CustomNumber15',
			'CustomNumber16',
			'CustomNumber17',
			'CustomNumber18',
			'CustomNumber19',
			'CustomNumber20',
			'CustomNumber21',
			'CustomNumber22',
			'CustomNumber23',
			'CustomNumber24',
			'CustomNumber25',
			'CustomNumber26',
			'CustomNumber27',
			'CustomNumber28',
			'CustomNumber29',
			'CustomNumber30',
			'CustomNumber31',
			'CustomNumber32',
			'CustomNumber33',
			'CustomNumber34',
			'CustomNumber35',
			'CustomNumber36',
			'CustomNumber37',
			'CustomNumber38',
			'CustomNumber39',
			'CustomNumber40',
			'CustomNumber41',
			'CustomNumber42',
			'CustomNumber43',
			'CustomNumber44',
			'CustomNumber45',
			'CustomNumber46',
			'CustomNumber47',
			'CustomNumber48',
			'CustomNumber49',
			'CustomNumber50',
			'CustomNumber51',
			'CustomNumber52',
			'CustomNumber53',
			'CustomNumber54',
			'CustomNumber55',
			'CustomNumber56',
			'CustomNumber57',
			'CustomNumber58',
			'CustomNumber59',
			'CustomNumber60',
			'CustomNumber61',
			'CustomNumber62',
			'CustomObject1ExternalSystemId',
			'CustomObject1Id',
			'CustomObject1Name',
			'CustomObject2ExternalSystemId',
			'CustomObject2Id',
			'CustomObject2Name',
			'CustomObject3ExternalSystemId',
			'CustomObject3Id',
			'CustomObject3Name',
			'CustomObject5ExternalSystemId',
			'CustomObject5Id',
			'CustomObject5Name',
			'CustomObject6ExternalSystemId',
			'CustomObject6Id',
			'CustomObject6Name',
			'CustomObject4Id',
			'CustomObject4Name',
			'CustomObject7Id',
			'CustomObject7Name',
			'CustomObject8Id',
			'CustomObject8Name',
			'CustomObject9Id',
			'CustomObject9Name',
			'CustomObject10Id',
			'CustomObject10Name',
			'CustomObject11Id',
			'CustomObject11Name',
			'CustomObject12Id',
			'CustomObject12Name',
			'CustomObject13Id',
			'CustomObject13Name',
			'CustomObject14Id',
			'CustomObject14Name',
			'CustomObject15Id',
			'CustomObject15Name',
			'CustomPhone0',
			'CustomPhone1',
			'CustomPhone2',
			'CustomPhone3',
			'CustomPhone4',
			'CustomPhone5',
			'CustomPhone6',
			'CustomPhone7',
			'CustomPhone8',
			'CustomPhone9',
			'CustomPhone10',
			'CustomPhone11',
			'CustomPhone12',
			'CustomPhone13',
			'CustomPhone14',
			'CustomPhone15',
			'CustomPhone16',
			'CustomPhone17',
			'CustomPhone18',
			'CustomPhone19',
			'CustomPickList0',
			'CustomPickList1',
			'CustomPickList2',
			'CustomPickList3',
			'CustomPickList4',
			'CustomPickList5',
			'CustomPickList6',
			'CustomPickList7',
			'CustomPickList8',
			'CustomPickList9',
			'CustomPickList10',
			'CustomPickList11',
			'CustomPickList12',
			'CustomPickList13',
			'CustomPickList14',
			'CustomPickList15',
			'CustomPickList16',
			'CustomPickList17',
			'CustomPickList18',
			'CustomPickList19',
			'CustomPickList20',
			'CustomPickList21',
			'CustomPickList22',
			'CustomPickList23',
			'CustomPickList24',
			'CustomPickList25',
			'CustomPickList26',
			'CustomPickList27',
			'CustomPickList28',
			'CustomPickList29',
			'CustomPickList30',
			'CustomPickList31',
			'CustomPickList32',
			'CustomPickList33',
			'CustomPickList34',
			'CustomPickList35',
			'CustomPickList36',
			'CustomPickList37',
			'CustomPickList38',
			'CustomPickList39',
			'CustomPickList40',
			'CustomPickList41',
			'CustomPickList42',
			'CustomPickList43',
			'CustomPickList44',
			'CustomPickList45',
			'CustomPickList46',
			'CustomPickList47',
			'CustomPickList48',
			'CustomPickList49',
			'CustomPickList50',
			'CustomPickList51',
			'CustomPickList52',
			'CustomPickList53',
			'CustomPickList54',
			'CustomPickList55',
			'CustomPickList56',
			'CustomPickList57',
			'CustomPickList58',
			'CustomPickList59',
			'CustomPickList60',
			'CustomPickList61',
			'CustomPickList62',
			'CustomPickList63',
			'CustomPickList64',
			'CustomPickList65',
			'CustomPickList66',
			'CustomPickList67',
			'CustomPickList68',
			'CustomPickList69',
			'CustomPickList70',
			'CustomPickList71',
			'CustomPickList72',
			'CustomPickList73',
			'CustomPickList74',
			'CustomPickList75',
			'CustomPickList76',
			'CustomPickList77',
			'CustomPickList78',
			'CustomPickList79',
			'CustomPickList80',
			'CustomPickList81',
			'CustomPickList82',
			'CustomPickList83',
			'CustomPickList84',
			'CustomPickList85',
			'CustomPickList86',
			'CustomPickList87',
			'CustomPickList88',
			'CustomPickList89',
			'CustomPickList90',
			'CustomPickList91',
			'CustomPickList92',
			'CustomPickList93',
			'CustomPickList94',
			'CustomPickList95',
			'CustomPickList96',
			'CustomPickList97',
			'CustomPickList98',
			'CustomPickList99',
			'CustomText0',
			'CustomText1',
			'CustomText2',
			'CustomText3',
			'CustomText4',
			'CustomText5',
			'CustomText6',
			'CustomText7',
			'CustomText8',
			'CustomText9',
			'CustomText10',
			'CustomText11',
			'CustomText12',
			'CustomText13',
			'CustomText14',
			'CustomText15',
			'CustomText16',
			'CustomText17',
			'CustomText18',
			'CustomText19',
			'CustomText20',
			'CustomText21',
			'CustomText22',
			'CustomText23',
			'CustomText24',
			'CustomText25',
			'CustomText26',
			'CustomText27',
			'CustomText28',
			'CustomText29',
			'CustomText30',
			'CustomText31',
			'CustomText32',
			'CustomText33',
			'CustomText34',
			'CustomText35',
			'CustomText36',
			'CustomText37',
			'CustomText38',
			'CustomText39',
			'CustomText40',
			'CustomText41',
			'CustomText42',
			'CustomText43',
			'CustomText44',
			'CustomText45',
			'CustomText46',
			'CustomText47',
			'CustomText48',
			'CustomText49',
			'CustomText50',
			'CustomText51',
			'CustomText52',
			'CustomText53',
			'CustomText54',
			'CustomText55',
			'CustomText56',
			'CustomText57',
			'CustomText58',
			'CustomText59',
			'CustomText60',
			'CustomText61',
			'CustomText62',
			'CustomText63',
			'CustomText64',
			'CustomText65',
			'CustomText66',
			'CustomText67',
			'CustomText68',
			'CustomText69',
			'CustomText70',
			'CustomText71',
			'CustomText72',
			'CustomText73',
			'CustomText74',
			'CustomText75',
			'CustomText76',
			'CustomText77',
			'CustomText78',
			'CustomText79',
			'CustomText80',
			'CustomText81',
			'CustomText82',
			'CustomText83',
			'CustomText84',
			'CustomText85',
			'CustomText86',
			'CustomText87',
			'CustomText88',
			'CustomText89',
			'CustomText90',
			'CustomText91',
			'CustomText92',
			'CustomText93',
			'CustomText94',
			'CustomText95',
			'CustomText96',
			'CustomText97',
			'CustomText98',
			'CustomText99',
			'IndexedBoolean0',
			'IndexedCurrency0',
			'IndexedDate0',
			'IndexedLongText0',
			'IndexedNumber0',
			'IndexedPick0',
			'IndexedPick1',
			'IndexedPick2',
			'IndexedPick3',
			'IndexedPick4',
			'IndexedPick5',
			'IndexedShortText0',
			'IndexedShortText1'
		];
		protected static const MAP_MONTH:Object = {
			'11':{min:9,max:11},
			'10':{min:9,max:11},
			'9':{min:9,max:11},
			'8':{min:6,max:8},
			'7':{min:6,max:8},
			'6':{min:6,max:8},
			'5':{min:3,max:5},
			'4':{min:3,max:5},
			'3':{min:3,max:5},
			'2':{min:0,max:2},
			'1':{min:0,max:2},
			'0':{min:0,max:2}		
		
		};
		public static const TOTAL_FIELD:Array=[	
			"CustomCurrency0",//Annualized Impact
			"CustomCurrency1",//Current FY Impact
			"CustomCurrency3",//Previous FY Impact
			"CustomCurrency4",//Next FY Impact
		];
		private static const MAP_CURVE_TYPE_VALUE:Object={
			//last item is default value
			'Straight Line':[0.0833333],
			'3 Month Curve':[0.025,0.05,0.075,0.0833333],
			'6 Month Curve':[0.02,0.03,0.04,0.05,0.06,0.07,0.0833333],
			'Up-front Purchase':[0.32,0.06,0.04,0.0833333]		
			
		};
		public static const ALL_FY_QUATER:Array = ["Q1","Q2","Q3","Q4","Q5","Q6","Q7","Q8"];
		public static const CURRENT_YEAR_QUATER:Array=["Q1","Q2","Q3","Q4"];
		public static const NEXT_YEAR_QUATER:Array=["Q5","Q6","Q7","Q8"];
		
		
		
		
		public function findImpactCalendar(opColumns:Array=null,co7Field:Array=null,opportId:String=null):ArrayCollection {
			if(opColumns==null||opColumns.length<1){
				opColumns = OP_IMP_CAL_FIELD;
			}
			if(co7Field==null||co7Field.length<1){
				co7Field = CO7_IMP_CAL_FIELD;
			}
			if(UserService.getCustomerId()==UserService.COLOPLAST){//should be work for coloplast only
				var cols:String = '';
				for each (var column:String in opColumns) {
					cols += ", o." + column;
				}
				for each (var co7f:String in co7Field) {
					cols += ", co." + co7f +" co7_"+co7f;
				}
				
				stmtFindAllWithCO7.text = "SELECT '" + entity + "' gadget_type " +cols +",o.gadget_id,co.gadget_id as co7_gadget_id,co.Id as co7_Id, u.CustomText30 as User_CustomText30 FROM " + tableName + "  o inner join allusers u on o.OwnerId= u.Id LEFT OUTER JOIN sod_customobject7  co ON o.OpportunityId = co.OpportunityId AND co.Type='Forecast'  WHERE  (o.deleted = 0 OR o.deleted IS null)AND (co.deleted = 0 OR co.deleted IS null) AND o.OpportunityType='Forecast'  "+(StringUtils.isEmpty(opportId)?"":"AND o.OpportunityId='"+opportId+"'") +" order by o.gadget_id desc";
				exec(stmtFindAllWithCO7);
				var result:SQLResult = stmtFindAllWithCO7.getResult();
				var data:Array = result.data;
				if (data != null && data.length>0) {
					return plate2Row(data,getCompititor(),getCallExpensesForCurrentQuater());
				}
			}
			return new ArrayCollection();
		}
		
		private static function getCurveTypevalue(curveType:String):Array{
			return MAP_CURVE_TYPE_VALUE[curveType];
		}
		
		public static function getCurrentFyImpact(item:Object,formatNum:Boolean=true):String{
			if(item.isTotal && (item.type==ACTUAL_TYPE||item.type==VARIANCE_TYPE)){
				return "";
			}
			var total:Number = 0;
			for each(var q:String in CURRENT_YEAR_QUATER){
				var qVal:Number = parseFloat(colValue(item,q,false));
				if(!isNaN(qVal)){
					total+=qVal;
				}
				
			}				
			if(formatNum){
				return NumberLocaleUtils.format(total);
			}else{
				return total.toFixed(4);
			}
		}
		
		public static function colValue(data:Object,colName:String,formatNum:Boolean=true):String{			
			
			var obj:Object =data[colName];
			if(colName.indexOf('.')!=-1){
				var fields:Array = colName.split('.');
				var q:Object = data[fields[0]];
				if(q!=null){
					obj = parseFloat(q[fields[1]]);
					if(isNaN(Number(obj))){
						obj="";
					}
				}
			}
			
			if(obj!=null){
				if(obj is String  || obj is Boolean){					
					return obj.toString();
				}else if( obj is Number){
					if(!formatNum){
						return Number(obj).toFixed(4);
					}
					return NumberLocaleUtils.format(obj);
				}else{
					//it is quater
					if(colName.indexOf("Q")==0){
						var total:Number =0;
						for each(var f:String in OpportunityDAO.MONTH_FIELD_FOR_EACH_Q){
							try{
								if(obj[f] is Number){
									total +=Number(obj[f]);
								}else if(obj[f] is String){
									if(!StringUtils.isEmpty(obj[f])){
										var qVal:Number =parseFloat(obj[f]);
										if(!isNaN(qVal)){
											total +=qVal;
										}
									}
								}
								
							}catch(e:Error){
								trace(e.getStackTrace());
								//nothing to to
							}
						}
						if(!formatNum){
							return Number(total).toFixed(4);
						}else{
							return NumberLocaleUtils.format(total);
						}
						
					}
				}
				
				
			}
			
			return null;
			
		}
		
		
		public static function getAnnualizedInpact(item:Object,formatNum:Boolean = true):String{
			
			if(!StringUtils.isEmpty(String(item.co7_CustomNumber0)) &&!StringUtils.isEmpty(String(item.co7_CustomCurrency4))){
				var qty:int = parseInt(item.co7_CustomNumber0);
				var val:Number = parseFloat(item.co7_CustomCurrency4);
				var total:Number = qty*val;
				//set annualized impact value;
				if(!isNaN(total)){						
					if(formatNum){
						return NumberLocaleUtils.format(total);
					}else{
						return total.toFixed(4);
					}
				}
			}
			return "0";
			
		}
		
		private static function getCurrentYearOfImpCal(currentYear:Date = null):Date{
			if(currentYear==null){
				currentYear = new Date();
			}
			if(currentYear.month>=9){//
				//#11402 Oct - Sep ( so it goes over 2 calendar years)
				currentYear = Utils.calculateDate(1,currentYear,"fullYear");
			}
			return currentYear;
		}
		
		private static function calImpCalMonthByYear(row:Object,quters:Array,currentYear:Date):void{
			var curveVal:Array = getCurveTypevalue(row['CustomPickList7'])
			var minDate:Date=DateUtils.guessAndParse(row.CustomDate26);
			var maxDate:Date = DateUtils.guessAndParse(row.CustomDate25);
			var currentMonth:Date = new Date(currentYear.fullYear-1,9,1,0,0,0,0)
			var clearQuater:Boolean = true;
			if(curveVal!=null && minDate!=null && maxDate!=null){
				var currentMonthIdx:int = 0;
				//CustomCurrency0 is annulized
				var annulizedInpact:Number = parseFloat(getAnnualizedInpact(row,false));
				if(!isNaN(annulizedInpact)){	
					clearQuater = false;
					for each(var qstr:String in quters){
						var q:Object=row[qstr];
						if(q==null){
							q = new Object();
							row[qstr]=q;
						}
						for each(var f:String in OpportunityDAO.MONTH_FIELD_FOR_EACH_Q){								
							var cal:Boolean = false;								
							if(currentMonth.fullYear==maxDate.fullYear){
								if(currentMonth.fullYear==minDate.fullYear){
									cal=currentMonth.month>=minDate.month && currentMonth.month<=maxDate.month;
								}else{
									cal=currentMonth.month<=maxDate.month;
								}
								
							}else if(currentMonth.fullYear<maxDate.fullYear){
								if(currentMonth.fullYear>minDate.fullYear){
									cal = true;
								}else if(currentMonth.fullYear==minDate.fullYear){
									cal=currentMonth.month>=minDate.month;
								}
							}
							if(cal){									
								var monthVal:Number = 0;
								if(currentMonthIdx>=curveVal.length){
									monthVal= annulizedInpact*curveVal[curveVal.length-1];
								}else{
									monthVal= annulizedInpact*curveVal[currentMonthIdx];
								}
								currentMonthIdx++;
								q[f]= monthVal; 
							}else{
								q[f]="0";
							}
							currentMonth=Utils.calculateDate(1,currentMonth,"month");
						}
					}
				}
			}
			
			if(clearQuater){
				for each(var qs:String in quters){
					var qo:Object=row[qs];
					if(qo!=null){
						for each(var m:String in OpportunityDAO.MONTH_FIELD_FOR_EACH_Q){
							qo[m]="0";
						}
					}
				}
			}
			
		}
		
		
		//"CustomDate26",//Stard Date
		//"CustomDate25",//end date
		public static function calImpactCalMonth(row:Object):void{
			//CustomPickList7 is curve_type 
			var curveVal:Array = getCurveTypevalue(row['CustomPickList7']);
			var currentYear:Date =getCurrentYearOfImpCal();
			//calculate current year
			calImpCalMonthByYear(row,CURRENT_YEAR_QUATER,currentYear);
			//calculate next year
			calImpCalMonthByYear(row,NEXT_YEAR_QUATER,Utils.calculateDate(1,currentYear,'fullYear'));
		
		}
		
		
		
		
		
		
	
		
		public function getCompititor(filter:String=null):Dictionary{
			var map:Dictionary = new Dictionary();
			var result:ArrayCollection = Database.opportunityCompetitorDao.findAll(new ArrayCollection([{element_name:'OpportunityId,CompetitorName,RelationshipRole,ReverseRelationshipRole'}]),filter,null,0);
			if(result!=null){
				for each(var obj:Object in result){
					var existobj:Object = map[obj.OpportunityId];
					if(existobj==null){
						existobj = new Object();
						map[obj.OpportunityId]=existobj;
					}
					//opportunity has only one compititor
					if(obj.RelationshipRole=='Membership Group' || obj.ReverseRelationshipRole=='Membership Group'){
						existobj.membershipgroup = obj;
					}
					
					if(obj.RelationshipRole=='Distributor' || obj.ReverseRelationshipRole=='Distributor'){
						existobj.distributor=obj;
					}				
					
				}

			}
			
			
			return map;
		}
		
		
		
		public function getCallExpensesForCurrentQuater(filter:String=null):Dictionary{
			var today:Date = new Date();
			
			//quater cannot null
			var q:Object = MAP_MONTH[today.month.toString()];
			var minDate:Date = new Date(today.fullYear,q.min,1);//min date of the mon
			var maxDate:Date = new Date(today.fullYear,q.max+1,0);//get max date of the month
			
			var paramStartDate:String = DateUtils.format(minDate,DateUtils.DATABASE_DATE_FORMAT);
			var paramEndDate:String = DateUtils.format(maxDate,DateUtils.DATABASE_DATE_FORMAT);
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = this.sqlConnection;
			var dateFilter:String = "(CompletedDatetime >= '" + paramStartDate + "T00:00:00Z'" +
				" AND CompletedDatetime<= '" + paramEndDate + "T23:59:59Z')";
			stmt.text = "select AccountId,Type,count(accountid) NumCall, sum(CustomCurrency0) Expenses  from activity WHERE " + (StringUtils.isEmpty(filter) ? "" : filter + " AND ")+ "CallType='Account Call' and Status='Completed' AND Activity = 'Appointment' AND "+dateFilter+"  group by accountid";
			exec(stmt);
			var items:ArrayCollection = new ArrayCollection(stmt.getResult().data);
			var result:Dictionary = new Dictionary();
			for each(var obj:Object in items){
				result[obj.AccountId]=obj;	
			}
			return result;
			
		}
		
		private function setCompititor(row:Object,compititor:Object):void{
			if(compititor!=null){
				if(compititor.membershipgroup){
					row.Membership = compititor.membershipgroup.CompetitorName;
				}
				if(compititor.distributor){
					row.TradingPartner = compititor.distributor.CompetitorName;
				}
			}
		}
		
		private function setCallAndExpenses(row:Object,call:Object):void{
			if(call!=null){
				//"CustomText37",//Total Calls Current Quarter
				//"CustomCurrency2",//Expenses
				row.CustomText37= call.NumCall;
				row.CustomCurrency2 = call.Expenses;
			}else{
				//clear value
				row.CustomText37= '';
				row.CustomCurrency2 = '';
			}
		}
		
		protected function getCo7Value(obj:Object, f:String):String{
			return obj[CO7_PREFIX+f];
		}
		
		protected function plate2Row(result:Array,opid2Compititor:Dictionary,accId2Call:Dictionary):ArrayCollection{
			var dic:Dictionary = new Dictionary();
			var rows:ArrayCollection = new ArrayCollection();
			var opId2Row:Dictionary = new Dictionary();
			var opId2CategorySlected:Dictionary = new Dictionary();
			var group:int =-1;
			var currentDate:Date = getCurrentYearOfImpCal();
			//row idenfify is opportunityId and category
			for each(var obj:Object in result){
				var maxDate:Date = getCurrentYearOfImpCal(DateUtils.guessAndParse(obj.CustomDate25));
				if(currentDate.fullYear>maxDate.fullYear){//we show only opportunity which has end date > now
					continue;
				}
				if(!StringUtils.isEmpty(obj.co7_Id)){
					
					var rId:String = obj.OpportunityId+"_"+getCo7Value(obj,'CustomPickList31');
					var row:Object=dic[rId];
					if(row==null){
						
						row = new Object();
						
						
						var categorySelected:ArrayCollection = opId2CategorySlected[obj.OpportunityId];
						if(categorySelected==null){
							categorySelected=new ArrayCollection();
							opId2CategorySlected[obj.OpportunityId]=categorySelected;
						}
						row.categorySelected=categorySelected;
						dic[rId]=row;
						rows.addItem(row);
						if(!opId2Row.hasOwnProperty(obj.OpportunityId)){
							opId2Row[obj.OpportunityId]=obj.OpportunityId;
							row.editable=true;	
							group++;
							row.group=group;
							
						}else{
							row.group=group;
							row.editable=false;
						}
					}
					//CustomPickList33 it is quater
					var quater:String = getCo7Value(obj,'CustomPickList33');
					if(StringUtils.isEmpty(quater)){
						//it is product
						ArrayCollection(row.categorySelected).addItem(getCo7Value(obj,'CustomPickList31'));
						Utils.copyObject(row,obj);
						//store original from db
						row.origOP = Utils.copyModel(obj,false);
						row.origCo7 = row.origOP;
						setCompititor(row,opid2Compititor[obj.OpportunityId]);
						setCallAndExpenses(row,accId2Call[obj.AccountId]);
					}else{
						//it is quater
						obj.origCo7 = Utils.copyModel(obj,false);
						row[quater]=obj;
					}
					
					
				}else{
					//opportunity no co7
					obj.isNoCo7=true;
					setCompititor(obj,opid2Compititor[obj.OpportunityId]);
					setCallAndExpenses(obj,accId2Call[obj.AccountId]);
					group++;
					obj.group=group;
					
					//store original from db
					obj.origOP = Utils.copyModel(obj,false);
					obj.categorySelected = new ArrayCollection();
					rows.addItem(obj);
				}
			}
			
			
			
			
			return rows;
		}
		private static const CO7_PRODUCT_FIELD:Array =[
			"CustomPickList31",//Category
			"CustomPickList34",//unit
			"CustomNumber0",//Quantity
			"CustomCurrency4",//value
			"CustomCurrency5",//Current FY Impact
			"CustomCurrency7",//Change vs last FY 
			"CustomCurrency8",//Next FY Impact
			"CustomCurrency9"//Annualized Impact 
		];
		
		
		private function initOpTotal(rows:ArrayCollection):void{
			//"CustomCurrency0",//Annualized Impact
			//"CustomCurrency1",//Current FY Impact
			//"CustomCurrency3",//Previous FY Impact
			//"CustomCurrency4",//Next FY Impact
			for each(var r:Object in rows){
				if(r.isTotal) continue;
				r.CustomCurrency0 = getAnnualizedInpact(r,false);
				r.CustomCurrency1 =  getCurrentFyImpact(r,false);
				r.CustomCurrency3 = r[OpportunityDAO.CO7_PREFIX+'CustomCurrency6'];
				r.CustomCurrency4 = getNextFyImpact(r,false);
				//save for co7
				r[OpportunityDAO.CO7_PREFIX+"CustomCurrency9"] = r.CustomCurrency0;
				r[OpportunityDAO.CO7_PREFIX+"CustomCurrency8"] = r.CustomCurrency4;
				r[OpportunityDAO.CO7_PREFIX+"CustomCurrency5"] = r.CustomCurrency1;
				r[OpportunityDAO.CO7_PREFIX+"CustomCurrency7"] = getChangeVsLastFY(r,false);
				
				
			}
		}
		
		public static function getChangeVsLastFY(item:Object,formatNum:Boolean=true):String{
			if(item.isTotal && (item.type==ACTUAL_TYPE||item.type==VARIANCE_TYPE)){
				return "";
			}
			var total:Number =parseFloat(getCurrentFyImpact(item,false));
			var prefNumStr:Number = 0;
			if(item["co7_CustomCurrency6"]!=null){
				prefNumStr = parseFloat(StringUtil.trim(item["co7_CustomCurrency6"]));
			}
			if(isNaN(total)){
				total =0;
			}
			
			if(!isNaN(prefNumStr)){
				total = total-prefNumStr;
			}
		
			if(formatNum){
				return NumberLocaleUtils.format(total);
			}else{
				return total.toFixed(4);
			}
		}
		
		public static function getNextFyImpact(item:Object,formatNum:Boolean=true):String{
			if(item.isTotal && (item.type==ACTUAL_TYPE||item.type==VARIANCE_TYPE)){
				return "";
			}
			var total:Number = 0;
			for each(var q:String in OpportunityDAO.NEXT_YEAR_QUATER){
				var qVal:Number = parseFloat(colValue(item,q,false));
				if(!isNaN(qVal)){
					total+=qVal;
				}
				
			}				
			if(formatNum){
				return NumberLocaleUtils.format(total);
			}else{
				return total.toFixed(4);
			}
		}
		
		private function saveCo7(fields:Array,obj:Object,quater:String=null,op:Object=null):void{
			var objSav:Object = new Object();
			for each (var f:String in fields){
				var tem_f:String = CO7_PREFIX+f;
				//save category,unit,quantity and value to each quater
				if(CO7_PRODUCT_FIELD.indexOf(f)!=-1 && op!=null){
					objSav[f]=op[tem_f];
				}else{
					objSav[f]=obj[tem_f];
				}
				
				if(op!=null &&(objSav[f]==null||objSav[f]=='')){
					objSav[f]=op[tem_f];
				}
			}
			objSav['gadget_id']=obj['co7_gadget_id'];
			if(op!=null){
				objSav.OpportunityId=op.OpportunityId;
				objSav.OpportunityName=op.OpportunityName;
				objSav.AccountName=op.AccountName;
				objSav.AccountId = op.AccountId;
				objSav.OpportunityAccountName=op.AccountName;
				//curve type should be alway get from real product
				objSav.CustomPickList31 = op[CO7_PREFIX+'CustomPickList31'];
			}else{
				objSav.OpportunityId=obj.OpportunityId;
				objSav.OpportunityName=obj.OpportunityName;
				objSav.AccountName=obj.AccountName;
				objSav.AccountId = obj.AccountId;
				objSav.OpportunityAccountName=obj.AccountName;
			}
			
			//CustomPickList33 it is quater
			objSav.CustomPickList33=quater;
			objSav.Type = 'Forecast';
			if(!StringUtils.isEmpty(quater)){
				var currentyear:Date = getCurrentYearOfImpCal();
				if(CURRENT_YEAR_QUATER.indexOf(quater)!=-1){
					//current year
					objSav[CO7_CURRENT_YEAR_FIELD] = currentyear.fullYear;
				}else{
					//next year
					objSav[CO7_CURRENT_YEAR_FIELD] =currentyear.fullYear+1;
				}
				var total:Number =0;
				//save total of the quater
				for each(var m:String in MONTH_FIELD_FOR_EACH_Q){
					var strNum:String = obj[m];
					if(!StringUtils.isEmpty(strNum)){
						total+=parseFloat(strNum);
					}
				}
				objSav.CustomCurrency3=total;
			}
			delete objSav['co7_gadget_id'];
			
			//name is category_quater
			var name:String = objSav.CustomPickList31;
			
			if(StringUtils.isEmpty(objSav.CustomPickList31)){				
				return;//no category cannot save
			}
			//CustomPickList33 is quater picklist
			if(!StringUtils.isEmpty(objSav.CustomPickList33)){
				name = name+'_'+objSav.CustomPickList33;
			}			
			
			objSav.Name = name;
			
			if(StringUtils.isEmpty(objSav['gadget_id'])){
				
				//set owner 
				var dao:BaseDAO = Database.customObject7Dao;
				for each(var objf:Object in dao.getOwnerFields()){						
					objSav[objf.entityField] = Database.allUsersDao.ownerUser()[objf.userField];
				}
				Database.customObject7Dao.insert(objSav);
				var item:Object=Database.customObject7Dao.selectLastRecord()[0];
				item[DAOUtils.getOracleId(Database.customObject7Dao.entity)]="#"+item.gadget_id;
				Database.customObject7Dao.updateByField([DAOUtils.getOracleId(Database.customObject7Dao.entity)],item);
				obj.co7_gadget_id = item.gadget_id;
				obj.co7_Id= "#"+item.gadget_id;
				
			}else{
				//if(isChange(obj.origCo7,objSav,fields,true)){					
					objSav.local_update = new Date().getTime();
					objSav.ms_local_change = new Date().getTime();
					Database.customObject7Dao.updateByField(fields,objSav,'gadget_id',true);
				//}
			}
			obj.origCo7= Utils.copyModel(obj,false);
		}
		
		
	
		
		//calculate total 
		protected function calculateOpportunityTotal(data:ArrayCollection):Dictionary{
			var totaldic:Dictionary = new Dictionary();
			for each(var row:Object in data){
				if(row.isTotal) continue;
				var totalObj:Object = totaldic[row.OpportunityId];
				if(totalObj==null){
					totalObj = new Object();
					//init value
					for each(var ft:String in TOTAL_FIELD){
						totalObj[ft]=0;
					}
					totaldic[row.OpportunityId]=totalObj;
				}
				for each(var f:String in TOTAL_FIELD){
					var val:Object = row[f];
					if(val!=null){
						if(val is Number){
							totalObj[f]+=Number(val);
						}else{
							var n:Number = parseFloat(val.toString());
							if(!isNaN(n)){
								totalObj[f]+=n;
							}
						}
					}
				}
			}
			return totaldic;
		}
		//check co7 mandatoryfield

		private function isMandatory(r:Object,mustCheckMan:Boolean=false):Boolean{
			
			for each (var type:String in ENTITY_CHECKS){
				if(!r.opChange && type==Database.opportunityDao.entity && !mustCheckMan){
					continue;
				}
				if(!r.co7Change && type==Database.customObject7Dao.entity&& !mustCheckMan){
					continue;
				}
				var fields:Array = OpportunityDAO.MANDATORY_FIELD[type];
				var isco7:Boolean = type==Database.customObject7Dao.entity;
				for each(var mf:String in fields){
					var datafield:String = mf;
					if(isco7){
						datafield = OpportunityDAO.CO7_PREFIX+mf;
					}
					if(StringUtils.isEmpty(r[datafield])){
						
						return true;
						
						
					}
				}
				
			}
			
			return false;
		}
		
		public function triggerUpdateImpCal():void{
			//user only for coloplast
			if(UserService.getCustomerId()==UserService.COLOPLAST && Database.preferencesDao.isEnableImpactCalendar()){
				var results:ArrayCollection =findImpactCalendar();
				var currentYear:Date = getCurrentYearOfImpCal();
				var listChange:ArrayCollection = new ArrayCollection();
				var listUpdateTotal:ArrayCollection = new ArrayCollection();
				for each(var row:Object in results){
					if(isMandatory(row)){
						continue;//is mandatory mean that row no product
					}
					if(getCurrentYearFromRow(row)<currentYear.fullYear && currentYear.fullYear<=getNextYearForRow(row)){
						//start calculate new year
						for( var i:int=0;i<CURRENT_YEAR_QUATER.length;i++){
							var cq:Object = row[CURRENT_YEAR_QUATER[i]];
							var nq:Object = row[NEXT_YEAR_QUATER[i]];
							if(nq!=null){
								nq.CustomPickList33=CURRENT_YEAR_QUATER[i];
								row[CURRENT_YEAR_QUATER[i]]=nq;							
								
							}
							
							if(cq!=null){
								//clear next year quator
								for each(var m:String in OpportunityDAO.MONTH_FIELD_FOR_EACH_Q){
									cq[m]="0.00";	
								}
								cq.CustomPickList33=NEXT_YEAR_QUATER[i];
								row[NEXT_YEAR_QUATER[i]]=cq;
							}
							
							
						}					
						calImpCalMonthByYear(row,NEXT_YEAR_QUATER,Utils.calculateDate(1,currentYear,'fullYear'));
						if(isRecal(row)){
							calImpactCalMonth(row);
						}
						row.co7Change=true;
						
						listChange.addItem(row);
					}else{
						
						if(isRecal(row)){
							//mark row as change
							row.co7Change=true;
							calImpactCalMonth(row);
							listChange.addItem(row);
						}
						
					
					}
					listUpdateTotal.addItem(row);
				}
				if(listChange.length>0){
					saveImpactCalendar(listChange,OP_IMP_CAL_FIELD,CO7_IMP_CAL_FIELD,results);
				}
				//bug#12095
				checkOpportunityTotal(listUpdateTotal);
				
			}
		}
		private function isRecal(row:Object):Boolean{
			
			if(row.isNoCo7){
				return false;
			}
			//check if has invalid data
			var cloneRow:Object = Utils.cloneObject(row);
			//clear all quater
			for each(var cq:String in ALL_FY_QUATER){
				cloneRow[cq]=null;
			}
			calImpactCalMonth(cloneRow);			
			for each(var q:String in ALL_FY_QUATER){
				var cQ:Object = cloneRow[q]==null?{}:cloneRow[q];
				var rQ:Object = row[q]==null?{}:row[q];							
				for each(var month:String in OpportunityDAO.MONTH_FIELD_FOR_EACH_Q){
					var cmV:Number = parseFloat(cQ[month]);
					var rmV:Number = parseFloat(rQ[month]);
					if(isNaN(cmV) && !isNaN(rmV)){
						return true;
					}
					if(cmV==0 && (rmV!=0 && !isNaN(rmV))){
						return true;
					}
					if(rmV==0 &&(cmV!=0 && !isNaN(cmV))){
						return true;
					}			
				}				
			}
			
			return false;
		}
			
				
				
				
		
		
		
		private function getCurrentYearFromRow(r:Object):int{
			if(r["Q1"]!=null){
				var y:String = getCo7Value(r["Q1"],CO7_CURRENT_YEAR_FIELD);
				if(!StringUtils.isEmpty(y)){
					var yn:int = parseInt(y);
					if(!isNaN(yn)){
						return yn;
					}
				}else{
					return 0;
				}
			}
			return 999;
			
		}
		
		private function getNextYearForRow(r:Object):Number{
			if(r["Q4"]!=null){
				var y:String =getCo7Value(r["Q4"],CO7_CURRENT_YEAR_FIELD);
				if(!StringUtils.isEmpty(y)){
					var yn:int = parseInt(y);
					if(!isNaN(yn)){
						return yn;
					}
				}
				
				
				var maxDate:Date = DateUtils.guessAndParse(r.CustomDate25);		
				if(maxDate!=null){
					return maxDate.fullYear;
				}
			}
			
			
			
			return -1;
		}
		/**
		 * 
		 * OppId cannot null
		 */ 
		public function checkOpportunityTotalByOppId(oppId:String):void{
			var results:ArrayCollection =findImpactCalendar(null,null,oppId);
			var listUpdateTotal:ArrayCollection = new ArrayCollection();
			for each(var row:Object in results){
				if(isMandatory(row)){
					continue;//is mandatory mean that row no product
				}
				listUpdateTotal.addItem(row);
			}
			checkOpportunityTotal(listUpdateTotal);
		}
		private function checkOpportunityTotal(oppRows:ArrayCollection):void{
			initOpTotal(oppRows);
			var totalDic:Dictionary = calculateOpportunityTotal(oppRows);
			var oppSaved:Dictionary = new Dictionary();		
			try{
				Database.begin();
				for each(var row:Object in oppRows){
					if(row.isTotal){
						continue;//total not save
					}
					//update opportunity--no need to check
					if(!oppSaved.hasOwnProperty(row.OpportunityId)){
						var totalObj:Object = totalDic[row.OpportunityId];
						oppSaved[row.OpportunityId]=row.OpportunityId;
						if(totalObj!=null){
							var isSave:Boolean = false;
							var oldOpp:Object = findByOracleId(row.OpportunityId);
							if(oldOpp!=null){
								for(var tf:String in totalObj){
									var total:Number =totalObj[tf];
									var oldTotal:Number = parseFloat(oldOpp[tf]);
									if( isNaN(oldTotal)){
										oldTotal = 0;//because total no null
									}
									//may old data store only .2
									if(oldTotal!=total&& oldTotal.toFixed(2)!=total.toFixed(2)){										
										isSave = true;
										break;
									}
								}
								if(isSave){
									for(var f:String in totalObj){
										var totalVal:Number =totalObj[f];
										row[f] = totalVal.toFixed(4);
									}
									super.updateByField(OP_IMP_CAL_FIELD,row,'gadget_id',true);
								}
							}
						}	
					}
				}
				Database.commit();
				
			}catch(e:Error){
				Database.rollback();
				OOPS(e.getStackTrace());
			}
		}
		
		public function updateOpportunityTotal(oppRows:ArrayCollection):void{
			initOpTotal(oppRows);
			var totalDic:Dictionary = calculateOpportunityTotal(oppRows);
			var oppSaved:Dictionary = new Dictionary();			
			try{
				for each(var row:Object in oppRows){
					if(row.isTotal){
						continue;//total not save
					}
					//update opportunity--no need to check
					if(!oppSaved.hasOwnProperty(row.OpportunityId)){
						var totalObj:Object = totalDic[row.OpportunityId];
						oppSaved[row.OpportunityId]=row.OpportunityId;
						if(totalObj!=null){
							for(var tf:String in totalObj){
								var total:Number =totalObj[tf];
								row[tf] = total.toFixed(4);
							}
						}	
						super.updateByField(OP_IMP_CAL_FIELD,row,'gadget_id',true);
						row.origOP=Utils.copyModel(row,false);
						
					}
					
				}
				
			}catch(e:SQLError){
				
				OOPS(e.getStackTrace());
			}
		}
		
		public function saveImpactCalendar(recordChanges:ArrayCollection,opField:Array,co7Fields:Array,allRows:ArrayCollection):void{
			initOpTotal(allRows);
			var totalDic:Dictionary = calculateOpportunityTotal(allRows);
			var oppSaved:Dictionary = new Dictionary();
			Database.begin();
			try{
				for each(var row:Object in recordChanges){
					if(row.isTotal){
						continue;//total not save
					}
					//update opportunity--no need to check
					if(!oppSaved.hasOwnProperty(row.OpportunityId)){
						var totalObj:Object = totalDic[row.OpportunityId];
						oppSaved[row.OpportunityId]=row.OpportunityId;
						if(totalObj!=null){
							for(var tf:String in totalObj){
								var total:Number =totalObj[tf];
								row[tf] = total.toFixed(4);
							}
						}	
						super.updateByField(opField,row,'gadget_id',true);
						row.origOP=Utils.copyModel(row,false);
						
					}
					//save product usage
					if(row.co7Change){
						saveCo7(co7Fields,row);		
					}
					
					for each(var f:String in ALL_FY_QUATER){
						var qObj:Object = row[f];
						//if(f!='categorySelected' && f!='origCo7' && f!='origOP'){
							if(qObj!=null && (qObj.co7Change||row.co7Change)){
								
								//save quater
								saveCo7(co7Fields,qObj,f,row);
								
							}
						//}
					}
				}
				Database.commit();
			}catch(e:SQLError){
				
				Database.rollback();
			}
			
			
		}
		
		
		
		override public function getOwnerFields():Array{
			var mapfields:Array = [
				{entityField:"OwnerFullName", userField:"FullName"},{entityField:"Owner", userField:"Alias"},{entityField:"OwnerId", userField:"Id"}
			];
			return mapfields;
			
		}
	}
	
}