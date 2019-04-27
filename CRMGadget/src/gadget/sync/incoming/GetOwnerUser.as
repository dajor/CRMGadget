package gadget.sync.incoming
{
	import gadget.dao.Database;
	import gadget.dao.UserDAO;
	import gadget.sync.task.TaskParameterObject;
	
	
	public class GetOwnerUser extends IncomingUser {
		
		
		public var completeHandler:Function = null;
		public var sessionId:String;
		
		public function GetOwnerUser(completeHandler:Function, sessionId:String) {
			this.completeHandler = completeHandler;
			this.sessionId = sessionId;
		}	
		
		override protected function handleResponse(request:XML, result:XML):int {
			
			var userDao:UserDAO = Database.userDao;
			var cnt:int = 0;
			Database.begin();
			
			for each(var user:XML in result.ns2::ListOfCurrentUser[0].ns2::CurrentUser) {
				var tmpUser:Object = new Object();
				
				tmpUser.id = user.ns2::UserId[0].toString();
				tmpUser.full_name = user.ns2::Alias[0].toString();
				tmpUser.user_sign_in_id = user.ns2::UserSignInId[0].toString();
				
				userDao.deleteAll();
				userDao.insert(tmpUser);
				userDao.setUser(tmpUser);
				cnt++;
			}
			
			Database.commit();
			
			var incoming:GetOwnerUserData = new GetOwnerUserData(completeHandler, sessionId);
			var _param2:TaskParameterObject = new TaskParameterObject(incoming);
			_param2.preferences = param.preferences;
			incoming.param = _param2;
			incoming.requestCall();			
			// nextPage(false);
			return cnt;
		}
		
		override protected function nextPage(lastPage:Boolean, minRow:int=0, mustBeSame:String=''):void {
				
		}
		
	}
}