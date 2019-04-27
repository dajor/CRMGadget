package com.fellow.dto;

import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "header")
public class DtoHeaders {
	
	@XmlAttribute(name="title")
	private String title;

	@XmlElement(name = "row")
	private List<DtoRow> rows;
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public List<DtoRow> getRows() {
		return rows;
	}
	public void setRows(List<DtoRow> row) {
		this.rows = row;
	}
	
	
	
}
