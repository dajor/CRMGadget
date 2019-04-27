package gadget.sync.incoming
{
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.util.DateUtils;
	import gadget.util.ObjectUtils;

	public class IncomingEmaiMSExchange extends IncomingMSExchange
	{
		public function IncomingEmaiMSExchange()
		{
			super('sentitems');
		}
		override public function getEntityName():String{
			return "Email";
		}
		
		override protected function importObject(xml:XML,isCreate:Boolean):int{
			var msId:XMLList = xml.child(new QName(nsChange.uri,WSProps.ws10to20('Message','ItemId')));
			var id:String =  (msId.@Id as XMLList)[0].toString();
			var tampObj:Object = Database.activityDao.findByMSId(id);
			if(tampObj == null){
				tampObj = new Object();
			}
			for(var name:String in mapEmail){
				var value:XMLList = xml.child(new QName(nsChange.uri,WSProps.ws10to20('Message',name)));
				if(name =='DateTimeCreated' || name =='DateTimeSent'){
					if(name =='DateTimeCreated'){
						tampObj['Start'] =DateUtils.format(DateUtils.guessAndParse(value[0].toString()), "DD/MM/YYYY JJ:NN:SS");
					}else{
						tampObj['End'] =DateUtils.format(DateUtils.guessAndParse(value[0].toString()), "DD/MM/YYYY JJ:NN:SS");
					}
					tampObj[mapEmail[name]] =DateUtils.format(DateUtils.guessAndParse(value[0].toString()), DateUtils.DATABASE_DATETIME_FORMAT);
				}else if(name =='ItemId'){
					tampObj['ms_change_key'] = value == null ? '': (value.@ChangeKey as XMLList)[0].toString();
					tampObj['ms_id'] = value == null ? '': (value.@Id as XMLList)[0].toString();
				}else{
					tampObj[mapEmail[name]] = value[0]==null ? '' : value[0].toString();
				}
				
			}
			tampObj["ModifiedDate"] =DateUtils.format(new Date(), DateUtils.DATABASE_DATETIME_FORMAT);
			tampObj['Activity'] = 'Appointment';
			tampObj['Type'] = 'Email';
			tampObj['getMyClassName'] = getMyClassName();
			listRecord.addItem(tampObj);
			var nameCols:Array		= DAOUtils.getNameColumns(Database.activityDao.entity);
			_logInfo(ObjectUtils.joinFields(tampObj, nameCols));
			return 1;
		}
	}
}