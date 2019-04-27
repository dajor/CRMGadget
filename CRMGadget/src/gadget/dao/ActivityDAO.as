package gadget.dao
{
	import flash.data.SQLCollationType;
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.util.Relation;
	
	import mx.collections.ArrayCollection;

	public class ActivityDAO extends BaseDAO {
		
		private var stmtFindRelated:SQLStatement;
		private var stmtGetAppointment:SQLStatement;
		private var stmtGetAppointmentAccount:SQLStatement;
		private var stmtFindUpdated:SQLStatement;
		private var stmtFindCreated:SQLStatement;
		private var stmtFindDeleted:SQLStatement;
		private var stmtFind:SQLStatement;
		private var stmtFindUpcoming:SQLStatement;
		private var stmtFindByStatus:SQLStatement;
		private var stmtFindDelegate:SQLStatement;
		private var stmtFindSurvey:SQLStatement;
		private var stmtFindByParentSurveyId:SQLStatement;
		private var stmtFindByParentSurveyIdAndPage:SQLStatement ;
		private var stmtUpdateParentActivityId:SQLStatement;
		private var stmtVisitCustomer:SQLStatement;
		private var stmtDelTempSubTaskSurveyByParentId:SQLStatement;
		
		public static var PARENTSURVEYID:String = "ParentActivityId"; //Store parentId of survey
		
		public static var ASS_PAGE_NAME:String = "assessment_page";
		
		public function ActivityDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'activity',
				oracle_id: 'ActivityId',
				name_column: [ 'Subject' ],
				order_by : 'DueDate',
				search_columns: [ 'Subject' ],
				display_name : "activities",
				index: [ "ActivityId"
					, "OpportunityId", "PrimaryContactId", "ServiceRequestId", "CampaignId", "AccountId"
					, "CustomObject1Id", "CustomObject2Id", "CustomObject3Id"
					, "CustomObject4Id", "CustomObject5Id", "CustomObject6Id", "CustomObject7Id"
					, "CustomObject8Id", "CustomObject9Id", "CustomObject10Id", "CustomObject11Id"
					, "CustomObject12Id", "CustomObject13Id", "CustomObject14Id", "CustomObject15Id"
// DO NOT ENABLE UNTIL CALLBACK WORKS!	, "StartTime, EndTime", "EndTime"
				],
				ws10ignore: [ "CustomObject14Id" ],
				columns: { 'TEXT' : textColumns }
			});
			
			stmtUpdateParentActivityId = new SQLStatement();
			stmtUpdateParentActivityId.sqlConnection = sqlConnection;
			stmtUpdateParentActivityId.text = "UPDATE " + tableName + " SET parentActivityId = :newParentActivityId WHERE parentActivityId = :oldParentActivityId";
			
			// Find Survey Tasks by AccountId
			stmtFindByParentSurveyId = new SQLStatement();
			stmtFindByParentSurveyId.sqlConnection = sqlConnection;
			stmtFindByParentSurveyId.text = "SELECT '" + entity + "' gadget_type, * FROM Activity WHERE Type LIKE :type And ParentActivityId=:ParentActivityId AND (deleted = 0 OR deleted IS null) ORDER BY gadget_id";	

			
			stmtFindByParentSurveyIdAndPage = new SQLStatement();
			stmtFindByParentSurveyIdAndPage.sqlConnection = sqlConnection;
			stmtFindByParentSurveyIdAndPage.text = "SELECT '" + entity + "' gadget_type, * FROM Activity WHERE Type LIKE :type And ParentActivityId=:ParentActivityId And Subject=:Subject AND (deleted = 0 OR deleted IS null) ORDER BY gadget_id";
			
			// Find Survey Tasks by AccountId
			stmtFindSurvey = new SQLStatement();
			stmtFindSurvey.sqlConnection = sqlConnection;
			stmtFindSurvey.text = "SELECT '" + entity + "' gadget_type, * FROM Activity WHERE Type LIKE '"+ Survey.ACTIVITY_TYPE +"' And AccountId=:accountId AND (deleted = 0 OR deleted IS null) ORDER BY DueDate";	

			
			// Find all items updated locally
			stmtFindUpdated = new SQLStatement();
			stmtFindUpdated.sqlConnection = sqlConnection;
			stmtFindUpdated.text = "SELECT '" + entity + "' gadget_type, *, " + DAOUtils.getNameColumn(entity) + " name FROM Activity WHERE local_update is not null AND (deleted = 0 OR deleted IS null) AND (GUID IS NOT null AND GUID != '') ORDER BY local_update LIMIT :limit OFFSET :offset";	
			
			// Find all items created locally
			stmtFindCreated = new SQLStatement();
			stmtFindCreated.sqlConnection = sqlConnection;
			stmtFindCreated.text = "SELECT '" + entity + "' gadget_type, *, " + DAOUtils.getNameColumn(entity) + " name FROM Activity WHERE ( (ActivityId >= '#' AND ActivityId <= '#zzzz') OR  ActivityId  IS NULL ) AND (deleted = 0 OR deleted IS null) AND (GUID IS NOT null AND GUID != '') ORDER BY  ActivityId LIMIT :limit OFFSET :offset";	

			// Find all deleted google event
			stmtFindDeleted = new SQLStatement();
			stmtFindDeleted.sqlConnection = sqlConnection;
			stmtFindDeleted.text = "SELECT ActivityId, gadget_id, Subject name, GUID, GDATA FROM Activity WHERE deleted = true  AND (GUID IS NOT null AND GUID != '') ORDER BY uppername LIMIT :limit OFFSET :offset";
			
			// Find by Oracle CRM Id
			stmtFindRelated = new SQLStatement();
			stmtFindRelated.sqlConnection = sqlConnection;
			
			// Get Current Appointment For Daily Agenda
			stmtGetAppointment = new SQLStatement();
			stmtGetAppointment.sqlConnection = sqlConnection;
			stmtGetAppointment.text = "SELECT * FROM Activity WHERE (StartTime >= :startTime and StartTime <= :endTime and act.Activity = :activity) AND (deleted = 0 OR deleted IS null) " + 
				" ORDER BY StartTime";
			//Get all activities by Today,ThisWeek,ThisMonth and Overdue 
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT '" + entity + "' gadget_type,local_update, gadget_id, error,sync_number,Activity,Subject," +
				"Owner,DelegatedById,DelegatedBy,DueDate,Subject,Status,important FROM Activity WHERE (deleted = 0 OR deleted IS null) AND ((Status !=:status or Status is null or Status = '') and OwnerId=:ownerId and DueDate >= :startTime and DueDate < :endTime and Activity='Task') " + 
				" ORDER BY Priority,DueDate Limit:limit";
			//Get activity by status 
			stmtFindByStatus = new SQLStatement();
			stmtFindByStatus.sqlConnection = sqlConnection;
			//stmtFindByStatus.text = "SELECT '" + entity + "' gadget_type,* FROM Activity WHERE (Status =:status and OwnerId=:ownerId and activity='Task')  limit 20";
			stmtFindByStatus.text = "SELECT '" + entity + "' gadget_type,local_update, gadget_id, error,sync_number,Activity,Subject," +
				"Owner,DelegatedById,DelegatedBy,DueDate,Subject,Status,important" +
				" FROM Activity WHERE (Status =:status and OwnerId=:ownerId and activity='Task') AND (deleted = 0 OR deleted IS null)  limit 20";
			
			stmtFindUpcoming = new SQLStatement();
			stmtFindUpcoming.sqlConnection = sqlConnection;
			stmtFindUpcoming.text = "Select '" + entity + "' gadget_type,* from Activity Where (DueDate>=:startTime and DueDate< :endTime and OwnerId=:ownerId) AND (deleted = 0 OR deleted IS null)" + 
				" ORDER BY Priority,DueDate Limit:limit";
			
			stmtFindDelegate = new SQLStatement();
			stmtFindDelegate.sqlConnection = sqlConnection;
			stmtFindDelegate.text = "Select '" + entity + "' gadget_type,local_update, gadget_id, error,sync_number,Activity,Subject," +
				"Owner,DelegatedById,DelegatedBy,DueDate,Subject,Status,important" + " from Activity Where ( DelegatedById =:ownerId and Activity='Task') AND (deleted = 0 OR deleted IS null)" + 
				" ORDER BY DueDate DESC Limit 20";		
			
			stmtGetAppointmentAccount = new SQLStatement();
			stmtGetAppointmentAccount.sqlConnection = sqlConnection;
			stmtGetAppointmentAccount.text = "SELECT '" + entity + "' gadget_type,CallType,Activity,Subject,StartTime,EndTime,PrimaryContactId,AccountId,gadget_id,ActivityId,important,favorite FROM Activity act" +
					" WHERE (act.StartTime >= :startTime and act.StartTime <= :endTime and act.Activity = :activity) AND (deleted = 0 OR deleted IS null)  AND ( OwnerId=:ownerId OR ActivityId IN (SELECT ActivityId from  activity_user WHERE UserId=:ownerId)) ORDER BY act.StartTime";

			stmtVisitCustomer = new SQLStatement();
			stmtVisitCustomer.sqlConnection = sqlConnection;
			
			stmtDelTempSubTaskSurveyByParentId = new SQLStatement();
			stmtDelTempSubTaskSurveyByParentId.text = "UPDATE " + tableName + " SET deleted = true WHERE ParentActivityId = :ParentActivityId";
			stmtDelTempSubTaskSurveyByParentId.sqlConnection = sqlConnection;
		}
/*
		override protected function get sortColumn():String {
			return "subject";
		}
*/		
		override public function get entity():String {
			return "Activity";
		}
		
		public function updadteParentSurveyId(newParentActivityId:String,oldParentActivityId:String):void{
			stmtUpdateParentActivityId.parameters[":newParentActivityId"] = newParentActivityId;
			stmtUpdateParentActivityId.parameters[":oldParentActivityId"] = oldParentActivityId;
			exec(stmtUpdateParentActivityId);
			
		}
		public function findSurveyByParentSurveyId(appId:String,typ:String):ArrayCollection{
			stmtFindByParentSurveyId.parameters[":ParentActivityId"] = appId;
			stmtFindByParentSurveyId.parameters[":type"] = typ;
			exec(stmtFindByParentSurveyId, false);
			return  new ArrayCollection(stmtFindByParentSurveyId.getResult().data);
		}
		public function findSurveyByParentSurveyIdAndPage(appId:String,pagename:String,typ:String):ArrayCollection{
			stmtFindByParentSurveyIdAndPage.parameters[":ParentActivityId"] = appId;
			stmtFindByParentSurveyIdAndPage.parameters[":Subject"]=pagename;
			stmtFindByParentSurveyIdAndPage.parameters[":type"] = typ;
			exec(stmtFindByParentSurveyIdAndPage, false);
			return  new ArrayCollection(stmtFindByParentSurveyIdAndPage.getResult().data);
		}
		
		// for visit customer
		public function getAppointmentAccountList(query:String):ArrayCollection {
			stmtVisitCustomer.text = "SELECT '" + entity + "' gadget_type,act.*, a.PrimaryBillToStreetAddress, a.PrimaryBillToPostalCode, a.PrimaryBillToCity," +
				" a.PrimaryShipToStreetAddress, a.PrimaryShipToPostalCode, a.PrimaryShipToCity, a.MainPhone" +
				" FROM Activity act LEFT OUTER JOIN Account a ON act.accountId = a.accountID" +
				" WHERE act.Status !='Completed' And act.Activity='Appointment' And " + query + "   ORDER BY act.StartTime DESC";
			exec(stmtVisitCustomer);
			return new ArrayCollection((stmtVisitCustomer.getResult() as SQLResult).data);
		}
		public function findSurveyTaskByAccId(accId:String):ArrayCollection {
			stmtFindSurvey.parameters[":accountId"] = accId; 
			exec(stmtFindSurvey, false);
			return  new ArrayCollection(stmtFindSurvey.getResult().data);
		}	
		
		
		public function findGoogleDeleted(offset:int, limit:int):ArrayCollection {
			stmtFindDeleted.parameters[":offset"] = offset; 
			stmtFindDeleted.parameters[":limit"] = limit; 
			exec(stmtFindDeleted, false);
			return new ArrayCollection(stmtFindDeleted.getResult().data);
		}
		
		public function findGoogleCreated(offset:int, limit:int):ArrayCollection {
			stmtFindCreated.parameters[":offset"] = offset; 
			stmtFindCreated.parameters[":limit"] = limit; 
			exec(stmtFindCreated, false);
			var list:ArrayCollection = new ArrayCollection(stmtFindCreated.getResult().data);
			checkBindPicklist(stmtFindCreated.text,list);
			return list;
		}
		
		public function findGoogleUpdated(offset:int, limit:int):ArrayCollection {
			stmtFindUpdated.parameters[":offset"] = offset; 
			stmtFindUpdated.parameters[":limit"] = limit; 
			exec(stmtFindUpdated, false);
			var list:ArrayCollection = new ArrayCollection(stmtFindUpdated.getResult().data);
			checkBindPicklist(stmtFindUpdated.text,list);
			return list;
		}		
		
		/**
		 * 
		 * Get All Appointments to Display in Daily Agenda
		 * 
		 * @param objectTime
		 * 		startTime    : "YYYY-MM-DDTJJ:NN:SSZ"
		 * 		endTime      : "YYYY-MM-DDTJJ:NN:SSZ"
		 * @return 
		 * 
		 */
		public function getCurrentAppointmentList(objectTime:Object):ArrayCollection{
			stmtGetAppointment.parameters[":startTime"] = objectTime.StartTime;
			stmtGetAppointment.parameters[":endTime"] = objectTime.EndTime;
			stmtGetAppointment.parameters[":activity"] = "Appointment";
			exec(stmtGetAppointment);
			return new ArrayCollection((stmtGetAppointment.getResult() as SQLResult).data);
		}
		
		
		public function getCurrentAppointmentAccountList(objectTime:Object):ArrayCollection {
			stmtGetAppointmentAccount.parameters[":startTime"] = objectTime.StartTime;
			stmtGetAppointmentAccount.parameters[":endTime"] = objectTime.EndTime;
			stmtGetAppointmentAccount.parameters[":activity"] = "Appointment";
			stmtGetAppointmentAccount.parameters[":ownerId"] = objectTime.OwnerId;
			exec(stmtGetAppointmentAccount);
			return new ArrayCollection((stmtGetAppointmentAccount.getResult() as SQLResult).data);
		}	
		
		/**
		 * 
		 * Get All Appointments to Display in Home Task
		 * 
		 * @param objectTime
		 * 		startTime    : "YYYY-MM-DDTJJ:NN:SSZ"
		 * 		endTime      : "YYYY-MM-DDTJJ:NN:SSZ"
		 * @return 
		 * 
		 */
		public function getActivityByStartEndTime(objectTime:Object):ArrayCollection{
			
			stmtFind.parameters[":startTime"] = objectTime.StartTime;
			stmtFind.parameters[":endTime"] = objectTime.EndTime;
			stmtFind.parameters[":ownerId"] = objectTime.OwnerId;
			stmtFind.parameters[":status"] = objectTime.Status;
			stmtFind.parameters[":limit"] = objectTime.Limit;
		
			exec(stmtFind);
			return new ArrayCollection((stmtFind.getResult() as SQLResult).data);
		}
		public function getDelegate(objectTime:Object):ArrayCollection{
			stmtFindDelegate.parameters[":ownerId"] = objectTime.OwnerId;
		
			exec(stmtFindDelegate);
			return new ArrayCollection((stmtFindDelegate.getResult() as SQLResult).data);
		}
		public function getUpcomingActivity(objectTime:Object):ArrayCollection{
		
			stmtFindUpcoming.parameters[":startTime"] = objectTime.StartTime;
			stmtFindUpcoming.parameters[":endTime"] = objectTime.EndTime;
			stmtFindUpcoming.parameters[":ownerId"] = objectTime.OwnerId;
			stmtFindUpcoming.parameters[":limit"] = objectTime.limit;
			exec(stmtFindUpcoming);
			return new ArrayCollection((stmtFindUpcoming.getResult() as SQLResult).data);
		}
		public function getActivityByStatus(objectTime:Object):ArrayCollection{
			stmtFindByStatus.parameters[":ownerId"] = objectTime.OwnerId;
			stmtFindByStatus.parameters[":status"] = objectTime.Status;
			exec(stmtFindByStatus);
			return new ArrayCollection((stmtFindByStatus.getResult() as SQLResult).data);
		}
		
		public function findRelatedActivities(srcEntity:String, oracleId:String):ArrayCollection {
			var relation:Object = Relation.getRelation("Activity", srcEntity);
			if (relation == null) {
				return new ArrayCollection();
			}			
			var arr:ArrayCollection;
			stmtFindRelated.text = "SELECT gadget_id, 'Activity' as gadget_type, Subject, DueDate, Priority, Status, Alias FROM activity WHERE " + relation.keySrc + " = '" + oracleId + "'";
			exec(stmtFindRelated);
			var result:SQLResult = stmtFindRelated.getResult();
			if (result.data == null || result.data.length == 0) {
				return new ArrayCollection();
			}
			return new ArrayCollection(result.data);
		}
		
		override public function getOwnerFields():Array{
			var mapfields:Array = [
				{entityField:"AssignedTo", userField:"FullName"},{entityField:"Alias", userField:"Alias"},{entityField:"Owner", userField:"Alias"},{entityField:"OwnerId", userField:"Id"}
			];
			return mapfields;
			
		}
		
		public function deleteTempSubTaskSuryveyByParent(parentId:String):void{
			stmtDelTempSubTaskSurveyByParentId.parameters[":ParentActivityId"]=parentId;
			exec(stmtDelTempSubTaskSurveyByParentId);
		}

		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return INGNORE_FIELDS;
		}
		
		
		override protected function getIncomingIgnoreFields():ArrayCollection{
			return INCOMING_INGNORE_FIELDS;
		}
		private static const INCOMING_INGNORE_FIELDS:ArrayCollection=new ArrayCollection(
			[
				"ms_id",
				"ms_change_key",
				"IsPrivateEvent",
				"GUID",
				"GDATA",
				//"Owner",
				"ms_local_change"
			]);
		private static const INGNORE_FIELDS:ArrayCollection=new ArrayCollection(
				["AccountExternalSystemId"
				,"AccountIntegrationId"
				,"AccountLocation","AccountName"
				,"CampaignExternalSystemId"
				,"CampaignIntegrationId"
				,"CampaignName"
				,"CustomObject1ExternalSystemId"
				,"CustomObject1IntegrationId"
				,"CustomObject2ExternalSystemId"
				,"CustomObject2IntegrationId"
				,"CustomObject3ExternalSystemId"
				,"CustomObject3IntegrationId"
				,"OpportunityExternalSystemId"
				,"OpportunityIntegrationId"
				,"OpportunityName"
				,"OwnerExternalSystemId"
				,"PrimaryContactExternalSystemId"
				,"PrimaryContact"
				,"PrimaryContactFirstName"
				,"PrimaryContactIntegrationId"
				,"PrimaryContactLastName"
				,"SPRequestExternalSystemId"
				,"SPRequestIntegrationId"
				,"SPRequestSPRequestName"
				,"ServiceRequestExternalSystemId"
				,"ServiceRequestIntegrationId"
				,"ServiceRequestNumber"
				,"Address"
				,"Owner"
				,"OpportunityName",
				"Lead",
				"LeadExternalSystemId",
				"LeadFirstName",				
				"LeadIntegrationId",
				"LeadLastName",
				"IsPrivateEvent",
				"GUID",
				"GDATA",
				"ms_id",
				"ms_change_key",
				"ms_local_change",
				"ModifiedByExt",
				"CreatedByExt",
				"SmartCall"
				]);
			
			
		
		// This are the WS1.0 names.
		// WS2.0 extended fields must be added to
		// gadget.util.SodUtils.fieldsToFix
		// as well!
		private const textColumns:Array = [
			"CustomObject10ExternalSystemId",
			"CustomObject10Id",
			"CustomObject10IntegrationId",
			"CustomObject10Name",
			"CustomObject11ExternalSystemId",
			"CustomObject11Id",
			"CustomObject11IntegrationId",
			"CustomObject11Name",
			"CustomObject12ExternalSystemId",
			"CustomObject12Id",
			"CustomObject12IntegrationId",
			"CustomObject12Name",
			"CustomObject13ExternalSystemId",
			"CustomObject13Id",
			"CustomObject13IntegrationId",
			"CustomObject13Name",
			"CustomObject14ExternalSystemId",
			"CustomObject14Id",
			"CustomObject14IntegrationId",
			"CustomObject14Name",
			"CustomObject15ExternalSystemId",
			"CustomObject15Id",
			"CustomObject15IntegrationId",
			"CustomObject15Name",
			"CustomObject4ExternalSystemId",
			"CustomObject4Id",
			"CustomObject4IntegrationId",
			"CustomObject4Name",
			"CustomObject5ExternalSystemId",
			"CustomObject5Id",
			"CustomObject5IntegrationId",
			"CustomObject5Name",
			"CustomObject6ExternalSystemId",
			"CustomObject6Id",
			"CustomObject6IntegrationId",
			"CustomObject6Name",
			"CustomObject7ExternalSystemId",
			"CustomObject7Id",
			"CustomObject7IntegrationId",
			"CustomObject7Name",
			"CustomObject8ExternalSystemId",
			"CustomObject8Id",
			"CustomObject8IntegrationId",
			"CustomObject8Name",
			"CustomObject9ExternalSystemId",
			"CustomObject9Id",
			"CustomObject9IntegrationId",
			"CustomObject9Name",

			// Original columns
			"AccountExternalSystemId",
			"AccountId",
			"AccountIntegrationId",
			"AccountLocation",
			"AccountName",
			"Activity",
			"ActivityId",
			"ActivitySubType",
			"AddressId",
			"Alias",
			"ApplicationApplicationUID",
			"ApplicationCompanyLocation",
			"ApplicationCompanyName",
			"ApplicationExternalSystemId",
			"ApplicationIndexedShortText2",
			"ApprovalStatus",
			"AssignedQueue",
			"CallType",
			"CampaignExternalSystemId",
			"CampaignId",
			"CampaignIntegrationId",
			"CampaignName",
			"Cost",
			"CreatedBy",
			"CreatedById",
			"CreatedDate",
			"CreatedbyEmailAddress",
			"CurrencyCode",
			"CustomBoolean0",
			"CustomBoolean1",
			"CustomBoolean10",
			"CustomBoolean11",
			"CustomBoolean12",
			"CustomBoolean13",
			"CustomBoolean14",
			"CustomBoolean15",
			"CustomBoolean16",
			"CustomBoolean17",
			"CustomBoolean18",
			"CustomBoolean19",
			"CustomBoolean2",
			"CustomBoolean20",
			"CustomBoolean21",
			"CustomBoolean22",
			"CustomBoolean23",
			"CustomBoolean24",
			"CustomBoolean25",
			"CustomBoolean26",
			"CustomBoolean27",
			"CustomBoolean28",
			"CustomBoolean29",
			"CustomBoolean3",
			"CustomBoolean30",
			"CustomBoolean31",
			"CustomBoolean32",
			"CustomBoolean33",
			"CustomBoolean34",
			"CustomBoolean4",
			"CustomBoolean5",
			"CustomBoolean6",
			"CustomBoolean7",
			"CustomBoolean8",
			"CustomBoolean9",
			"CustomCurrency0",
			"CustomCurrency1",
			"CustomCurrency10",
			"CustomCurrency11",
			"CustomCurrency12",
			"CustomCurrency13",
			"CustomCurrency14",
			"CustomCurrency15",
			"CustomCurrency16",
			"CustomCurrency17",
			"CustomCurrency18",
			"CustomCurrency19",
			"CustomCurrency2",
			"CustomCurrency20",
			"CustomCurrency21",
			"CustomCurrency22",
			"CustomCurrency23",
			"CustomCurrency24",
			"CustomCurrency3",
			"CustomCurrency4",
			"CustomCurrency5",
			"CustomCurrency6",
			"CustomCurrency7",
			"CustomCurrency8",
			"CustomCurrency9",
			"CustomDate0",
			"CustomDate1",
			"CustomDate10",
			"CustomDate11",
			"CustomDate12",
			"CustomDate13",
			"CustomDate14",
			"CustomDate15",
			"CustomDate16",
			"CustomDate17",
			"CustomDate18",
			"CustomDate19",
			"CustomDate2",
			"CustomDate20",
			"CustomDate21",
			"CustomDate22",
			"CustomDate23",
			"CustomDate24",
			"CustomDate25",
			"CustomDate26",
			"CustomDate27",
			"CustomDate28",
			"CustomDate29",
			"CustomDate3",
			"CustomDate30",
			"CustomDate31",
			"CustomDate32",
			"CustomDate33",
			"CustomDate34",
			"CustomDate35",
			"CustomDate36",
			"CustomDate37",
			"CustomDate38",
			"CustomDate39",
			"CustomDate4",
			"CustomDate40",
			"CustomDate41",
			"CustomDate42",
			"CustomDate43",
			"CustomDate44",
			"CustomDate45",
			"CustomDate46",
			"CustomDate47",
			"CustomDate48",
			"CustomDate49",
			"CustomDate5",
			"CustomDate50",
			"CustomDate51",
			"CustomDate52",
			"CustomDate53",
			"CustomDate54",
			"CustomDate55",
			"CustomDate56",
			"CustomDate57",
			"CustomDate58",
			"CustomDate59",
			"CustomDate6",
			"CustomDate7",
			"CustomDate8",
			"CustomDate9",
			"CustomInteger0",
			"CustomInteger1",
			"CustomInteger10",
			"CustomInteger11",
			"CustomInteger12",
			"CustomInteger13",
			"CustomInteger14",
			"CustomInteger15",
			"CustomInteger16",
			"CustomInteger17",
			"CustomInteger18",
			"CustomInteger19",
			"CustomInteger2",
			"CustomInteger20",
			"CustomInteger21",
			"CustomInteger22",
			"CustomInteger23",
			"CustomInteger24",
			"CustomInteger25",
			"CustomInteger26",
			"CustomInteger27",
			"CustomInteger28",
			"CustomInteger29",
			"CustomInteger3",
			"CustomInteger30",
			"CustomInteger31",
			"CustomInteger32",
			"CustomInteger33",
			"CustomInteger34",
			"CustomInteger4",
			"CustomInteger5",
			"CustomInteger6",
			"CustomInteger7",
			"CustomInteger8",
			"CustomInteger9",
			"CustomMultiSelectPickList0",
			"CustomMultiSelectPickList1",
			"CustomMultiSelectPickList2",
			"CustomMultiSelectPickList3",
			"CustomMultiSelectPickList4",
			"CustomMultiSelectPickList5",
			"CustomMultiSelectPickList6",
			"CustomMultiSelectPickList7",
			"CustomMultiSelectPickList8",
			"CustomMultiSelectPickList9",
			"CustomNumber0",
			"CustomNumber1",
			"CustomNumber10",
			"CustomNumber11",
			"CustomNumber12",
			"CustomNumber13",
			"CustomNumber14",
			"CustomNumber15",
			"CustomNumber16",
			"CustomNumber17",
			"CustomNumber18",
			"CustomNumber19",
			"CustomNumber2",
			"CustomNumber20",
			"CustomNumber21",
			"CustomNumber22",
			"CustomNumber23",
			"CustomNumber24",
			"CustomNumber25",
			"CustomNumber26",
			"CustomNumber27",
			"CustomNumber28",
			"CustomNumber29",
			"CustomNumber3",
			"CustomNumber30",
			"CustomNumber31",
			"CustomNumber32",
			"CustomNumber33",
			"CustomNumber34",
			"CustomNumber35",
			"CustomNumber36",
			"CustomNumber37",
			"CustomNumber38",
			"CustomNumber39",
			"CustomNumber4",
			"CustomNumber40",
			"CustomNumber41",
			"CustomNumber42",
			"CustomNumber43",
			"CustomNumber44",
			"CustomNumber45",
			"CustomNumber46",
			"CustomNumber47",
			"CustomNumber48",
			"CustomNumber49",
			"CustomNumber5",
			"CustomNumber50",
			"CustomNumber51",
			"CustomNumber52",
			"CustomNumber53",
			"CustomNumber54",
			"CustomNumber55",
			"CustomNumber56",
			"CustomNumber57",
			"CustomNumber58",
			"CustomNumber59",
			"CustomNumber6",
			"CustomNumber60",
			"CustomNumber61",
			"CustomNumber62",
			"CustomNumber7",
			"CustomNumber8",
			"CustomNumber9",
			"CustomObject1ExternalSystemId",
			"CustomObject1Id",
			"CustomObject1IntegrationId",
			"CustomObject1Name",
			"CustomObject2ExternalSystemId",
			"CustomObject2Id",
			"CustomObject2IntegrationId",
			"CustomObject2Name",
			"CustomObject3ExternalSystemId",
			"CustomObject3Id",
			"CustomObject3IntegrationId",
			"CustomObject3Name",
			"CustomPhone0",
			"CustomPhone1",
			"CustomPhone10",
			"CustomPhone11",
			"CustomPhone12",
			"CustomPhone13",
			"CustomPhone14",
			"CustomPhone15",
			"CustomPhone16",
			"CustomPhone17",
			"CustomPhone18",
			"CustomPhone19",
			"CustomPhone2",
			"CustomPhone3",
			"CustomPhone4",
			"CustomPhone5",
			"CustomPhone6",
			"CustomPhone7",
			"CustomPhone8",
			"CustomPhone9",
			"CustomPickList0",
			"CustomPickList1",
			"CustomPickList10",
			"CustomPickList11",
			"CustomPickList12",
			"CustomPickList13",
			"CustomPickList14",
			"CustomPickList15",
			"CustomPickList16",
			"CustomPickList17",
			"CustomPickList18",
			"CustomPickList19",
			"CustomPickList2",
			"CustomPickList20",
			"CustomPickList21",
			"CustomPickList22",
			"CustomPickList23",
			"CustomPickList24",
			"CustomPickList25",
			"CustomPickList26",
			"CustomPickList27",
			"CustomPickList28",
			"CustomPickList29",
			"CustomPickList3",
			"CustomPickList30",
			"CustomPickList31",
			"CustomPickList32",
			"CustomPickList33",
			"CustomPickList34",
			"CustomPickList35",
			"CustomPickList36",
			"CustomPickList37",
			"CustomPickList38",
			"CustomPickList39",
			"CustomPickList4",
			"CustomPickList40",
			"CustomPickList41",
			"CustomPickList42",
			"CustomPickList43",
			"CustomPickList44",
			"CustomPickList45",
			"CustomPickList46",
			"CustomPickList47",
			"CustomPickList48",
			"CustomPickList49",
			"CustomPickList5",
			"CustomPickList50",
			"CustomPickList51",
			"CustomPickList52",
			"CustomPickList53",
			"CustomPickList54",
			"CustomPickList55",
			"CustomPickList56",
			"CustomPickList57",
			"CustomPickList58",
			"CustomPickList59",
			"CustomPickList6",
			"CustomPickList60",
			"CustomPickList61",
			"CustomPickList62",
			"CustomPickList63",
			"CustomPickList64",
			"CustomPickList65",
			"CustomPickList66",
			"CustomPickList67",
			"CustomPickList68",
			"CustomPickList69",
			"CustomPickList7",
			"CustomPickList70",
			"CustomPickList71",
			"CustomPickList72",
			"CustomPickList73",
			"CustomPickList74",
			"CustomPickList75",
			"CustomPickList76",
			"CustomPickList77",
			"CustomPickList78",
			"CustomPickList79",
			"CustomPickList8",
			"CustomPickList80",
			"CustomPickList81",
			"CustomPickList82",
			"CustomPickList83",
			"CustomPickList84",
			"CustomPickList85",
			"CustomPickList86",
			"CustomPickList87",
			"CustomPickList88",
			"CustomPickList89",
			"CustomPickList9",
			"CustomPickList90",
			"CustomPickList91",
			"CustomPickList92",
			"CustomPickList93",
			"CustomPickList94",
			"CustomPickList95",
			"CustomPickList96",
			"CustomPickList97",
			"CustomPickList98",
			"CustomPickList99",
			"CustomText0",
			"CustomText1",
			"CustomText10",
			"CustomText11",
			"CustomText12",
			"CustomText13",
			"CustomText14",
			"CustomText15",
			"CustomText16",
			"CustomText17",
			"CustomText18",
			"CustomText19",
			"CustomText2",
			"CustomText20",
			"CustomText21",
			"CustomText22",
			"CustomText23",
			"CustomText24",
			"CustomText25",
			"CustomText26",
			"CustomText27",
			"CustomText28",
			"CustomText29",
			"CustomText3",
			"CustomText30",
			"CustomText31",
			"CustomText32",
			"CustomText33",
			"CustomText34",
			"CustomText35",
			"CustomText36",
			"CustomText37",
			"CustomText38",
			"CustomText39",
			"CustomText4",
			"CustomText40",
			"CustomText41",
			"CustomText42",
			"CustomText43",
			"CustomText44",
			"CustomText45",
			"CustomText46",
			"CustomText47",
			"CustomText48",
			"CustomText49",
			"CustomText5",
			"CustomText50",
			"CustomText51",
			"CustomText52",
			"CustomText53",
			"CustomText54",
			"CustomText55",
			"CustomText56",
			"CustomText57",
			"CustomText58",
			"CustomText59",
			"CustomText6",
			"CustomText60",
			"CustomText61",
			"CustomText62",
			"CustomText63",
			"CustomText64",
			"CustomText65",
			"CustomText66",
			"CustomText67",
			"CustomText68",
			"CustomText69",
			"CustomText7",
			"CustomText70",
			"CustomText71",
			"CustomText72",
			"CustomText73",
			"CustomText74",
			"CustomText75",
			"CustomText76",
			"CustomText77",
			"CustomText78",
			"CustomText79",
			"CustomText8",
			"CustomText80",
			"CustomText81",
			"CustomText82",
			"CustomText83",
			"CustomText84",
			"CustomText85",
			"CustomText86",
			"CustomText87",
			"CustomText88",
			"CustomText89",
			"CustomText9",
			"CustomText90",
			"CustomText91",
			"CustomText92",
			"CustomText93",
			"CustomText94",
			"CustomText95",
			"CustomText96",
			"CustomText97",
			"CustomText98",
			"CustomText99",
			"Date",
			"DealRegistrationDealRegistrationName",
			"DealRegistrationExternalSystemId",
			"DealerExternalSystemId",
			"DealerId",
			"DealerName",
			"DelegatedBy",
			"DelegatedByExternalSystemId",
			"DelegatedById",
			"Description",
			"Destination",
			"DisbursTransCount",	// In WSDL1.0, whatever this is
			"DueDate",
			"Duration",
			"EndTime",
			"ExternalSystemId",
			"FundName",
			"FundRequest",
			"FundRequestExternalSystemId",
			"FundRequestId",
			"HandleTime",
			"IVRStartTime",
			"IVRTime",
			"IndexedBoolean0",
			"IndexedCurrency0",
			"IndexedDate0",
			"IndexedLongText0",
			"IndexedNumber0",
			"IndexedPick0",
			"IndexedPick1",
			"IndexedPick2",
			"IndexedPick3",
			"IndexedPick4",
			"IndexedPick5",
			"IndexedShortText0",
			"IndexedShortText1",
			"IntegrationId",
			"InteractionId",
			"InteractionTime",
			"Lead",
			"LeadExternalSystemId",
			"LeadFirstName",
			"LeadId",
			"LeadIntegrationId",
			"LeadLastName",
			"BusinessPlanId",
			"BusinessPlanPlanName",
			"BusinessPlanType",
			"BusinessPlanStatus",
			"BusinessPlanDescription",
			"BusinessPlanExternalSystemId",
			/*
			"ListOfAttachment",
			"ListOfBook",
			"ListOfContact",
			"ListOfProductsDetailed",
			"ListOfPromotionalItems",
			"ListOfSampleDropped",
			"ListOfSolution",
			"ListOfUser",
			*/
			"Location",
			"MDFRequestExternalSystemId",
			"MDFRequestIntegrationId",
			"MDFRequestRequestName",
			"MedEdEventExternalSystemId",
			"MedEdEventId",
			"MedEdEventIntegrationId",
			"MedEdEventName",
			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"ModifiedbyEmailAddress",
			"NextCall",
			"Objective",
			"OpportunityExternalSystemId",
			"OpportunityId",
			"OpportunityIntegrationId",
			"OpportunityName",
			"Origin",
			"Owner",
			"OwnerExternalSystemId",
			"OwnerId",
			"PaperSign",
			"PortfolioExternalSystemId",
			"PortfolioId",
			"PortfolioNumber",
			"PrimaryContact",
			"PrimaryContactExternalSystemId",
			"PrimaryContactFirstName",
			"PrimaryContactId",
			"PrimaryContactIntegrationId",
			"PrimaryContactLastName",
			"Priority",
			"Private",
			"ProductDetailedCount",
			"PromotionalItemDroppedCount",
			"QueueHoldTime",
			"QueueStartTime",
			"RefNum",
			"RejectReason",
			"ResolutionCode",
			"SPRequestExternalSystemId",
			"SPRequestIntegrationId",
			"SPRequestSPRequestName",
			"SampleDroppedCount",
			"ServiceRequestExternalSystemId",
			"ServiceRequestId",
			"ServiceRequestIntegrationId",
			"ServiceRequestNumber",
			"SmartCall",
			"StartTime",
			"Status",
			"SubType",
			"Subject",
			"TotalHoldTime",
			"Type",			
			"WrapUpBeginTime",
			"WrapUpEndTime",
			"WrapUpTime",
			"Address",
			"AssignedTo",
			"ModifiedByExt",
			"CreatedByExt",
			PARENTSURVEYID,
			ASS_PAGE_NAME,
			"CompletedDatetime"
		];
	}
}