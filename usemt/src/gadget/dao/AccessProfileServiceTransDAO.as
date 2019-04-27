package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.service.LocaleService;
	
	import mx.collections.ArrayCollection;
	
	public class AccessProfileServiceTransDAO extends SimpleTable {
		private var stmtSelectContactAccess:SQLStatement;
		public function AccessProfileServiceTransDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "access_profile_trans",
				unique: [ 'AccessProfileServiceName,LanguageCode' ],
				index:[]
			});
			
			stmtSelectContactAccess=new SQLStatement();
			stmtSelectContactAccess.sqlConnection=sqlConnection;
			
						
			
		}
		
		
		
		override public function getColumns():Array {
			return [
				'AccessProfileServiceName',
				'LanguageCode',
				'Title',
				'Description'
			];
		}
	}
}
