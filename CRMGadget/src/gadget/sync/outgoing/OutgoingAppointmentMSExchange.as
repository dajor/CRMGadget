package gadget.sync.outgoing
{
	import gadget.dao.Database;
	
	import mx.collections.ArrayCollection;

	public class OutgoingAppointmentMSExchange extends OutgoingMSExchange
	{
		private var records:ArrayCollection =null;
		public function OutgoingAppointmentMSExchange(entiy:String, msExchange:MSExchangeSynchronize)
		{
			super(entiy);
			records = Database.getDao(entity).getMSOutgoingObject("Appointment");
		}
		
		override protected function doRequest():void{
			if(records==null||records.length<1){
				successHandler("Success: "+ getName());
			}else{
				super.doRequest();
			}
		}
		override public function getEntityName():String{
			return "Calendar";
		}
		  protected override function getXMlRequest():XML{
			  _logInfo("Starting update to MS Exchange...");
			  
			
			var itemChange:String ='';
			for each (var item:Object in records){
				 itemChange += '<t:ItemChange>'+
					'<t:ItemId Id="'+item.ms_id+'" ChangeKey="'+item.ms_change_key+'"/>'+
					'<t:Updates>'+
					'<t:SetItemField>'+
					'<t:FieldURI FieldURI="item:Subject" />'+
					'<t:CalendarItem>'+
					'<t:Subject>'+item.Subject+'</t:Subject>'+
					'</t:CalendarItem>'+
					'</t:SetItemField>'+
					'<t:SetItemField>'+
					'<t:FieldURI FieldURI="calendar:Location" />'+
					'<t:CalendarItem>'+
					'<t:Location>'+item.Location+'</t:Location>'+
					'</t:CalendarItem>'+
					'</t:SetItemField>'+
					'<t:SetItemField>'+
					'<t:FieldURI FieldURI="calendar:Start" />'+
					'<t:CalendarItem>'+
					'<t:Start>'+item.StartTime+'</t:Start>'+
					'</t:CalendarItem>'+
					'</t:SetItemField>'+
					'<t:SetItemField>'+
					'<t:FieldURI FieldURI="calendar:End" />'+
					'<t:CalendarItem>'+
					'<t:End>'+item.EndTime+'</t:End>'+
					'</t:CalendarItem>'+
					'</t:SetItemField>'+
					'</t:Updates>'+
					'</t:ItemChange>';
			}
			
			var xml:XML = new XML('<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages" xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
					'<soap:Body>'+
						'<m:UpdateItem ConflictResolution="AlwaysOverwrite" SendMeetingInvitationsOrCancellations="SendToAllAndSaveCopy">'+
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