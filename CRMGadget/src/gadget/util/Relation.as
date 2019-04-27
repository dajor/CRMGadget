package gadget.util
{
	import gadget.dao.DAOUtils;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import org.as3commons.logging.util.clone;
	
	public class Relation
	{
		// This array describes relation between entities and is used for :
		// 1) Row ID updates via the ReferenceUpdater class
		// 2) ItemFinder initialization in entity details, when the user clicks on a field that is a relation between two entites.
		//    ItemFinder updates the detail with both ID and label, so we need both information in the table.
		// 3) Link lists and link creation between objects.
		//
		// entitySrc : source entity
		// keySrc : name of the field that is a reference to another entity.
		// keyDest : name of the rowId field of the referenced entity. (it would better to remove this field and replace it with DAOUtils.getOracleId()) 
		// labelSrc : label/name of the referenced entity in the source object.
		// labelDest : label/name of the referenced entity.
		// entityDest : referenced entity.
		// supportTable (optional) : support table that handles m-n relationship between entities.
		//
		public static const RELATIONS:ArrayCollection = new ArrayCollection([
			{entitySrc:"Contact", keySrc:"ContactId", keySupport:"UserId", keyDest:"Id", labelSrc:["ContactId"], labelSupport:["UserLastName","UserFirstName","UserRole","ContactAccess"],isColDynamic:true, labelDest:["LastName","FirstName"], entityDest:"User", supportTable:"Contact.Team"},
			{entitySrc:"Contact", keySrc:"ReferredById", keyDest:"ContactId", labelSrc:["ReferredByFullName","ReferredByFirstName","ReferredByLastName"], labelDest:["ContactFullName","ContactFirstName", "ContactLastName"], entityDest:"Contact"},
			{entitySrc:"Contact", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName", "PrimaryCity", "PrimaryCountry", "PrimaryAddress", "AccountLocation", "PrimaryZipCode",'PrimaryProvince','PrimaryStateProvince','PrimaryCounty','PrimaryStreetAddress3','PrimaryStreetAddress2'], labelDest:["AccountName", "PrimaryBillToCity", "PrimaryBillToCountry", "PrimaryBillToStreetAddress", "Location", "PrimaryBillToPostalCode",'PrimaryBillToProvince','PrimaryBillToState','PrimaryBillToCounty','PrimaryBillToStreetAddress3','PrimaryBillToStreetAddress2'], entityDest:"Account"},
			{entitySrc:"Contact", keySrc:"ManagerId", keyDest:"ContactId", labelSrc:["Manager"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Contact", keySrc:"SourceCampaignId", keyDest:"CampaignId", labelSrc:["SourceCampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Contact", keySrc:"ContactId", keySupport:"ContactId", keyDest:"Id", labelSrc:["ContactFullName"], labelSupport:["RelatedContactFullName","ReverseRelationshipRole","Description","RelationshipStatus","StartDate","EndDate"],isColDynamic:true, labelDest:["RelatedContactFirstName","RelatedContactLastName"], entityDest:"Relationships", supportTable:"Contact.Related"},
			{entitySrc:"Contact", keyDest:"PrimaryContactId", keySrc:"ContactId", labelDest:["PrimaryContact", "PrimaryContactFirstName", "PrimaryContactLastName"], keepOutLabelSrc : true,isExceptLabelSrc:true,labelSrc:["ContactFullName", "ContactFirstName", "ContactLastName"], entityDest:"Activity"},
			{entitySrc:"Contact", keySrc:"ContactId", keyDest:"KeyContactId",isExceptLabelSrc:true, labelSrc:["ContactLastName"], labelDest:["KeyContactLastName"], entityDest:"Opportunity"},
			{entitySrc:"Contact", keySrc:"TerritoryId", keyDest:"Id", labelSrc:["Territory"], labelDest:["TerritoryName"], entityDest:"Territory"},
			{entitySrc:"Contact", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"Contact", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"Contact", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Contact", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Contact", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Contact", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Contact", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Contact", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Contact", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Contact", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Contact", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Contact", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Contact", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Contact", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Contact", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			{entitySrc:"Opportunity.ContactRole",  keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactLastName","ContactFirstName"], labelDest:["ContactLastName","ContactFirstName"], entityDest:"Contact"},
			{entitySrc:"Activity.Contact", keySrc:"Id", keyDest:"ContactId", labelSrc:["ContactLastName","ContactFirstName"], labelDest:["ContactLastName","ContactFirstName"], entityDest:"Contact"},
			{entitySrc:"Contact.Related", keySrc:"RelatedContactId", keyDest:"ContactId", labelSrc:["RelatedContactFullName","RelatedContactFirstName","RelatedContactLastName"], labelDest:["ContactFullName","ContactFirstName", "ContactLastName"], entityDest:"Contact"},
			{entitySrc:"Contact.Team", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactId"], labelDest:["ContactId"], entityDest:"Contact"},
			{entitySrc:"Contact.Note", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactId"], labelDest:["ContactId"], entityDest:"Contact"},
			{entitySrc:"Contact", keySrc:"ContactId", keySupport:"ContactId", keyDest:"Id", labelSrc:["ContactFullName"], labelSupport:["Subject","Private","CreatedByFullName","ModifiedDate"],isColDynamic:true, labelDest:["Subject"], entityDest:"Note", supportTable:"Contact.Note"},
			
			// contact_account
			{entitySrc:"Contact", keySrc:"ContactId", keySupport:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelSupport:["AccountName"], labelDest:["AccountName"], entityDest:"Account", supportTable:"Contact.Account"},
			{entitySrc:"Contact", keySrc:"ContactId", keyDest:"Id",keySupport:"Id", labelSrc:["ContactFullName"],labelSupport:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Custom Object 2", supportTable:"Contact.CustomObject2"},
			
			{entitySrc:"Campaign", keySrc:"CampaignId", keySupport:"CampaignId", keyDest:"Id", labelSrc:["CampaignName"], labelSupport:["Subject","Private","CreatedByFullName","ModifiedDate"],isColDynamic:true, labelDest:["Subject"], entityDest:"Note", supportTable:"Campaign.Note"},
			{entitySrc:"Campaign.Note", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignId"], labelDest:["CampaignId"], entityDest:"Campaign"},
			
			
			{entitySrc:"Account.Competitor", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["CompetitorName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Account.Competitor", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContactName"], labelDest:["ContactFullName"], entityDest:"Contact"},			
			
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"AccountId", keyDest:"RelatedAccountId", labelSrc:["AccountName"], labelSupport:["RelatedAccountName","ReverseRole","RelationshipStatus","StartTime","EndTime"],isColDynamic:true, labelDest:["AccountName"], entityDest:"Relationships", supportTable:"Account.Related"},
			{entitySrc:"Account.Related", keySrc:"RelatedAccountId", keyDest:"AccountId", labelSrc:["RelatedAccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Account.Partner", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["PartnerName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Account.Partner", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContactName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			
			{entitySrc:"Account.Team", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Account.Note", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountId"], labelDest:["AccountId"], entityDest:"Account"},
			//Account.Account,Account.Objective,Account.ServiceRequest,Account.Opportunity,Account.CustomObject2,
			//Account.CustomObject3,Account.CustomObject4,Account.CustomObject10,Account.Address,
			
			{entitySrc:"Address", keySrc:"ParentId", keyDest:"AccountId", labelSrc:["ParentId"], labelDest:["AccountId"], entityDest:"Account"},
			//			{entitySrc:"Account.Address", keySrc:"ParentId", keyDest:"AccountId", labelSrc:["ParentId"], labelDest:["AccountId"], entityDest:"Account"},
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"UserId", keyDest:"Id", labelSrc:["AccountName"],isExceptLabelSrc:true, labelSupport:["LastName","FirstName","RoleName","AccountAccess","ContactAccess","OpportunityAccess"],isColDynamic:true, labelDest:["LastName","FirstName"], entityDest:"User", supportTable:"Account.Team"},
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"Id", keyDest:"Id", labelSrc:["AccountName"],isExceptLabelSrc:true, labelSupport:["Subject","Private","CreatedByFullName","ModifiedDate"],isColDynamic:true, labelDest:["Subject"], entityDest:"Note", supportTable:"Account.Note"},
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"AccountId", keyDest:"Id", labelSrc:["CompetitorName"], labelSupport:["CompetitorName","PrimaryContactName","RelationshipRole"],isColDynamic:true, labelDest:["CompetitorName"], entityDest:"Competitor", supportTable:"Account.Competitor"},			
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"AccountId", keyDest:"Id", labelSrc:["PartnerName"], labelSupport:["PartnerName","PrimaryContactName","RelationshipRole"],isColDynamic:true, labelDest:["PartnerName"], entityDest:"Partner", supportTable:"Account.Partner"},
			{entitySrc:"Account", keySrc:"SourceCampaignId", keyDest:"CampaignId", labelSrc:["SourceCampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Account", keySrc:"AccountId", keyDest:"ParentAccountId", labelSrc:["AccountName"],isExceptLabelSrc:true,keepOutLabelSrc : true, labelDest:["ParentAccount"], entityDest:"Account"},
			{entitySrc:"Account", keySrc:"ParentAccountId", keyDest:"AccountId", labelSrc:["ParentAccount"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Account", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Account", keySrc:"PriceListId", keyDest:"Id", labelSrc:["PriceListPriceListName"], labelDest:["PriceListName"], entityDest:"PriceList"},
			{entitySrc:"Account", keySrc:"TerritoryId", keyDest:"Id", labelSrc:["Territory"], labelDest:["TerritoryName"], entityDest:"Territory"},
			{entitySrc:"Account", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"Account", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"Account", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Account", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Account", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Account", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Account", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Account", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Account", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Account", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Account", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Account", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Account", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Account", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Account", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			
			// account_contact
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"ContactId", keyDest:"ContactId", labelSrc:["PrimaryContactFullName"], labelSupport:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact", supportTable:"Contact.Account"},
			
//			{entitySrc:"Account", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Asset"},
			/* fix #2018
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"ContactId", keyDest:"ContactId", labelSrc:["AccountName"], labelSupport:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact", supportTable:"Contact.Account"},
			*/
			//{entitySrc:"Account", keySrc:"AccountId", keySupport:"Id", keyDest:"Id", labelSrc:["AccountName"], labelSupport:["Product","SerialNumber","Quantity","Type","Status","PurchaseDate","PurchasePrice","NotifyDate"],isColDynamic:true, labelDest:["Product"], entityDest:"Asset", supportTable:"Account.Asset"},
			{entitySrc:"Account", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Account", keySrc:"AccountId", keyDest:"AccountId", labelDest:["AccountName", "AccountLocation"],keepOutLabelSrc : true, labelSrc:["AccountName", "Location"],isExceptLabelSrc:true, entityDest:"Activity"},
			
			{entitySrc:"Opportunity.Competitor", keySrc:"CompetitorId", keyDest:"AccountId", labelSrc:["CompetitorName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Opportunity.Competitor", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"Opportunity", keySrc:"OpportunityId", keySupport:"OpportunityId", keyDest:"CompetitorId", labelSrc:["OpportunityName"], labelSupport:["CompetitorName","PrimaryContactName","RelationshipRole"],isColDynamic:true, labelDest:["OpportunityName"], entityDest:"Competitor", supportTable:"Opportunity.Competitor"},
			
			
			{entitySrc:"Opportunity", keySrc:"OpportunityId", keySupport:"ContactId", keyDest:"ContactId", labelSrc:["KeyContactLastName"], labelSupport:["ContactFirstName", "ContactLastName","BuyingRole"], labelDest:["ContactLastName"], entityDest:"Contact", isColDynamic:true, supportTable:"Opportunity.ContactRole"},
			{entitySrc:"Opportunity.ContactRole",  keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"Opportunity",  keySrc:"SourceCampaignId", keyDest:"CampaignId", labelSrc:["SourceCampaign"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Opportunity.Product", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Opportunity.Product", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","ProductCategory","ProductType","ProductStatus","ProductPartNumber"], labelDest:["Name","ProductCategory","ProductType","Status","PartNumber"], entityDest:"Product"},
			{entitySrc:"Opportunity.Partner", keySrc:"PartnerId", keyDest:"AccountId", labelSrc:["PartnerName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Opportunity.Partner", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContactName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Opportunity.Team", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityId"], labelDest:["OpportunityId"], entityDest:"Opportunity"},
			{entitySrc:"Opportunity.Note", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityId"], labelDest:["OpportunityId"], entityDest:"Opportunity"},
			{entitySrc:"Opportunity.Competitor", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContactName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			
			
			{entitySrc:"Opportunity", keySrc:"KeyContactId", keyDest:"ContactId", labelSrc:["KeyContactLastName"], labelDest:["ContactLastName"], entityDest:"Contact"},
			{entitySrc:"Opportunity", keySrc:"OpportunityId", keySupport:"OpportunityId", keyDest:"ProductId", labelSrc:["OpportunityName"], labelSupport:["ProductName","Quantity","PurchasePrice","Revenue","Frequency","NumberOfPeriods","Owner"],isColDynamic:true, labelDest:["Name"], entityDest:"Product", supportTable:"Opportunity.Product"},
			{entitySrc:"Opportunity", keySrc:"OpportunityId", keySupport:"OpportunityId", keyDest:"Id", labelSrc:["PartnerName"], labelSupport:["PartnerName","PrimaryContactName","RelationshipRole"],isColDynamic:true, labelDest:["PartnerName"], entityDest:"Partner", supportTable:"Opportunity.Partner"},
			{entitySrc:"Opportunity", keySrc:"OpportunityId", keySupport:"UserId", keyDest:"Id", labelSrc:["OpportunityId"], labelSupport:["UserLastName","UserFirstName","OpportunityAccess"],isColDynamic:true, labelDest:["LastName","FirstName"], entityDest:"User", supportTable:"Opportunity.Team"},
			{entitySrc:"Opportunity", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Opportunity", keySrc:"OpportunityId", keySupport:"Id", keyDest:"Id", labelSrc:["OpportunityId"], labelSupport:["Subject","Private","CreatedByFullName","ModifiedDate"],isColDynamic:true, labelDest:["Subject"], entityDest:"Note", supportTable:"Opportunity.Note"},
			{entitySrc:"Opportunity", keySrc:"TerritoryId", keyDest:"Id", labelSrc:["Territory"], labelDest:["TerritoryName"], entityDest:"Territory"},
			{entitySrc:"Opportunity", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"Opportunity", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"Opportunity", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Opportunity", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Opportunity", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Opportunity", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Opportunity", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Opportunity", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Opportunity", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Opportunity", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Opportunity", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Opportunity", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Opportunity", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Opportunity", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Opportunity", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"Opportunity", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Opportunity", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			
			
			
			{entitySrc:"Service Request", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Service Request", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName",'ContactFirstName','ContactLastName'], labelDest:["ContactFullName","ContactFirstName","ContactLastName"], entityDest:"Contact"},
			{entitySrc:"Service Request", keySrc:"ServiceRequestId", keySupport:"ServiceRequestId", keyDest:"Id", labelSrc:["ServiceRequestId"], labelSupport:["Subject","Private","CreatedByFullName","ModifiedDate"],isColDynamic:true, labelDest:["Subject"], entityDest:"Note", supportTable:"Service Request.Note"},
			{entitySrc:"Service Request.Note", keySrc:"ServiceRequestId",labelSrc:["ServiceRequestId"], keyDest:"ServiceRequestId",labelDest:["ServiceRequestId"],  entityDest:"Service Request"},
			{entitySrc:"Service Request", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["Product"], labelDest:["Name"], entityDest:"Product"},
			//{entitySrc:"Service Request", keySrc:"AssetId", keyDest:"Id", labelSrc:["AssetName"], labelDest:["ProductName"], entityDest:"Asset"},
			//{entitySrc:"Service Request", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Service Request", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"Service Request", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"Service Request", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Service Request", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Service Request", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Service Request", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Service Request", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Service Request", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Service Request", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Service Request", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Service Request", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Service Request", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Service Request", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Service Request", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Service Request", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			
			//{entitySrc:"Service Request", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			//{entitySrc:"Service Request", keySrc:"CustomObject2Id", keyDest:"CustomObject2Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			
			
			{entitySrc:"Activity.Contact", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["Subject"], labelDest:["Subject"], entityDest:"Activity"},		
			//{entitySrc:"Custom Object 1", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Activity.Product", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["Product","ProductCategory"], labelDest:["Name","ProductCategory"], entityDest:"Product"},
			{entitySrc:"Activity.Product", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityId"], labelDest:["ActivityId"], entityDest:"Activity"},
			{entitySrc:"Activity", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName", "AccountLocation"], labelDest:["AccountName", "Location"], entityDest:"Account"},
			{entitySrc:"Activity", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Activity", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"Activity", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContact", "PrimaryContactFirstName", "PrimaryContactLastName"], labelDest:["ContactFullName", "ContactFirstName", "ContactLastName"], entityDest:"Contact"},
			{entitySrc:"Activity", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"Activity", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["Lead"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"Activity", keySrc:"ActivityId", keySupport:"ProductId", keyDest:"ProductId", labelSrc:["Subject"], labelSupport:["Product"], labelDest:["Name"], entityDest:"Product", supportTable:"Activity.Product",isColDynamic:true},
			{entitySrc:"Activity", keySrc:"ActivityId", keySupport:"UserId", keyDest:"Id", labelSrc:["UserFirstName", "UserLastName"], labelSupport:["UserFirstName", "UserLastName"], labelDest:["FirstName", "LastName"]/*labelSrc:["Subject"], labelSupport:"UserAlias", labelDest:["Alias"]*/, entityDest:"User", supportTable:"Activity.User"}, // SC-20110616
			{entitySrc:"Activity", keySrc:"ActivityId", keySupport:"Id", keyDest:"ContactId", labelSrc:["PrimaryContactFirstName", "PrimaryContactLastName"], labelSupport:["ContactFirstName", "ContactLastName"], labelDest:["ContactFirstName", "ContactLastName"]/*labelSrc:["Subject"], labelSupport:"ContactFullName", labelDest:["ContactFullName"]*/, entityDest:"Contact", supportTable:"Activity.Contact"},
			{entitySrc:"Activity", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"Activity", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"Activity", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Activity", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Activity", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Activity", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Activity", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Activity", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Activity", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Activity", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Activity", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Activity", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Activity", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Activity", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Activity", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"Activity", keySrc:"ActivityId", keySupport:"ActivityId", keyDest:"ProductId", labelSrc:["Subject"], labelSupport:["CustomInteger1","CustomInteger2","Quantity","CustomInteger0","Product"],isColDynamic:true, labelDest:["Name"], entityDest:"Sample Dropped", supportTable:"Activity.SampleDropped"},
			{entitySrc:"Activity.SampleDropped", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["Product"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"Activity", keySrc:"BusinessPlanId", keyDest:"Id",labelSrc:["BusinessPlanPlanName","BusinessPlanType","BusinessPlanStatus","BusinessPlanDescription"],labelDest:["PlanName","Status","Type","Description"],entityDest:"BusinessPlan" },
			
			
			{entitySrc:"Lead", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["Campaign"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Lead", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName","AccountLocation","AccountFuriganaName"],labelDest:["AccountName","Location",'FuriganaName'],  entityDest:"Account"},
			{entitySrc:"Lead", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName","ContactFirstName","ContactFuriganaFirstName","ContactFuriganaLastName","ContactLastName"], labelDest:["ContactFullName","ContactFirstName","FuriganaFirstName", "FuriganaLastName", "ContactLastName" ], entityDest:"Contact"},
			{entitySrc:"Lead", keySrc:"ReferredById", keyDest:"ContactId", labelSrc:["ReferredByFullName","ReferredByFirstName","ReferredByLastName"], labelDest:["ContactFullName","ContactFirstName", "ContactLastName" ], entityDest:"Contact"},
			{entitySrc:"Lead", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"Lead", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"Lead", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Lead", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Lead", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Lead", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Lead", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Lead", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Lead", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Lead", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Lead", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Lead", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Lead", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Lead", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Lead", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"Custom Object 1", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Custom Object 1", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Custom Object 1", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"Custom Object 1", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["Opportunity"], entityDest:"Opportunity"},
			{entitySrc:"Custom Object 1", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"Custom Object 1", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"Custom Object 1", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Custom Object 1", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Custom Object 1", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			
			
			{entitySrc:"Custom Object 2", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Custom Object 2", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Custom Object 2", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"Custom Object 2", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"Custom Object 2", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"Custom Object 2", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"Custom Object 2", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Custom Object 2", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Custom Object 2", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			// contact_custom_object2
			{entitySrc:"Custom Object 2", keySrc:"Id", keyDest:"ContactId",keySupport:"ContactId", labelSrc:["ContactFullName"],labelSupport:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact", supportTable:"Contact.CustomObject2"},
			
			//{entitySrc:"Custom Object 2", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			
			//			{entitySrc:"Custom Object 3", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			//			{entitySrc:"Custom Object 3", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			//			{entitySrc:"Custom Object 3", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			//			{entitySrc:"Custom Object 3", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			//			{entitySrc:"Custom Object 3", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			//			{entitySrc:"Custom Object 3", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			//			
			//			
			//			{entitySrc:"CustomObject4", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			//			{entitySrc:"CustomObject4", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			//			{entitySrc:"CustomObject4", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			//			{entitySrc:"CustomObject4", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			//			{entitySrc:"CustomObject4", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			
			{entitySrc:"Custom Object 3", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Custom Object 3", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Custom Object 3", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"Custom Object 3", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"Custom Object 3", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"Custom Object 3", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"Custom Object 3", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Custom Object 3", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Custom Object 3", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"CustomObject4", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject4", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"CustomObject4", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject4", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject4", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject4", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject4", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject4", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"CustomObject4", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			
			{entitySrc:"CustomObject5", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject5", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","CustomCurrency20"], labelDest:["ProductName","ListPrice"], entityDest:"PriceListLineItem"},
			{entitySrc:"CustomObject5", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject5", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject5", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject5", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject5", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject5", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"CustomObject6", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject6", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","CustomCurrency20"], labelDest:["ProductName","ListPrice"], entityDest:"PriceListLineItem"},
			{entitySrc:"CustomObject6", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject6", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject6", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject6", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject6", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject6", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"CustomObject6", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"CustomObject7", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject7", keySrc:"PickValueGroupId", keyDest:"PicklistValueGroupId", labelSrc:["PickValueGroupFullName"], labelDest:["PicklistValueGroupName"], entityDest:"PiclistValueGroup"},
			{entitySrc:"CustomObject7", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","CustomCurrency20"], labelDest:["ProductName","ListPrice"], entityDest:"PriceListLineItem"},
			{entitySrc:"CustomObject7", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject7", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName","OpportunityAccountName"], labelDest:["OpportunityName","AccountName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject7", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject7", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject7", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject7", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"CustomObject8", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject8", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","CustomCurrency20"], labelDest:["ProductName","ListPrice"], entityDest:"PriceListLineItem"},
			{entitySrc:"CustomObject8", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject8", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject8", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject8", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject8", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject8", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"CustomObject8", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"CustomObject9", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject9", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","CustomCurrency20"], labelDest:["ProductName","ListPrice"], entityDest:"PriceListLineItem"},
			{entitySrc:"CustomObject9", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject9", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject9", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject9", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject9", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject9", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"CustomObject9", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"CustomObject10", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject10", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","CustomCurrency20"], labelDest:["ProductName","ListPrice"], entityDest:"PriceListLineItem"},
			{entitySrc:"CustomObject10", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject10", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject10", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject10", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject10", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject10", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"CustomObject10", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"CustomObject11", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject11", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","CustomCurrency20"], labelDest:["ProductName","ListPrice"], entityDest:"PriceListLineItem"},
			{entitySrc:"CustomObject11", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject11", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName",'ContactFirstName','ContactLastName','ContactAccountName'], labelDest:["ContactFullName",'ContactFirstName','ContactLastName','AccountName'], entityDest:"Contact"},
			{entitySrc:"CustomObject11", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject11", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject11", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject11", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"CustomObject11", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"CustomObject12", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject12", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","CustomCurrency20"], labelDest:["ProductName","ListPrice"], entityDest:"PriceListLineItem"},
			{entitySrc:"CustomObject12", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject12", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject12", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject12", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject12", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject12", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name","CustomObject14ExternalSystemId",'CustomCurrency1'], labelDest:["Name","ExternalSystemId",'CustomCurrency0'], entityDest:"CustomObject14"},
			{entitySrc:"CustomObject12", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"CustomObject13", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject13", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","CustomCurrency20"], labelDest:["ProductName","ListPrice"], entityDest:"PriceListLineItem"},
			{entitySrc:"CustomObject13", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject13", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject13", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject13", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject13", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject13", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"CustomObject13", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			
			{entitySrc:"CustomObject14", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject14", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject14", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"CustomObject14", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject14", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject14", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestSRNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject14", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject14", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"CustomObject15", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject15", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject15", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"CustomObject15", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject15", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivityName"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject15", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestSRNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject15", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["LeadFullName"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"CustomObject15", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"CustomObject15", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			
			{entitySrc:"Asset", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["Product"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"Asset", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Contact"},
			//{entitySrc:"Asset", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Account"},
			{entitySrc:"Asset", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Asset", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Asset", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Asset", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Asset", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Asset", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Asset", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Asset", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Asset", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Asset", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Asset", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Asset", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			
			
			{entitySrc:"Campaign", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"Campaign", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"Campaign", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Campaign", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Campaign", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Campaign", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Campaign", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Campaign", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Campaign", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Campaign", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Campaign", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Campaign", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Campaign", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Campaign", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Campaign", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"Product", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			//			{entitySrc:"Product", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"A"},
			
			{entitySrc:"Product", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"Product", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Product", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Product", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"Product", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"Product", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"Product", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"Product", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"Product", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"Product", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"Product", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"Product", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"Product", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Product", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"MedEdEvent", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"MedEdEvent", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["Product"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject6Id", keyDest:"Id", labelSrc:["CustomObject6Name"], labelDest:["Name"], entityDest:"CustomObject6"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject7Id", keyDest:"Id", labelSrc:["CustomObject7Name"], labelDest:["Name"], entityDest:"CustomObject7"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject8Id", keyDest:"Id", labelSrc:["CustomObject8Name"], labelDest:["Name"], entityDest:"CustomObject8"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject9Id", keyDest:"Id", labelSrc:["CustomObject9Name"], labelDest:["Name"], entityDest:"CustomObject9"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject10Id", keyDest:"Id", labelSrc:["CustomObject10Name"], labelDest:["Name"], entityDest:"CustomObject10"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject11Id", keyDest:"Id", labelSrc:["CustomObject11Name"], labelDest:["Name"], entityDest:"CustomObject11"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject12Id", keyDest:"Id", labelSrc:["CustomObject12Name"], labelDest:["Name"], entityDest:"CustomObject12"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject13Id", keyDest:"Id", labelSrc:["CustomObject13Name"], labelDest:["Name"], entityDest:"CustomObject13"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"MedEdEvent", keySrc:"CustomObject15Id", keyDest:"Id", labelSrc:["CustomObject15Name"], labelDest:["Name"], entityDest:"CustomObject15"},
			
			{entitySrc:"Objectives", keySrc:"AccountNameId", keyDest:"AccountId", labelSrc:["AccountNameAccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Objectives", keySrc:"PlanNameId", keyDest:"Id", labelSrc:["PlanNamePlanName","PlanNameType","PlanNameStatus","PlanNameDescription"], labelDest:["PlanName","Type","Status","Description"], entityDest:"BusinessPlan"},
			{entitySrc:"Objectives", keySrc:"ProductNameId", keyDest:"Id", labelSrc:["ProductNameName"], labelDest:["Name"], entityDest:"Product"},
			
			
			{entitySrc:"BusinessPlan", keySrc:"ParentPlanNameId", keyDest:"Id", labelSrc:["ParentPlanNamePlanName"],keepOutLabelSrc : true, labelDest:["PlanName"], entityDest:"BusinessPlan"},
			{entitySrc:"BusinessPlan", keySrc:"Id", keySupport:"UserId", keyDest:"Id", labelSrc:["PlanName"],isExceptLabelSrc:true, labelSupport:["LastName","FirstName","TeamRole","RoleName","AccessProfileName"],isColDynamic:true, labelDest:["LastName","FirstName"], entityDest:"User", supportTable:"BusinessPlan.Team"},			
			{entitySrc:"BusinessPlan.Team", keySrc:"ParentId", keyDest:"Id", labelSrc:["PlanName"], labelDest:["PlanName"], entityDest:"BusinessPlan"},			
			{entitySrc:"PlanAccount", keySrc:"BusinessPlanId", keyDest:"Id", labelSrc:["BusinessPlanPlanName"], labelDest:["PlanName"], entityDest:"BusinessPlan"},
			{entitySrc:"PlanContact", keySrc:"BusinessPlanId", keyDest:"Id", labelSrc:["BusinessPlanPlanName"], labelDest:["PlanName"], entityDest:"BusinessPlan"},
			{entitySrc:"PlanOpportunity", keySrc:"PlanId", keyDest:"Id", labelSrc:["PlanName"], labelDest:["PlanName"], entityDest:"BusinessPlan"},
			
			{entitySrc:"PlanOpportunity", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:['OpportunityName','OptyName',"OpportunityAccountName","OpportunityOwner","OpportunityForecast","OpportunityCloseDate","OpportunityRevenue"], labelDest:['OpportunityName','OpportunityName','AccountName','Owner','CloseDate','Forecast','Revenue'], entityDest:"Opportunity"},
			{entitySrc:"PlanAccount", keySrc:"AccountIDId", keyDest:"AccountId", labelSrc:['AccountIDAccountName',"AccountIDAccountType","AccountIDLocation","AccountIDOwner","AccountIDPriority","AccountIDReference"], labelDest:['AccountName','AccountType','Location','Owner','Priority','Reference'], entityDest:"Account"},
			{entitySrc:"PlanContact", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName","ContactFirstName","ContactLastName","ContactAccountName"], labelDest:['ContactFullName','ContactFirstName','ContactLastName','AccountName'], entityDest:"Contact"},
			
			{entitySrc:"AuditTrail", keySrc:"Id", keyDest:"ServiceRequestId", labelSrc:["RecordName"], labelDest:['SRNumber'], entityDest:"Service Request"},
			{entitySrc:"AuditTrail", keySrc:"Id", keyDest:"OpportunityId", labelSrc:["RecordName"], labelDest:['OpportunityName'], entityDest:"Opportunity"},
			
			{entitySrc:"Contact.CampaignRecipient", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:['ContactFullName'], entityDest:"Contact"},
			{entitySrc:"Contact.CampaignRecipient", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName",'CampaignType'], labelDest:['CampaignName','CampaignType'], entityDest:"Campaign"},
			
		]);
		
		
		public static function getFieldRelation(entitySrc:String, field:String):Object {
			for each (var relation:Object in RELATIONS) {
				if (relation.entitySrc == entitySrc && relation.labelSrc[0] == field) {
					//				if (relation.entitySrc == entitySrc && relation.labelSrc == field) {
					return copyRelation((relation));
				}
			}
			if (entitySrc.indexOf(".")>0) {
				return DAOUtils.fakeGetFieldRelation(entitySrc, field);
			}
			return null;
		}
		
		
		public static function getAllFieldsRelation(entitySrc:String):ArrayCollection{
			var rFields:ArrayCollection=new ArrayCollection();
			for each (var relation:Object in RELATIONS) {
				if (relation.entitySrc == entitySrc) {
					for each(var f:String in relation.labelSrc){
						if(rFields.contains(f)) continue;
						rFields.addItem(f);
					}
				}
			}
			return rFields;
		}
		
		
		public static function getParentRelation(entitySrc:String,removeParent:String=""):ArrayCollection {
			var references:ArrayCollection = new ArrayCollection();
			references.addItem({data:'',label:'',entityDest:'',entitySrc:''});
			for each (var relation:Object in RELATIONS) {
				if (relation.supportTable == null && relation.entitySrc == entitySrc && entitySrc != relation.entityDest) {
					if(!StringUtils.isEmpty(removeParent) && removeParent == relation.entityDest){
						continue;
					}
					references.addItem(copyRelation(relation));
				}
			}	
			if(references.length>0){
				var dataSortField:SortField = new SortField();
				
				var s:Sort = new Sort();
				s.fields = [new SortField("entityDest", true, false, false)];
				references.sort = s;
				references.refresh();
			}
			return references;
		}
		
		private static function copyRelation(rel:Object):Object{
			var clone:Object = new Object();
			for(var f:String in rel){
				var val:Object = rel[f];
				if(val is Array){
					var ac:Array = new Array();
					for each(var item:String in val){
						ac.push(item);
					}
					clone[f] = ac;
				}else{
					clone[f] = val;
				}
			}
			
			return clone;
		}
		
		//VAHI There can be more than one field which has a relation to another object.
		// So this should return a list (Array) of such relations, not just an arbitrary one.
		// Perhaps rename it to getRelations() then.
		public static function getRelation(entitySrc:String, entityDest:String):Object {
			for each (var relation:Object in RELATIONS) {
				if (relation.supportTable == null && relation.entitySrc == entitySrc && relation.entityDest == entityDest) {
					return copyRelation((relation));
				}
			}	
			return null;
		}
		
		public static function getMNRelation(entitySrc:String, entityDest:String):Object {
			for each (var relation:Object in RELATIONS) {
				if (relation.supportTable != null && relation.entitySrc == entitySrc && (relation.entityDest == entityDest||relation.supportTable==entityDest)) {
					return copyRelation((relation));
				}
			}	
			return null;
		}
		
		
		/**
		 * Returns the entities that are referenced by this entity. 
		 * @param entity
		 * @return 
		 * 
		 */
		public static function getReferenced(entity:String):ArrayCollection {
			var references:ArrayCollection = new ArrayCollection();
			for each (var relation:Object in RELATIONS) {
				if (relation.entitySrc == entity) {
					references.addItem(copyRelation(relation));
				}
			}
			return references;
		}
		
		/**
		 * Returns the entities that are referenced by this entity, and that use a MxN relationship. 
		 * @param entity
		 * @return 
		 */
		public static function getMNReferenced(entity:String):ArrayCollection {
			var references:ArrayCollection = new ArrayCollection();
			for each (var relation:Object in RELATIONS) {
				if (relation.entitySrc == entity && relation.supportTable) {
					references.addItem(copyRelation(relation));
				}
			}
			return references;
		}
		
		/**
		 * Returns the entities that reference this entity. 
		 * @param entity
		 * @return 
		 * 
		 */
		public static function getReferencers(entity:String):ArrayCollection {
			var referencers:ArrayCollection = new ArrayCollection();
			for each (var relation:Object in RELATIONS) {
				if (relation.entityDest == entity) {
					referencers.addItem(copyRelation(relation));
				}
			}			
			if (entity.indexOf(".")>0) {
				OOPS("=missing","getReferencers for SupportDAO not yet implemented");
			}
			return referencers;
		}
		
		/**
		 * Returns all the entities that are linkable to a specific entity. 
		 * @param entity
		 * @return 
		 * 
		 */
		public static function getLinkable(entity:String):ArrayCollection {
			var linkable:ArrayCollection = new ArrayCollection();
			for each (var relation:Object in RELATIONS) {
				if (relation.entityDest == entity && !linkable.contains(relation.entitySrc)) {
					linkable.addItem(relation.entitySrc);
				}
				if (relation.entitySrc == entity && !linkable.contains(relation.entityDest)) {
					linkable.addItem(relation.entityDest);
				}
				
			}
			if (entity.indexOf(".")>0) {
				OOPS("=missing","getLinkable for SupportDAO not yet implemented");
			}
			return linkable;
		}
		
	}
}