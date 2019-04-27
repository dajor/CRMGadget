package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class RelatedContactDAO extends SupportDAO
	{
		
		private var stmtDeleteByRelatedContactId:SQLStatement = null;
		public function RelatedContactDAO(sqlConnection:SQLConnection, work:Function) {
			
			super(work, sqlConnection, {
				entity: [ 'Contact','Related'   ],
				id:     [ 'Id' ],
				columns: TEXTCOLUMNS
			},{				
				name_column:["RelatedContactFirstName","RelatedContactLastName"],
				oracle_id:"Id",
				unique:['Id'],
				search_columns:["RelatedContactFirstName","RelatedContactLastName"],
				record_type:"ContactRelationship",
				clean_table:true,
				columns: { DummySiebelRowId:{type:"TEXT", init:"gadget_id" } }
			
			
			});
			stmtDeleteByRelatedContactId = new SQLStatement();
			stmtDeleteByRelatedContactId.text = "DELETE FROM  contact_related WHERE ContactId = :ContactId";
			stmtDeleteByRelatedContactId.sqlConnection = sqlConnection;
			_isSyncWithParent = false;
			_isSelectAll = false;
			_isGetField = true;
		}
		
		
		public function deleteByRelatedContactId(relatedContactId:String):void{
			stmtDeleteByRelatedContactId.parameters[":ContactId"] = relatedContactId;
			exec(stmtDeleteByRelatedContactId);
		}
		
		override protected function getIncomingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["ContactId","RelatedContactFullName"]);
		}
		
		override protected function getOutgoingIgnoreFields():ArrayCollection{
			return new ArrayCollection(["ContactId",
				"RelatedContactFullName",
				"RelatedContactFirstName",
				"RelatedContactLastName",
				"RelatedContactExternalId"
			]);
		}
		override public function getLayoutFields():Array{
			var layoutFields:Array = [
				{data_type:"Picklist",display_name:"Related Contact",element_name:"RelatedContactFullName",entity:this.entity,required:true},				
				{data_type:"Picklist",display_name:"Role",isCustom:true,element_name:"RelationshipRole",entity:this.entity,required:true},
				{data_type:"Picklist",display_name:"Reverse Role",isCustom:true,element_name:"ReverseRelationshipRole",entity:this.entity,required:true},
				{data_type:"Date",display_name:"Start Date",element_name:"StartDate",entity:this.entity,required:false},
				{data_type:"Date",display_name:"End Date",element_name:"EndDate",entity:this.entity,required:false},
				{data_type:"Picklist",display_name:"Status",isCustom:true,element_name:"RelationshipStatus",entity:this.entity,required:false},
				{data_type:"Text (Long)",display_name:"Description",element_name:"Description",entity:this.entity,required:false}
				
			];
			return layoutFields;
		}
		
		private const TEXTCOLUMNS:Array = [
			"CreatedBy",
			"CreatedByAlias",
			"CreatedByEMailAddr",
			"CreatedByExternalSystemId",
			"CreatedByFirstName",
			"CreatedByFullName",
			"CreatedByIntegrationId",
			"CreatedByLastName",
			"CreatedByUserSignInId",
			"CreatedDate",
			"Description",
			"EndDate",
			"Id",
			"ModifiedBy",
			"ModifiedDate",
			"RelatedContactFirstName",
			"RelatedContactLastName",
			"RelatedContactFullName",
			"RelationshipRole",
			"RelationshipStatus",
			"ReverseRelationshipRole",
			"StartDate",
			"UpdatedByAlias",
			"UpdatedByEMailAddr",
			"UpdatedByExternalSystemId",
			"UpdatedByFirstName",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			"ContactId"
		];
	}
}
