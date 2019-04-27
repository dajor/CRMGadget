package com.fellow.dto;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "row")
public class DtoRow {
		@XmlAttribute(name="title")
		private String title;
		@XmlAttribute(name="colspan")
		private int colspan;
		@XmlAttribute(name="isheader")
		private boolean header;
		@XmlAttribute(name="value")
		private String value;
		@XmlAttribute(name="odd")
		private boolean odd;
		
		public String getTitle() {
			return title;
		}
		public void setTitle(String title) {
			this.title = title;
		}
		@XmlElement(name="col")
		private List<DtoColumn> columns = new ArrayList<DtoColumn>(0);
		public List<DtoColumn> getColumns() {
			return columns;
		}
		public void setColumns(List<DtoColumn> columns) {
			this.columns = columns;
		}
		public String getValue() {
			return value;
		}
		public void setValue(String value) {
			this.value = value;
		}
		
		public boolean isHeader() {
			return header;
		}
		public void setHeader(boolean header) {
			this.header = header;
		}
		public int getColspan() {
			return colspan;
		}
		public void setColspan(int colspan) {
			this.colspan = colspan;
		}
		public boolean isOdd() {
			return odd;
		}
		public void setOdd(boolean odd) {
			this.odd = odd;
		}
		
		
		
}
