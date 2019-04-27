package gadget.sync.incoming {
	
	import flash.events.Event;
	
	import gadget.dao.Database;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	import gadget.sync.task.SyncTask;

	
	public class IncomingSalesProcess extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/salesproc/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/salesprocess/Data");
		
		override protected function doRequest():void {
			var request:XML =
                <SalesProcessQueryPage_Input xmlns='urn:crmondemand/ws/salesproc/'>
                    <ListOfSalesProcess>
                        <SalesProcess>
                            <Id/>
                            <Name/>
                        	<Description/>
							<Default/>
                        	<ListOfSalesStage>
                                <SalesStage>
                                    <Id/>
                                    <Name/>
                                    <Order/>
									<Probability/>
									<SalesCategoryName/>
                                </SalesStage>
                            </ListOfSalesStage>
                            <ListOfOpportunityType>
								<OpportunityType>
									<Id/>
									<Type/>
								</OpportunityType>
                             </ListOfOpportunityType>
                        </SalesProcess>                    
                    </ListOfSalesProcess>
                </SalesProcessQueryPage_Input>
			sendRequest("\"document/urn:crmondemand/ws/salesproc/:SalesProcessQueryPage\"", request);
		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			var cnt:int = 0;
			Database.begin();
			for each(var salesProc:XML in result.ns2::ListOfSalesProcess[0].ns2::SalesProcess) {
				var tmpSalesProc:Object = new Object();
				tmpSalesProc.id = salesProc.ns2::Id[0].toString();
				tmpSalesProc.name = salesProc.ns2::Name[0].toString();
				tmpSalesProc.description = salesProc.ns2::Description[0].toString();
				tmpSalesProc.default_stage = salesProc.ns2::Default[0].toString();
				
				var localSalesProc:Object = Database.salesProcDao.findById(tmpSalesProc.id);
				if (localSalesProc == null) {
					Database.salesProcDao.insert(tmpSalesProc);
					notifyCreation(false, tmpSalesProc.name);
				} else {
					var changed:Boolean = false;
					for each (var field2:String in ['id','name','description','default_stage']) {
						if (tmpSalesProc[field2] != localSalesProc[field2]) {
							changed = true;
							break;
						}
					}
					if (changed) {
						Database.salesProcDao.update(tmpSalesProc);
						notifyUpdate(false, tmpSalesProc.name);
					}
				}
				cnt++;
				
				for each(var salesstage:XML in salesProc.ns2::ListOfSalesStage[0].ns2::SalesStage){
					var tmpSalesStage:Object = new Object();
					tmpSalesStage.id = salesstage.ns2::Id[0].toString();
					tmpSalesStage.name = salesstage.ns2::Name[0].toString();
					tmpSalesStage.sales_proc_id = tmpSalesProc.id; 
					tmpSalesStage.sales_stage_order = salesstage.ns2::Order[0].toString();
					tmpSalesStage.probability = salesstage.ns2::Probability[0].toString();
					tmpSalesStage.sales_category_name=salesstage.ns2::SalesCategoryName[0].toString();
					
					var localSalesStage:Object = Database.salesStageDao.find(tmpSalesStage);
					if (localSalesStage == null) {
						Database.salesStageDao.insert(tmpSalesStage);
						notifyCreation(false, tmpSalesStage.name);
					} else {
						changed = false;
						for each (var fieldSalesStage:String in ['name','sales_stage_order','probability','sales_category_name']) {
							if (tmpSalesStage[fieldSalesStage] != localSalesStage[fieldSalesStage]) {
								changed = true;
								break;
							}
						}
						if (changed) {
							Database.salesStageDao.update(tmpSalesStage);
							notifyUpdate(false, tmpSalesStage.name);
						}						
					}
				}
				
				for each(var opportunityType:XML in salesProc.ns2::ListOfOpportunityType[0].ns2::OpportunityType){
					var tmpOpportunityType:Object = new Object();
					tmpOpportunityType.process_id = salesProc.ns2::Id[0].toString();
					tmpOpportunityType.opportunity_type_id = opportunityType.ns2::Id[0].toString();
					tmpOpportunityType.opportunity_type_name = opportunityType.ns2::Type[0].toString(); 

					var localProcessOpportunity:Object = Database.processOpportunityDao.find(tmpOpportunityType);
					if (localProcessOpportunity == null) {
						Database.processOpportunityDao.insert(tmpOpportunityType);
						notifyCreation(false, tmpOpportunityType.opportunity_type_name);
					} else {
						changed = false;
						for each (var fieldProcessOpportunity:String in ['opportunity_type_name']) {
							if (tmpOpportunityType[fieldProcessOpportunity] != localProcessOpportunity[fieldProcessOpportunity]) {
								changed = true;
								break;
							}
						}
						if (changed) {
							Database.processOpportunityDao.update(tmpOpportunityType);
							notifyUpdate(false, tmpOpportunityType.name);
						}						
					}
				}
								
			}
			Database.commit();
			nextPage(true);
			return cnt;
 		}
 		
		override public function getEntityName():String {
			return "salesproc";
		}

		override public function getTransactionName():String {
			return "Opportunity";
		}

		override public function getName():String {
			return "Receiving sales process updates from server..."; 
		}
		
	}
}