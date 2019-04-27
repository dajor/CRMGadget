package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.util.CacheUtils;
	import gadget.util.FieldUtils;
	
	import mx.collections.ArrayCollection;
	
	public class DivisionUserDAO extends SupportDAO {

		private var stmtUserSelect:SQLStatement;
		public function DivisionUserDAO(sqlConnection:SQLConnection, work:Function) {

			super(work, sqlConnection, {
				entity: [ 'Division' ,'User' ],
				id:     [ 'DivisionId', 'UserId' ],
				columns: TEXTCOLUMNS
			},{
				oracle_id:"Id",
				unique:['DivisionId,UserId,PickValueGroupId'],
				name_column:["DivisionName"],
				search_columns:["DivisionName"]
			});
			_isSyncWithParent = false;		
			
		}
		
	
		public function getPVGId():String{			
			var div:Object = getDefaultDivision();
			return div.DivisionId;
			
		}
		public function getDefaultDivision():Object{
			var cache_owner:CacheUtils = new CacheUtils("division_user");			
			var div:Object =cache_owner.get("currentpvg");
			if(div!=null){
				return div;
			}else{			
				var pvgs:ArrayCollection = findAll(new ArrayCollection([{element_name:"*"}]));
				if(pvgs!=null&& pvgs.length>0){
					div = pvgs.getItemAt(0);		
				}else{
					div = new Object();				
				}
				cache_owner.put("currentpvg",div);
				return div;
			}
		}
		public function setPVG(div:Object):void{
			var cache_owner:CacheUtils = new CacheUtils("division_user");			
			cache_owner.put("currentpvg",div);
		}
		

		override protected function getIncomingIgnoreFields():ArrayCollection{			
			return new ArrayCollection(["PickValueGroupId","PickValueGroupFullName" ]);
		}
		private const TEXTCOLUMNS:Array = [
			"ModifiedDate",
			"CreatedDate",
			"ModifiedById",
			"CreatedById",
			"ModId",
			"Id",
			"UserId",
			"FirstName",
			"LastName",
			"LoginName",
			"FullName",
			"IsPrimary",
			"PickValueGroupId",
			"PickValueGroupFullName",
			"DivisionId",
			"DivisionName",			
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