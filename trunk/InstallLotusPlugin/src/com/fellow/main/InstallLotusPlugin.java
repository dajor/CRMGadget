package com.fellow.main;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class InstallLotusPlugin {
	private static final String INCORRECT_PATH = "Incorrect lotus notes path";
	private static final String LABEL = "label";
	private static final String NAME = "name";
	private static final String CATEGORY_DEF = "category-def";
	private static final String FEATURE = "feature";
	private static final String VERSION = "version";
	private static final String URL = "url";
	private static final String ID = "id";
	public static final String PREFERENCE_FILE = "com/fellow/lotus/views/Preference.xml";
	private String pluginFolder = "/workspace/applications/eclipse/plugins";
	private String featureFolder = "/workspace/applications/eclipse/features";
	public byte[] getContentOfZipEntryFromZipInputStream(ZipInputStream in)
			throws IOException {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		byte buf[] = new byte[1024];
		int len;
		while ((len = in.read(buf)) > 0) {
			out.write(buf, 0, len);
		}
		out.flush();
		out.close();
		return out.toByteArray();
	}
	public  byte[] docToByteArray(Document doc) throws IOException {
		Format format = Format.getPrettyFormat();
		format.setEncoding("UTF-8");
		XMLOutputter xmlOut = new XMLOutputter(format);
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		xmlOut.output(doc, out);
		out.flush();
		out.close();
		return out.toByteArray();
	}
	
	
	
	
	
	public void installFile(String lotusInstallPath) throws Exception {

		try {
			
			pluginFolder = lotusInstallPath + pluginFolder;
			featureFolder = lotusInstallPath + featureFolder;
			File pluginsFolder = new File(lotusInstallPath+"/workspace/.config/org.eclipse.update/platform.xml");
			if(!pluginsFolder.exists()){
				System.out.println(INCORRECT_PATH);
				return;
			}
			DocumentBuilderFactory icFactory = DocumentBuilderFactory.newInstance();
		    DocumentBuilder icBuilder = icFactory.newDocumentBuilder();
		    org.w3c.dom.Document doc = icBuilder.parse(pluginsFolder);
			Map<String, String> map = getMapVersion();
			//SAXBuilder builder = new SAXBuilder();
			//FileInputStream is = new FileInputStream(pluginsFolder);
//			org.w3c.dom.Document doc = builder.build(is);
			if(doc == null){
				System.out.println("missing file platform.xml");
				return;
			}
	
			NodeList listSite = doc.getElementsByTagName("site");
			
			org.w3c.dom.Element addNewPlugin = null;
			NodeList features = null;
			if(listSite != null && listSite.getLength()>0){
				for(int i=0;i<listSite.getLength();i++){
					Node node = listSite.item(i);
				
					String url = node.getAttributes().getNamedItem(URL)==null?"":node.getAttributes().getNamedItem(URL).getNodeValue();
					if(url.contains("/applications/eclipse/")){
						features = node.getChildNodes();
						if(features != null && features.getLength()>0){
							for(int j=0;j<features.getLength();j++){
								Node element = features.item(j);
								if(element.getAttributes()!=null){
									String id = element.getAttributes().getNamedItem(ID)==null?"":element.getAttributes().getNamedItem(ID).getNodeValue();
									if(id.equals("com.fellow.lotus.feature") && element.getNodeType() == Node.ELEMENT_NODE){
										addNewPlugin = (org.w3c.dom.Element)element;
										
									}
								}
								
							}
						}
						break;
					}
				}
			}
			if(features == null){
				System.out.println("not found applications path");
				return;
			}
			if(addNewPlugin == null ){
				addNewPlugin = doc.createElement(FEATURE);
				((Node)features).appendChild(addNewPlugin);
			}else{
				removeFileOrFolder(pluginFolder);
				removeFileOrFolder(featureFolder);
			}
			addNewPlugin.setAttribute(ID, map.get(ID));
			addNewPlugin.setAttribute(URL, map.get(URL));
			addNewPlugin.setAttribute(VERSION, map.get(VERSION));
			
			
		
			
//			byte[] bytes = docToByteArray(doc);
//			OutputStream out = new FileOutputStream(pluginsFolder);
//			out.write(bytes);
//			out.close();
			Transformer transformer = TransformerFactory.newInstance().newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes"); 
            DOMSource source = new DOMSource(doc);
            StreamResult result = new StreamResult(pluginsFolder);
            transformer.transform(source, result);
			String name = map.get(ID)+"_"+map.get(VERSION);
			copyFeature(name);
			copyPlugin(name);
			
			System.out.println("Plugin has been installed succesfully");
		} catch (IOException e) {
			System.out.println(e.getMessage());
			e.printStackTrace();
		}
	}
	private static void copyFile(File source, File dest) throws IOException {
	
	    InputStream input = null;
	
	    OutputStream output = null;
	
	    try {
	
	        input = new FileInputStream(source);
	
	        output = new FileOutputStream(dest);
	
	        byte[] buf = new byte[1024];
	
	        int bytesRead;
	
	        while ((bytesRead = input.read(buf)) > 0) {
	
	            output.write(buf, 0, bytesRead);
	
	        }
	
	    } finally {
	
	        input.close();
	
	        output.close();
	
	    }
	
	}
	private void removeFileOrFolder(String folder ){
		File pluginsFolder = new File(folder);
		for(File f:pluginsFolder.listFiles()){
			if(f.getName().contains("com.fellow.lotus")){
				if(f.isDirectory()){
					removeSubFolder(f);
				}
				f.delete();
			}
		}
	}
	private void removeSubFolder(File f){
		File[] list = f.listFiles();
        if (list != null) {
            for (int i = 0; i < list.length; i++) {
                File tmpF = list[i];
                if (tmpF.isDirectory()) {
                	removeSubFolder(tmpF);
                }
                tmpF.delete();
            }
        }
	}
	private void checkCreateFolder(String folderName){
		File folder = new File(folderName);
		if(!folder.exists()){
			folder.mkdir();
		}
	}
	private void copyPlugin(String folderName) throws Exception{
		String path = new File("").getAbsolutePath();
		File pluginsFolder = new File(path+"/plugins");
		if(!pluginsFolder.exists()){
			System.out.println(INCORRECT_PATH);
			return;
		}

		File jarFile = getJarFile(pluginsFolder);
		copyFile(jarFile, new File(pluginFolder+"/"+jarFile.getName()));
	}
	private File getJarFile(File pluginsFolder){
		File jarFile = null;
		for(File f:pluginsFolder.listFiles()){
			if(f.getName().endsWith(".jar")){
				jarFile = f;
				break;
			}
		}
		return jarFile;
	}
	private void copyFeature(String folderName) throws Exception{
		String path = new File("").getAbsolutePath();
		File pluginsFolder = new File(path+"/features");
		if(!pluginsFolder.exists()){
			System.out.println("missing features folder");
			return;
		}
		String folderPath = featureFolder+"/"+folderName;
		checkCreateFolder(folderPath);
		
		File jarFile = getJarFile(pluginsFolder);
		
		if(jarFile==null){
			System.out.println("missing jar file");
			return;
		}
		InputStream in = new FileInputStream(jarFile);
		ZipInputStream zipIs = new ZipInputStream(in);
		ZipEntry entry = null;
		
		
		while ((entry = zipIs.getNextEntry()) != null) {
			String filename = folderPath+"/"+entry.getName();
			if(entry.getName().contains(folderName)){
				continue;
			}
			File f = new File(filename);
			if(filename.endsWith("/")){
				f.mkdir();
			}else{
				byte[] content = getContentOfZipEntryFromZipInputStream(zipIs);
				OutputStream out = new FileOutputStream(f);
				out.write(content);
				out.close();
			}

		}
		
		
		//zipOut.putNextEntry(new ZipEntry(folderPath));

		in.close();
		zipIs.close();
		

	}
	private Map<String, String> getMapVersion() throws Exception{
		Map<String, String> version = new HashMap<String, String>(0);
		SAXBuilder builder = new SAXBuilder();
		String path = new File("").getAbsolutePath();
		File prefFile = new File(path,"site.xml");
		if(!prefFile.exists()){
			System.out.println("missing site.xml");
			return version;
		}
		FileInputStream is = new FileInputStream(prefFile);
		Document doc = builder.build(is);
		if(doc == null  || doc.getRootElement() == null){
			return version;
		}
		Element root =doc.getRootElement();
		Element feature = root.getChild(FEATURE);
		String v = feature.getAttributeValue(VERSION);
		String id = feature.getAttributeValue(ID);
		String url = feature.getAttributeValue(URL);
		version.put(URL, url.replace(".jar", "/"));
		version.put(ID, id);
		version.put(VERSION, v);
		Element category = root.getChild(CATEGORY_DEF);
		version.put(NAME, category.getAttributeValue(NAME));
		version.put(LABEL, category.getAttributeValue(LABEL));
		return version;
	}
	public static void main(String[] args) {
		try {
			String arg = "";
//			String arg = "C:/Program Files (x86)/IBM/Lotus/Notes/Data";
			if(args != null && args.length>0){
				arg = args[0];
				
			}
//			System.out.println(arg);
			new InstallLotusPlugin().installFile(arg);
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
		
	}

}
