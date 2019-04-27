package gadget.control
{
	import com.adobe.images.PNGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.errors.SQLError;
	import flash.utils.ByteArray;
	
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.util.DateUtils;
	import gadget.util.GUIUtils;
	import gadget.util.ImageUtils;
	import gadget.util.LayoutUtils;
	import gadget.util.Relation;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;

	public class AppointmentPDF extends CustomPurePDF
	{
		
		private var cell:PdfPCell;
		private var p:Paragraph;
		private var appointmentFields:ArrayCollection;
		
		public function AppointmentPDF(entity:String, subtype:int, item:Object)
		{
			
			var pdfSize:String = "PORTRAIT" ;
			var rotat:Boolean = false;
			pdfSize = Database.preferencesDao.getValue(PreferencesDAO.PDF_SIZE)as String ;
			if(pdfSize.toLocaleUpperCase()=="LANDSCAPE"){
				rotat = true;
			}
			
			appointmentFields = new ArrayCollection();
			var field:Object = Database.fieldDao.findFieldByPrimaryKey(entity, 'StartTime');
			field.key='Time'; field.display_name='Time' // put unique key Time for generate Time and change display_name to Time
			appointmentFields.addItem(field);
			field = Utils.copyModel(field);
			field.key='Date'; field.display_name='Date'; // put unique key Date to generate Date and change display_name to Date 
			appointmentFields.addItem(field);
			appointmentFields.addItem(Database.fieldDao.findFieldByPrimaryKey(entity, 'Location'));
			appointmentFields.addItem(Database.fieldDao.findFieldByPrimaryKey(entity, 'Description'));

			var fileName:String = entity + " exported on " +  DateUtils.getCurrentDateAsSerial() + ".pdf";
			var pdf:CustomPurePDF = new CustomPurePDF();
			
			// --- create doc pdf first ---//
			var document:PdfDocument = pdf.createDocument(rotat);
			
			var tableHeader:PdfPTable = new PdfPTable(Vector.<Number>([1]));
			tableHeader.widthPercentage = 100;
			
			//p = mailto('daniel.jordan@fellow-consulting.de', 12, Font.NORMAL, RGBColor.WHITE, Element.ALIGN_RIGHT);
			var user:Object = Database.allUsersDao.findByOracleId(item['OwnerId']);
			p = mailto(user.EMailAddr.toString().toLowerCase(), 12, Font.NORMAL, RGBColor.WHITE, Element.ALIGN_RIGHT);
			cell = addCell(p, 0, RGBColor.DARK_GRAY, RectangleElement.NO_BORDER);
			tableHeader.addCell(cell);
			document.addElement(tableHeader);

			document.addElement(newParagraph('\n'));
			
			var tableTitle:PdfPTable =  new PdfPTable(Vector.<Number>([1, 2, 2]));
			tableTitle.widthPercentage = 100;
			
			var bmp:BitmapData = (new (ImageUtils.appointmentIcon) as Bitmap).bitmapData;
			var img:ImageElement = ImageElement.getInstance(PNGEncoder.encode(bmp));
			cell = PdfPCell.fromImage(img);
			cell.paddingTop = 12;
			cell.border = RectangleElement.NO_BORDER;
			cell.horizontalAlignment = Element.ALIGN_CENTER;
			tableTitle.addCell(cell);

			//p = newParagraph('Biogen Idec - Oracle CRM on Demand Unterstützung', 26);
			p = newParagraph(item['Subject'], 26);
			cell = addCell(p, 2, RGBColor.WHITE, RectangleElement.NO_BORDER);
			tableTitle.addCell(cell);
			
			cell = addCell(newParagraph(''));
			tableTitle.addCell(cell);
			
			//p = newParagraph('Created by: daniel.jordan@fellow-consulting.de · Your response: Yes, I\'m going', 9);
			p = newParagraph('Created by: ' + user.FirstName + ' ' + user.LastName, 9);
			cell = addCell(p, 2, RGBColor.WHITE, RectangleElement.NO_BORDER);
			tableTitle.addCell(cell);
			
			document.add(tableTitle);
			
			document.addElement(newParagraph('\n'));
			
			var mainTable:PdfPTable = new PdfPTable(Vector.<Number>([4, 3]));
			mainTable.widthPercentage = 100;
			
			var appointmentTable:PdfPTable = new PdfPTable(Vector.<Number>([1]));
			appointmentTable.widthPercentage = 100;
			// add appointment data
			addAppointmentTable(appointmentTable, item);
			
			cell = new PdfPCell();
			cell.paddingLeft = 18;
			cell.border = RectangleElement.NO_BORDER;
			cell.addElement(appointmentTable);
			
			mainTable.addCell(cell);
			
			// guest table
			var subtype:int = LayoutUtils.getSubtypeIndex(item);
			var fields:ArrayCollection = Database.layoutDao.selectLayout(entity, subtype);
			
			var guestTable:PdfPTable = new PdfPTable(Vector.<Number>([1, 2]));
			guestTable.setTotalWidths(Vector.<Number>([12, 100]));
			guestTable.widthPercentage = 100;
			p = newParagraph('Guests', 12, Font.NORMAL, RGBColor.GRAY);
			cell = addCell(p, 2);
			guestTable.addCell(cell);
			for (var i:int = 0; i < fields.length; i++) {
				if(fields[i].custom){
					if(fields[i].column_name.indexOf(CustomLayout.RELATION_CODE) != -1 ){
						var relation:Object = Relation.getMNRelation(fields[i].entity, fields[i].custom);
						if (!relation.error) {
							try{
								var relationRecords:ArrayCollection = GUIUtils.getRelationList(relation,item);
								if(relationRecords.length > 0) {
									addGuestTable(guestTable, relationRecords, fields[i].custom);
								}
							}catch(e:SQLError){}
						}
					}
				}
			}
			cell = new PdfPCell();
			cell.border = RectangleElement.NO_BORDER;
			cell.addElement(guestTable);
			mainTable.addCell(cell);
			
			document.addElement(mainTable);
			document.close();
			
			Utils.writeFile(fileName, pdf.getByteArray()).openWithDefaultApplication();
		}
		
		private function newParagraph(text:String, fontSize:int=12, fontBold:int=Font.NORMAL, fontColor:RGBColor=RGBColor.BLACK, alignment:int=Element.ALIGN_LEFT):Paragraph {
			var font:Font = getUnicodeFont(fontSize, fontBold);
			font.color = fontColor;
			var p:Paragraph = new Paragraph(text, font);
			p.alignment = alignment;
			return p;
		}
		
		private function mailto(mail:String, fontSize:int=12, fontBold:int=Font.NORMAL, fontColor:RGBColor=RGBColor.BLACK, alignment:int=Element.ALIGN_LEFT):Paragraph {
			var chunk:Chunk = new Chunk(mail);
			if(iMail(mail)) chunk.setAction(PdfAction.fromURL('mailto:'+mail));
			p = newParagraph('', fontSize, fontBold, fontColor, alignment);
			p.add(chunk);
			return p;
		}
		
		private function addCell(paragraph:Paragraph, colspan:int=0, bgColor:RGBColor=RGBColor.WHITE, border:int=RectangleElement.NO_BORDER, vAlign:int=Element.ALIGN_MIDDLE, hAlign:int=Element.ALIGN_LEFT):PdfPCell {
			var cell:PdfPCell = new PdfPCell();
			cell.paddingTop = -5;
			cell.paddingBottom = 5;
			cell.colspan = colspan;
			cell.backgroundColor = bgColor;
			cell.border = border;
			cell.verticalAlignment = vAlign;
			cell.horizontalAlignment = hAlign;
			cell.addElement(paragraph);
			return cell;
		}
		
		private function addGuestTable(guestTable:PdfPTable, relationRecords:ArrayCollection, customRecordType:String):void {
			for each(var obj:Object in relationRecords) {
				p = newParagraph('', 9); // add empty paragraph
				guestTable.addCell(addCell(p, 0, RGBColor.WHITE, RectangleElement.NO_BORDER, Element.ALIGN_MIDDLE, Element.ALIGN_CENTER));
				if(customRecordType == 'User') {
					var user:Object = Database.allUsersDao.findByOracleId(obj.UserId);
					p = mailto(user.EMailAddr.toString().toLowerCase(), 9);
					guestTable.addCell(addCell(p, 0, RGBColor.WHITE, RectangleElement.NO_BORDER));
				}else if(customRecordType == 'Contact') {
					p = newParagraph(obj.ContactFirstName + ' ' + obj.ContactLastName, 9);
					guestTable.addCell(addCell(p, 0, RGBColor.WHITE, RectangleElement.NO_BORDER));
				}
			}
		}
		
		private function addAppointmentTable(appointmentTable:PdfPTable, item:Object):void {
			for each(var fieldInfo:Object in appointmentFields) {
				p = newParagraph(fieldInfo.display_name, 12, Font.NORMAL, RGBColor.GRAY);
				appointmentTable.addCell(addCell(p));
				var value:String = fieldInfo.key=='Time' ? getTime(item) : fieldInfo.key=='Date' ? getDate(item) : item[fieldInfo.element_name];
				p = newParagraph(value, (fieldInfo.element_name=='Description' ? 14 : 18))
				appointmentTable.addCell(addCell(p));
				p = newParagraph('\n');
				appointmentTable.addCell(addCell(p));
			}
		}
		
		private function getTime(item:Object):String {
			return DateUtils.format(parseDate(item['StartTime']), 'H:NN:SS A') + ' - ' + DateUtils.format(parseDate(item['EndTime']), 'H:NN:SS A');
		}
		
		private function getDate(item:Object):String {
			return DateUtils.format(parseDate(item['StartTime']), 'EEE MMM DD, YYYY');
		}
		
		private function parseDate(sTime:String):Date {
			var date:Date = DateUtils.parse(sTime, DateUtils.DATABASE_DATETIME_FORMAT);
			date = new Date(date.getTime()+(DateUtils.getCurrentTimeZone(date)*GUIUtils.millisecondsPerHour));
			return date;
		}
		
		private function iMail(mail:String):Boolean {
			return /([^\s]+@[a-zA-Z0-9_-]+?\.[a-zA-Z]{2,6})/.test(mail);
		}
		
	}
}