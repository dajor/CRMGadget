package gadget.sync.incoming
{
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.util.DateUtils;
	import gadget.util.ObjectUtils;
	
	import org.purepdf.utils.pdf_core;

	public class IncomingTaskMSExchange extends IncomingMSExchange
	{
		public function IncomingTaskMSExchange()
		{
			super('tasks');
		}


		override public function getEntityName():String{
			return "Task";
		}
		override protected function importObject(xml:XML,isCreate:Boolean):int{
			if(xml.localName().toString() =='Task'){
				
				var msId:XMLList = xml.child(new QName(nsChange.uri,WSProps.ws10to20('Task','ItemId')));
				var id:String =  (msId.@Id as XMLList)[0].toString();
				var tampObj:Object = Database.activityDao.findByMSId(id);
				if(tampObj == null){
					tampObj = new Object();
					
				}
			
				for(var name:String in mapFieldTask){
					var value:XMLList = xml.child(new QName(nsChange.uri,WSProps.ws10to20('Task',name)));
					if(name =='StartDate' || name =='DueDate'){
						if(name =='StartDate'){
							tampObj['Start'] =DateUtils.format(DateUtils.guessAndParse(value[0].toString()), "DD/MM/YYYY JJ:NN:SS");
						}else{
							tampObj['End'] =DateUtils.format(DateUtils.guessAndParse(value[0].toString()), "DD/MM/YYYY JJ:NN:SS");
						}
						
						//tampObj[name] =DateUtils.format(DateUtils.guessAndParse(value[0].toString()), "DD/MM/YYYY JJ:NN:SS");
						tampObj[mapFieldTask[name]] =DateUtils.format(DateUtils.guessAndParse(value[0].toString()), DateUtils.DATABASE_DATETIME_FORMAT);
					}else if(name =='ItemId'){
						tampObj['ms_change_key'] = value == null ? '': (value.@ChangeKey as XMLList)[0].toString();
						tampObj['ms_id'] = value == null ? '': (value.@Id as XMLList)[0].toString();
					}else{
						tampObj[mapFieldTask[name]] = value[0]== null ?'': value[0].toString();
					}
					
				}
				tampObj["ModifiedDate"] =DateUtils.format(new Date(), DateUtils.DATABASE_DATETIME_FORMAT);
				tampObj['Activity'] = 'Task';
				tampObj['getMyClassName'] = getMyClassName();
				listRecord.addItem(tampObj);
				var nameCols:Array		= DAOUtils.getNameColumns(Database.activityDao.entity);
				_logInfo(ObjectUtils.joinFields(tampObj, nameCols));
//				if(isCreate){
//					// inser into table here
//					tampObj["deleted"] = false;
//					tampObj["error"] = false;
//					tampObj["OwnerId"] = tampObj["OwnerId"] == null || tampObj["OwnerId"]=="" ? Database.userDao.read().id : tampObj["OwnerId"];
//					Database.activityDao.insert(tampObj,false);
//					Database.activityDao.selectLastRecord()[0];
//					var oidName:String = DAOUtils.getOracleId(Database.activityDao.entity);
//					tampObj[oidName] = "#" + tampObj.gadget_id;
//				}
//				var nameCols:Array		= DAOUtils.getNameColumns(Database.activityDao.entity);
//				_logInfo(ObjectUtils.joinFields(tampObj, nameCols));
//				Database.activityDao.update(tampObj);
				return 1;
			}else{
				return 0;
			}
		}
	}
}