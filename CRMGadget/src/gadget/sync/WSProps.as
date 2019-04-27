//VAHI WS2.0 binding.
// To ease refactoring, search for use of those routines here.
// Then you have all the pieces where WS2.0 was hacked into the app.
// THIS MODULE SHALL VANISH WHEN WS1.0 IS NO MORE SUPPORTED/USED
// SO EVERYTHING YOU SEE HERE IS DUE TO HACKS AND UNFINISHED THINGS.
package gadget.sync
{
	import gadget.dao.Database;
	import gadget.util.Hack;
	import gadget.util.ObjectUtils;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.util.StringUtils;

	public class WSProps
	{




	
		/** Tells if this filter is a special WS20 filter or not.
		 * For GUI Preferences usage.
		 * If transaction is given, it is checked if transaction is enabled in PreferenceDAO, too.
		 * 
		 * @param filt filter_id, <=0 are builtin, >0 are user defined
		 * @return Boolean false if transaction given and transaction WS20 enabled, else true if filter is special WS20 filter, else false
		 */
		public static function isWS20filter(filt:int):Boolean {
			return (filt<=-10);
		}


		// Is there something like a bi-directional relation in MX?
		// With an easy syntax to write?
		// Or some cache object with a way to populate it?

		//VAHI translate object: WS1.0-Name:"WS2.0Name" ...
		// This shall be migrated to SodUtils.fieldsToFix for each object which is WS2.0 only
		private static const TRANSLATE_FIELD:Object = {
			_: {
				CreatedbyEmailAddress:'CreatedByEMailAddr',
				ModifiedbyEmailAddress: 'UpdatedByEMailAddr'
			},
			Account: {
				OriginatingPartnerName: 'OriginatingPartnerPartnerName',
				OwnerPartnerName: 'OwnerPartnerPartnerName',
				PartnerOrgStatus: 'PartnerStatus',
				PrincipalPartnerName: 'PrincipalPartnerPartnerName',
//				PrincipalPartnerChannelManagerAlias: 'PrincipalPartnerChannelAccountManagerAlias',
				AccountId:'Id'
			},
			Activity: {
				ApplicationApplicationUID: 'ApplicationUID',
				DealRegistrationDealRegistrationName: 'DealRegistrationName',
				MedEdEventExternalSystemId: 'MedEdExternalSystemId',
				MedEdEventId: 'MedEdId',
				MedEdEventName: 'MedEdName',
				PromotionalItemDroppedCount: 'PromItemsDroppedCount',
				SPRequestSPRequestName: 'SPRequestName',
				ActivityId:'Id',
				Owner:'Alias'
			},
			Campaign: {
				LastUpdated: 'ModifiedDateExt',	//VAHI really unsure, no better candidate found
				CampaignId:'Id'
			},
			Contact: {
				OccamTerritory: 'Territory',
				ContactId:'Id'
			},
			//VAHI20101113 for Transition of CustomObject1DAO from WS1.0 to WS2.0 following hack must vanish
			"Custom Object 1": {
				CustomObject1Id:'Id'	//VAHI warning: There is a CustomObject1Id, but it probably is the wrong one
			},
			//CustomObject2 already is WS2.0 (not from GetFields)
			Lead: {
				ChannelAccountManager: 'OriginatingPartnerId',	//VAHI REALLY UNSURE!
				LastUpdated: 'ModifiedDateExt',					//VAHI really unsure, no better candidate found
				OriginatingPartnerChannelManagerAlias: 'OriginatingPartnerChannelAccountManagerAlias',
				OriginatingPartnerName: 'OriginatingPartnerPartnerName',
				PrincipalPartnerChannelManagerAlias: 'PrincipalPartnerChannelAccountManagerAlias',
				PrincipalPartnerName: 'PrincipalPartnerPartnerName',
				LeadId:'Id'
			},
			Opportunity: {
				CreatedByEmailAddress: 'CreatedByEMailAddr',
				ModifiedByEmailAddress: 'UpdatedByEMailAddr',
				ApprovedDRExpiresDate: 'ApprovedDRExpirationDeate',	//VAHI WTF?
				ApprovedDRId: 'ApprovedDRID',
				ApprovedDRPartnerId: 'ApprovedDRPartnerID',
				ApproverAlias: 'Approver',
				ChannelAccountManager: 'OwnerPartnerAccountChannelManagerAlias',	//VAHI really not sure
				OriginatingPartnerName: 'OriginatingPartnerPartnerName',
				PrincipalPartnerName: 'PrincipalPartnerPartnerName',
				ProgramProgramName: 'ProgramName',
				OpportunityId:'Id'
			},
			Product: {
				CreatedByDate: 'CreatedDate',
				ModifiedByDate: 'ModifiedDate',
				ProductId:'Id'
			},
			"Service Request": {
				LastUpdated: 'ModifiedDateExt',	//VAHI really unsure, no better candidate found
				ServiceRequestId:'Id'
			},
			Asset:{
				OwnerAccountId: 'AccountId'
			},
			MedEdEvent:{
				MedEdId: 'Id'
			},
			'Division.User':{'IsPrimary':'Primary'}
			
		};
		
		public static var cache:Object = {};
		
		//VAHI translate WS2.0 field names to the one used for
		// WS1.0, this application and other APIs
		public static function ws20to10(entitySod:String, field:String):String {
			if (!(entitySod in cache))
				cache[entitySod]	= {};
			else if (field in cache[entitySod])
				return cache[entitySod][field];

			function huntfor(ob:Object):String {
				for (var s:String in ob)
					if (ob[s]==field)
						return s;
				return null;
			}

			var res:String	= (entitySod in TRANSLATE_FIELD) ? huntfor(TRANSLATE_FIELD[entitySod]) : null;
			if (res==null)
				res = huntfor(TRANSLATE_FIELD._);
			if (res==null)
				res = field;
			cache[entitySod][field]	= res;
			return res;
		}
		
		//VAHI translate WS1.0 (application and mapping) field names to the
		// WS2.0 name (which might differ a lot)
		public static function ws10to20(entitySod:String, field:String):String {
//			if (! (entity in translate)) throw("OOPS "+entity);
			if (entitySod in TRANSLATE_FIELD && field in TRANSLATE_FIELD[entitySod])
				return TRANSLATE_FIELD[entitySod][field];
			if (field in TRANSLATE_FIELD._)
				return TRANSLATE_FIELD._[field];
			return field;
		}
	}
}
