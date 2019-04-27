package gadget.sync.incoming {
	import flash.events.IOErrorEvent;
	
	import gadget.dao.Database;
	import gadget.sync.task.SyncTask;
	import gadget.util.CacheUtils;
	import gadget.util.FieldUtils;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	public class ReadCascadingPicklists extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/cascadingpicklist/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/cascadingpicklist/data");

		override protected function doRequest():void {
 			if (getLastSync() != NO_LAST_SYNC_DATE){
				successHandler(null);
				return;
			} 
			FieldUtils.reset();			
			sendRequest("\"document/urn:crmondemand/ws/odesabs/cascadingpicklist/:CascadingPicklistReadAll\"",
				<CascadingPicklistReadAll_Input xmlns='urn:crmondemand/ws/odesabs/cascadingpicklist/'/>,
				"admin",
				"Services/cte/CascadingPicklistService"
			);

		}
		
		private function getDataStr(field:XML, col:String):String {
			var tmp:XMLList = field.child(new QName(ns2.uri,col));
			return tmp.length()==0 ? "" : StringUtils.replaceStartEndBracket(tmp[0].toString());
		}

		
		// quick and dirty fix to make cascading picklists work for Nestle
		// maps picklists names from WS CascadingPicklist to WS GetMapping
		private function mapPicklist(picklistName:String):String {
			return picklistName
				.replace(/\s/g, "")
				.replace(/ZPick_/g, "CustomPickList")
				.replace(/M\/M/g, "MrMrs")
				.replace(/M\/F/g, "Gender")
				.replace("PrimaryMarket","MarketSegment"); //Bug 5209
		}

		// quick and dirty fix to make cascading picklists work for Nestle
		// maps picklists names from WS CascadingPicklist to WS PicklistService
		private function mapPicklist2(picklistName:String):String {
			return picklistName
			.replace(/ZPick_/g, "PICK_0");
		}

		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			if (faultString.indexOf("(SBL-DAT-00215)")>=0 || faultString.indexOf("(SBL-DAT-00468)")>=0) {
				trace("no cascaded picklists",faultString);
				nextPage(true);
				return true;
			}
			return false;
		}
/*		override protected function handleSoapFault(soapAction:String, request:XML, response:XML, errors:XMLList, soapError:String, soapMessage:String):void {
			if (soapMessage.indexOf("(SBL-DAT-00215)")>=0) {
				trace("no cascaded picklists",soapError,soapMessage);
				nextPage(true);
			} else {
				super.handleSodFault(soapAction, request, response, errors, soapError, soapMessage);
			}
		}
*//*
		override protected function handleSodFault(soapAction:String, request:XML, response:XML, err:XMLList, siebelError:String, siebelMessage:String):void {
			if (siebelMessage.indexOf("(SBL-DAT-00215)")>=0) {
				trace("no cascaded picklists",siebelError,siebelMessage);
				nextPage(true);
			} else {
				super.handleSodFault(soapAction, request, response, err, siebelError, siebelMessage);
			}
		}
*/
		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}

			var cnt:int = 0;
			var fields:ArrayCollection = new ArrayCollection();
			new CacheUtils("cascading_ood").clear();
			Database.begin();
			Database.cascadingPicklistDAO.delete_all();
			
			for each (var picklistSet:XML in result.ns2::ListOfCascadingPicklistSet[0].ns2::CascadingPicklistSet) {
				var entity:String = getDataStr(picklistSet, "ObjectName");
				for each (var cascadingPickList:XML in picklistSet.ns2::ListOfCascadingPicklist[0].ns2::CascadingPicklist) {
					var parentPickList:String = getDataStr(cascadingPickList, "ParentPicklist");
					var parentPickListDB:String = mapPicklist(parentPickList); 
					var relatedPickList:String = getDataStr(cascadingPickList, "RelatedPicklist");
					var relatedPickListDB:String = mapPicklist(relatedPickList);
					for each (var association:XML in cascadingPickList.ns2::ListOfPicklistValueAssociations[0].ns2::PicklistValueAssociations) {
						var parentValue:String = getDataStr(association, "ParentPicklistValue");
						for each (var related:XML in association.ns2::RelatedPicklistValue) {
							var relatedValue:String = StringUtils.replaceStartEndBracket(related[0].toString());							
							
							
							var cascading:Object = new Object();
							// "entity, parent_picklist, child_picklist, parent_value, child_value, parent_code, child_code"
							cascading["entity"] = entity;
							cascading["parent_picklist"] = parentPickListDB;
							cascading["child_picklist"] = relatedPickListDB;
							cascading["parent_value"] = parentValue;
							cascading["child_value"] = relatedValue;
							
											

							try{
								Database.cascadingPicklistDAO.checkPicklistCode_(cascading);			
								Database.cascadingPicklistDAO.insert(cascading);
							}catch(e:Error){
								trace(e.getStackTrace());								
							}
														
							
							
						}
						
					}
				}
				cnt++;
			}
			Database.commit();
			
			nextPage(true);
			return cnt;
		}

		override public function getName():String {
			return "Getting cascading picklists..."; 
		}
		
		override public function getEntityName():String {
			return "CascadingPicklists"; 
		}
	}
}
