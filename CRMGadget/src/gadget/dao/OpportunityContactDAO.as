package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.utils.Dictionary;
	
	import gadget.util.StringUtils;
	
	public class OpportunityContactDAO extends SupportDAO
	{
		public function OpportunityContactDAO(work:Function, sqlConnection:SQLConnection)
		{
			super(work, sqlConnection, {
				sodName: 'ContactRole',
				entity: [ 'Opportunity',   'ContactRole'   ],
				id:     [ 'Id' ],
				columns: TEXTCOLUMNS
				
			},{
				record_type:"ContactRole",
				unique:['OpportunityId,ContactId'],
				oracle_id:"Id",	
				name_column:["ContactFirstName"],
				search_columns:["ContactFirstName"],
				columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" }}
			});
			_isGetField = true;
			_isSyncWithParent = false;
			_isSelectAll = true;
		}
		public override function getLinkFields():Dictionary{
			var fields:Dictionary = new Dictionary();
			
			fields["ContactLastName"]=Database.contactDao.entity;
			return fields;
			
		}
		
		override public function get metaDataEntity():String{
			return "Opportunity Contact Role";
		}
		override public function getLayoutFields():Array{
			var layoutFields:Array = [
				{data_type:"Text (Short)",display_name:"First Name",element_name:"ContactFirstName",entity:this.entity,required:true},
				{data_type:"Text (Short)",display_name:"Last Name",element_name:"ContactLastName",entity:this.entity,required:true},
				{data_type:"Picklist",display_name:"Buying Role",element_name:"BuyingRole",entity:this.entity,required:true}
			];
			return layoutFields;
		}
		private var TEXTCOLUMNS:Array=[
			"ModifiedDate",
			"CreatedDate",
			"ModifiedById",
			"CreatedById",
			"ModId",
			"Id",
			"ContactExternalSystemId",
			"OpportunityExternalSystemId",
			"CreatedBy",
			"ContactId",
//			"Primary",
			"BuyingRole",
			"ContactLastName",
			"ContactFirstName",
			"OpportunityId",
			"OpportunityName",
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
			"ModifiedBy"
		];
	}
}