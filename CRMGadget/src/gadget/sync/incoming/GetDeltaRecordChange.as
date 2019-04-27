package gadget.sync.incoming
{
	import flash.utils.Dictionary;
	
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.util.FieldUtils;
	import gadget.util.SodUtils;
	
	import mx.collections.ArrayCollection;

	public class GetDeltaRecordChange extends JDIncomingProduct
	{
		protected var finishFunc:Function;
		protected var listIds:ArrayCollection = new ArrayCollection();
		protected var oracleFieldId:String;
		protected var recCount:int =0;
		protected var currentIds:ArrayCollection = new ArrayCollection();
		protected var readById:Boolean = false;
		public function GetDeltaRecordChange(searchSpec:String,entity:String,finishFunc:Function)
		{
			this.finishFunc = finishFunc;
			this.oracleFieldId = DAOUtils.getOracleId(entity);
			recCount = Database.getDao(entity,false).count();
			super(searchSpec,entity);
		}
	
		override protected function getSearchSpec():String{
			var searchSpec:String = super.getSearchSpec();
			if(readById){
				var first:Boolean = true;
				var searchProductSpec:String = "";
				var maxIndex:int = Math.min(pageSize,currentIds.length);
				for(var i:int=1;i<=maxIndex;i++){				
					var id:Object = currentIds.removeItemAt(0);
					if(id==null){
						continue;
					}
					if(!first){
						searchProductSpec=searchProductSpec+" OR ";
					}
					searchProductSpec=searchProductSpec+"["+WSProps.ws10to20(entityIDsod, oracleFieldId)+"] = \'"+id+'\'';
					
					
					first = false;
				}			
				
				
				searchSpec+=' AND ('+searchProductSpec+')';
			}
			
			return searchSpec;
			
		}
		
		
		protected override function getViewmode():String{
			return "Broadest";
		}
		
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
			if(finishFunc!=null){//retry by manual
				finishFunc(listIds);
			}
			return true;
		}
		
		
		override protected function doRequest():void {		
			if(readById){
				_page =0;//read by id page must be start with zero
				if(currentIds.length<1){
					nextPage(true);
					return;
				}
				
			}
			
			super.doRequest();
		}
		
		override protected function handleResponse(request:XML, response:XML):int {
			var ns:Namespace = getResponseNamespace();
			var listObject:XML = response.child(new QName(ns.uri,listID))[0];
			var lastPage:Boolean = listObject.attribute("lastpage")[0].toString() == 'true';	
			var recordcount:int =-1; 
			try{
				recordcount = parseInt(listObject.attribute("recordcount")[0].toString());
			}catch(e:Error){
				//noting todo
			}
			if(recCount<=recordcount && !readById){
				readById = true;
				currentIds=dao.findAllIds();
				_page = 0;//reset page
				doRequest();
			}else{
				var cnt:int = importRecords(entityIDsod, listObject.child(new QName(ns.uri,entityIDns)));			
				nextPage(lastPage && currentIds.length<1);
			}
			
			return cnt;
		}
	
		override protected function getFields(alwaysRead:Boolean=false):ArrayCollection{
			return new ArrayCollection([{element_name:oracleFieldId}]);
		}
		
		protected override function initXML(baseXML:XML):void {
			
			
			var qlist:QName=new QName(ns1.uri,listID), qent:QName=new QName(ns1.uri,entityIDns);	
			
			var xml:XML = baseXML.child(qlist)[0].child(qent)[0];
			var hasActivityParent:Boolean = false;
			var ignoreFields:Dictionary = dao.incomingIgnoreFields;
			for each (var field:Object in getFields(true)) {				
				if(!ignoreFields.hasOwnProperty(field.element_name)){
					if (ignoreQueryFields.indexOf(field.element_name)<0) {
						var ws20name:String = WSProps.ws10to20(entityIDsod, field.element_name);
						xml.appendChild(new XML("<" + ws20name + "/>"));
					}
				}
			}
			
		}
		
		protected override function importRecord(entitySod:String, data:XML, googleListUpdate:ArrayCollection=null):int {
			var tmpOb:Object={};
			var hasActivityParent:Boolean = false;
			for each (var field:Object in getFields()) {
				tmpOb[field.element_name] = getValue(entitySod,data,WSProps.ws10to20(entitySod,field.element_name));	
			}
			//right now we need only oracle id
			listIds.addItem(tmpOb[oracleFieldId]);
			
			return 1;
		}
		
		protected override function nextPage(lastPage:Boolean):void {
			
			
			if (lastPage) {
				if(finishFunc!=null){
					finishFunc(listIds);
				}
			}else{	
				if(!readById){
					_page ++;
				}
				doRequest();//next paage
			}
			
		}
		
	}
}