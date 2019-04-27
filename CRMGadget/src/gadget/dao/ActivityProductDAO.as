package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class ActivityProductDAO extends SupportDAO {
		
//		private var stmtRead:SQLStatement;
		
		public function ActivityProductDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				sodName: 'ProductsDetailed',
				entity: [ 'Activity',   'Product'   ],
				id:     [ 'ActivityId', 'ProductId' ],
				columns: TEXTCOLUMNS
			},{				
				record_type:"Call ProdDetail",
				name_column:["Product"],
				oracle_id:"Id",	
				search_columns:["Product"]
			});
			_isGetField = true;
			_isSyncWithParent = false;
			_isSelectAll=true;
		}


		private const TEXTCOLUMNS:Array = [
			"ModifiedDate",
			"CreatedDate",
			"ModifiedById",
			"CreatedById",
			"ModId",
			"Id",
			"CustomCurrency2",
			"CustomCurrency18",
			"CustomCurrency19",
			"CustomCurrency3",
			"CustomBoolean7",
			"CustomBoolean4",
			"CustomBoolean8",
			"CustomBoolean9",
			"CustomCurrency0",
			"CustomCurrency1",
			"CustomBoolean3",
			"CustomBoolean5",
			"CustomBoolean6",
			"CustomCurrency10",
			"CustomCurrency11",
			"CustomCurrency12",
			"CustomCurrency13",
			"CustomCurrency14",
			"CustomCurrency16",
			"CustomCurrency15",
			"CustomCurrency17",
			"CustomCurrency6",
			"CustomCurrency7",
			"CustomCurrency4",
			"CustomCurrency5",
			"CustomCurrency8",
			"CustomDate47",
			"CustomDate49",
			"CustomDate43",
			"CustomDate44",
			"CustomDate5",
			"CustomDate48",
			"CustomDate52",
			"CustomDate51",
			"CustomDate50",
			"CustomDate45",
			"CustomDate46",
			"CustomDate59",
			"CustomDate53",
			"CustomDate54",
			"CustomDate55",
			"CustomDate56",
			"CustomDate57",
			"CustomDate58",
			"CustomDate6",
			"CustomDate7",
			"CustomDate8",
			"CustomNumber13",
			"CustomNumber19",
			"CustomNumber18",
			"CustomNumber17",
			"CustomNumber16",
			"CustomNumber15",
			"CustomNumber14",
			"CustomNumber11",
			"CustomNumber12",
			"CustomNumber2",
			"CustomNumber21",
			"CustomNumber20",
			"CustomNumber26",
			"CustomNumber27",
			"CustomNumber28",
			"CustomDate0",
			"CustomDate1",
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
			"CustomInteger8",
			"CustomNumber10",
			"CustomNumber1",
			"CustomInteger9",
			"CustomInteger2",
			"CustomNumber0",
			"CustomInteger3",
			"CustomDate10",
			"CustomCurrency9",
			"CustomDate21",
			"CustomDate20",
			"CustomDate2",
			"CustomDate19",
			"CustomDate18",
			"CustomDate17",
			"CustomDate16",
			"CustomDate15",
			"CustomDate14",
			"CustomInteger4",
			"CustomInteger5",
			"CustomInteger6",
			"CustomInteger7",
			"CustomDate13",
			"CustomDate11",
			"CustomDate12",
			"CustomDate31",
			"CustomDate3",
			"CustomDate29",
			"CustomDate28",
			"CustomDate27",
			"CustomDate30",
			"CustomDate25",
			"CustomDate26",
			"CustomDate22",
			"CustomDate23",
			"CustomDate24",
			"CustomDate37",
			"CustomDate38",
			"CustomDate40",
			"CustomDate36",
			"CustomDate35",
			"CustomDate34",
			"CustomDate33",
			"CustomDate32",
			"CustomDate39",
			"CustomDate4",
			"CustomDate41",
			"CustomDate42",
			"CustomPickList90",
			"CustomPickList9",
			"CustomPickList89",
			"CustomPickList88",
			"CustomPickList87",
			"CustomPickList83",
			"CustomPickList85",
			"CustomPickList84",
			"CustomPickList82",
			"CustomPickList81",
			"CustomPickList86",
			"CustomPickList80",
			"CustomPickList91",
			"CustomNumber25",
			"CustomNumber23",
			"CustomNumber24",
			"CustomNumber29",
			"CustomNumber3",
			"CustomNumber22",
			"CustomNumber30",
			"CustomPickList92",
			"CustomPickList93",
			"CustomPickList95",
			"CustomPickList96",
			"CustomPickList97",
			"CustomPickList98",
			"CustomPickList99",
			"CustomPickList94",
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
			"CustomNumber5",
			"CustomNumber6",
			"CustomPhone15",
			"CustomText17",
			"CustomText16",
			"CustomText15",
			"CustomText14",
			"CustomText13",
			"CustomText12",
			"CustomText11",
			"CustomText10",
			"CustomText1",
			"CustomText0",
			"CustomText21",
			"CustomText20",
			"CustomText2",
			"CustomText19",
			"CustomText18",
			"CustomText24",
			"CustomText25",
			"CustomPhone12",
			"CustomPhone11",
			"CustomPhone10",
			"CustomPhone1",
			"CustomPhone0",
			"CustomNumber9",
			"CustomNumber8",
			"CustomPhone14",
			"CustomNumber7",
			"CustomPhone13",
			"CustomPhone7",
			"CustomPhone16",
			"CustomPhone17",
			"CustomPhone18",
			"CustomPhone19",
			"CustomPhone2",
			"CustomPhone3",
			"CustomPhone8",
			"CustomPhone4",
			"CustomPhone6",
			"CustomPhone5",
			"CustomPickList12",
			"CustomPickList15",
			"CustomPhone9",
			"CustomPickList0",
			"CustomPickList11",
			"CustomText29",
			"CustomText3",
			"CustomPickList10",
			"CustomPickList1",
			"CustomPickList13",
			"CustomPickList14",
			"CustomPickList17",
			"CustomPickList18",
			"CustomPickList16",
			"CustomText30",
			"CustomText31",
			"CustomText32",
			"CustomText33",
			"CustomText34",
			"CustomText35",
			"CustomText36",
			"CustomText37",
			"CustomText38",
			"CustomText42",
			"CustomText49",
			"CustomText48",
			"CustomText47",
			"CustomText46",
			"CustomText45",
			"CustomText39",
			"CustomText43",
			"CustomText41",
			"CustomText40",
			"CustomText4",
			"CustomText44",
			"CustomPickList28",
			"CustomText26",
			"CustomText27",
			"CustomText28",
			"CustomText22",
			"CustomText23",
			"CustomPickList19",
			"CustomPickList2",
			"CustomPickList20",
			"CustomPickList21",
			"CustomPickList27",
			"CustomPickList23",
			"CustomPickList24",
			"CustomPickList25",
			"CustomPickList26",
			"CustomPickList22",
			"CustomPickList38",
			"CustomPickList37",
			"CustomPickList36",
			"CustomPickList35",
			"CustomPickList34",
			"CustomPickList39",
			"CustomPickList32",
			"CustomPickList31",
			"CustomPickList30",
			"CustomPickList3",
			"CustomPickList33",
			"CustomPickList29",
			"CustomPickList49",
			"CustomPickList48",
			"CustomPickList46",
			"CustomPickList45",
			"CustomPickList47",
			"CustomPickList43",
			"CustomPickList42",
			"CustomPickList40",
			"CustomPickList4",
			"CustomPickList44",
			"CustomPickList41",
			"CustomPickList58",
			"CustomPickList5",
			"CustomPickList50",
			"CustomPickList51",
			"CustomPickList52",
			"CustomPickList53",
			"CustomPickList54",
			"CustomPickList55",
			"CustomPickList56",
			"CustomPickList57",
			"CustomPickList59",
			"CustomPickList6",
			"CustomPickList60",
			"CustomPickList7",
			"CustomPickList69",
			"CustomPickList68",
			"CustomPickList66",
			"CustomPickList67",
			"CustomPickList64",
			"CustomPickList63",
			"CustomPickList62",
			"CustomPickList61",
			"CustomPickList65",
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
			"CustomText5",
			"CustomText50",
			"CustomText52",
			"CustomText53",
			"CustomText54",
			"CustomText55",
			"CustomText56",
			"CustomText57",
			"CustomText58",
			"CustomText59",
			"CustomText51",
			"CustomText61",
			"CustomText6",
			"CustomText60",
			"CustomText62",
			"CustomBoolean33",
			"CustomBoolean34",
			"CustomInteger20",
			"CustomInteger21",
			"CustomInteger22",
			"CustomInteger23",
			"CustomInteger24",
			"CustomInteger25",
			"CustomText63",
			"CustomText64",
			"CustomText65",
			"CustomText66",
			"CustomText67",
			"CustomText68",
			"CustomText69",
			"CustomText78",
			"CustomText76",
			"CustomText8",
			"CustomText79",
			"CustomText77",
			"CustomText71",
			"CustomNumber53",
			"CustomNumber54",
			"CustomNumber55",
			"CustomNumber56",
			"CustomNumber57",
			"CustomNumber58",
			"CustomNumber59",
			"CustomNumber60",
			"CustomNumber61",
			"CustomNumber62",
			"CustomCurrency20",
			"CustomText72",
			"CustomText70",
			"CustomText7",
			"CustomText75",
			"CustomText73",
			"CustomText74",
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
			"CustomInteger26",
			"CustomInteger27",
			"CustomInteger28",
			"CustomInteger29",
			"CustomInteger30",
			"CustomInteger31",
			"CustomInteger32",
			"CustomInteger33",
			"CustomInteger34",
			"CustomNumber40",
			"CustomNumber41",
			"CustomNumber42",
			"CustomNumber43",
			"CustomNumber44",
			"CustomText91",
			"CustomText92",
			"CustomText93",
			"CustomText95",
			"CustomText98",
			"CustomText94",
			"CustomText99",
			"CustomText96",
			"CustomText97",
			"CustomBoolean30",
			"CustomBoolean31",
			"CustomBoolean32",
			"CustomNumber45",
			"CustomNumber46",
			"CustomNumber47",
			"CustomNumber48",
			"CustomNumber49",
			"CustomNumber50",
			"CustomNumber51",
			"CustomNumber52",
			"CustomCurrency21",
			"CustomCurrency22",
			"CustomCurrency23",
			"CustomCurrency24",
			"ProductCategory",
			"Issue",
			"IndexedBoolean0",
			"IndexedCurrency0",
			"IndexedDate0",
			"IndexedLongText0",
			"IndexedNumber0",
			"IndexedPick0",
			"IndexedPick5",
			"IndexedPick4",
			"IndexedPick3",
			"IndexedPick1",
			"IndexedPick2",
			"IndexedShortText0",
			"IndexedShortText1",
			"ProductDetailedExternalSystemId",
			"ProductExternalSystemId",
			"Product",
			"Indication",
			"ActivityId",
			"ProductId",
			"Priority",
			"ProductCategoryId",
			"CustomBoolean0",
			"CustomBoolean10",
			"CustomBoolean11",
			"CustomBoolean12",
			"CustomBoolean13",
			"CustomBoolean14",
			"CustomBoolean15",
			"CustomBoolean16",
			"CustomBoolean17",
			"CustomBoolean18",
			"CustomBoolean1",
			"CustomBoolean19",
			"CustomBoolean29",
			"CustomBoolean23",
			"CustomBoolean27",
			"CustomBoolean26",
			"CustomBoolean25",
			"CustomBoolean24",
			"CustomBoolean22",
			"CustomBoolean21",
			"CustomBoolean20",
			"CustomBoolean28",
			"CustomBoolean2",
			"Sample",
			"StartTime",
			"EndTime",
			"ProductAllocationId",
			"UpdatedByFirstName",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			"UpdatedByAlias",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByExternalSystemId",
			"UpdatedByEMailAddr",
			"CreatedByFirstName",
			"CreatedByLastName",
			"CreatedByUserSignInId",
			"CreatedByAlias",
			"CreatedByFullName",
			"CreatedByIntegrationId",
			"CreatedByExternalSystemId",
			"CreatedByEMailAddr",
			"CreatedBy",
			"ModifiedBy"
		];
	}
}
