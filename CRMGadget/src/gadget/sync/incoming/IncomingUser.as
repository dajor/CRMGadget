package gadget.sync.incoming
{
	import flash.events.Event;
	
	import gadget.dao.Database;
	import gadget.dao.UserDAO;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	import gadget.sync.task.SyncTask;

	
	public class IncomingUser extends SyncTask {
		
		protected var ns1:Namespace = new Namespace("urn:crmondemand/ws/currentuser/");
		protected var ns2:Namespace = new Namespace("urn:/crmondemand/xml/currentuser");
		
		override protected function doRequest():void {
			var request:XML =
                <CurrentUserWS_CurrentUserQueryPage_Input xmlns='urn:crmondemand/ws/currentuser/'>
                    <ListOfCurrentUser>
                        <CurrentUser>
                            <UserId/>
                            <Alias/>
                        	<UserSignInId/>
                        </CurrentUser>                    
                    </ListOfCurrentUser>
                </CurrentUserWS_CurrentUserQueryPage_Input>;
			sendRequest("\"document/urn:crmondemand/ws/currentuser/:CurrentUserQueryPage\"", request);
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
			nextPage(true);
			return cnt;
 		}
 		
		override public function getEntityName():String {
			return "User";
		}
		
		override public function getName():String {
			return "Receiving user updates from server..."; 
		}
		
	}
}