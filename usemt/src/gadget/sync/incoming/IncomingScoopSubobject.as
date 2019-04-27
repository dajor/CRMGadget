package gadget.sync.incoming
{
	import gadget.dao.BaseDAO;
	import gadget.dao.Database;
	import gadget.util.SodUtils;

	public class IncomingScoopSubobject extends IncomingSubobjects {
		
		private const IdQueryPlaceholder:String = "___HERE_THE_ID_QUERY___";
		private var allParents:Array;

		public function IncomingScoopSubobject(entity:String, sub:String) {
			linearTask = true;
			super(entity, sub);
		}
		
		override protected function tweak_vars2():void {
			
			pageSize	= 50;	//VAHI 75 is too much
			stdXML =
				<{wsID} xmlns={ns1.uri}>
					<{listID} pagesize={pageSize} startrownum={ROW_PLACEHOLDER}>
						<{entityIDns}>
							<Id>{IdQueryPlaceholder}</Id>
							<{subList} pagesize={SUB_PAGE_SIZE} startrownum={SUBROW_PLACEHOLDER}>
								<{subIDns}>
									<ModifiedDate/>
								</{subIDns}>
							</{subList}>
						</{entityIDns}>
					</{listID}>
				</{wsID}>
			;
			
		}
		
		override protected function initOnce():void {
			super.initOnce();
			allParents = Database[SodUtils.transactionProperty(entityIDour).dao].listAll();
		}

		override protected function doRequest():void {

			if (_page*pageSize>=allParents.length) {
				successHandler(null);
				return;
			}

			var subList:Array = allParents.slice(_page*pageSize, _page*pageSize+pageSize);

			var idList:String = "='"+subList[0]+"'";
			for (var i:int=1; i<subList.length; i++) {
				idList = "(='" + subList[i] + "') OR (" + idList + ')';
			}
			
			trace("::::::: SCOOPREQUEST20 ::::::::",getEntityName(),param.force,_page,_subpage,isLastPage,haveLastPage,idList);
//			Database.errorLoggingDao.add(null,{trace:[getEntityName(),param.force,_page,_subpage,isLastPage,haveLastPage,idList]});
			
			sendRequest("\""+getURN()+"\"", new XML(
				getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, _page*pageSize)
				.replace(SUBROW_PLACEHOLDER, _subpage*SUB_PAGE_SIZE)
				.replace(IdQueryPlaceholder,idList)
			));
		}
		
		override protected function nextPage(lastPage:Boolean):void {
		  super.nextPage(false);
		}
	}
}
