package gadget.chatclient
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.setInterval;
	
	import gadget.dao.Database;
	import gadget.util.FeedUtils;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	import org.igniterealtime.xiff.conference.InviteListener;
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.Browser;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.disco.ItemDiscoExtension;
	import org.igniterealtime.xiff.data.im.RosterGroup;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.events.ConnectionSuccessEvent;
	import org.igniterealtime.xiff.events.DisconnectionEvent;
	import org.igniterealtime.xiff.events.IncomingDataEvent;
	import org.igniterealtime.xiff.events.InviteEvent;
	import org.igniterealtime.xiff.events.LoginEvent;
	import org.igniterealtime.xiff.events.MessageEvent;
	import org.igniterealtime.xiff.events.OutgoingDataEvent;
	import org.igniterealtime.xiff.events.PresenceEvent;
	import org.igniterealtime.xiff.events.RegistrationFieldsEvent;
	import org.igniterealtime.xiff.events.RegistrationSuccessEvent;
	import org.igniterealtime.xiff.events.RoomEvent;
	import org.igniterealtime.xiff.events.RosterEvent;
	import org.igniterealtime.xiff.events.VCardEvent;
	import org.igniterealtime.xiff.events.XIFFErrorEvent;
	import org.igniterealtime.xiff.im.Roster;
	import org.igniterealtime.xiff.vcard.VCard;
	import org.igniterealtime.xiff.vcard.VCardPhoto;

	public class CRMXAMPPConnection extends EventDispatcher
	{
		
		private static var crmXMPPConnection:CRMXAMPPConnection;
		
		private static var _connection:XMPPConnection;
		private var _inviteListener:InviteListener;
		private var _roster:Roster;
		private static var _room:Room;
		
		private var _server:String;
		private var _port:uint;
		
		private var _username:String;
		private var _password:String;
		private var _roomname:String = "";
		
		private var _rooms:Array;
		private var _users:Array;
		
		private var _isRegisterUser:Boolean = false;
		private var _registrationData:Object;
		
		public var appendLog:Function;
		public var fnRefresh:Function;
		
		public function get rooms():Array {
			return _rooms;
		}
		
		public function get users():Array {
			return _users;
		}
		
		public function get roster():Roster {
			return _roster;
		}
		
		public function get room():Room {
			return _room;
		}
		
		public function get connection():XMPPConnection {
			return _connection;
		}
		
		public function set isRegisterUser(value:Boolean):void {
			_isRegisterUser = value;
		}
		
		public function isValidJID( jid:EscapedJID ):Boolean{
			var value:Boolean = false;
			var pattern:RegExp = /(\w|[_.\-])+@(localhost$|((\w|-)+\.)+\w{2,4}$){1}/;
			var result:Object = pattern.exec( jid.unescaped.toString() );
			if( result )
			{
				value = true;
			}
			return value;
		}
		
		public static function getInstance():CRMXAMPPConnection {
			if(crmXMPPConnection == null) crmXMPPConnection = new CRMXAMPPConnection();
			return crmXMPPConnection;
		}
		
		public function CRMXAMPPConnection() {}
		
		public function setupChat(server:String, port:uint):void {
			_server = server;
			_port = port;
			setupConnection();
			setupRoster();
			setupInviteListener();
			setupRoom();
			
			var followers:Array = Database.feedFollowerDAO.fetch();
			if(followers.length == 0){
				_roster.fetchRoster();
				_roster.removeAll();
			}
			
		}
		
		private function setupConnection():void{
			_connection = new XMPPConnection();
			
			_connection.domain = _server;
			_connection.server = _server;
			_connection.port = _port;
			
			_connection.addEventListener( ConnectionSuccessEvent.CONNECT_SUCCESS, onConnectSuccess );
			_connection.addEventListener( DisconnectionEvent.DISCONNECT, onDisconnect );
			_connection.addEventListener( LoginEvent.LOGIN, onLogin );
			_connection.addEventListener( XIFFErrorEvent.XIFF_ERROR, onXIFFError );
			_connection.addEventListener( OutgoingDataEvent.OUTGOING_DATA, onOutgoingData )
			_connection.addEventListener( IncomingDataEvent.INCOMING_DATA, onIncomingData );
			_connection.addEventListener( RegistrationFieldsEvent.REG_FIELDS, onRegistrationFields );
			_connection.addEventListener( RegistrationSuccessEvent.REGISTRATION_SUCCESS, onRegistrationSuccess );
			_connection.addEventListener( PresenceEvent.PRESENCE, onPresence );
			_connection.addEventListener( MessageEvent.MESSAGE, onMessage );
		}
		
		private function setupRoster():void {
			_roster = new Roster();
			_roster.addEventListener( RosterEvent.ROSTER_LOADED, onRosterLoaded );
			_roster.addEventListener( RosterEvent.SUBSCRIPTION_DENIAL, onSubscriptionDenial );
			_roster.addEventListener( RosterEvent.SUBSCRIPTION_REQUEST, onSubscriptionRequest );
			_roster.addEventListener( RosterEvent.SUBSCRIPTION_REVOCATION, onSubscriptionRevocation );
			_roster.addEventListener( RosterEvent.USER_ADDED, onUserAdded );
			_roster.addEventListener( RosterEvent.USER_AVAILABLE, onUserAvailable );
			_roster.addEventListener( RosterEvent.USER_PRESENCE_UPDATED, onUserPresenceUpdated );
			_roster.addEventListener( RosterEvent.USER_REMOVED, onUserRemoved );
			_roster.addEventListener( RosterEvent.USER_SUBSCRIPTION_UPDATED, onUserSubscriptionUpdated );
			_roster.addEventListener( RosterEvent.USER_UNAVAILABLE, onUserUnavailable );
			_roster.connection = _connection;
		}
		
		private function setupInviteListener():void {
			_inviteListener = new InviteListener();
			_inviteListener.addEventListener( InviteEvent.INVITED, onInvited );
			_inviteListener.connection= _connection;
		}
		
		private function setupRoom():void {
			_room = new Room();
			addRoomListeners();
		}
		
		private function addRoomListeners():void {
			_room.addEventListener( RoomEvent.GROUP_MESSAGE, onGroupMessage, false, 0, true );
			_room.addEventListener( RoomEvent.ADMIN_ERROR, onAdminError, false, 0, true );
			_room.addEventListener( RoomEvent.ROOM_JOIN, onRoomJoin, false, 0, true );
			_room.addEventListener( RoomEvent.ROOM_LEAVE, onRoomLeave, false, 0, true );
			_room.addEventListener( RoomEvent.SUBJECT_CHANGE, onSubjectChange, false, 0, true );
			_room.addEventListener( RoomEvent.USER_DEPARTURE, onUserDeparture, false, 0, true );
			_room.addEventListener( RoomEvent.USER_JOIN, onUserJoin, false, 0, true );
			_room.addEventListener( RoomEvent.USER_KICKED, onUserKick, false, 0, true );
			_room.addEventListener( RoomEvent.USER_BANNED, onUserBanned, false, 0, true );
		}
		
		public function connect(userDTO:Object=null):void {
			Security.loadPolicyFile("xmlsocket://" + _server + ":" + _port);
			Security.loadPolicyFile("http://" + _server + "/crossdomain.xml" );
			if(userDTO){
				_username = userDTO.username;
				_password = userDTO.password;
			}else{
				_username = null;
				_password = null;
			}
			_connection.username = _username;
			_connection.password = _password;
			_connection.connect();
		}
		
		public function disconnect():void {
			_isRegisterUser = false;
			// SKH: fixed Bug #1726
			if(_connection){
				_connection.disconnect();
			}			
		}
		
		public function updatePresence( show:String, status:String ):void {
			_roster.setPresence( show, status, 0 );
		}
		
		public function addFollower( _jid:UnescapedJID ):void {
			var followerGroup:RosterGroup = _roster.getGroup("Follower");
			var rosterItem:RosterItemVO = RosterItemVO.get( _jid );
			if( followerGroup && !followerGroup.contains( rosterItem ) ){
				_roster.addContact( _jid, _jid.toString(), "Follower", false );
			}
			if( followerGroup == null ){
				_roster.addContact( _jid, _jid.toString(), "Follower", false );
			}
		}
		
		public function removeFollower( _jid:UnescapedJID ):void {
			var rosterItem:RosterItemVO = RosterItemVO.get( _jid );
			var followerGroup:RosterGroup = _roster.getGroup("Follower");
			if( followerGroup && followerGroup.contains( rosterItem ) ){
//				_roster.removeContact(rosterItem);
				followerGroup.removeItem( rosterItem );
			}
		}
		
		public function addFollowing( item:Object ):void {
			var _jid:UnescapedJID = getJID(item.Id);
			var rosterItem:RosterItemVO = RosterItemVO.get( _jid );
			var followingGroup:RosterGroup = _roster.getGroup("Following");
			if( followingGroup && !followingGroup.contains( rosterItem ) ){
				_roster.addContact( _jid, _jid.toString(), "Following" );
				Database.feedUserDAO.replace(item);
			}
			if( followingGroup == null ){
				_roster.addContact( _jid, _jid.toString(), "Following" );
				Database.feedUserDAO.replace(item);
			}
		}
		
		public function removeFollowing(jid:String):void {
			jid = jid.toLowerCase();
			var _jid:UnescapedJID = getJID(jid);
			var rosterItem:RosterItemVO = RosterItemVO.get( _jid );
			var followingGroup:RosterGroup = _roster.getGroup("Following");
			
			if(followingGroup != null)
			trace("rosterItem in FollowingGroup ", followingGroup.contains(rosterItem));
			
			var followerGroup:RosterGroup = _roster.getGroup("Follower");
			if(followerGroup != null)
			trace("rosterItem in FollowerGroup ", followerGroup.contains(rosterItem));
			
			if( followingGroup && followingGroup.contains( rosterItem ) ){
				Database.feedUserDAO.delete_({Id:jid.toUpperCase()});
//				_roster.removeContact( rosterItem );
				followingGroup.removeItem( rosterItem );
			}
		}
		
		
		
		public function register(userDTO:Object):void {
			_isRegisterUser = true;
			_registrationData = userDTO;
			connect();
		}
		
		//Connection Events
		private function onConnectSuccess(event:ConnectionSuccessEvent):void {
			if(_isRegisterUser){
				_connection.sendRegistrationFields( _registrationData, null );
			}
			dispatchEvent(event); 
		}
		
		private function onDisconnect(event:DisconnectionEvent):void {
			connect(_registrationData);
			dispatchEvent(event); 
		}
		
		private function onLogin(event:LoginEvent):void {
			fnReJoinRoom();
			dispatchEvent(event);
		}
		
		public function jointRoomName(name:String):void {
			disconnect();
			_roomname = name;
		}
		
		public function fnReJoinRoom():void {
			_room.roomJID = new UnescapedJID( _roomname + "@conference." + _server );
//			_room.roomJID = new UnescapedJID( _roomname + "@" + _server );
			_room.roomName = _roomname;
			_room.connection = _connection;
			_room.join();
		}
	
		public function getRooms(control:DisplayObject):void {
			var conferenceServer:String = "conference." + _server;
//			var conferenceServer:String = _server;
			var server:EscapedJID = new EscapedJID( conferenceServer );
			var browser:Browser = new Browser( _connection );
			browser.getServiceItems( server, function( iq:IQ ):void {
				var extensions:Array = iq.getAllExtensions();
				var disco:ItemDiscoExtension = extensions.length > 0 ? extensions[ 0 ] : null;
				if( disco )
				{
					_rooms = disco.items.concat();
					if(control is ComboBox){
						(control as ComboBox).dataProvider = _rooms;
						(control as ComboBox).labelField = 'name';
					}
				}
			});
		}
		
		public function getUsersInRoom(roomName:String):void {
			var server:EscapedJID = new EscapedJID( roomName );
			var browser:Browser = new Browser( _connection );
			browser.getServiceItems( server, callbackGetUsersInRoom );
		}
		
		private function callbackGetUsersInRoom( iq:IQ ):void {
			var extensions:Array = iq.getAllExtensions();
			var disco:ItemDiscoExtension = extensions.length > 0 ? extensions[ 0 ] : null;
			
			if( disco )
			{
				_users = disco.items.concat();
			}
			trace(_users);
		}		
		
		private function getJID(jid:String):UnescapedJID {
			return new UnescapedJID( jid + "@" + _server );
		}
		
		public function setAvatar(binData:String, imageType:String):void {
			var type:String = "image/" + imageType;
			var avatar:VCardPhoto = new VCardPhoto(type,binData );
			var vcard:VCard = new VCard();
			vcard.jid = getJID(_registrationData.username);
			vcard.photo = avatar;
			vcard.description = _registrationData.id;
			vcard.addEventListener(VCardEvent.SAVE_ERROR, function(event:VCardEvent):void {
				trace("VCard SaveError");
			});
			vcard.addEventListener(VCardEvent.SAVED, function(event:VCardEvent):void {
				trace("VCard Saved");
			});
			vcard.saveVCard(connection);
		}
		
		public function getAvatar(jid:String, chatClientControl:ChatClientControl):void {
			var vcard:VCard = VCard.getVCard(connection, getJID(jid) );
			vcard.addEventListener(VCardEvent.LOADED, function(event:VCardEvent):void {
				trace("VCard Loaded");
				var binaryValue:String = vcard.photo == null ? "" : vcard.photo.binaryValue;
				Database.feedUserDAO.update( {'Avatar':binaryValue},{'Id':jid} );
				chatClientControl.reloadData();
			});
		}
		
		private function onXIFFError(event:XIFFErrorEvent):void { dispatchEvent(event); }
		
		private function onOutgoingData(event:OutgoingDataEvent):void { dispatchEvent(event); }
		
		private function onIncomingData(event:IncomingDataEvent):void { dispatchEvent(event); }
		
		private function onRegistrationFields(event:RegistrationFieldsEvent):void { dispatchEvent(event); }
		
		private function onRegistrationSuccess(event:RegistrationSuccessEvent):void { disconnect(); dispatchEvent(event); }
		
		private function onPresence(event:PresenceEvent):void { dispatchEvent(event); }
		
		private function onMessage(event:MessageEvent):void { dispatchEvent(event); }
		
		//Roster Events
		private function onRosterLoaded( event:RosterEvent ):void {
			trace("Roster Loaded");
			dispatchEvent( event ); 
		}
		
		private function onSubscriptionDenial( event:RosterEvent ):void { dispatchEvent( event ); }
		
		private function onSubscriptionRequest( event:RosterEvent ):void {
			trace("Roster Subscription Request");
			if( !_roster.contains( RosterItemVO.get( event.jid ) ) ){
				_roster.grantSubscription( event.jid );
				var columns:ArrayCollection = new ArrayCollection([
					{'element_name': 'Id'},
					{'element_name': 'MrMrs'},
					{'element_name': 'FirstName'},
					{'element_name': 'LastName'},
					{'element_name': 'Alias'},
					{'element_name': 'JobTitle'},
					{'element_name': 'EMailAddr'},
					{'element_name': 'PhoneNumber'},
					{'element_name': 'Department'}
				]);
				var filter:String = "Id = '" + event.jid.node.toUpperCase() + "'";
				var results:ArrayCollection = Database.allUsersDao.filter( columns,filter );
				if( results.length > 0 ){
					var follower:Object = results.getItemAt(0);
					addFollower( event.jid );
					Database.feedFollowerDAO.replace( follower );	
				}
			}
			dispatchEvent( event );
		}
		
		private function onSubscriptionRevocation( event:RosterEvent ):void {
			trace("Roster Subscription Revocation");
			removeFollower( event.jid );
			Database.feedFollowerDAO.delete_( {'Id':event.jid.node.toUpperCase()} );
			if( fnRefresh != null ) fnRefresh();
			dispatchEvent( event ); 
		}
		
		private function onUserAdded( event:RosterEvent ):void {	
			dispatchEvent( event ); 
		}
		
		private function onUserAvailable( event:RosterEvent ):void { dispatchEvent( event ); }
		
		private function onUserPresenceUpdated( event:RosterEvent ):void { dispatchEvent( event ); }
		
		private function onUserRemoved( event:RosterEvent ):void {
			dispatchEvent( event ); 
		}
		
		private function onUserSubscriptionUpdated( event:RosterEvent ):void { dispatchEvent( event ); }
		
		private function onUserUnavailable( event:RosterEvent ):void { dispatchEvent( event ); }
		
		//Invite Event
		private function onInvited( event:InviteEvent ):void { dispatchEvent( event ); }
		
		//Room Event
		private function onGroupMessage( event:RoomEvent ):void {
			dispatchEvent(event);
		}

		private function onAdminError( event:RoomEvent ):void {
			var xiffErrorEvent:XIFFErrorEvent = new XIFFErrorEvent();
			xiffErrorEvent.errorCode = event.errorCode;
			xiffErrorEvent.errorCondition = event.errorCondition;
			xiffErrorEvent.errorMessage = event.errorMessage;
			xiffErrorEvent.errorType = event.errorType;
			dispatchEvent( xiffErrorEvent );
		}
		
		private function onRoomJoin( event:RoomEvent ):void {
			trace("onRoomJoin");
			dispatchEvent(event);
			FeedUtils.parseAndSendFeedHistory();
		}
		
		private function onRoomLeave( event:RoomEvent ):void {
			trace("onRoomLeave")
			dispatchEvent(event);
		}
		
		private function onSubjectChange( event:RoomEvent ):void {
			trace("onSubjectChange");
			dispatchEvent(event);
		}
		
		private function onUserDeparture( event:RoomEvent ):void {
			trace("onUserDeparture");
			dispatchEvent(event);
		}
		
		private function onUserJoin( event:RoomEvent ):void {
			trace("onUserJoin");
			dispatchEvent(event);
		}
		
		private function onUserKick( event:RoomEvent ):void {
			trace("onUserKick");
			dispatchEvent(event);
		}
		
		private function onUserBanned( event:RoomEvent ):void {
			trace("onUserBanned");
			dispatchEvent(event);
		}
		
		public function sendMessage(message:String):void {
			if( message.length > 0 ) {
				_room.sendMessage( message );
			}
		}
		
	}
}