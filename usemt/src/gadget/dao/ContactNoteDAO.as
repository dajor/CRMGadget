package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class ContactNoteDAO extends SupportDAO
	{
		public function ContactNoteDAO(work:Function, sqlConnection:SQLConnection)
		{
			super(work, sqlConnection, {
				
				entity: ['Contact',   'Note'],
				id:     ['Id' ],
				columns: TEXTCOLUMNS
			}
				,{
					record_type:"Contact Note",
					unique:['Id'],
					clean_table:true,
					must_drop :true,
					name_column:["Subject"],
					search_columns:["Subject"],
					oracle_id:"Id",		//VAHI's not so evil kludge
					columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
				});
			_isSyncWithParent = false;
			_isGetField = true;
		}
		
		override public function getLayoutFields():Array{
			var layoutFields:Array = [
				{data_type:"Checkbox",display_name:"Private",element_name:"Private",entity:this.entity,required:false},
				{data_type:"Text (Short)",display_name:"Subject",element_name:"Subject",entity:this.entity,required:true},
				{data_type:"Text (Long)",display_name:"Description",element_name:"Description",entity:this.entity,required:false}
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
			"CreatedBy",
			"ContactId",
			"Subject",
			"Private",
			"CreatedByName",
			"IntegrationId",
			"ExternalSystemId",
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
			"CreatedByFullName",
			"CreatedByIntegrationId",
			"CreatedByExternalSystemId",
			"CreatedByEMailAddr",
			"ModifiedBy",
			"Description"		
			
		];
		
	}
}