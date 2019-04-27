package gadget.sync.incoming
{
	public class IncomingMSExchange extends MSExchangeService
	{
		public function IncomingMSExchange(entiy:String)
		{
			super(entiy);
		}
		
		
		override protected function getXMlRequest():XML{
			var xml:XML = <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">
						  <soap:Body>
							<SyncFolderItems xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">
							<ItemShape>
							<t:BaseShape>Default</t:BaseShape>
								</ItemShape>
								<SyncFolderId>
								<t:DistinguishedFolderId Id={entity}/>
								</SyncFolderId>
								<SyncState>{getLastSyncState()}</SyncState>
								<MaxChangesReturned>100</MaxChangesReturned>
								</SyncFolderItems>
								</soap:Body>
						</soap:Envelope>;
			return xml;
			
		}
	}
}