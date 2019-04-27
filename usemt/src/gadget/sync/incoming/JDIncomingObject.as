package gadget.sync.incoming
{
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.sync.WSProps;
	
	import mx.collections.ArrayCollection;

	public class JDIncomingObject extends IncomingObject
	{
		
		private var currentIndx:int=0;
		private var listChecks:ArrayCollection;
		
		public function JDIncomingObject(entity:String, records:ArrayCollection=null)
		{
			super(entity);
			haveLastPage = true;
			if(records==null){
				//service request only			
				listChecks = Database.serviceDao.selectOpenService();
			}else{
				listChecks = records;
			}
			
			
			
		}
		
		
		override protected function getViewmode():String{
			return "Broadest";
		}
		
		
		override  public function getName() : String {
			return i18n._("RE_ASSIGNED_OR_CANCELED_ORDER");
		}
		
		override protected function initEach():void {
			_page	= 0;
			haveLastPage = true;
			isLastPage = false;
		}
		override protected function isChangeOwner(localeRec:Object,serverRec:Object):Boolean{			
			
			
			if(localeRec==null) return false;
			
			if(serverRec["Status"]=='Cancelled'){
				return true;//delete canceled
			}
			
			return localeRec["Owner"]!=serverRec["Owner"];
		}

		
		override protected function doRequest():void{
			if(currentIndx >= listChecks.length){
				successHandler(null);
				return;
			}
			param.range=null;
			param.force = true;
			super.doRequest();
		}
		
		override protected function generateSearchSpec(byModiDate:Boolean=true):String{
			var ids:String="";
			var oraId:String = DAOUtils.getOracleId(entityIDour);
			var fId:String = WSProps.ws10to20(entityIDsod, oraId);
			var i:int=0;
			var owner:String = listChecks[0].Owner;
			for( ;currentIndx<listChecks.length;currentIndx++){
				var rec:Object = listChecks.getItemAt(currentIndx);
				if(i>0){
					ids= ids+ " OR ";
				}
				
				ids = ids+ "["+fId+"] = \'"+rec[oraId]+"\'" ;
				i++;
				if(i==pageSize){	
					currentIndx++;
					break;
				}
			}
			
			return ids;
			
		}
		
		override public function getEntityName():String { return entityIDsod+"ownerchange"; }
		
		
		
		
		
		override protected function nextPage(lastPage:Boolean):void {
			if(currentIndx >= listChecks.length){
				successHandler(null);
				
			}else{
				doRequest();
			}			
			
		}
		
		
	}
}