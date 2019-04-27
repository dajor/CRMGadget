package gadget.util
{
	
	import com.as3xls.xls.Cell;
	import com.crmgadget.eval.Evaluator;
	
	import flash.display.Loader;
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import gadget.control.AppointmentPDF;
	import gadget.control.CustomPurePDF;
	import gadget.control.SampleItemView;
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.i18n.i18n;
	import gadget.service.PicklistService;
	
	import mx.collections.ArrayCollection;
	import mx.utils.Base64Decoder;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;
	
	public class PDFUtil extends CustomPurePDF
	{
		private static const CELL_HEIGHT:int = 10;
		private static const CELL_WIDTH:int = 50;
		private static const HEADER_CELL_WIDTH:int = 150;
		private static const LINE_HEIGHT:int = 6;
		private static const TITLE_HEIGHT:int = 10;
		
		
		private static const PDFUTIL_DATE:String = 'GLOBAL_DATE';
		private static const PDFUTIL_TITLE:String = 'PDFUTIL_TITLE';
		private static const PDFUTIL_JANUARY:String = 'PDFUTIL_JANUARY';
		private static const PDFUTIL_FEBRUARY:String = 'PDFUTIL_FEBRUARY';
		private static const PDFUTIL_MARCH:String = 'PDFUTIL_MARCH';
		private static const PDFUTIL_APRIL:String = 'PDFUTIL_APRIL';
		private static const PDFUTIL_MAY:String = 'PDFUTIL_MAY';
		private static const PDFUTIL_JUNE:String = 'PDFUTIL_JUNE';
		private static const PDFUTIL_JULY:String = 'PDFUTIL_JULY';
		private static const PDFUTIL_AUGUST:String = 'PDFUTIL_AUGUST';
		private static const PDFUTIL_SEPTEMBER:String = 'PDFUTIL_SEPTEMBER';
		private static const PDFUTIL_OCTOBER:String = 'PDFUTIL_OCTOBER';
		private static const PDFUTIL_NOVEMBER:String = 'PDFUTIL_NOVEMBER';
		private static const PDFUTIL_DECEMBER:String = 'PDFUTIL_DECEMBER';
		private static const PDFUTIL_STARTTIME:String = 'GLOBAL_START_TIME';
		private static const PDFUTIL_ENDTIME:String = 'GLOBAL_ENDTIME';
		//CRO 05.01.2011
		private static const PDFUTIL_SUBJECT:String = 'GLOBAL_SUBJECT';
		private static const PDFUTIL_MARK:String = 'PDFUTIL_MARK';
		private static const PDFUTIL_ACCOUNT:String = 'GLOBAL_ACCOUNT_NAME';
		private static const PDFUTIL_ADDRESS:String = 'GLOBAL_ADDRESS';
		private static const PDFUTIL_TELEPHONE_NUMBER:String = 'PDFUTIL_TELEPHONE_NUMBER';
		private static  const TAG_PATTERN:RegExp=/\<B>|\<\/B>/gi;
		private static  const ROUTE_POSITION:Array = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y"]
		public function PDFUtil(){}
		
		public static function getObjectColumn(_element_name:String,_display_name:String, width:Number = -1):Object{
			var obj:Object = new Object();
			obj.element_name = _element_name;
			obj.display_name = _display_name;
			obj.width = width;
			return obj;
		}
		
		private static function step2(entity:String, subtype:int, item:Object, create:Boolean, errorMessage:Function,byteSign:ByteArray, bytes:ByteArray = null, width:int = 0, height:int = 0):void {
			
			// entity: 'Activity' && subtype: 1 = 'Appointment'
			if(entity == 'Activity' && subtype == 1) {
				var appointment:AppointmentPDF = new AppointmentPDF(entity, subtype, item);
			}else {
				generalPDF(entity, subtype, item, create, errorMessage,byteSign, bytes, width, height);
			}
			
		}
		private static function addImageToTable(table:PdfPTable,bytes:ByteArray,width:int,height:int):void{
			
			if(bytes != null){
				//logo 
				var cell:PdfPCell = new PdfPCell();
				var img:org.purepdf.elements.images.ImageElement = org.purepdf.elements.images.ImageElement.getInstance(bytes);
				var imageHeight:int = 60;
				var imageWidth:int = width * imageHeight / height;
				img.scaleToFit(imageWidth,imageHeight);
				
				cell.borderWidthLeft = 0;
				cell.borderWidthRight = 0;
				cell.borderWidthTop = 0;
				cell.colspan = 2;
				
				cell.verticalAlignment = Element.ALIGN_MIDDLE;
				cell.addElement(img);
			    table.addCell(cell);
				
				
			}
			
		}
		private static function generalPDF(entity:String, subtype:int, item:Object, create:Boolean, errorMessage:Function,bytesSign:ByteArray, bytes:ByteArray = null, width:int = 0, height:int = 0):void {
			var pdfSize:String = "PORTRAIT" ;
			var rotat:Boolean = false;
			pdfSize = Database.preferencesDao.getValue(PreferencesDAO.PDF_SIZE)as String ;
			if(pdfSize.toLocaleUpperCase()=="LANDSCAPE"){
				rotat = true;
			}
			
			var title:String = Utils.getTitle(entity,subtype,item,create);
			var pdfHeader:String = Database.preferencesDao.getValue(PreferencesDAO.PDF_HEADER) as String;
			var newsCount:int = 0,newsLoadingCount:int=0;
			var fileName:String = entity + " exported on " +  DateUtils.getCurrentDateAsSerial() + ".pdf";
			var pdf:CustomPurePDF = new CustomPurePDF(pdfHeader,bytes,width,height);
			
			// --- create doc pdf first ---//
			var document:PdfDocument = pdf.createDocument(rotat);
			
			var table: PdfPTable = new PdfPTable(2);
			var subtype:int = LayoutUtils.getSubtypeIndex(item);
			var fields:ArrayCollection = Database.layoutDao.selectLayout(entity, subtype);
			table.widthPercentage = 100;
			var details:ArrayCollection = new ArrayCollection();
			addTitle(document,title,table);
			for (var i:int = 0; i < fields.length; i++) {
				if(fields[i].column_name.indexOf(CustomLayout.NEWS_CODE) != -1 ){
					var topic:String = SQLUtils.setParams(fields[i].custom, item, false);
					if (!topic) {
						try{
							++newsCount;
							columns = new Array();
							columns.push(getObjectColumn("pDate",i18n._(PDFUTIL_DATE)));
							columns.push(getObjectColumn("title",i18n._(PDFUTIL_TITLE)));
							details.addItem({'fields':columns,'records':relationRecords});
							
							var request:URLRequest = new URLRequest();
							var loaderNews:URLLoader = GUIUtils.getNewsURLLoader(topic,request);
							loaderNews.addEventListener(Event.COMPLETE, function(e:Event):void {
								++newsLoadingCount;
								var listNews:ArrayCollection = GUIUtils.getNewsList(e);
								document.add(table);
								table = new PdfPTable(2);
								table.widthPercentage = 100;
								addGrid(document,columns,listNews.toArray());
								if(newsCount == newsLoadingCount)
									Utils.writeFile( fileName, pdf.getByteArray() ).openWithDefaultApplication();						
							});
							loaderNews.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void {
								++newsLoadingCount;
								if(newsCount == newsLoadingCount)
									Utils.writeFile( fileName, pdf.getByteArray() ).openWithDefaultApplication();
							});
							loaderNews.load(request);
						}catch(e:SQLError){}
					}
				}else if(fields[i].custom){
					if(fields[i].column_name.indexOf(CustomLayout.SQLLIST_CODE) != -1 ){
						var objectSQLQuery:Object = SQLUtils.checkQueryGrid(fields[i].custom, item);
						if (!objectSQLQuery.error) {
							try{
								var sqlListRecords:ArrayCollection = Database.queryDao.executeQuery(objectSQLQuery.sqlString);
								details.addItem({'fields':objectSQLQuery.fields,'records':sqlListRecords});
								document.add(table);
								table = new PdfPTable(2);
								table.widthPercentage = 100;
								addGrid(document,objectSQLQuery.fields,sqlListRecords.toArray());
							}catch(e:SQLError){}
						}
					}else if(fields[i].column_name.indexOf(CustomLayout.RELATION_CODE) != -1 ){
						var relation:Object = Relation.getMNRelation(fields[i].entity, fields[i].custom);
						if (!relation.error) {
							try{
								var relationRecords:ArrayCollection = GUIUtils.getRelationList(relation,item);
								var columns:Array = new Array();
								
								var subDao:BaseDAO = Database.getDao(relation.supportTable);
								var subFields:ArrayCollection = Database.subColumnLayoutDao.fetchColumnLayout(entity,relation.supportTable);
								var tempCols:Array =null;
								if(subFields!=null && subFields.length>0){
									tempCols = new Array();
									for each(var subField:Object in subFields){
										tempCols.push(subField.element_name);
									}
								}else{
									tempCols = relation.labelSupport;
								}
								
								for each(var colname:String in tempCols ) {
									var label:String ="";
									var obj:Object = null;
									if(subDao!=null){
										obj = Database.fieldDao.findFieldByPrimaryKey(DAOUtils.getRecordType(subDao.entity),colname);
									}else{
										obj = Database.fieldDao.findFieldByPrimaryKey(relation.entityDest, colname);
									}
									if(obj!=null){
										label = obj.display_name;
									}else{
										label = colname;
									}
									
									columns.push(getObjectColumn(colname,label));
								}
								
								details.addItem({'fields':columns,'records':relationRecords});
								document.add(table);
								table = new PdfPTable(2);
								table.widthPercentage = 100;
								addGrid(document,columns,relationRecords.source);
							}catch(e:SQLError){}
						}
						
					}else if(fields[i].column_name.indexOf(CustomLayout.SQLFIELD_CODE) != -1){
						try{
							var fieldQuery:Object = SQLUtils.checkQueryField(fields[i].custom,item);
							var list:ArrayCollection = Database.queryDao.executeQuery(fieldQuery.sqlString);
							if(list != null && list.length>0){
								var content:String = "";
								var object:Object = list.getItemAt(0);
								content = object[fieldQuery.column_name];
								addField(table, fieldQuery.display_name, content);
							}
						}catch(e:SQLError){}
					}else if(fields[i].column_name.indexOf(CustomLayout.CALCULATED_CODE) != -1){
						var objectCustomField:Object = fields[i].customField;
						if(objectCustomField){
							var ownerUser:Object = Database.allUsersDao.ownerUser();
							var result:String = Utils.doEvaluate(objectCustomField.value,ownerUser,null,null,item,null);
							addField(table, objectCustomField.displayName, result);
						}
						
					}else if(fields[i].custom != "Photo"){
						addTitle(document,fields[i].custom as String,table);
					}
				}else{
					if( fields[i].column_name != '{' + CustomLayout.GOOGLEMAP_CODE + '}' && fields[i].column_name != "picture" ){
						var fieldInfo:Object = FieldUtils.getField(entity, fields[i].column_name);
						if(fieldInfo){
							var data:String = item[fieldInfo.element_name] == null ? ' ' : item[fieldInfo.element_name];
							if (fieldInfo.data_type == 'Picklist') 
								data = PicklistService.getValue(entity,fieldInfo.element_name,item[fieldInfo.element_name],item);
							addField(table, fieldInfo.display_name, data);
						}
					}
				}
			}	
			
			document.add(table);
			table = new PdfPTable(2);
			table.widthPercentage = 100;
			addTitle(document,"Signature",table);
			addImageToTable(table,bytesSign,90,50);
			document.add(table);
			document.close();
			if(newsCount==0){
				Utils.writeFile( fileName, pdf.getByteArray() ).openWithDefaultApplication();
			}
		}
		
		private static var loader:Loader;
		
		public static function detailToPDF(entity:String, subtype:int, item:Object, create:Boolean, errorMessage:Function,byteSign:ByteArray=null):void {
			
			var bytes:ByteArray = null;
			var pdfLogo:String = Database.preferencesDao.getValue(PreferencesDAO.PDF_LOGO) as String;
			
			if (!StringUtils.isEmpty(pdfLogo)) {
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(pdfLogo);
				bytes = base64Dec.toByteArray();
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
					step2(entity, subtype, item, create, errorMessage, byteSign,bytes, e.target.width, e.target.height);
				});
				loader.loadBytes(bytes);
			} else {
				step2(entity, subtype, item, create, errorMessage,byteSign);
			}
		}
		
		public static function sampleItemsToPDF(item:Object,sampleItems:ArrayCollection):void{
			
			var bytes:ByteArray = null;
			var pdfLogo:String = Database.preferencesDao.getValue(PreferencesDAO.PDF_LOGO) as String;
			
			if (!StringUtils.isEmpty(pdfLogo)) {
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(pdfLogo);
				bytes = base64Dec.toByteArray();
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
					doExportSampleItems(item,sampleItems,   bytes, e.target.width, e.target.height);
				});
				loader.loadBytes(bytes);
			} else {
				doExportSampleItems( item,sampleItems);
			}
			
			
			
		}
		
		private static function doExportSampleItems(item:Object,sampleItems:ArrayCollection,logo:ByteArray=null,width:int=0,height:int=0):void{
			var entity:String = Database.customObject11Dao.entity;
			var pdfSize:String = "PORTRAIT" ;
			var rotat:Boolean = false;
			pdfSize = Database.preferencesDao.getValue(PreferencesDAO.PDF_SIZE)as String ;
			if(pdfSize.toLocaleUpperCase()=="LANDSCAPE"){
				rotat = true;
			}
			
			var title:String = Utils.getEntityDisplayName(entity);
			var pdfHeader:String = Database.preferencesDao.getValue(PreferencesDAO.PDF_HEADER) as String;			
			var fileName:String = entity + " exported on " +  DateUtils.getCurrentDateAsSerial() + ".pdf";
			var pdf:CustomPurePDF = new CustomPurePDF(pdfHeader,logo,width,height);
			
			// --- create doc pdf first ---//
			var document:PdfDocument = pdf.createDocument(rotat);
			
			var table: PdfPTable = new PdfPTable(2);
			
			table.widthPercentage = 100;
			var details:ArrayCollection = new ArrayCollection();
			addTitle(document,title,table);
			//header information
			for each(var field:Object in getOrderFields()){
				if(field.isTitle){
					addTitle(document,field.display_name as String,table);
				}else{
					var elementname:String = field.element_name;
					//IndexedBoolean0---use alterate address
					if(StringUtils.isTrue(item['IndexedBoolean0'])){
						elementname = field.element_name2;	
					}
					
					var data:String = item[elementname] == null ? ' ' : item[elementname];
					if (field.data_type == 'Picklist') {
						data = PicklistService.getValue(entity,elementname,item[elementname],item);
					}
					addSampleField(table, field.display_name, data);
				}
			}
			
			//add items title
			addTitle(document,Database.customLayoutDao.getPlural(Database.customObject7Dao.entity),table);			
			//write items
			
			var newLine:PdfPCell = new PdfPCell();
			newLine.colspan = 2;
			newLine.border = 0;
			newLine.fixedHeight = 10;			
			table.addCell(newLine);
			
			addSampleItemGrid(table,getItemFields(),sampleItems.toArray());	
			document.add(table);
			document.close();
			Utils.writeFile( fileName, pdf.getByteArray() ).openWithDefaultApplication();
		}
		
		protected static function getOrderFields():Array{
			var tempFields:ArrayCollection =SampleItemView.getHeaderField();
			var fields:Array  = new Array();
			fields.push({isTitle:true,display_name:i18n._('SAMPLE_HEADER_INFO@Header Infomation')});
			
			for each(var f:Object in tempFields){
				var obj:Object = new Object();
				obj.display_name = FieldUtils.getFieldDisplayName(Database.customObject11Dao.entity,f.element_name);
				obj.element_name = f.element_name;
				obj.element_name2 = f.element_name2;
				fields.push(obj);
			} 
			return fields;
		}
		
		private static function getItemFields():Array{
			var tempFields:Array =['CustomObject1Name','CustomText3','CustomNumber0'];
			var fields:Array  = new Array();
			var first:Boolean = true;
			for each(var f:String in tempFields){
				var obj:Object = new Object();
				if(first){
					obj.display_name = FieldUtils.getFieldDisplayName(Database.customObject1Dao.entity,"Name");
				}else{
					obj.display_name = FieldUtils.getFieldDisplayName(Database.customObject7Dao.entity,f);
				}
				obj.element_name = f;
				fields.push(obj);
				first = false;
			} 
			
			return fields;
			
		}
		
		private static function addSampleField(table: PdfPTable,display:String,data:String):void{
			var font: Font = getUnicodeFont(11, Font.BOLD );
			var fontNormal: Font = getUnicodeFont(11);
			
			
			var label:Paragraph = new Paragraph(display + "  ", fontNormal );
			var vaue:Paragraph = new Paragraph(data , font );
			
			var cell: PdfPCell = new PdfPCell();
			label.alignment = Element.ALIGN_LEFT;
			cell.addElement(label);
			cell.border = 0;
			cell.paddingRight = 7;
			table.addCell(cell);
			
			cell = new PdfPCell();
			vaue.alignment = Element.ALIGN_LEFT;
			cell.addElement(vaue);
			cell.border = 0;
			table.addCell(cell);
			
		}
		
		
		private static function addField(table: PdfPTable,display:String,data:String):void{
			var font: Font = getUnicodeFont(12, Font.BOLD );
			var fontNormal: Font = getUnicodeFont();
			
			
			var label:Paragraph = new Paragraph(display + "  ", font );
			var vaue:Paragraph = new Paragraph(data , fontNormal );
			
			var cell: PdfPCell = new PdfPCell();
			label.alignment = Element.ALIGN_RIGHT;
			cell.addElement(label);
			cell.border = 0;
			cell.paddingRight = 7;
			table.addCell(cell);
			
			cell = new PdfPCell();
			vaue.alignment = Element.ALIGN_LEFT;
			cell.addElement(vaue);
			cell.border = 0;
			table.addCell(cell);
			
		}
		
		private static function addTitle(document:PdfDocument,lable:String,table: PdfPTable):void{
			
			var ch:Chunk = new Chunk("");
			var newLine:PdfPCell = new PdfPCell();
			newLine.colspan = 2;
			newLine.border = 0;
			newLine.fixedHeight = 10;
			newLine.addElement(ch);
			table.addCell(newLine);
			
			var font: Font = getUnicodeFont(12, Font.BOLD );
			var label:Paragraph = new Paragraph(lable + "  ", font );
			
			var cell: PdfPCell = new PdfPCell();
			cell.borderWidthLeft = 0;
			cell.borderWidthRight = 0;
			cell.borderWidthTop = 0.5;
			cell.colspan = 2;
			cell.fixedHeight = 20;
			cell.verticalAlignment = Element.ALIGN_MIDDLE;
			label.alignment = Element.ALIGN_LEFT;
			cell.addElement(label);
			cell.borderWidthBottom = 0;
			table.addCell(cell);
			
		}
		public static function dailyAgendaToPDF(strDay:String,dataSource:Array,image:ByteArray, errorMessage:Function,isIncludeRoute:Boolean):void {
			var allAddress:Array = new Array();
			if(isIncludeRoute){
				for(var i:int=0;i<dataSource.length;i++){
					if(dataSource[i].address != null && dataSource[i].address != ""){
						var addr:String = dataSource[i].address;
						allAddress[i] =  addr.replace(/\s+/gi,'+');
					}
				}
			}
			getMapDirection(new Array(),allAddress,0,dataSource.length,strDay,dataSource,image, errorMessage);
			
		}
		private static function getMapDirection(xmls:Array,allAddress:Array,start:int,stop:int,strDay:String,dataSource:Array,image:ByteArray, errorMessage:Function):void{
			var urlLoader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest();
			
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				xmls = new Array();
				creatDailyAgenda(strDay,dataSource,image,xmls,errorMessage,allAddress);
			});
			
			
			urlLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
				
				if(allAddress.length>0 && start<stop-1 ){
					xmls.push(new XML(e.target.data));
					getMapDirection(xmls,allAddress,start+1,stop,strDay,dataSource,image, errorMessage);
				}else{
					creatDailyAgenda(strDay,dataSource,image,xmls, errorMessage,allAddress);
					
				}
			});
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			request.url = "http://maps.googleapis.com/maps/api/directions/xml?origin="+allAddress[start]+"&destination="+allAddress[start+1]+"&OK&sensor=false";
			urlLoader.load(request);
		}
		private static function creatDailyAgenda(strDay:String,dataSource:Array,image:ByteArray,xmls:Array,errorMessage:Function,allAddress:Array):void{
			var bytes:ByteArray = null;
			var pdfLogo:String = Database.preferencesDao.getValue(PreferencesDAO.PDF_LOGO) as String;			
			//var tblRoutes:Array = readXML(xmls);
			if (!StringUtils.isEmpty(pdfLogo)) {
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(pdfLogo);
				bytes = base64Dec.toByteArray();
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
					stepView(strDay,dataSource,image, errorMessage,xmls,allAddress, bytes,e.target.width, e.target.height);
				});
				loader.loadBytes(bytes);
			} else {
				stepView(strDay,dataSource,image, errorMessage,xmls,allAddress);
			}
		}
		private static function readXML(xmls:Array,allAddress:Array,document:PdfDocument):void{
			var fontNormal: Font = getUnicodeFont();
			var font: Font = getUnicodeFont(12, Font.BOLD );
			var data:Array=new Array();
			var index:int =0;
			
			for (var i:int=0 ; i<xmls.length ; i++){
				var blank:Paragraph = new Paragraph("\n");
				document.add(blank);
				var addr:String = StringUtils.isEmpty(allAddress[i]) ? '' : allAddress[i];
				var addrEnd:String = StringUtils.isEmpty(allAddress[i+1]) ? '' : allAddress[i+1];
				var table:PdfPTable =  new PdfPTable(8);
				var cellDirection:PdfPCell = new PdfPCell();
				var chunckDirect:Chunk = new Chunk("Driving Directions to " +addrEnd.replace(/\+/gi," "),font);
				var cellAddrStart:PdfPCell = new PdfPCell();
				var lblPosition:Paragraph = new Paragraph("");
				var pos:Chunk = new Chunk(ROUTE_POSITION[i]+". ",font);
				var adr:Chunk = new Chunk(addr.replace(/\+/gi," "),fontNormal);
				table.widthPercentage= 80;
				cellDirection.colspan =8;
				cellDirection.addElement(chunckDirect);
				table.addCell(cellDirection);
				cellAddrStart.colspan =8;
				lblPosition.add(pos);
				lblPosition.add(adr);
				cellAddrStart.addElement(lblPosition);
				table.addCell(cellAddrStart);
				index = 0;
				var xml:XML = xmls[i];
				var routeElement:XMLList = xml.elements("route");
				if(routeElement == null) continue;
				var legElement:XMLList = routeElement.elements("leg");
				if(legElement == null) continue;
				
				for each(var step:XML in legElement.children()){
					if(step.elements("html_instructions") != null && step.elements("html_instructions") != ""){
						
						var d:String = step.elements("html_instructions");
						if(d != ""){
							var distance:XMLList = step.elements("distance") ; 
							var textDistance:String = distance.elements("text") ;
							
							var cell:PdfPCell = new PdfPCell();
							var cellIndex:PdfPCell = new PdfPCell();
							var cellDistance:PdfPCell = new PdfPCell();
							d = d.replace(TAG_PATTERN,"");
							var label:Paragraph = new Paragraph(d.replace(/<[^>]*>/g, "\n"),fontNormal);
							var labelIndex:Paragraph = new Paragraph((index+1) + "",fontNormal);
							var labelDistance:Paragraph = new Paragraph(textDistance,fontNormal);
							cellIndex.addElement(labelIndex);
							cell.addElement(label);
							cell.colspan = 6;
							cellDistance.addElement(labelDistance);
							cellDistance.colspan = 1;
							
							table.addCell(cellIndex);
							table.addCell(cell);
							table.addCell(cellDistance);
						}
						index ++;
					}
				}
				
				var cellAddrEnd:PdfPCell = new PdfPCell();
				var chunkPos:Chunk = new Chunk(ROUTE_POSITION[i+1]+". ",font);
				var endAddr:Chunk = new Chunk(addrEnd.replace(/\+/gi," "),fontNormal);
				var lblAddrEnd:Paragraph = new Paragraph("");
				lblAddrEnd.add(chunkPos);
				lblAddrEnd.add(endAddr);
				cellAddrEnd.colspan = 8;
				
				cellAddrEnd.addElement(lblAddrEnd);
				
				table.addCell(cellAddrEnd);
				document.add(table);
			}
			//return data;
		}
		public static function birthdayListToPDF(errorMessage:Function):void {
			var bytes:ByteArray = null;
			var pdfLogo:String = Database.preferencesDao.getValue(PreferencesDAO.PDF_LOGO) as String;
			
			if (!StringUtils.isEmpty(pdfLogo)) {
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(pdfLogo);
				bytes = base64Dec.toByteArray();
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
					generateBirthdayList(errorMessage, bytes, e.target.width, e.target.height);
				});
				loader.loadBytes(bytes);
			} else {
				generateBirthdayList(errorMessage);
			}
		}
		
		
		public static function generateDashboardReport(pieByte:ByteArray, lineByte:ByteArray, colByte:ByteArray):void{
			var fileName:String = "ACUTE SAINT LOUIS WEST TERRITORY.pdf";
			var pdf:CustomPurePDF = new CustomPurePDF("Segmentation & Targeting");
			var document:PdfDocument = pdf.createDocument();
//			addImage(document, pieByte, 70, 70);
			addImage(document, lineByte, 150, 500);
			addImage(document, colByte, 350, 500);
			document.close();
			Utils.writeFile( fileName, pdf.getByteArray() ).openWithDefaultApplication();
		}
		
		private static function addImage(document:PdfDocument, byteArray:ByteArray, x:int, y:int):void{
			if(byteArray != null){
				var img: ImageElement = ImageElement.getInstance( byteArray );
				var imageHeight:int = 100;
				var imageWidth:int = 200;
				img.scaleToFit(imageWidth,imageHeight);
				img.alignment = ImageElement.RIGHT;
				var cb: PdfContentByte = document.getDirectContent();
				
				cb.saveState();
				cb.restoreState();
				img.setAbsolutePosition(x, y);
				cb.addImage( img );
			}
		}
		
		private static function generateBirthdayList(errorMessage:Function, bytes:ByteArray = null, width:int = 0, height:int = 0):void {
			
			//CRO 05.01.2011
			var title:String = i18n._('GLOBAL_BIRTHDAY_LIST');
			var pdfHeader:String = Database.preferencesDao.getValue(PreferencesDAO.PDF_HEADER) as String;
			var fileName:String = " exported on " +  DateUtils.getCurrentDateAsSerial() + ".pdf";
			var pdf:CustomPurePDF = new CustomPurePDF(pdfHeader,bytes,width,height);
			var document:PdfDocument = pdf.createDocument();
			
			//addLogo(bytes,document,width,height);
			var table:PdfPTable = new PdfPTable(2);
			table.widthPercentage = 100;
			addTitle(document,title,table);
			document.add(table);
			//Getting all contacts.
			var dataSource:ArrayCollection = Database.contactDao.findAll(
				new ArrayCollection([{element_name:"ContactFullName"}, {element_name:"ContactEmail"}, {element_name:"DateofBirth"}]),
				"DateofBirth != ''" 
			);
			
			var birthdayListKey:Array = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
			var birthdayListValue:Object = 
				{
					Jan:i18n._(PDFUTIL_JANUARY),Feb:i18n._(PDFUTIL_FEBRUARY),Mar:i18n._(PDFUTIL_MARCH),Apr:i18n._(PDFUTIL_APRIL),May:i18n._(PDFUTIL_MAY),Jun:i18n._(PDFUTIL_JUNE),
						Jul:i18n._(PDFUTIL_JULY),Aug:i18n._(PDFUTIL_AUGUST),Sep:i18n._(PDFUTIL_SEPTEMBER),Oct:i18n._(PDFUTIL_OCTOBER),Nov:i18n._(PDFUTIL_NOVEMBER),Dec:i18n._(PDFUTIL_DECEMBER)
				};
			var birthdayList:Object = {
				'Jan':[],'Feb':[],'Mar':[],'Apr':[],'May':[],'Jun':[],
				'Jul':[],'Aug':[],'Sep':[],'Oct':[],'Nov':[],'Dec':[]
			};
			
			//Gouping data by month.
			for each(var data:Object in dataSource){
				var d:Date = DateUtils.guessAndParse(data.DateofBirth);
				data.DateofBirth = DateUtils.format(d, DateUtils.getCurrentUserDatePattern().dateFormat);
				var monthIndex:Number = d.getMonth();
				(birthdayList[birthdayListKey[monthIndex]] as Array).push(data);
			}
			
			//Getting the display_name.
			var contactEmailField:Object = Database.fieldDao.findFieldByPrimaryKey("Contact","ContactEmail");
			var contactDateofBirthField:Object = Database.fieldDao.findFieldByPrimaryKey("Contact","DateofBirth");
			
			for (var index:int = 0; index < 12; index ++){
				var monthKey:String = birthdayListKey[index];
				var contactsInMonth:Array = birthdayList[monthKey] as Array;
				if(contactsInMonth.length != 0){
					var dataColumns:Array = new Array();	
					dataColumns.push(getObjectColumn("ContactFullName",birthdayListValue[monthKey] + " [" + contactsInMonth.length + "]"));
					dataColumns.push(getObjectColumn("ContactEmail",contactEmailField.display_name));
					dataColumns.push(getObjectColumn("DateofBirth",contactDateofBirthField.display_name));
					addGrid(document,dataColumns,birthdayList[monthKey]);
					
				}
			}
			document.close();
			Utils.writeFile( fileName, pdf.getByteArray() ).openWithDefaultApplication();
			
		}
		
		private static function stepView(strDay:String,dataSource:Array,image:ByteArray, errorMessage:Function,xmlRoute:Array,allAddress:Array, bytes:ByteArray = null, width:int = 0, height:int = 0):void {
			
			var title:String = i18n._('PDF_UTIL_TITLE_DAILY_ANGENDA_FOR') + " " + strDay;
			var pdfHeader:String = Database.preferencesDao.getValue(PreferencesDAO.PDF_HEADER) as String;
			var fileName:String = " exported on " +  DateUtils.getCurrentDateAsSerial() + ".pdf";
			var pdf:CustomPurePDF = new CustomPurePDF(title,bytes,width,height);
			var document:PdfDocument = pdf.createDocument();
			
			//addLogo(bytes,document,100,50);
			
			var table:PdfPTable =  new PdfPTable(2);
			table.widthPercentage = 100;
			addTitle(document,title,table);	
			document.add(table);
			
			if(image){
				//-- add title --//
				var blankCell:PdfPCell = new PdfPCell();
				blankCell.colspan = 2;
				blankCell.border = 0;
				blankCell.fixedHeight = 10;
				blankCell.addElement(new Chunk(""));
				
				table.addCell(blankCell);
				var img: ImageElement = ImageElement.getInstance( image );
				img.scaleToFit(400,150);
				document.add(img);
				
				table = new PdfPTable(2);
				table.widthPercentage = 100;
				var ch:Chunk = new Chunk("");
				var newLine:PdfPCell = new PdfPCell();
				newLine.colspan = 2;
				newLine.border = 0;
				newLine.fixedHeight = 10;
				newLine.addElement(ch);
				table.addCell(newLine);
				document.add(table);
				
			}	
			
			
			/*dataColumns.push(getObjectColumn("stTime",i18n._(PDFUTIL_STARTTIME),17));
			dataColumns.push(getObjectColumn("enTime",i18n._(PDFUTIL_ENDTIME),17));
			dataColumns.push(getObjectColumn("Subject",i18n._(PDFUTIL_SUBJECT), 28));
			dataColumns.push(getObjectColumn("mark",i18n._(PDFUTIL_MARK), 15));
			dataColumns.push(getObjectColumn("AccountName",i18n._(PDFUTIL_ACCOUNT), 40));
			dataColumns.push(getObjectColumn("address",i18n._(PDFUTIL_ADDRESS), 38));
			dataColumns.push(getObjectColumn("MainPhone",i18n._('PDFUTIL_TELEPHONE_NUMBER')));
			dataColumns.push(getObjectColumn("conFirstName",i18n._("CONTACT_FIRST_NAME")));
			dataColumns.push(getObjectColumn("conLastName",i18n._("CONTACT_LAST_NAME")));
			dataColumns.push(getObjectColumn("conCellularPhone",i18n._("CONTACT_MOBILE_PHONE")));*/
			
			var dataColumns:Array = new Array();
			for each(var export_Field:Object in CustomLayoutPDFExport.EXPORT_FIELDS){
				var exportField:Object = CustomLayoutPDFExport.agenda_pdf_layout_cache.get(export_Field.fieldName);
				if(exportField.checked){
					dataColumns.push(getObjectColumn(exportField.fieldName, exportField.displayName, exportField.width));
				}
			}
			
			addGrid(document,dataColumns,dataSource);
			
			readXML(xmlRoute,allAddress,document);
			
			document.close();
			Utils.writeFile( fileName, pdf.getByteArray() ).openWithDefaultApplication();
			
		}
		
		
		
		private static function addSampleItemGrid(table: PdfPTable, fields:Array, dataSource:Array):void {
			var colorName:Object = Database.preferencesDao.getValue(PreferencesDAO.HEADER_COLOR_PDF);
			var headerColor:Array = Utils.MAP_HEADER_COLOR_PDF[colorName];
			if(headerColor == null) {
				colorName = Preferences.DARK_BLUE;
				headerColor = Utils.MAP_HEADER_COLOR_PDF[colorName];
				
			}
			var font: Font = getUnicodeFont(11, Font.BOLD );
			var fontNormal: Font = getUnicodeFont(11);
			//setFont(pdf, FontFamily.HELVETICA, 9 );
			var columns:Array = new Array();
			var columnCount:int = 9;
			for each(var objCol:Object in fields) if (!objCol.hidden) columnCount++;
			//var columnWidth:int = columnWidth = Math.floor((pdf.getDefaultSize().mmSize[0] - (pdf.getMargins().left * 2)) / columnCount);
			var tableGrid:PdfPTable = new PdfPTable(columnCount);
			tableGrid.widthPercentage = 100;
			/* color rgb
			E4E4FE = 228,228,254
			C8C8FE = 200,200,254
			9191FE = 145,145,254
			*/
			var color:org.purepdf.colors.RGBColor = new org.purepdf.colors.RGBColor();
			color.setValue(headerColor[0][0],headerColor[0][1],headerColor[0][2]);
			font.color = RGBColor.BLACK;
			var colInd:int=1;
			for each(var obj:Object in fields){
				if (obj.hidden) continue;
				//var alignStr:String = Align.LEFT;
				var cellHeader:PdfPCell = new PdfPCell();
				cellHeader.backgroundColor = color;
				cellHeader.verticalAlignment = Element.ALIGN_MIDDLE ;
				var p:Paragraph = new Paragraph(obj.display_name,font);
				//if(obj.data_type=="Number" || obj.data_type=="Currency" || obj.data_type=="Integer") alignStr = Element.ALIGN_RIGHT;
				if(colorName == Preferences.DARK_BLUE || colorName == Preferences.BLACK){
					font.color = RGBColor.WHITE;
				}
				p.alignment = Element.ALIGN_CENTER;
				cellHeader.addElement(p);
				if(colInd==1){
					cellHeader.colspan=8;
				}else if(colInd<5){
					cellHeader.colspan=2;
				}
				tableGrid.addCell(cellHeader);
				
				colInd++;
				
			}
			
			var odd:Boolean = false;
			for each (var data:Object in dataSource){
				color = new org.purepdf.colors.RGBColor();
				if(odd){
					//color.setValue(228,228,254);
					color.setValue(headerColor[1][0],headerColor[1][1],headerColor[1][2]);
					
				}else{
					//color.setValue(200,200,254);
					color = null;
				}
				colInd = 1;
				for each(var prop:Object in fields){
					if (prop.hidden) continue;
					var cellValue:PdfPCell = new PdfPCell();
					cellValue.backgroundColor = color;
					var val:Paragraph = new Paragraph(data[prop.element_name],fontNormal);
					cellValue.addElement(val);
					if(colInd==1){
						cellValue.colspan=8;
					}else if(colInd<5){
						cellValue.colspan=2;
					}
					colInd++;
					tableGrid.addCell(cellValue);
					
				}
				odd = !odd;
			}
			var cell:PdfPCell = new PdfPCell();
			cell.colspan = 2;
			cell.border = 0; 
			cell.addElement(tableGrid);
			table.addCell(cell);
			
		}
		
		
		
		private static function addGrid(document: PdfDocument, fields:Array, dataSource:Array):void {
			var colorName:Object = Database.preferencesDao.getValue(PreferencesDAO.HEADER_COLOR_PDF);
		    var headerColor:Array = Utils.MAP_HEADER_COLOR_PDF[colorName];
			if(headerColor == null) {
				colorName = Preferences.DARK_BLUE;
				headerColor = Utils.MAP_HEADER_COLOR_PDF[colorName];
				
			}
			var font: Font = getUnicodeFont(12, Font.BOLD );
			var fontNormal: Font = getUnicodeFont();
			//setFont(pdf, FontFamily.HELVETICA, 9 );
			var columns:Array = new Array();
			var columnCount:int = 0;
			for each(var objCol:Object in fields) if (!objCol.hidden) columnCount++;
			//var columnWidth:int = columnWidth = Math.floor((pdf.getDefaultSize().mmSize[0] - (pdf.getMargins().left * 2)) / columnCount);
			var tableGrid:PdfPTable = new PdfPTable(columnCount);
			tableGrid.widthPercentage = 100;
			/* color rgb
			E4E4FE = 228,228,254
			C8C8FE = 200,200,254
			9191FE = 145,145,254
			*/
			var color:org.purepdf.colors.RGBColor = new org.purepdf.colors.RGBColor();
			color.setValue(headerColor[0][0],headerColor[0][1],headerColor[0][2]);
			font.color = RGBColor.BLACK;
			
			for each(var obj:Object in fields){
				if (obj.hidden) continue;
				//var alignStr:String = Align.LEFT;
				var cellHeader:PdfPCell = new PdfPCell();
				cellHeader.backgroundColor = color;
				cellHeader.verticalAlignment = Element.ALIGN_MIDDLE ;
				var p:Paragraph = new Paragraph(obj.display_name,font);
				//if(obj.data_type=="Number" || obj.data_type=="Currency" || obj.data_type=="Integer") alignStr = Element.ALIGN_RIGHT;
				if(colorName == Preferences.DARK_BLUE || colorName == Preferences.BLACK){
					font.color = RGBColor.WHITE;
				}
				p.alignment = Element.ALIGN_CENTER;
				cellHeader.addElement(p);
				tableGrid.addCell(cellHeader);
				
			}
			var odd:Boolean = false;
			for each (var data:Object in dataSource){
				color = new org.purepdf.colors.RGBColor();
				if(odd){
					//color.setValue(228,228,254);
					color.setValue(headerColor[1][0],headerColor[1][1],headerColor[1][2]);
					
				}else{
					//color.setValue(200,200,254);
					color = null;
				}
				for each(var prop:Object in fields){
					if (prop.hidden) continue;
					var cellValue:PdfPCell = new PdfPCell();
					cellValue.backgroundColor = color;
					var val:Paragraph = new Paragraph(data[prop.element_name],fontNormal);
					cellValue.addElement(val);
					tableGrid.addCell(cellValue);
				}
				odd = !odd;
			}
			var cell:PdfPCell = new PdfPCell();
			cell.colspan = 2;
			cell.border = 0; 
			cell.addElement(tableGrid);
			document.add(tableGrid);
			
		}
		
		public static function listToPDF(entity:String, filter_type:String, records:Object, reportFields:Array=null):void {
			
			var pdf:CustomPurePDF = new CustomPurePDF();
			var document:PdfDocument = pdf.createDocument();
			
			//To start writing all items of the entity
			var columns:Array = [];
			var fieldsDB:ArrayCollection;
			if(reportFields){
				fieldsDB = new ArrayCollection(reportFields);
			}else{
				fieldsDB = Database.columnsLayoutDao.fetchColumnLayout(entity, filter_type);
				if(fieldsDB.length==0) fieldsDB = Database.columnsLayoutDao.fetchColumnLayout(entity);
			}
			for each (var field:Object in fieldsDB){
				var obj:Object = FieldUtils.getField(entity, field.element_name);
				if (obj) {
					columns.push(obj);
				}
			}
			
			//	var grid:Grid = new Grid(, p.getDefaultSize().mmSize[0], p.getDefaultSize().mmSize[1], new RGBColor ( 0x9191FE ), new RGBColor (0xE4E4FE), true, new RGBColor(0xC8C8FE), 1, null, columns);		
			//p.addGrid( grid);
			
			addGrid(document,columns,records.toArray())
			document.close();
			
			var fileName:String = entity + " exported on " +  DateUtils.getCurrentDateAsSerial() + ".pdf"; 
			Utils.writeFile( fileName ,pdf.getByteArray() ).openWithDefaultApplication();		
			
		}
		
	}
}