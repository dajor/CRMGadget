package gadget.util
{
	import gadget.chatclient.CRMXAMPPConnection;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	
	import mx.collections.ArrayCollection;
	
	import org.igniterealtime.xiff.events.RoomEvent;

	public class FeedUtils
	{
		
		private static var rooms2joint:ArrayCollection;
		private static var rooms2jointIndex:int = 0;
		
		public function FeedUtils(){}
		
		private static function getRoomsToJoint():ArrayCollection {
			var rooms:ArrayCollection = new ArrayCollection;
			var currentUser:Object = Database.currentUserDAO.getCurrentUser();
			if( currentUser ) rooms.addItem(currentUser.Id); //create a room for the current user.
			
			var feedEntities:ArrayCollection = Database.feedEntityDAO.select_distinct_feed_entities();
			for each(var feedEntity:Object in feedEntities){
				if( !StringUtils.isEmpty(feedEntity.OwnerId) ){
					var roomName:String = feedEntity.OwnerId + "_" + feedEntity.Entity;
					trace(roomName);
					rooms.addItem(roomName);
				}
			}

			return rooms;
		}
		
		public static function getRoomsToJoint2():ArrayCollection {
			var rooms:ArrayCollection = new ArrayCollection;
			var enabledFeeds:ArrayCollection = Database.feedDAO.getEnabledFeeds();
			var feedEntities:ArrayCollection = Database.feedEntityDAO.select_feed_entities();
			for each(var enabledFeed:Object in enabledFeeds){
				var entity:String = enabledFeed.entity;
				for each(var feedEntity:Object in feedEntities){
					if( !StringUtils.isEmpty(feedEntity.OwnerId) ){
						var roomName:String = feedEntity.OwnerId + "_" + entity;
						rooms.addItem({name:roomName,jid:roomName + "@conference.jabber.fellow-consulting.de"});
					}
				}
			}
			return rooms;
		}
		
		public static function refreshRooms():void {
			rooms2joint = FeedUtils.getRoomsToJoint();
			rooms2jointIndex = 0;
		}
		
		public static function getRoomName():String {
			if( rooms2joint.length == 0 ) return "";
			if( rooms2jointIndex > rooms2joint.length-1 ){
				rooms2jointIndex = 0;
			}
			var roomName:String = rooms2joint.getItemAt(rooms2jointIndex) as String;
			rooms2jointIndex++;
			return roomName;
		}
		
		public static function isEnabledFeed(entity:String):Boolean {
			var enabledFeeds:ArrayCollection = Database.feedDAO.getEnabledFeeds();
			for each(var enabledFeed:Object in enabledFeeds){
				if(enabledFeed.entity == entity) return true;
			}
			return false;
		}
		
		public static function sendMessage(msg:String, roomName:String):void {
			CRMXAMPPConnection.getInstance().jointRoomName(roomName);
			CRMXAMPPConnection.getInstance().addEventListener( RoomEvent.ROOM_JOIN, function( event:RoomEvent ):void {
				CRMXAMPPConnection.getInstance().sendMessage(msg);
			});
		}
		
		public static function getRecordName(item:Object, entity:String):String {
			var recName:String = "";
			var nameColumns:Array = DAOUtils.getNameColumns(entity);
			for(var index:int=0; index<nameColumns.length; index++){
				var name_column:String = nameColumns[index]; 
				recName += item[name_column];
				if(index<nameColumns.length-1 && nameColumns.length>1){
					recName += " ";
				}
			}
			return recName;
		}
		
		public static function feedTemplate(msg:String):String {
			var currentUser:Object = Database.currentUserDAO.getCurrentUser();
			var txtMsg:String = "";
			var username:String = currentUser != null ? currentUser.full_name : "";
			//var file:File = new File("app:/assets/no-image.gif");
			//trace(file.nativePath);
			//txtMsg += "<img src='" + file.nativePath + "' style='float:left'/>";
			txtMsg += "<div style='clear:both;'></div>";
			txtMsg += "<img src='http://profile.ak.fbcdn.net/static-ak/rsrc.php/v1/yo/r/UlIqmHJn-SK.gif' style='float:left'/>";
			txtMsg += "<table width='80%' border='0' style='font-family: verdana,helvetica,aria; font-size:13px; border: 1px solid; border-color: #333399; border-left:none; border-right:none; border-top:none;'>";
			txtMsg += "<tr><td colspan='3'><font color='#333399'>" + username + "</font></td></tr>";
			txtMsg += msg;
			txtMsg += "</table><br/>";
			return txtMsg;
		}
		
		public static function formatAndSendFeed(msg:Object):void {
			
			var currentUser:Object = Database.currentUserDAO.getCurrentUser();
			
			if( currentUser == null) return;
			
			var strMsg:String = "";
			var currentUserId:String = currentUser.id;
			var timestamp:String = new String(new Date().time).toString();
			var entity:String = msg.Entity;
			
			if( StringUtils.isEmpty(msg.CommentChannel) ){
				strMsg += "<COMMENTCHANNEL>" + currentUserId + ( StringUtils.isEmpty(entity) ? "" : "_" + entity ) + "_" + timestamp + "</COMMENTCHANNEL>";	
			}else {
				strMsg += "<COMMENTCHANNEL>" + msg.CommentChannel + "</COMMENTCHANNEL>";
			}
			
			if( msg.IsParent == "false" ){
				strMsg += "<COMMENTCHILDCHANNEL>" + currentUserId + "_" + timestamp + "</COMMENTCHILDCHANNEL>";
			}
			
			strMsg += "<FEEDFILTER>" + currentUserId + ( StringUtils.isEmpty(entity) ? "" : "_" + entity ) + "</FEEDFILTER>";
			strMsg += "<ISPARENT>" + msg.IsParent + "</ISPARENT>";
			strMsg += "<USERID>" + currentUserId + "</USERID>";
			strMsg += "<USERNAME>" + currentUser.full_name + "</USERNAME>";
			strMsg += "<COMMENTTIME>" + DateUtils.format(new Date(), "YYYY-MM-DD JJ:NN:SS") +"</COMMENTTIME>";
			strMsg += "<COMMENTTEXT>" + ( StringUtils.isEmpty(msg.CommentText) ? "" : msg.CommentText ) + "</COMMENTTEXT>";
			strMsg += "<OPERATION>" + ( StringUtils.isEmpty(msg.Operation) ? "" : msg.Operation ) + "</OPERATION>";
			strMsg += "<RECORDID>" + ( StringUtils.isEmpty(msg.RecordId) ? "" : msg.RecordId ) + "</RECORDID>";
			strMsg += "<RECORDNAME>" + ( StringUtils.isEmpty(msg.RecordName) ? "" : msg.RecordName ) + "</RECORDNAME>";
			strMsg += "<ENTITY>" + ( StringUtils.isEmpty(entity) ? "" : entity ) + "</ENTITY>";
			
			try {
				var msgXML:XML = new XML('<message>'+strMsg+'</message>');
				msg = new Object();
				msg['commentchannel'] = getElement(msgXML, 'COMMENTCHANNEL');
				msg['isparent'] = getElement(msgXML, 'ISPARENT');
				msg['userid'] = getElement(msgXML, 'USERID');
				msg['username'] = getElement(msgXML, 'USERNAME');
				msg['commenttime'] = getElement(msgXML, 'COMMENTTIME');
				msg['commenttext'] = getElement(msgXML, 'COMMENTTEXT');
				msg['feedfilter'] = getElement(msgXML, 'FEEDFILTER');
				msg['operation'] = getElement(msgXML, 'OPERATION');
				msg['recordid'] = getElement(msgXML, 'RECORDID');
				msg['recordname'] = getElement(msgXML, 'RECORDNAME');
				msg['entity'] = getElement(msgXML, 'ENTITY');
				msg['commentchildchannel'] = getElement(msgXML, 'COMMENTCHILDCHANNEL');
				// Insert into table feed history
				Database.feedHistoryDAO.insert(msg);
			}catch(e:Error) {}
			
			CRMXAMPPConnection.getInstance().sendMessage(strMsg);
			
		}
		
		public static function formatAndSendFeedHistory(msg:Object):void {
			var strMsg:String = "";
			strMsg += "<COMMENTCHANNEL>" + msg['commentchannel'] + "</COMMENTCHANNEL>";	
			strMsg += "<FEEDFILTER>" + msg['feedfilter'] + "</FEEDFILTER>";
			strMsg += "<ISPARENT>" + msg['isparent'] + "</ISPARENT>";
			strMsg += "<USERID>" + msg['userid'] + "</USERID>";
			strMsg += "<USERNAME>" + msg['username'] + "</USERNAME>";
			strMsg += "<COMMENTTIME>" + msg['commenttime'] +"</COMMENTTIME>";
			strMsg += "<COMMENTTEXT>" + msg['commenttext'] + "</COMMENTTEXT>";
			strMsg += "<OPERATION>" + msg['operation'] + "</OPERATION>";
			strMsg += "<RECORDID>" + msg['recordid'] + "</RECORDID>";
			strMsg += "<RECORDNAME>" + msg['recordname'] + "</RECORDNAME>";
			strMsg += "<ENTITY>" + msg['entity'] + "</ENTITY>";
			strMsg += "<COMMENTCHILDCHANNEL>" + msg['commentchildchannel'] + "</COMMENTCHILDCHANNEL>";
			CRMXAMPPConnection.getInstance().sendMessage(strMsg);
		}
		
		private static function getElement(msgXML:XML, elementName:String):String {
			return (msgXML.elements(elementName).children().length() > 0 ? msgXML.elements(elementName).children()[0] : "");
		}
		
		public static function parseAndSendFeedHistory():void {
			var currentDayFeedHistory:ArrayCollection = Database.feedHistoryDAO.getCurrentDayFeedHistory()
			for each(var msg:Object in currentDayFeedHistory) {
				formatAndSendFeedHistory(msg);
			}
		}
		
	}
}