// semi-automatically generated from Book.wsdl
package gadget.dao
{
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;

	public class BookDAO extends BaseDAO {

		private var stmtSelectDefault:SQLStatement;
		public function BookDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'sod_book',
				oracle_id: 'Id',
				name_column: [ 'Id' ],	//___EDIT__THIS___
				search_columns: [ 'Id' ],	//___EDIT__THIS___
				display_name : "Book",	//___EDIT__THIS___
				index: [ 'Id' ],
				columns: { 'TEXT' : textColumns }
			});
			stmtSelectDefault=new SQLStatement();
			stmtSelectDefault.text = "select * from sod_book where BookName=:BookName";
			stmtSelectDefault.sqlConnection=sqlConnection;
		}

		override public function get entity():String {
			return "Book";
		}
		protected override function getIndexColumns():Array{
			return ["deleted", "local_update" ];			
			
		}
		
		
		public function getDefaultBookId():String{
			var owner:Object = Database.allUsersDao.ownerUser();
			stmtSelectDefault.parameters[":BookName"]=owner.DefaultBookName;
			exec(stmtSelectDefault);
			var result:SQLResult = stmtSelectDefault.getResult();
			if(result==null){
				return null;
			}
			var datas:Array = result.data;
			if(datas!=null && datas.length>0){
				var obj:Object = datas[0];
				return obj.Id;
			}
			return null;
		}
		
		private var textColumns:Array = [
			"BookName",
			"BookType",
			"CanContainDataFlag",
			"CreatedBy",
			"CreatedByAlias",
			"CreatedByEMailAddr",
			"CreatedByExternalSystemId",
			"CreatedByFirstName",
			"CreatedByFullName",
			"CreatedById",
			"CreatedByIntegrationId",
			"CreatedByLastName",
			"CreatedByUserSignInId",
			"CreatedDate",
			"Description",
			"Id",
			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"ParentBookId",
			"ParentBookName",
			"PartnerChannelAccountManagerAlias",
			"PartnerExternalSystemId",
			"PartnerId",
			"PartnerIntegrationId",
			"PartnerLocation",
			"PartnerName",
			"UpdatedByAlias",
			"UpdatedByEMailAddr",
			"UpdatedByExternalSystemId",
			"UpdatedByFirstName",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			];
	}
}
