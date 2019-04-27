package gadget.sync.incoming
{
	import com.adobe.utils.DateUtil;
	
	import flash.utils.Dictionary;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.sync.WSProps;
	import gadget.util.DateUtils;
	import gadget.util.FieldUtils;
	import gadget.util.ObjectUtils;
	import gadget.util.ServerTime;
	
	import mx.collections.ArrayCollection;

	public class CheckConflictObject extends IncomingObject
	{
		
		protected var _foundRecords:ArrayCollection = new ArrayCollection();
		protected var _localRecordsCheck:Object={};
		protected var oracId:String = '';
		protected var nameCols:Array;
		public function CheckConflictObject(entity:String)
		{
			super(entity);
			oracId=DAOUtils.getOracleId(entityIDour);
			nameCols		= DAOUtils.getNameColumns(entity);
		}
		
		
		override protected function initXML(baseXML:XML):void {
			
			
			var qlist:QName=new QName(ns1.uri,listID), qent:QName=new QName(ns1.uri,entityIDns);
			
			var ignoreFields:Dictionary = dao.incomingIgnoreFields;
			
			for each (var field:Object in getFields()) {
				if(ignoreFields.hasOwnProperty(field.element_name)) continue;
				if (ignoreQueryFields.indexOf(field.element_name)<0) {
					var ws20name:String = WSProps.ws10to20(getEntityName(), field.element_name);
					var xml:XML = baseXML.child(qlist)[0].child(qent)[0];					
					xml.appendChild(new XML("<" + ws20name + "/>"));
					
				}
			}
		}
		
		override protected function getViewmode():String{
			
			return "Broadest";
		}
		override public function done():void{
			//nothing todo
		}
		
		override protected function doRequest():void {
					
			var pagenow:int = _page;
			var searchSpec:String=generateSearchCriteria();
			if(searchSpec==null || searchSpec==''){
				successHandler(null);
				return;
			}			
			isLastPage=false;			
			
			
//			Database.errorLoggingDao.add(null, {trace:[getEntityName(), _page, pagenow, isLastPage, haveLastPage, searchSpec]});
			//VAHI another poor man's workaround for missing late binding in XML templates
			sendRequest("\""+getURN()+"\"", new XML(getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, pagenow*pageSize)
				.replace(SEARCHSPEC_PLACEHOLDER, searchSpec)
			));
		}
		
		private function generateSearchCriteria():String{
//			var oracId:String = DAOUtils.getOracleId(entityIDour);
			var id:String = WSProps.ws10to20(getEntityName(), oracId);
			var criteria:String='';
			var checkRecs :ArrayCollection= dao.findUpdated(0,100);
			checkRecs.addAll(dao.findDeleted(0,100));
			var i:int=0;
			for each(var obj:Object in checkRecs){
				if(i>0){
					criteria = criteria+"OR";
				}
				var idVal:String=obj[oracId];
				criteria=criteria+'['+id+'] ='+'\''+idVal+'\'';
				_localRecordsCheck[idVal] = obj; 
				i++;
			}			
			
			if(i==0){
				return '';
			}
			
			
			return criteria;
			
			
			
		}
		
		override protected function getFields(alwaysRead:Boolean=false):ArrayCollection{
			var fields:ArrayCollection = FieldUtils.allFields(entityIDsod,alwaysRead);
			var foundMDBy:Boolean = false;
			for each(var f:Object in fields){
				if(f.element_name=='ModifiedBy'){
					foundMDBy= true;
					break;
				}
			}
			//for check conflict we alway need modifiedby
			if(!foundMDBy){
				fields.addItem({'element_name':'ModifiedBy'});
			}
			return fields;
		}
		override protected function nextPage(lastPage:Boolean):void {
			
			showCount();
			if (lastPage == false) {
				_page ++;			
				doRequest();
				return;				
			}
			successHandler(null);
		}

		
		override protected function handleResponse(request:XML, response:XML):int {
			
			var listObject:XML = response.child(new QName(ns2.uri,listID))[0];
			var lastPage:Boolean = listObject.attribute("lastpage")[0].toString() == 'true';			

			var cnt:int = importRecords(entityIDsod, listObject.child(new QName(ns2.uri,entityIDns)));
			nextPage(lastPage);
			return cnt;
		}
		
		override protected function importRecords(entitySod:String, list:XMLList, googleListUpdate:ArrayCollection=null):int {
			var cnt:int = 0;
			for each (var data:XML in list) {
				cnt += importRecord(entitySod, data, googleListUpdate);
			}
			return cnt;
		}
		
		override protected function importRecord(entitySod:String, data:XML, googleListUpdate:ArrayCollection=null):int {
			var tmpOb:Object={};
			
			for each (var field:Object in getFields()) {
				var xmllist:XMLList = data.child(new QName(ns2.uri,WSProps.ws10to20(entitySod,field.element_name)));
				if (xmllist.length()>1)
					trace(field.element_name,xmllist.length());
				if (xmllist.length() > 0) {
					tmpOb[field.element_name] = xmllist[0].toString();
				} else {
					tmpOb[field.element_name] = null;
				}
				
			}
			var locRec:Object = _localRecordsCheck[tmpOb[oracId]];
			var localupdateDate:String = null;
			var oodLastModified:String = '';
			if(entityIDour == Database.productDao.entity){
				oodLastModified = tmpOb.ModifiedByDate;
				localupdateDate = locRec.ModifiedByDate; 
			}else{
				oodLastModified = tmpOb.ModifiedDate;
				localupdateDate = locRec.ModifiedDate;
			}
			
			
			var lastLocModi:Date = DateUtils.guessAndParse(locRec.ood_lastmodified);
			var lastSerModi:Date = DateUtils.guessAndParse(oodLastModified);
			if(lastLocModi.getTime()<lastSerModi.getTime()){
				var conflictObj:Object = new Object();
				conflictObj.serverModified = DateUtils.format(lastSerModi,"DD/MM/YY JJ:NN:SS");
				conflictObj.localeModified = DateUtils.format(DateUtils.guessAndParse(localupdateDate),"DD/MM/YY JJ:NN:SS");;
				conflictObj.name=ObjectUtils.joinFields(locRec, nameCols);
				conflictObj.accept=false;
				conflictObj.gadget_type = entityIDour;
				conflictObj.serverRec = tmpOb;
				conflictObj.localeRec = locRec;
				_foundRecords.addItem(conflictObj);
				dicCount.count(tmpOb[oracId]);
				return 1;
			}			
			
			return 0;
		}

		
		public function getConflicts():ArrayCollection{			
			return _foundRecords;
		}
		
		override  public function getName() : String {
			return i18n._('Checking "{1}" conflict data from server', getEntityName());
		}
		
	}
}