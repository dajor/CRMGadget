package gadget.sync.outgoing
{
	import gadget.dao.Database;
	
	import mx.collections.ArrayCollection;

	public class OutgoingTaskMSExchange extends OutgoingMSExchange
	{
		private var records:ArrayCollection =null;
		public function OutgoingTaskMSExchange(entiy:String, msExchange:MSExchangeSynchronize)
		{
			super(entiy);
			records = Database.getDao(entity).getMSOutgoingObject("Task");
		}
		override protected function doRequest():void{
			if(records==null||records.length<1){
				successHandler("Success: "+ getName());
			}else{
				super.doRequest();
			}
		}
		override public function getEntityName():String{
			return "Task";
		}
		protected override function getXMlRequest():XML{
			_logInfo("Starting update to MS Exchange...");

			var itemChange:String ='';
			for each (var item:Object in records){
				itemChange += '<t:ItemChange>'+
					'<t:ItemId Id="'+item.ms_id+'" ChangeKey="'+item.ms_change_key+'"/>'+
						'<t:Updates>'+
							'<t:SetItemField>'+
								'<t:FieldURI FieldURI="tasks:Subject" />'+
								'<t:Task>'+
									'<t:Subject>'+item.Subject+'</t:Subject>'+
								'</t:Task>'+
							'</t:SetItemField>'+
							'<t:SetItemField>'+
								'<t:FieldURI FieldURI="tasks:StartDate" />'+
								'<t:Task>'+
									'<t:StartDate>'+item.StartTime+'</t:StartDate>'+
								'</t:Task>'+
							'</t:SetItemField>'+
							'<t:SetItemField>'+
								'<t:FieldURI FieldURI="tasks:DueDate" />'+
								'<t:Task>'+
									'<t:DueDate>'+item.EndTime+'</t:DueDate>'+
								'</t:Task>'+
							'</t:SetItemField>'+
							'<t:SetItemField>'+
								'<t:FieldURI FieldURI="tasks:Status" />'+
								'<t:Task>'+
									'<t:Status>'+item.Status+'</t:Status>'+
								'</t:Task>'+
							'</t:SetItemField>'+
						'</t:Updates>'+
					'</t:ItemChange>';
			}
			
			var xml:XML = new XML('<soap:Envelope ' +
				'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
				'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' +
				'xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages" ' +
				'xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types" ' +
				'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
					'<soap:Body>'+
						'<m:UpdateItem ConflictResolution="NeverOverwrite" >'+
							'<m:ItemChanges>'+
								itemChange +
							'</m:ItemChanges>'+
						'</m:UpdateItem>'+
					'</soap:Body>'+
				'</soap:Envelope>');
			
			return xml;
		}
	}
}