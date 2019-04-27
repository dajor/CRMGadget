package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	public class RegisteredUserDAO extends SimpleTable {
		
		public function RegisteredUserDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table:"registered_user",
				unique : ["username, roomname"],
				columns: {
					'TEXT' : [ 'username', 'password', 'roomname' ]
				}
			});		
			
		}
		
		public function find(user:Object):Object
		{
			var result:Array = fetch({username:user.username,roomname:user.roomname});
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