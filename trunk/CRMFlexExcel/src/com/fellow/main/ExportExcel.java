package com.fellow.main;

import java.awt.Font;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Unmarshaller;

import org.apache.commons.lang.StringUtils;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFPalette;
import org.apache.poi.hssf.usermodel.HSSFRichTextString;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.util.CellRangeAddress;

import com.fellow.dto.DtoColumn;
import com.fellow.dto.DtoHeaders;
import com.fellow.dto.DtoModel;
import com.fellow.dto.DtoModelTotal;
import com.fellow.dto.DtoPageTotal;
import com.fellow.dto.DtoPages;
import com.fellow.dto.DtoRow;
import com.fellow.dto.DtoSections;




public class ExportExcel {
	private static final String TRYGGMAT = "Tryggmat";
	private static final String BUTIKS = "Butiks";
	private static final String MILJO = "Miljö";
	protected static final short SHEET_EXPORT = 0;
	private HSSFWorkbook workBook = null;
	private HSSFSheet sheet = null;
	private HSSFCellStyle styleGrey =null;
	private HSSFCellStyle styleBlack = null;
	private HSSFCellStyle styleBlackBoldCenter = null;
	private HSSFCellStyle styleGreen = null;
	private HSSFCellStyle styleGreenLeft = null;
	private HSSFCellStyle styleNomal =null;
	private HSSFCellStyle styleUnlock =null;
	private HSSFCellStyle defualtStyle;
	private boolean isFoersaeljningsledare = false;
	
	private String template_name = "";
	public void exportExcel(String fpath){
//		fpath ="C:/Users/ASUS/Desktop/KiB Miljö_testFC_2014.10.13.17.32.01.xml";
		//fpath = "C:\Users\ASUS\AppData\Local\Temp\flaA67E.tmp\KiB Tryggmat_ICA_Nära_Duvbo_2014.06.19.11.38.27.xml";
//		fpath = fpath.replaceAll("\\", "/");
		File f = new File(fpath);
		File folder = f.getParentFile();
		//DataOutputStream dataOutputStream = new DataOutputStream(System.out);
		
		try{
			DtoModel dtoModel = (DtoModel) loadData(DtoModel.class, fpath);  
			String type = dtoModel.getType();
			if(MILJO.equalsIgnoreCase(type)){
				template_name = "Miljo.xls";
				
			}else if(BUTIKS.equalsIgnoreCase(type)){
				template_name = "Foersaeljningsledare.xls";
				isFoersaeljningsledare = true;
				
			}else if(TRYGGMAT.equalsIgnoreCase(type)){
				template_name = "Tryggmat.xls";
				
			}
			workBook =  getWorkBook();
			ByteArrayOutputStream out=new ByteArrayOutputStream();
	        
	        HSSFColor color = null;
			if(MILJO.equalsIgnoreCase(type)){				
				color = getColor(workBook,HSSFColor.BLUE_GREY.index,153,204,0);
			}else if(BUTIKS.equalsIgnoreCase(type)){				
				isFoersaeljningsledare = true;
				color =getColor(workBook,HSSFColor.BLUE_GREY.index,204,0,0);
			}else if(TRYGGMAT.equalsIgnoreCase(type)){				
				color = getColor(workBook,HSSFColor.BLUE_GREY.index,255,51,0);
			}
			
			if(workBook != null){
			
				sheet = getSheet(workBook);
				defualtStyle=workBook.createCellStyle();
				setCellBorder(defualtStyle);
				//style.setAlignment(HSSFCellStyle.ALIGN_LEFT);
				int startRow = 2;
				/*
				HSSFRow row=sheet.getRow(0);
				HSSFCell cell = row.getCell(0);
				
				HSSFFont redFont = workBook.createFont();
				redFont.setColor(HSSFColor.RED.index);
				redFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
				HSSFFont whiteFont = workBook.createFont();
				whiteFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
				whiteFont.setColor(HSSFColor.WHITE.index);
				
				
				String header = dtoModel.getHeader()==null?"":dtoModel.getHeader().getTitle();
				dtoModel.getHeader().getTitle();
				
				
				HSSFCellStyle style = createFillBackGroundColor(workBook, HSSFColor.BLACK.index, null);
				style.setAlignment(HSSFCellStyle.ALIGN_CENTER);
				// assign the style to the cell
				cell.setCellStyle(style);
				
				HSSFRichTextString text = new HSSFRichTextString();
				text.setString(header);
				if(header != null && header.length()>3){
					text.applyFont(0, 3, redFont);
					text.applyFont(4, header.length(), whiteFont);
				}
				
				cell.setCellValue(text);
				*/
				// styleGreen = header color of table
				styleGreen = createFillBackGroundColor(workBook, color.getIndex(), null);
				
				HSSFFont font = workBook.createFont();
				font.setFontName(HSSFFont.FONT_ARIAL);
			    //font.setFontHeightInPoints((short)10);
			    font.setColor(IndexedColors.WHITE.getIndex());
			    styleGreen.setFont(font);
			    styleGreen.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
			    styleGreen.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
			    
			    styleGreenLeft = createFillBackGroundColor(workBook, color.getIndex(), null);
			    styleGreenLeft.setFont(font);
			    styleGreenLeft.setAlignment(HSSFCellStyle.ALIGN_LEFT);
			    styleGreenLeft.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
			    
				styleGrey = createFillBackGroundColor(workBook, getColor(workBook,HSSFColor.DARK_BLUE.index,192,192,192).getIndex(), null);
				styleBlack = createFillBackGroundColor(workBook, HSSFColor.BLACK.index, null);
			    styleBlack.setFont(font);
				
			    styleBlackBoldCenter = createFillBackGroundColor(workBook, HSSFColor.BLACK.index, null);
			    HSSFFont fontBold = workBook.createFont();
				font.setFontName(HSSFFont.FONT_ARIAL);
				fontBold.setColor(IndexedColors.WHITE.getIndex());
				fontBold.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
			    styleBlackBoldCenter.setFont(font);
			    styleBlackBoldCenter.setAlignment(HSSFCellStyle.ALIGN_CENTER);
			    
			    
				styleNomal = (HSSFCellStyle)workBook.createCellStyle();
				styleNomal.setAlignment(HSSFCellStyle.ALIGN_LEFT);
				
				styleUnlock = (HSSFCellStyle)workBook.createCellStyle();
				styleUnlock.setAlignment(HSSFCellStyle.ALIGN_LEFT);
				
				styleGrey.setAlignment(HSSFCellStyle.ALIGN_LEFT);
				setCellBorder(styleGreen);
				setCellBorder(styleGrey);
				setCellBorder(styleNomal);
				setCellBorder(styleBlack);
				setCellBorder(styleGreenLeft);
				setCellBorder(styleUnlock);
				
				startRow = createTableHeader(dtoModel,startRow);
				
				// sum field
				
				startRow = startRow+  1;
				startRow = createModelTotal(dtoModel,startRow) + 1;
				// create page
				
				createPageSection(dtoModel,startRow);
				
			}
			
			workBook.write(out);
			/*dataOutputStream.write(out.toByteArray());

			 dataOutputStream.flush();

			 dataOutputStream.close();*/
			// String s = new String(out.toByteArray(),"UTF-8");
			
		//	String content = new String(Base64.encodeBase64(out.toByteArray()));
//			System.out.println(content);
			
			/*File filetest = new File("C:/Users/ASUS/Desktop/Test.xls");
			FileOutputStream nfielTest = new FileOutputStream(filetest);
			nfielTest.write(out.toByteArray());*/
			
			String fName = f.getName().replace("xml", "xls");
//			fName = URLEncoder.encode(fName, "UTF-8");
			File file = new File(folder,fName);
			FileOutputStream nfiel = new FileOutputStream(file);
			nfiel.write(out.toByteArray());
			out.close();
			nfiel.close();
			//byte[] theByteArray = stringToConvert.getBytes();    

			/*DataOutputStream dataOutputStream = new DataOutputStream(System.out);

			dataOutputStream.write(out.toByteArray());

			dataOutputStream.flush();   */
			System.out.println(file.getAbsolutePath().replaceAll("\\\\", "/"));
//			System.out.println(fName);
		}catch(Exception e){
			/*final Writer result = new StringWriter();
			final PrintWriter printWriter = new PrintWriter(result);
			e.printStackTrace(printWriter);*/

			//System.out.println("Error: "+fpath+"," + result.toString());
			throw new RuntimeException(e);
		}

	}
	 public HSSFColor getColor(HSSFWorkbook workbook, short index, int red, int green, int blue) {
		 HSSFPalette palette = workbook.getCustomPalette();
		 HSSFColor hssfColor = null;

		 hssfColor = palette.findColor((byte)red, (byte)green, (byte)blue);
		 if (hssfColor == null) {
			
		 palette.setColorAtIndex(index, (byte)red, (byte)green, (byte)blue);
		 hssfColor = palette.getColor(index);
		 }

		 return hssfColor;
		 }

	private void setCellBorder(HSSFCellStyle style){
		style.setBorderLeft(HSSFCellStyle.BORDER_THIN);             
		style.setBorderRight(HSSFCellStyle.BORDER_THIN);            
		style.setBorderTop(HSSFCellStyle.BORDER_THIN);              
		style.setBorderBottom(HSSFCellStyle.BORDER_THIN);
        style.setBottomBorderColor(HSSFColor.BLACK.index);
        style.setTopBorderColor(HSSFColor.BLACK.index);
        style.setRightBorderColor(HSSFColor.BLACK.index);
        style.setLeftBorderColor(HSSFColor.BLACK.index);
//		style.setBorderColor(HSSFCellStyle.LEFT,new HSSFColor(new Color(0,0,0)));
//		style.setBorderColor(BorderSide.RIGHT,new HSSFColor(new Color(0,0,0)));
//		style.setBorderColor(BorderSide.TOP,new HSSFColor(new Color(0,0,0)));
//		style.setBorderColor(BorderSide.BOTTOM,new HSSFColor(new Color(0,0,0)));
	}
	private int createModelTotal(DtoModel dtoModel,int startRow){
		HSSFCellStyle style = styleNomal;
		DtoModelTotal modelTotal = dtoModel.getModelTotal();
		if(modelTotal != null && modelTotal.getRows() != null && modelTotal.getRows().size()>0){
			
			int startCol = 0;
			int endCol = 0;
			if(isFoersaeljningsledare){
				endCol = 8;
			}
			int indRow = 0;
			for(DtoRow row : modelTotal.getRows()){
				HSSFRow qRow=sheet.getRow(startRow);
				if(qRow == null){
					qRow=sheet.createRow(startRow);
				}
				if(isFoersaeljningsledare){
					mergeCell(startRow, startCol, endCol, qRow,defualtStyle);
				}
				if(indRow == 0){
					if(!isFoersaeljningsledare){
						qRow.setHeight((short)(qRow.getHeight()*3));
					}
					
					
					style = styleGreenLeft;
					
					fillCell(qRow, 0,"", HSSFCell.CELL_TYPE_STRING, true,styleGreen);
//					style.setAlignment(HorizontalAlignment.LEFT);
					
					
					
				}else if(indRow == 1){
					style = styleGrey;
//					style.setAlignment(HorizontalAlignment.LEFT);
					fillCell(qRow, 0,row.getTitle(), HSSFCell.CELL_TYPE_STRING, true,styleGreen);
				}
				if(indRow == 2){
					
//					sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, 1, 9));
					mergeCell(startRow, 1, 9, qRow,styleNomal);
					fillCell(qRow, 0,row.getTitle(), HSSFCell.CELL_TYPE_STRING, true,styleGreen);
					//style.setAlignment(HorizontalAlignment.LEFT);
					style = null;
				}else{
					if(!isFoersaeljningsledare){
//						sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, 6, 9));
						mergeCell(startRow, 6, 9, qRow,styleNomal);
						fillCell(qRow, 7,"", HSSFCell.CELL_TYPE_STRING, true,styleGreen);
					}
					
				}
				
//				sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, startCol, endCol));
				List<DtoColumn> cols = row.getColumns();
				int c = endCol+1;
				if(cols != null && cols.size()>0){
					for(DtoColumn col : cols){
						fillCell(qRow, c,col.getValue(), HSSFCell.CELL_TYPE_STRING, true,style);
						
						c++;
					}
				}
				indRow++;
				startRow++;
			}
		}
		sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, 0, 9));
		return startRow;
	}
	private void mergeCell(int startRow,int startCol,int endCol,HSSFRow row,HSSFCellStyle style){
		sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, startCol, endCol));
		for(int i=startCol;i<=endCol;i++){
			fillCell(row, i,"", HSSFCell.CELL_TYPE_STRING, true,style);
		}
	}
	private int createPageSection(DtoModel dtoModel,int startRow){
		List<DtoPages> pages = dtoModel.getPages();
		if(pages != null && pages.size()>0){
			
			HSSFCellStyle style = styleNomal;
			
			for(DtoPages page : pages){
				
				HSSFRow row=sheet.getRow(startRow);
				if(row == null){
					row=sheet.createRow(startRow);
				}
				sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, 0, 9));
				fillCell(row, 0, page.getTitle(), HSSFCell.CELL_TYPE_STRING, true,null);
				
				startRow++;
				
				List<DtoSections> sections = page.getSections();
				if(sections != null && sections.size()>0){
					for(DtoSections dtoSect : sections){
						
						
						List<DtoRow> dtoRow = dtoSect.getRows();
						if(dtoRow != null && dtoRow.size()>0){
							for(DtoRow r : dtoRow){
								
								List<DtoColumn> lstQ = r.getColumns();
								HSSFRow qRow=sheet.getRow(startRow);
								if(qRow == null){
									qRow=sheet.createRow(startRow);
								}
								if(r.isHeader()){
									style = styleBlack;
								}else if(!r.isOdd()){
									style = styleGrey;
								}else{
									style = styleNomal;
								}
								int c = 1;
								if(r.getColspan()>0){
									style = styleGrey;
//									sheet.addMergedRegion(new CellRangeAddress(startRow,startRow,0,r.getColspan()));
									mergeCell(startRow, 0, r.getColspan(), qRow, defualtStyle);
								}else if(isFoersaeljningsledare){
//									sheet.addMergedRegion(new CellRangeAddress(startRow,startRow,0,6));
//									sheet.addMergedRegion(new CellRangeAddress(startRow,startRow,8,9));
									mergeCell(startRow, 0, 6, qRow, defualtStyle);
									mergeCell(startRow, 8, 9, qRow, defualtStyle);
									c=7;
								}
								fillCell(qRow, 0, r.getTitle(), HSSFCell.CELL_TYPE_STRING, true, style);
								
								if(lstQ != null && lstQ.size()>0){
									for(DtoColumn colQ : lstQ){
										boolean lock = true;
										int cellStyle = HSSFCell.CELL_TYPE_STRING;
										try{
											Double.parseDouble(colQ.getValue());
											cellStyle = HSSFCell.CELL_TYPE_NUMERIC;
										}catch(NumberFormatException nfe){
											if(!isFoersaeljningsledare && c > 6 && r.isHeader()==false){
												
												lock = false;
												style = styleUnlock;
												
											}
											
										}
										fillCell(qRow, c, colQ.getValue(), cellStyle, lock,style);
										c++;
									}
								}
								startRow ++;
								
							}
						}
						
					}
					
				}
				sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, 0, 9));
				startRow = startRow + 1;
				createPageTotal(page,startRow);
				sheet.addMergedRegion(new CellRangeAddress(startRow+2, startRow+2, 0, 9));
				startRow = startRow + 3;
			}
			
		}
		return startRow;
	}
	private void createPageTotal(DtoPages page,int startRow){
//		HSSFCellStyle styleBlack = createFillBackGroundColor(workBook, new HSSFColor(new Color(0,0,0)), null);
		HSSFCellStyle style = styleNomal;
		DtoPageTotal pageTotal = page.getPageTotal();
		if(pageTotal != null && pageTotal.getRows()!= null && pageTotal.getRows().size()>0){
			
			for(DtoRow row : pageTotal.getRows()){
				int c=1;
				

				HSSFRow qRow=sheet.getRow(startRow);
				if(qRow == null){
					qRow=sheet.createRow(startRow);
				}
				if(isFoersaeljningsledare){
//					sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, 0, 8));
					mergeCell(startRow, 0, 8, qRow,styleNomal);
					c = 9;
				}else{
//					sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, 0, 4));
					//mergeCell(startRow, 0, 4, qRow,styleNomal);
					fillCell(qRow, 1, "", HSSFCell.CELL_TYPE_STRING, true, style);
					fillCell(qRow, 2, "", HSSFCell.CELL_TYPE_STRING, true, style);
					fillCell(qRow, 3, "", HSSFCell.CELL_TYPE_STRING, true, style);
					fillCell(qRow, 4, "", HSSFCell.CELL_TYPE_STRING, true, style);
				}
				if(StringUtils.isNotBlank(row.getTitle())){
					style = styleBlack;
					fillCell(qRow, 0, row.getTitle(), HSSFCell.CELL_TYPE_STRING, true, style);
				}else{
					style = styleGrey;
					fillCell(qRow, 0, "", HSSFCell.CELL_TYPE_STRING, true, style);
				}
				
				
				
				for(DtoColumn col : row.getColumns()){
					fillCell(qRow, c, col.getValue(), HSSFCell.CELL_TYPE_STRING, true, style);
					c++;
				}
				startRow++;
				
			}
			
		}
	}
	private int createTableHeader(DtoModel dtoModel,int startRow){
		DtoHeaders header = dtoModel.getHeader();
		
		if(StringUtils.isNotBlank(header.getTitle())){
			if(isFoersaeljningsledare){
				sheet.addMergedRegion(new CellRangeAddress(2, 2, 0, 9));
			    sheet.addMergedRegion(new CellRangeAddress(3, 3, 0, 9));
				// replace title
				HSSFRow row=sheet.getRow(2);
				if(row == null){
					row=sheet.createRow(2);
				}
				HSSFCellStyle style =  styleBlackBoldCenter;
				
			    
				fillCell(row, 0, header.getTitle(), HSSFCell.CELL_TYPE_STRING, true,style);
				startRow = 4;
			}else{
				
				HSSFRow row=sheet.getRow(0);//head row cannot null,because we have default font
				String title = StringUtils.trim(header.getTitle());
				if(StringUtils.startsWithIgnoreCase(title, "ICA")){
					HSSFFont redFont = sheet.getWorkbook().createFont();					
					redFont.setColor(HSSFColor.RED.index);					
					redFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
					
					HSSFFont witheFont = workBook.createFont();						
					witheFont.setColor(IndexedColors.WHITE.getIndex());
					witheFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);					
					// override the parts of the text that you want to
					// color differently by applying a different font.
					HSSFRichTextString richString = new HSSFRichTextString(header.getTitle());
					richString.applyFont(0, 3, redFont);
					richString.applyFont(3, title.length(), witheFont);
					HSSFCell cell = row.getCell(0);
					cell.setCellValue(richString);
				}else{
					fillCell(row, 0, header.getTitle(), HSSFCell.CELL_TYPE_STRING, true,styleBlackBoldCenter);
				}
				
				
			}
		}
		
		//HSSFCellStyle styleVal = sheet.getRow(2).getCell(1).getCellStyle();
		for(int i=0;i<header.getRows().size();i++){
			HSSFRow row=sheet.getRow(startRow);
			if(row == null){
				row=sheet.createRow(startRow);
			}
			//sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, 0, 2));
//			sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, 1, 9));
			mergeCell(startRow, 1, 9, row,styleNomal);
			DtoRow rowHeader = header.getRows().get(i);
			
			fillCell(row, 0, rowHeader.getTitle(), HSSFCell.CELL_TYPE_STRING, true,styleGreen);
			fillCell(row, 1, rowHeader.getValue(), HSSFCell.CELL_TYPE_STRING, true,styleNomal);
			startRow++;
		}		
		sheet.createRow(startRow);
		sheet.addMergedRegion(new CellRangeAddress(startRow, startRow, 0, 9));
		return startRow;
	}
	
	
	protected HSSFCellStyle createFillBackGroundColor(HSSFWorkbook workBook, short color, HSSFCellStyle oldStyle) {
		HSSFCellStyle style = workBook.createCellStyle();
		if (oldStyle != null) {
			style.cloneStyleFrom(oldStyle);
		
		}
		else {
		style = workBook.createCellStyle();
		
		}

		style.setFillPattern(HSSFCellStyle.FINE_DOTS);
		style.setFillForegroundColor(color);
		style.setFillBackgroundColor(color);
		return style;
		}

	public HSSFWorkbook getWorkBook(){
		try {
			
			return new HSSFWorkbook(ExportExcel.class.getResourceAsStream(template_name));
		} catch (IOException e) {
			
			System.out.println(e.getMessage());
		}
		return null;
	}
	public HSSFSheet getSheet(HSSFWorkbook workBook){
		return workBook.getSheetAt(SHEET_EXPORT);
	}
	
	
	protected  HSSFCell fillCell(HSSFRow r, int cellnr, String content,int type,boolean isLock,HSSFCellStyle style) {
		
		HSSFCell cell = r.getCell(cellnr);
		if (cell==null) {
			cell = r.createCell(cellnr);
			
			
		}
		//type = cell.getCellType();		
		//cell.setCellType(type);
		if(style == null){
			style = cell.getCellStyle();
			style.setAlignment(HSSFCellStyle.ALIGN_LEFT);
			//setCellBorder(style);
		}
		
		style.setWrapText(true);
		style.setLocked(isLock);
		cell.setCellStyle(style);
		
		
		if(type==HSSFCell.CELL_TYPE_BOOLEAN){
			if(StringUtils.isNotBlank(content)){
				cell.setCellValue(Boolean.valueOf(content));
			}else{
				//if  value null
				cell.setCellValue(new HSSFRichTextString());
			}
		}else if(type==HSSFCell.CELL_TYPE_NUMERIC){
			if(StringUtils.isNotBlank(content)){
				cell.setCellValue(Double.valueOf(content));	
			}else{
				//if value null
				cell.setCellValue(new HSSFRichTextString());
			}
		}else if(type==HSSFCell.CELL_TYPE_STRING){
			cell.setCellValue(content);
		}	
	
		return cell;
	}
	protected Object loadData(Class<?> responseCls, String fileName) throws Exception {

		
		JAXBContext jc = JAXBContext.newInstance(responseCls);
		Unmarshaller marshal = jc.createUnmarshaller();
		FileInputStream is = new FileInputStream(fileName);
		try{
		return marshal.unmarshal(is);
		}finally{
			is.close();
		}
		
		}
}
