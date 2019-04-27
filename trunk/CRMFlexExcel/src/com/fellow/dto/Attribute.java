package com.fellow.dto;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

import org.apache.poi.ss.formula.functions.Value;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "Attribute")
@XmlType(propOrder = { "attributeId","description","values"})
public class Attribute {

@XmlElement(name="AttributeId")
protected String attributeId;

@XmlElement(name="Description")
protected String description;

@XmlElementWrapper(name = "Values")
@XmlElement(name = "Value")
protected List<Value> values=new ArrayList<Value>();


public String getAttributeId() {
return attributeId;
}


public void setAttributeId(String attributeId) {
this.attributeId = attributeId;
}


public String getDescription() {
return description;
}


public void setDescription(String description) {
this.description = description;
}


public List<Value> getValues() {
return values;
}


public void setValues(List<Value> values) {
this.values = values;
}




}

