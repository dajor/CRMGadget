//VAHI added

package gadget.util
{
	public class SodUtils
	{
		/* Not getable APIs:
		Deleted Item
		Integration Event
		Login History
		Mapping Service
		Merge
		Metadata Change SuXXXXXX
		Picklist
		Sales Process
		Time
		User Usage
		
		Not getable Services:
		Access Profile
		Cascading Picklists
		Custom Web Tab
		Customize Record Type
		Field Management
		Picklist
		*/
		
		// To introduce a new object to sync, we only need to edit 3 files:
		// - Create the DAO file for it, listing all the columns from WSDL
		// - Enter the DAO into Database.as
		// - List the properties in transactionProperties
		// If the object works analogous to known objects, this should be all!
		// WS2.0 sync automatically shall be able to fetch the object.
		// WS2.0 upload must be programmed, so it's not there yet anyway.
		//
		// Sync order: 0=incoming only, 9=temporarily enabled until correct value known
		//
		// Documentation of the columns see SodUtilsTAO
		
		// T.W1 now always is false as WS1.0 has been retired (keep it for debugging purpose until the WS1.0 code is removed completely)
		// T.W2Gen shall come true next
		private static var T:Object = SodUtilsTAO;	//Hack to shorten
		private static const TRANSACTION_PROPERTIES:Array = [
			[T.Order,T.OurName,          T.Top, T.SodName                , T.Dao, T.W2Act,T.W2Att, T.W2AttId,T.W2Prod, ],
			[9, "SampleDropped",         false,  "SampleDropped",           null, false,  false,   null,      false,   ],
			[9, "ProductsDetailed",         false,  "ProductsDetailed",     "activityProductDao" , false,  false,   null,      false,   ],
			[1, "Account",               true,  null,                       null, true,   true,    null,      false,   ],
			[2, "Activity",              true,  null,                       null, false,  true,    null,      true ,   ],	//ActivityActivity fetches ActivityProduct
			[9, "Allocation",            true,  "CRMOD_LS_Allocation",      null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[0, "User",   		         true,  null,              "allUsersDao", false,  false,   null,      false,   ],	// there is WS10, disable it for now?
			[9, "Application",           true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Asset",                 true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[0, "Attachment",            false, null,                       null, false,  false,   null,      false,   ],
			[9, "Book",                  true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			// [9, "BusinessPlan",          true,  "CRMODLS_BusinessPlan",     null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[2, "Campaign",              true,  null,                       null, true,   true,    null,      false,   ],
			[9, "Category",              true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Claim",                 true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[1, "Contact",               true,  null,                       null, true,   true,    null,      false,   ],
			[9, "ContactBestTimes",      true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "ContactLicense",        true,  "CRMOD_LS_ContactLicenses", null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Coverage",              true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "Custom Object 1",       true,  null,                       null, false,  true, "CustomObjectId", false,],
			[3, "Custom Object 2",       true,  null,                       null, true,   true, "CustomObjectId", false,],	//VAHI according to WSDL there is no Activity in this object
			[3, "Custom Object 3",       true,  null,                       null, false,  true, "CustomObjectId", false,],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject4",         true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject5",         true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject6",         true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject7",         true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject8",         true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject9",         true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject10",        true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject11",        true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject12",        true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject13",        true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[3, "CustomObject14",        true,  null,                       null, true,   false,   null,      false,   ],
			[3, "CustomObject15",        true,  null,                       null, true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Damage",                true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Dealer",                true,  "Channel Partner",          null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "DealRegistration",      true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "FinancialAccount",      true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "FinancialAccountHolder", true, null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "FinancialAccountHolding", true, null,                      null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "FinancialPlan",         true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "FinancialProduct",      true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "FinancialTransaction",  true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Fund",                  true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Group",                 true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Household",             true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "InsuranceProperty",     true, null,                        null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "InventoryAuditReport", true, "CRMODLS_InventoryAuditReport", null, false, false,  null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "InventoryPeriod",       true,  "CRMODLS_InventoryPeriod",  null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "InvolvedParty",         true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[1, "Lead",                  true,  null,                       null, true,   true,    null,      false,   ],
			[9, "MDFRequest",            true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "MedEd",                 true,  "MedEdEvent",               null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "MessagePlan",           true,  "CRMOD_LS_MessagingPlan",   null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "MessageResponse",       true,  "CRMODLS_PCD_MSGRSP",       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "ModificationTracking",  true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "MsgPlanItem",           true,  "CRMOD_LS_MsgPlanItem",     null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "MsgPlanItemRelation",   true,  "CRMOD_LS_MsgPlnRel",       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Note",                  true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			//[9, "Objectives",            true,  "CRMODLS_OBJECTIVE",        null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Objectives",            true,  null,        null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[1, "Opportunity",           true,  null,                       null, true,   true,    null,      false,   ],
			[9, "PlanAccount",           true,  "CRMODLS_BPL_ACNT",         null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "PlanContact",           true,  "CRMODLS_BPL_CNTCT",        null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "PlanOpportunity",       true, "CRMODLS_PlanOpportunities", null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[0, "Policy",                true,  null,                       null, true,   true,    null,      false,   ],
			[0, "PolicyHolder",          true,  null,                       null, true,   false,   null,      false,   ],
			[9, "Portfolio",             true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "PriceList",             true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "PriceListLineItem",     true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[0, "Product",               true,  null,                       null, false,  false,   null,      false,   ],
			[9, "SampleDisclaimer",      true,  "CRMODLS_SIGNDISC",         null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "SampleInventory",       true,  "CRMODLS_SampleInventory",  null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "SampleLot",             true,  "CRMODLS_SampleLot",        null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "SampleTransaction",     true,  "CRMOD_LS_Transactions",    null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[1, "Service Request",       true,  null,               "serviceDao", false,   true,   "SRId",    false,   ],
			[9, "Signature",             true,  "CRMODLS_Signature",        null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Solution",              true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "SPRequest",             true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "SPRequestLineItem",     true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[0, "Team",			         false, null,          				null, false,  false,   null,      false,  ],	// For AccountTeam etc. (not currently implemented)
			[0, "Partner",			     false, null,          				null, false,  false,   null,      false,  ],	// For AccountTeam etc. (not currently implemented)
			[0, "Address",			     false, null,          				null, false,  false,   null,      false,  ],	// For AccountAddress etc. (not currently implemented)
			[0, "Competitor",			 false, null,          				null, false,  false,   null,      false,  ],	// For AccountTeam etc. (not currently implemented)						
			[0, "Related",			     false, null,          				null, false,  false,   null,      false,  ],	// For AccountTeam etc. (not currently implemented)
			[9, "Territory",             true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "TransactionItem",       true, "CRMOD_LS_TransactionItems", null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Vehicle",               true,  null,                       null, false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "Pharma Call Products Detailed",false,  null,       "activityProductDao", false, true,   false,  false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "ContactRole",         false,  "ContactRole",           "opportunityContactDao", false,  false,   null,      false,   ],
			[9, "MedEdEvent",		     true,  "MedEd",              "medEdDao", true,   false,   null,      false,   ],	//NEW, perhaps some flags need to be set!
			[9, "BusinessPlan",		 	 true,  "BusinessPlan","businessPlanDao", true,   false,   null,      false,   ]	//NEW, perhaps some flags need to be set!
		];
		
		// HERE we repair everything in regards to what the SoD GetField service does wrong.
		//
		// For example, GetField returns WS1.0 column names for all old WS1.0 objects.
		// In this case it does not even mention any added WS2.0 column name!
		// But for all new WS2.0 objects (which often are not supported with WS1.0)
		// it returns the WS2.0 names.
		// So what do we enter here?
		// HERE ONLY INFORMATION IS ENTERED, WHICH AFFECTS NEW OBJECTS.
		//
		// What does this mean?
		//
		// This table ONLY contains fixes for things which
		// - EITHER are only in the WSDL 2.0 descriptions of the objects
		// - OR are returned wrong by GetField, if (and only if) the object uses the WSDL 2.0
		// So following columns are left out here, because they are correctly presented by GetField:
		// - Columns for objects which are still based on WSDL1.0
		//   These are handled in ws20.as, as we want to get rid of this module in future!
		//
		// For example, "Custom Object 2" is based on WSDL 2.0,
		// AND GetField presents us with the wrong WSDL 1.0 column for Id,
		// so we have to fix it here.
		//
		// In contrast, "Custom Object 1" is based on WSDL 1.0 (as it is old),
		// SO GETFIELD RETURNS THE RIGHT COLUMN NAMES, nothing to fix here.
		//
		// But for "Activity", which is based on WSDL 1.0 (old, too),
		// GETFIELD forgets about the WSDL 2.0 column "CustomObject14Id",
		// so we have to add THIS column here but NO columns which are
		// present in both, WSDL 2.0 and WSDL 1.0, even that the both
		// columns might have different names.  If so, this must go into ws20.as.
		// This means, in the process while bringing an object from WSDL1.0 to
		// WSDL2.0 the fixes from ws20.as will be moved here to repair the
		// - then wrong - output of GetField.  But as long as GetField is
		// still right because the Object here is handled according to WSDL1.0,
		// we DO NOT add this fix here.  Sigh.
		//
		// If you depend on changes to this structure (see sync.task.GetFields.as)
		// see SodUtils.fixFieldsHash
		//
		// Hope this explains it thoroughly.
		//
		//VAHI as this here is a little bit too confusing,
		// I think it shall be refactored into the Object's DAO later on.
		// Even that the information looks somewhat redundant now, it is NOT REALLY.
		// The bug is in the unrolling of the DAOs of similar objects.
		// So the right thing is to first wrap this into the DAOs,
		// then to refactor the DAOs such, that common code is combined somehow.
		
		// Suitable Hack for CustomObject4 to 15
		// Not for 1, 2 and 3, as they are somewhat disturbed by WS1.0
		private static const CUSTOM_OBJECT_FIX4TO15:Array = [
			{ name:"AccountId", type:"ID" },
			{ name:"ActivityId", type:"ID" },
			{ name:"AssetId", type:"ID" },
			{ name:"CampaignId", type:"ID" },
			{ name:"ContactId", type:"ID" },
			{ name:"CustomObject1Id", type:"ID" },
			{ name:"CustomObject2Id", type:"ID" },
			{ name:"CustomObject3Id", type:"ID" },
			{ name:"CustomObject3Id", type:"ID" },
			{ name:"CustomObject4Id", type:"ID" },
			{ name:"CustomObject5Id", type:"ID" },
			{ name:"CustomObject6Id", type:"ID" },
			{ name:"CustomObject7Id", type:"ID" },
			{ name:"CustomObject8Id", type:"ID" },
			{ name:"CustomObject9Id", type:"ID" },
			{ name:"CustomObject10Id", type:"ID" },
			{ name:"CustomObject11Id", type:"ID" },
			{ name:"CustomObject12Id", type:"ID" },
			{ name:"CustomObject13Id", type:"ID" },
			{ name:"CustomObject14Id", type:"ID" },
			{ name:"CustomObject15Id", type:"ID" },
			{ name:"DealRegistrationId", type:"ID" },
			{ name:"DealerId", type:"ID" },
			{ name:"FundId", type:"ID" },
			{ name:"FundRequestId", type:"ID" },
			{ name:"HouseholdId", type:"ID" },
			{ name:"LeadId", type:"ID" },
			{ name:"MDFRequestId", type:"ID" },
			{ name:"MedEdId", type:"ID" },
			{ name:"ModId", type:"ID" },
			{ name:"OpportunityId", type:"ID" },
			{ name:"OwnerId", type:"ID" },
			{ name:"PartnerId", type:"ID" },
			{ name:"PortfolioId", type:"ID" },
			{ name:"ProductId", type:"ID" },
			{ name:"ProgramId", type:"ID" },
			{ name:"SPRequestId", type:"ID" },
			{ name:"ServiceRequestId", type:"ID" },
			{ name:"SolutionId", type:"ID" },
			{ name:"VehicleId", type:"ID" },
		];
		
		private static const FIELDS_TO_FIX:Object = {
			Activity: [
				/* VAHI does not work with WS1.0 nor WS2.0.  If you add the "Owner" manually, SoD vomits.
				{ name:"Owner", type:"Picklist" },			// Wanted by DJ
				/**/
				{ name:"CustomObject14Id", type:"ID" },		// Add the missing ID field for WS2.0
				{ name:"CustomObject14Name", type:"Picklist" },
				{ name:"CustomObject10Id", type:"ID" },
				{ name:"CustomObject10Name", type:"Picklist" },
				{ name:"Alias", rename:"Owner" }
			],
			Asset: [
				{ name:"AssetId", rename:"Id" },
				{name:"OwnerAccountId", rename:"AccountId"}
			],
			Book: [
				{ name:"BookId", rename:"Id" },
			],
			"Custom Object 2": [
				//VAHI due to this we have a problem.  There is "CustomObject2Id" and "Id" in parallel in WS2.0
				{ name:"CustomObject2Id", rename:"Id" },	// Rename GetField WS1.0 field name to the correct value
			],
			"Custom Object 3": [
				//VAHI due to this we have a problem.  There is "CustomObject2Id" and "Id" in parallel in WS2.0
				{ name:"CustomObject3Id", rename:"Id" },	// Rename GetField WS1.0 field name to the correct value
			],
			
			CustomObject4: CUSTOM_OBJECT_FIX4TO15,
			CustomObject5: CUSTOM_OBJECT_FIX4TO15,
			CustomObject6: CUSTOM_OBJECT_FIX4TO15,
			CustomObject7: CUSTOM_OBJECT_FIX4TO15,
			CustomObject8: CUSTOM_OBJECT_FIX4TO15,
			CustomObject9: CUSTOM_OBJECT_FIX4TO15,
			CustomObject10: CUSTOM_OBJECT_FIX4TO15,
			CustomObject11: CUSTOM_OBJECT_FIX4TO15,
			CustomObject12: CUSTOM_OBJECT_FIX4TO15,
			CustomObject13: CUSTOM_OBJECT_FIX4TO15,
			CustomObject14: CUSTOM_OBJECT_FIX4TO15,
			CustomObject15: CUSTOM_OBJECT_FIX4TO15,
			
			Group: [
				{ name:"UserGroupId", rename:"Id" },
			],
			Household: [
				{ name:"HouseholdId", rename:"Id" },
			],
			Note: [
				{ name:"NoteId", rename:"Id" },
			],
			Portfolio: [
				{ name:"PortfolioId", rename:"Id" },
			],
			"Service Request": [
				{ name:"ModifiedDate", type:"Date/Time" },	// Add the missing and supported field
			],
			User: [
				{ name:"UserId", rename:"Id" },				// AllUsers is now on WS2.0
				{ name:"ModifiedDate", type:"Date/Time" },	// Add the missing and supported field
				{ name:"Role", type:"Text (Short)"},        // getFields only returns WS1.0 names for objects which are known to WS1.0, so "Role" which is WS2.0 is not returned
				{ name:"TimeZoneName", type:"Text (Short)"}// Add timezoneName into field mgt 
				
			],
			Vehicle: [
				{ name:"VehicleId", rename:"Id" },
			],
			MedEdEvent:[{name:"MedEdId",rename:"Id"}],
			AccountCompetitor:[				
				{name:"AccountCompetitorId", rename:"Id"}
			],
			AccountPartner:[
				{name:"Role", rename:"RelationshipRole" },
				{name:"AccountPartnerId", rename:"Id"}
			],
			ContactRelationship:[				
				{name:"ContactRelationshipId", rename:"Id"}
			]
			,
			AccountRelationship:[
				{name:"RelationshipRole", rename:"Role" },
				{name:"AccountRelationshipId", rename:"Id"},
				{name:"ReverseRelationshipRole",rename:"ReverseRole"}
			]
			,
			"Opportunity Team":[
				{name:"OptyId", rename:"OpportunityId" }]
		};
		
		public static function fixFields(entitySod:String):Array {
			return (entitySod in FIELDS_TO_FIX) ? FIELDS_TO_FIX[entitySod] : [];
		}
		
		// return an unique hash of the FIELDS_TO_FIX
		// This changes iff (=if and only if) the contents of FIELDS_TO_FIX changes.
		private static var _fixFieldsHash:String;
		public static function get fixFieldsHash():String {
			if (_fixFieldsHash==null)
				_fixFieldsHash = StringUtils.md5(ObjectUtils.toString(FIELDS_TO_FIX));
			return _fixFieldsHash;
		}
		
		private static var _transactionPropertiesObject:Object;
		private static function get transactionPropertiesObject():Object {
			if (_transactionPropertiesObject==null){
				_transactionPropertiesObject = ObjectUtils.objectFromArray(TRANSACTION_PROPERTIES, SodUtilsTAO, 1);
			}	
			return _transactionPropertiesObject;
		}
		
		public static function mkDaoName(s:String):String {
			s = s.replace(/ /g,"");
			s = s.substr(0,1).toLocaleLowerCase()+s.substr(1);
			return s+"Dao";
		}
		
		public static function transactionProperty(transaction:String):SodUtilsTAO {
			return transactionPropertiesObject[transaction];
		}
		
		public static function transactions():Array /*of String*/ {
			return ObjectUtils.keys(transactionPropertiesObject).sort();
		}
		
		public static function transactionsTAO():Array /*of SodUtilsTAO*/ {
			return transactions().map(function(s:String,i:int,a:Array):SodUtilsTAO { return transactionPropertiesObject[s]; });
		}
		
		public static function transactionsTAOif(s:String):Array {
			return transactionsTAOfunc(function(t:SodUtilsTAO):Boolean{return t[s]});
		}
		
		public static function transactionsTAOfunc(f:Function):Array {
			return transactionsTAO().filter(function(t:SodUtilsTAO,i:int,a:Array):Boolean { return (f)(t); });
		}
		
		
		public static function apiMappingNames():Object {
			return null;	//NOT READY
		}
	}
}

/* About Activity.Owner:

<SOAP-ENV:Fault xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
<faultcode>SOAP-ENV:Server</faultcode>
<faultstring>Error while processing argument urn:crmondemand/ws/ecbs/account/:ListOfAccount for operation AccountQueryPage(SBL-EAI-04316)</faultstring>
<detail>
<siebelf:siebdetail xmlns:siebelf="http://www.siebel.com/ws/fault">
<siebelf:logfilename>OnDemandServicesObjMgr_enu_30867.log</siebelf:logfilename>
<siebelf:errorstack>
<siebelf:error>
<siebelf:errorcode>(SBL-EAI-04316)</siebelf:errorcode>
<siebelf:errorsymbol/>
<siebelf:errormsg>Error while processing argument urn:crmondemand/ws/ecbs/account/:ListOfAccount for operation AccountQueryPage(SBL-EAI-04316)</siebelf:errormsg>
</siebelf:error>
<siebelf:error>
<siebelf:errorcode>(SBL-EAI-04127)</siebelf:errorcode>
<siebelf:errorsymbol>IDS_EAI_ERR_INTOBJHIER_ELEM_UNKN</siebelf:errorsymbol>
<siebelf:errormsg>Element with XML tag 'Owner' is not found in the definition of EAI Integration Component 'Account_Action'(SBL-EAI-04127)</siebelf:errormsg>
</siebelf:error>
</siebelf:errorstack>
</siebelf:siebdetail>
</detail>
</SOAP-ENV:Fault>
*/
