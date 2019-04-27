package gadget.sync.incoming
{
	import gadget.dao.Database;

	public class IncomingAuditTrail extends IncomingObject
	{
		protected var recordType:String;
		public function IncomingAuditTrail(entity:String)
		{
			super(Database.auditTrail.entity);
			this.recordType = entity;
		}
		
		override protected function getSodName():String{
			return  SodUtils.transactionProperty(ID).sod_name;
		}
		override protected function getSoapAction():String{
			return "document/urn:crmondemand/ws/audittrail/:AuditTrailQueryPage";
		}
		override protected function getNS1():Namespace{
			return new Namespace("urn:crmondemand/ws/audittrail/");
		}
		
		override protected function getNS2():Namespace{
			return new Namespace("urn:/crmondemand/xml/audittrail/Data");
		}
		protected function getNS3():Namespace{
			return new  Namespace("urn:/crmondemand/xml/audittrail/Query");
		}
		
		override protected function getResponseNamespace():Namespace{
			return getNS2();
		}
	
		override protected function buildStdXML():XML{
			return <{wsID} xmlns={getNS1().uri}>		
						<{listID} xmlns={getNS3().uri} pagesize={pageSize} startrownum={ROW_PLACEHOLDER}>
							<{entityIDns} searchspec={SEARCHSPEC_PLACEHOLDER}>
							</{entityIDns}>
						</{listID}>
					</{wsID}>;
		}
		
		
		
		
		override protected function initXML(baseXML:XML):void {
			
		
			var qlist:QName=new QName(getNS2().uri,listID), qent:QName=new QName(getNS2().uri,entityIDns);
			var xml:XML = baseXML.child(qlist)[0].child(qent)[0];			
			var ignoreFields:Dictionary = dao.incomingIgnoreFields;
			for each (var field:Object in getFields(true)) {				
				if(ignoreFields.hasOwnProperty(field.element_name)){
					continue;
				}
				
				if (ignoreQueryFields.indexOf(field.element_name)<0) {
					var ws20name:String = WSProps.ws10to20(entityIDsod, field.element_name);
					xml.appendChild(new XML("<" + ws20name + "/>"));					
				}
			}
			if(dao.entity==Database.allUsersDao.entity){
				xml.appendChild(new XML("<FullName/>"));
			}
			
			
			
		}
	}
}