package gadget.sync.incoming
{
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.util.DateUtils;
	import gadget.util.ObjectUtils;

	public class IncomingContactMSExchange extends IncomingMSExchange
	{
		public function IncomingContactMSExchange()
		{
			super("contacts");
		}
	
	
	

	override public function getEntityName():String { return 'Contact'; }
	
	//import----
	override protected function importObject(xml:XML,isCreate:Boolean):int{
		
			if(xml.localName().toString() =='Contact'){
				
//				if(!isCreate){
					var msId:XMLList = xml.child(new QName(nsChange.uri,WSProps.ws10to20('Contact','ItemId')));
					var id:String = (msId.@Id as XMLList)[0].toString();
					var tampObj:Object = Database.contactDao.findByMSId(id);
					if(tampObj == null){
						tampObj = new Object();
						isCreate = false;
					}
					tampObj["ModifiedDate"] =DateUtils.format(new Date(), DateUtils.DATABASE_DATETIME_FORMAT);;
//				}
				
				//				for each (var data:XML in listChild) {
				
				for(var pro:String in mapFields){
					
					var xmllist:XMLList = xml.child(new QName(nsChange.uri,WSProps.ws10to20('Contact',pro)));
					if( pro == 'CompleteName'){
						var  ch:XML = xmllist[0];
						if(ch != null){
							for(var name:String in mapCompleteName){
								var comName:XMLList = ch.child(new QName(nsChange.uri,WSProps.ws10to20('Contact',name)));
								
								//									 if (comName.length()>1)
								// trace(mapFields[pro],xmllist.length());
								if (comName.length() > 0) {
									tampObj[mapCompleteName[name]] = comName[0].toString();
								} else {
									tampObj[mapCompleteName[name]] = null;
								}
							}
						}
					}else if(pro == 'PhysicalAddresses'){
						var childAdd:XML = xmllist[0];
						for each(var add:XML in childAdd.children()){
							if(add.@Key =='Business'){
								for(var proAdd:String in mapAddress){
									var xmlAdd:XMLList = add.child(new QName(nsChange.uri,WSProps.ws10to20('Contact',proAdd)));
									
									//										if (xmlAdd.length()>1)
									// trace(mapFields[pro],xmllist.length());
									if (xmlAdd.length() > 0) {
										tampObj[mapAddress[proAdd]] = xmlAdd[0].toString();
									} else {
										tampObj[mapAddress[proAdd]] = null;
									}
								}
							}
						}	
					}else if(pro == 'PhoneNumbers'){
						var chPH:XML = xmllist[0];
						for each(var ph:XML in chPH.children()){
							if(ph.@Key =='BusinessPhone'){
								tampObj[mapFields['BusinessPhone']] = ph.toString();
								break;
							}
						}
					}else if(pro =='ImAddresses'){
						var chMail:XML = xmllist[0];
						if(chMail.children().length()>0){
							tampObj[mapFields[pro]] = chMail.children()[0].toString();
						}
					}else if(pro =='ItemId'){
						var chId:XML = xmllist[0];
						tampObj['ms_change_key'] = chId == null ? '': (chId.@ChangeKey as XMLList)[0].toString();
						tampObj['ms_id'] =chId == null ? '': (chId.@Id as XMLList)[0].toString();
					}else{
						// value no child xml
						if (xmllist.length()>1)
							trace(mapFields[pro],xmllist.length());
						if (xmllist.length() > 0) {
							tampObj[mapFields[pro]] = xmllist[0].toString();
						} else {
							tampObj[mapFields[pro]] = null;
						}
					}
					
				}
				tampObj['getMyClassName'] = getMyClassName();
				var nameCols:Array		= DAOUtils.getNameColumns(Database.contactDao.entity);
				_logInfo(ObjectUtils.joinFields(tampObj, nameCols));
				listRecord.addItem(tampObj);
				//				}
//				
//				if(isCreate){
//					// inser into table here
//					tampObj["deleted"] = false;
//					tampObj["error"] = false;
//					tampObj["OwnerId"] = tampObj["OwnerId"] == null || tampObj["OwnerId"]=="" ? Database.userDao.read().id : tampObj["OwnerId"];
//					Database.contactDao.insert(tampObj,false);
//					tampObj = Database.contactDao.selectLastRecord()[0];
//					var oidName:String = DAOUtils.getOracleId(Database.contactDao.entity);
//					tampObj[oidName] = "#" + tampObj.gadget_id;
//				}
//				var nameCols:Array		= DAOUtils.getNameColumns(Database.contactDao.entity);
//				_logInfo(ObjectUtils.joinFields(tampObj, nameCols));
//				Database.contactDao.update(tampObj);
				return 1;
			}else{
				return 0;
			}
			
		}
	}
}