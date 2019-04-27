package gadget.sync.incoming
{
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	import org.purepdf.pdf.ArabicLigaturizer;

	public class IncomingContactNotExistInAccCon extends IncomingObject
	{
		
		
		private var _parentRecord:ArrayCollection;
		private var _ListMissingIds:ArrayCollection;
		public function IncomingContactNotExistInAccCon()
		{
			super(Database.contactDao.entity);
			
		}
		
		
		override protected function doRequest():void {		
			this.isUnboundedTask = true;
			if(_ListMissingIds==null){
				_ListMissingIds=Database.contactAccountDao.findMissingContact();
			}
			if(_ListMissingIds==null ||_ListMissingIds.length<1){
				super.nextPage(true);
			}else{
				
				super.doRequest();
			}
		}
		
		override  public function getName() : String {
			return i18n._('Reading "ContactAccount" data from server');
		}
		
		protected override function nextPage(lastPage:Boolean):void {
			
				showCount();
				if(lastPage){
					if(_ListMissingIds.length<1){						
						super.nextPage(true);
					}else{						
						_page=0;
						doRequest();
					}
				}else{
					
					_ListMissingIds.addAllAt(_parentRecord,0);
					_page++;
					doRequest();
				}
				
			
		}
		
		override protected function generateSearchSpec(byModiDate:Boolean=true):String{
			var first:Boolean = true;
			var searchSpec:String = "";
			var maxIndex:int = Math.min(pageSize,_ListMissingIds.length);
			_parentRecord=new ArrayCollection();
			for(var _currentMinIndex:int=0; _currentMinIndex<maxIndex;_currentMinIndex++){				
				var id:String =_ListMissingIds.removeItemAt(0) as String;
				if(StringUtils.isEmpty(id)){
					continue;
				}
				_parentRecord.addItem(id);
				if(!first){
					searchSpec=searchSpec+" OR ";
				}
				searchSpec=searchSpec+"[Id] = \'"+id+'\'';
				
				
				first = false;
			}
			var searchFilter:String = getSearchFilterCriteria(entityIDour);
			if(!StringUtils.isEmpty(searchFilter)){
				
				if(searchSpec!=''){
					searchSpec = searchFilter+' AND ('+searchSpec+')';
				}else{
					searchSpec = searchFilter;
				}
				
				
			}		
			return searchSpec;
		}
	}
}