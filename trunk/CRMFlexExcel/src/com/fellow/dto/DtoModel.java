package com.fellow.dto;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "model")
public class DtoModel {
	@XmlAttribute(name="title")
	private String title;
	@XmlAttribute(name = "type")
	private String type;
	
	@XmlElement(name="account")
	private DtoAccount account;
	@XmlElement(name="page")
	private List<DtoPages> pages = new ArrayList<DtoPages>(0);
	@XmlElement(name="header")
	private DtoHeaders header;
	@XmlElement(name="modelTotal")
	private DtoModelTotal modelTotal;
	
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public List<DtoPages> getPages() {
		return pages;
	}
	public void setPages(List<DtoPages> pages) {
		this.pages = pages;
	}
	public DtoAccount getAccount() {
		return account;
	}
	public void setAccount(DtoAccount account) {
		this.account = account;
	}
	public DtoHeaders getHeader() {
		return header;
	}
	public void setHeader(DtoHeaders header) {
		this.header = header;
	}
	public DtoModelTotal getModelTotal() {
		return modelTotal;
	}
	public void setModelTotal(DtoModelTotal modelTotal) {
		this.modelTotal = modelTotal;
	}
	
	
	
}
