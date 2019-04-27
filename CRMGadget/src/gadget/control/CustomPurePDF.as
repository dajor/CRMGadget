package gadget.control
{
	import com.hurlant2.math.bi_internal;
	
	import flash.utils.ByteArray;
	
	import flashx.textLayout.tlf_internal;
	
	import gadget.dao.Database;
	
	import mx.olap.aggregators.AverageAggregator;
	
	import org.purepdf.Font;
	import org.purepdf.elements.HeaderFooter;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.events.PageEvent;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfViewPreferences;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.resources.BuiltinFonts;

	public class CustomPurePDF
	{
		public var isRotate:Boolean = false;
		private var buffer: ByteArray = null;
		private var document:PdfDocument = null;
		private var logoWidth:int;
		private var logoHeight:int;
		private var logo:ByteArray;
		private var title:String = "";
		[Embed(source="/assets/fonts/ARIAL.TTF", mimeType="application/octet-stream")] private var arial: Class;
		[Embed(source="/assets/fonts/epkyouka.ttf", mimeType="application/octet-stream")] private var jpn: Class;
		[Embed(source="/assets/fonts/simfang.ttf", mimeType="application/octet-stream")] private var chinese: Class;
		[Embed(source="/assets/fonts/avenir-roman.ttf", mimeType="application/octet-stream")] private var avenir: Class;
		[Embed(source="/assets/fonts/XB Roya.ttf", mimeType="application/octet-stream")]
		private var arabiDEU: Class;
		public function CustomPurePDF(text:String="", logo:ByteArray=null, logoWidth:int=0, logoHeight:int=0)
		{
			this.logoWidth = logoWidth;
			this.logoHeight = logoHeight;
			this.logo = logo;
			this.title = text;
			
		}
		
		public static function getUnicodeFont(size:int = 12 ,fontBold:int = Font.NORMAL):Font{
			var currentUser:Object = Database.allUsersDao.ownerUser()
			var languageCode:String = currentUser==null?"":currentUser.LanguageCode;
			//var bf: BaseFont = BaseFont.createFont("KozMinPro-Regular", BaseFont.UniJIS_UCS2_H, BaseFont.NOT_EMBEDDED );
			//--- default font (Arail)--//
			var fontName:String ="arial.ttf";
			if(languageCode == "DEU" || languageCode =="ARA"){
				fontName ="arbic.ttf";
			}else if(languageCode=='ENU' || languageCode=='ENG'){
				fontName = 'avenir.ttf';
			}
			//if(languageCode =="JPN"){
			//	fontName ="japanese_unicode.ttf";
			//}else if(languageCode =="CHS"){
			//	fontName ="chinese_unicode.ttf";
		//	}
			var bf: BaseFont = BaseFont.createFont( fontName, BaseFont.IDENTITY_H, true, true );
			var font: Font = new Font( -1. -1, size, fontBold, null, bf );
			return font;
		}
		
	
		public function createDocument(rotate:Boolean=false,marginLeft:int=25,marginRight:int=25,marginTop:int=50,marginBottom:int=50):PdfDocument{
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA, new BuiltinFonts.HELVETICA() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLD, new BuiltinFonts.HELVETICA_BOLD() );			
			
			FontsResourceFactory.getInstance().registerFont("arial.ttf", new chinese() );
			FontsResourceFactory.getInstance().registerFont("arbic.ttf", new arabiDEU() );
			FontsResourceFactory.getInstance().registerFont("avenir.ttf", new avenir() );
			
			//FontsResourceFactory.getInstance().registerFont("japanese_unicode.ttf", new jpn() );
			//FontsResourceFactory.getInstance().registerFont("chinese_unicode.ttf", new chinese() );
			/*
			var map1: ICMap = new CMap( new CMap.UniJIS_UCS2_V() );
			var map2: ICMap = new CMap( new CMap.UniJIS_UCS2_H() );
			var map3: ICMap = new CMap( new CMap.Adobe_Japan1_UCS2() );
			CMapResourceFactory.getInstance().registerCMap( BaseFont.UniJIS_UCS2_V, map1 );
			CMapResourceFactory.getInstance().registerCMap( BaseFont.UniJIS_UCS2_H, map2 );
			CMapResourceFactory.getInstance().registerCMap( BaseFont.AdobeJapan1_UCS2, map3 );
			// load and register a property
			//var prop: IProperties = new Properties();
			//prop.load( new BuiltinCJKFonts.KozMinPro_Regular() );
			//CJKFontResourceFactory.getInstance().registerProperty( BuiltinCJKFonts.getFontName( BuiltinCJKFonts.KozMinPro_Regular ), prop );
			*/
			isRotate =  rotate;
			buffer = new ByteArray();
			var writer:PdfWriter = PdfWriter.create( buffer, PageSize.A4 );
			document = writer.pdfDocument;
			if(logo){
				marginTop = 100;
			}
			if(rotate)
				document.pageSize = PageSize.A4.rotate();
			//941 pdf header not display CRO
			if(title != null &&  title!=""){
				document.setMargins(30,30,50,40);
			}else{
				//document.setMargins(30,30,100,50);
				document.setMargins(30,30,marginTop,50);
			}
			var bf: BaseFont = BaseFont.createFont( "arial.ttf", BaseFont.IDENTITY_H, true, true );
			var font: Font = new Font( -1. -1, 16, org.purepdf.Font.BOLD, null, bf );
			var h:HeaderFooter =new HeaderFooter(new Phrase(title,font,0),null,false);
			h.borderWidthTop = 0;
			h.border = 0;
			h.height 10;
			document.setHeader(h);
			//----------------
			var currentUser:Object= Database.allUsersDao.ownerUser();
			if(currentUser != null && currentUser.hasOwnProperty("FirstName")){
				var author:String = (currentUser.FirstName ==null?"":currentUser.FirstName) + " " + (currentUser.LastName==null?"":currentUser.LastName) ;
				document.addAuthor( author );
			}
			//document.addTitle( getQualifiedClassName(( this ) );
			document.addCreator( "http://desktop.crm-gadget.com" );
			if( title ) 
				document.addSubject( title );
			//document.addKeywords( "itext,purepdf" );
			document.setViewerPreferences( PdfViewPreferences.FitWindow );
			document.addEventListener(PageEvent.PAGE_END,onEndPage);
			document.open();
			addLogo(logo,document,logoWidth,logoHeight,rotate);
			return document;
		}
		
		public function addLogo(bytes:ByteArray,document:PdfDocument,width:int,height:int,rotate:Boolean=false):void{
			if(bytes != null){
				//logo 
				var img: ImageElement = ImageElement.getInstance( bytes );
				var imageHeight:int = 40;
				var imageWidth:int = width * imageHeight / height;
				img.scaleToFit(imageWidth,imageHeight);
				img.alignment = ImageElement.RIGHT;
				
				var cb: PdfContentByte = document.getDirectContent();
				cb.saveState();
				cb.restoreState();
				if(rotate){
					img.setAbsolutePosition(PageSize.A4.height - ( imageWidth + 30) ,PageSize.A4.width - 70);
				}else{
					img.setAbsolutePosition(PageSize.A4.width - ( imageWidth + 30) ,PageSize.A4.height - 70);
					
				}
				cb.addImage( img );
			}
		}
		
		protected function onEndPage( event: PageEvent ):void{
			if(document.pageNumber>1){
				addLogo(logo,document,logoWidth,logoHeight,isRotate);
			}
		}
		
		public function getByteArray():ByteArray{
			return buffer;
		}
	}
}