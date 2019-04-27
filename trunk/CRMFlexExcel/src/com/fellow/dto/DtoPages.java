package com.fellow.dto;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "page")
public class DtoPages {
	@XmlAttribute(name="title")
	private String title;
	
	@XmlElement(name="pageTotal")
	private DtoPageTotal pageTotal;
	
	@XmlElement(name="Section")
	private List<DtoSections> sections = new ArrayList<DtoSections>(0);
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public List<DtoSections> getSections() {
		return sections;
	}
	public void setSections(List<DtoSections> sections) {
		this.sections = sections;
	}
	public DtoPageTotal getPageTotal() {
		return pageTotal;
	}
	public void setPageTotal(DtoPageTotal pageTotal) {
		this.pageTotal = pageTotal;
	}
	
	
}
