package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	public class UserDAO extends SimpleTable {
		
		public function UserDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table:"user",
				unique : ["id, full_name"],
				columns: {
					'TEXT' : [ 'id','full_name', 'user_sign_in_id', 'Avatar' ]
				}
			});		
			
		}

		//VAHI MyXXXX filter bugfix
		public function deleteAll():void
		{
			delete_all();
		}
		
		
		public function find(user:Object):Object
		{
			var result:Array = fetch({id:user.id});
			return result.length == 0?null:result[0]; 
			
		}
		
		private var user:Object;
		
		public function setUser(user:Object):void{
			this.user = user;
		}
		public function read():Object
		{
			if(user ==null){
				var result:Array = fetch();
				user =  (result.length == 0?null:result[0]);
			}
			return user;
		}
		
	}
}