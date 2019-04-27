package gadget.sync.incoming
{
	
	
	import com.adobe.coreUI.util.StringUtils;
	
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.sync.WSProps;
	import gadget.util.FieldUtils;
	import gadget.util.ObjectUtils;
	import gadget.util.ServerTime;
	
	import mx.collections.ArrayCollection;

	public class JDIncomingPlant extends IncomingObject
	{
		
		private var searchProductSpec:String='';
		private var i:int=0;
		public function JDIncomingPlant(entity:String)
		{
			super(entity);
		}
		
		override protected function nextPage(lastPage:Boolean):void {
			//incoming product
			if(searchProductSpec!=''){
				new JDIncomingProduct(searchProductSpec).start();
			}
			searchProductSpec='';
			i=0;
			super.nextPage(lastPage);
			
			
			
		}
		
		override protected function importRecord(entitySod:String, data:XML, googleListUpdate:ArrayCollection=null):int {
			var tmpOb:Object={};
			
			for each (var field:Object in FieldUtils.allFields(entitySod)) {
				
				var xmllist:XMLList = data.child(new QName(ns2.uri,WSProps.ws10to20(entitySod,field.element_name)));
				if (xmllist.length()>1)
					trace(field.element_name,xmllist.length());
				if (xmllist.length() > 0) {
					tmpOb[field.element_name] = xmllist[0].toString();
				} else {
					tmpOb[field.element_name] = null;
				}
			}
			
			
			
			tmpOb.deleted = false;
			tmpOb.local_update = null;
			
			var info:Object = getInfo(data,tmpOb);
			
			var modName:String = WSProps.ws20to10(entitySod, MODIFIED_DATE);
			var modDate:Date = ServerTime.parseSodDate(tmpOb[modName]);
			if (modDate==null) {
				optWarn(i18n._("{1} record with Id {2} has NULL modification date", entitySod, info.rowid));   
			} else {
				if (param.minRec>modDate)		// this works for > but not for ==
					param.minRec	= modDate;
				if (param.maxRec<modDate)
					param.maxRec	= modDate;
			}
			
			dicCount.count(info.rowid);
			
			
			var localRecord:Object = dao.findByOracleId(info.rowid);
			if(entityIDour==Database.productDao.entity){
				tmpOb.ood_lastmodified=tmpOb.ModifiedByDate;
			}else{
				tmpOb.ood_lastmodified=tmpOb.ModifiedDate;
			}
			if (info.rowid == null || info.rowid == "") {
				//VAHI actually this is an internal programming error if it occurs
				//Database.errorLoggingDao.add(null,{entitySod:entitySod,task:getEntityName(),ob:ObjectUtils.DUMPOBJECT(tmpOb),data:data.toXMLString()});
				trace("missing rowid in",getEntityName(),ObjectUtils.DUMPOBJECT(tmpOb));
				optWarn(i18n._("empty rowid in {1}, ignoring record", getEntityName()));
			} else if (localRecord == null) {
				//-- VM -- bug 331
				tmpOb.sync_number = Database.syncNumberDao.getSyncNumber();
				
				trace('ADD',getTransactionName(), info.rowid,tmpOb[modName],info.name);
				updateTracking(entitySod, info.rowid);
				dao.insert(tmpOb);
				notifyCreation(false, info.name);
				
			} else {
				
				var changed:Boolean = false;
				if (this is IncomingObjectPerId) {
					changed = true;
				} else {
					for each (var field2:Object in FieldUtils.allFields(entitySod)) {
						
						if (tmpOb[field2.element_name] != localRecord[field2.element_name]) {
							
							if (StringUtils.isEmpty(tmpOb[field2.element_name]) && StringUtils.isEmpty(localRecord[field2.element_name])) {
								continue;
							}
							// VAHI: XXX
							// The ignoreFields are probably not used.
							// These fields may be present on the SoD side, but they are not on the fieldDao side.
							// As the iteration goes over fieldDao, these fields cannot be present.
							// So perhaps following is redundant code?
							if (field2.element_name.indexOf("CI_") == 0 || ignoreFields.indexOf(field2.element_name)>=0) {
								continue;
							}
							changed = true;
							break;
						}
					}
				}
				if (changed) {
					
					trace('UPD',getTransactionName(), info.rowid,tmpOb[modName],info.name);
					updateTracking(entitySod, info.rowid);
					dao.updateByOracleId(tmpOb);
					notifyUpdate(false, info.name);
					
				} else {
					trace('HAV',getTransactionName(), info.rowid,tmpOb[modName],info.name);
				}
			}
			//IndexedBoolean0 is consumable
			//CustomBoolean0 is deletion flag
			if(tmpOb.IndexedBoolean0!='true'){
				
				var productName:String=tmpOb['ProductName'];
				if(productName!=null&& productName.length>0){
					if(i>0){
						searchProductSpec=searchProductSpec+"OR";
					}
					searchProductSpec=searchProductSpec+" [Name] = \'"+productName+'\' ';
					i=i+1;
				}
				
			}
			
			
			handleInlineData(data, tmpOb, info);
			
			return 1;
		}
		
		
	}
}