package gadget.util
{
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;

	public class GetLayoutUtils{
		
//		private static var _getLayout:GetLayout;
//		
//		public function GetLayout():void{
//			if(_getLayout==null) getLayout = new GetLayout();
//		}
		
		
		public static function getFetchFields(username:String, password:String, sodUrl:String, entity:String, success:Function, failed:Function):void{
			var ns0:Namespace = new Namespace("http://schemas.xmlsoap.org/soap/envelope/");
			var request:URLRequest = new URLRequest();
			request.url = sodUrl + "/Services/cte/PageLayoutFieldService";
			https://secure-ausomxdsa.crmondemand.com/Services/cte/PageLayoutFieldService
			request.method = URLRequestMethod.POST;
			request.contentType = "text/xml; charset=utf-8";
			request.requestHeaders.push(new URLRequestHeader("SOAPAction", "document/urn:crmondemand/ws/odesabs/PageLayoutField/:PageLayoutFieldRead"));
			request.data =<soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
			xmlns:xsd='http://www.w3.org/2001/XMLSchema'
			xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'
			xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>
			
			  <soap:Header>
			    <wsse:Security>
			      <wsse:UsernameToken>
			        <wsse:Username>{username}</wsse:Username>
			        <wsse:Password>{password}</wsse:Password>
			
			      </wsse:UsernameToken>
			    </wsse:Security>
			  </soap:Header>
			  <soap:Body>
			    <PageLayoutFieldRead_Input xmlns='urn:crmondemand/ws/odesabs/pagelayout/pagelayoutfieldservice/'>
			      <PageLayout xmlns='urn:/crmondemand/xml/pagelayout/pagelayoutfieldservice/query'>
			        <ObjectName>{entity}</ObjectName>
			        <LayoutName />
			        <ListOfPageLayoutField>
			          <PageLayoutField></PageLayoutField>
			        </ListOfPageLayoutField>
			      </PageLayout>
			    </PageLayoutFieldRead_Input>
			  </soap:Body>
			</soap:Envelope>;
			
			//(request.data.ns0::Body[0] as XML).appendChild(xml);
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void{
				requestHandler(e, success, failed);
			});
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{
				requestFaultHandler(e, failed);
			});
			
			loader.load(request);
		}
		
		private static function requestHandler(e:Event, success:Function, failed:Function):void{
			var urlLoader:URLLoader = e.currentTarget as URLLoader;
			
			var env:Namespace = new Namespace("http://schemas.xmlsoap.org/soap/envelope/");
			var ns0:Namespace = new Namespace("urn:crmondemand/ws/odesabs/pagelayout/pagelayoutfieldservice/");
			var ns1:Namespace = new Namespace("urn:/crmondemand/xml/pagelayout/pagelayoutfieldservice/query");
			var ns2:Namespace = new Namespace("urn:/crmondemand/xml/pagelayout/pagelayoutfieldservice/data");
			var xsd:Namespace = new Namespace("http://www.w3.org/2001/XMLSchema"); 
			var xsi:Namespace = new Namespace("http://www.w3.org/2001/XMLSchema-instance");
			
			var byteArray:ByteArray = urlLoader.data as ByteArray;
			var data:String = byteArray.readUTFBytes(byteArray.length);
			var namespace:Namespace = new Namespace("env");
			var xml:XML = new XML(data);
			xml.removeNamespace(env);
			xml.removeNamespace(ns0);
			xml.removeNamespace(ns1);
			xml.removeNamespace(ns2);
			xml.removeNamespace(xsd);
			xml.removeNamespace(xsi);
			
			var xmlRoot:XMLList = xml.children();
			var output:XML = xmlRoot[1].children()[0];
			var listPages:XML = output.children()[0]; 
			var layoutAdmin:XML = listPages.children()[0];
			if(layoutAdmin==null) {
				failed("An error occured while fetching page layout.");
				return;
			}
			var entity:String = layoutAdmin.children()[0].toString();
			var layoutName:String = layoutAdmin.children()[1].toString();
			var objectFields:ArrayCollection = new ArrayCollection();
			var header:String = "";
			for each(var pageField:XML in layoutAdmin.children()[3].children()){
				var fields:Object = Database.fieldDao.getFieldByDisplayName(entity, pageField.children()[0].toString());
				if(fields){
					if(fields.element_name.indexOf("CI_")==-1){
						var object:Object = new Object();
						object.section = pageField.children()[4].toString();
						object.col = pageField.children()[4].toString();
						object.row = pageField.children()[5].toString();
						object.readonly = pageField.children()[1].toString()=="true"?1:0;
						object.mandatory = pageField.children()[2].toString()=="true"?1:0;
						object.entity = entity;
						object.subtype = 0;
						object.column_name = fields.element_name;
						objectFields.addItem(object);
					}
				}
			}
			
			var colSortField:SortField = new SortField();
			colSortField.name = "col";
			colSortField.numeric = true;
			
			var rowSortField:SortField = new SortField();
			rowSortField.name = "row";
			rowSortField.numeric = true;
			
			var sectionSortField:SortField = new SortField();
			sectionSortField.name = "section";
			sectionSortField.numeric = true;
			
			var numericDataSort:Sort = new Sort();
			numericDataSort.fields = [sectionSortField, colSortField, rowSortField];
			
			objectFields.sort = numericDataSort;
			objectFields.refresh();
			success(objectFields);
			
		}
		
		private static function requestFaultHandler(e:IOErrorEvent, failed:Function):void{
			var urlLoader:URLLoader = e.currentTarget as URLLoader;
			var byteArray:ByteArray = urlLoader.data as ByteArray;
			var response:String = byteArray.readUTFBytes(byteArray.length);
			if (response.indexOf("<env:Fault>") != -1) {
				failed(i18n._('GETLAYOUTUTILS_FETCH_LAYOUT_ACCESS_DENIED')); // Only CRM admin can use fetch layout
			}else if (response.indexOf("404") != -1) {
				failed(i18n._('GETLAYOUTUTILS_FETCH_LAYOUT_ERROR_404')); // Layout service unavailable on CRM
			} else {
				var error:String = e.text;
				error = error.substring(error.indexOf("" + e.errorID) + 6, error.length);
				failed(error);
			}
		}
		
	}
}