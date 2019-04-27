package gadget.sync.incoming
{
	import flash.utils.Dictionary;
	
	import gadget.dao.ContactAccountDAO;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.util.CacheUtils;
	
	import mx.collections.ArrayCollection;

	public class IncomingUserDivision extends IncomingSubobjects
	{
		
		protected var firstResponse:Boolean = true;
		protected var pid2pvg:Dictionary= new Dictionary();
		public function IncomingUserDivision()
		{
			super("Division","User");
			isUsedLastModified=true;
			this._listParents = new ArrayCollection();
			
		}
		override protected function getSubDao(pid:String,subId:String):SupportDAO{
			
			return Database.divisionUserDao;
		}
		protected override function getSubIdSod(pId:String,subId:String):String{
			
			return "UserDivision";
		}
		
		override protected function handleResponse(request:XML, response:XML):int {
			if(firstResponse){
				new CacheUtils("picklist").clear();
				firstResponse = false;
				Database.divisionUserDao.deleteAll();
			}
			return	super.handleResponse(request,response);
			
		}
		
		protected override function readParentInfo(parentRec:XML):void{
			var obj:Object = new Object();
			pid2pvg[parentRec.child(new QName(ns2.uri,"Id"))[0].toString()]=obj;
			obj["PickValueGroupId"]=parentRec.child(new QName(ns2.uri,"PickValueGroupId"))[0].toString();
			obj["PickValueGroupFullName"]=parentRec.child(new QName(ns2.uri,"PickValueGroupFullName"))[0].toString();
		}
		protected override function addParentInfo(rec:Object,parentId:String):void{
			var pObj:Object = pid2pvg[parentId];
			if(pObj!=null){
				rec["PickValueGroupId"]=pObj.PickValueGroupId;
				rec["PickValueGroupFullName"]=pObj.PickValueGroupFullName;
			}
			
			Database.divisionUserDao.setPVG(rec);
		}
		
		override protected function doRequest():void {
			
			
			
			
			var pagenow:int = _page;
			var subpagenow:int = _subpage;
			var parentcriteria:String = "";
			isLastPage = false;			
			
			
			var subCirteria:String = getSubSerachSpec();			
		
			trace("::::::: SUBREQUEST20 ::::::::",getEntityName(),param.force,_page,_subpage,pagenow,subpagenow,isLastPage,haveLastPage,subCirteria);			
			
			sendRequest("\""+getURN()+"\"", new XML(
				getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, pagenow*pageSize)
				.replace(SUBROW_PLACEHOLDER, subpagenow*SUB_PAGE_SIZE)
				.replace(PARENT_SEARCH_SPEC,parentcriteria)
				.replace(SEARCHSPEC_PLACEHOLDER,subCirteria)
			));
		}
		
		
		protected override function getSubSerachSpec():String{			
			return "[UserId] = '"+Database.allUsersDao.ownerUser().Id+"' AND  [Primary]='true'";
		}
		protected override function nextSubPage(lastPage:Boolean, lastSubPage:Boolean):void {
			
			if (!lastSubPage) {
				showCount();				
				_subpage++;	
				doRequest();
				return;
			}
			_subpage=0;
			nextPage(lastPage);
		}
		
		
		protected override function nextPage(lastPage:Boolean):void {			
			showCount();
			if(lastPage){
				super.nextPage(true);
			}else{				
				_subpage=0;
				_page++;
				doRequest();
			}
			
			
		}
		
		protected override function getSodName():String{
			return  Database.divisionDao.entity;
		}
		
		override protected function tweak_vars():void {			
			if (stdXML == null) {
				stdXML =
					<{wsID} xmlns={ns1.uri}>						
						<{listID} pagesize={pageSize} startrownum={ROW_PLACEHOLDER}>
							<{entityIDns} searchspec={PARENT_SEARCH_SPEC}>
								<Id/>								
								<PickValueGroupId/>
								<PickValueGroupFullName/>
								<{subList} pagesize={SUB_PAGE_SIZE} startrownum={SUBROW_PLACEHOLDER}>
									<{subIDns} searchspec={SEARCHSPEC_PLACEHOLDER}>										
									</{subIDns}>
								</{subList}>
							</{entityIDns}>
						</{listID}>
					</{wsID}>
				;
			}
		}
		
	}
}