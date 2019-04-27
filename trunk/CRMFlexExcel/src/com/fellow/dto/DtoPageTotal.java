package com.fellow.dto;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "pageTotal")
public class DtoPageTotal {
	@XmlElement(name="row")
	private List<DtoRow> rows = new ArrayList<DtoRow>(0);
	public List<DtoRow> getRows() {
		return rows;
	}
	public void setRows(List<DtoRow> rows) {
		this.rows = rows;
	}
}
