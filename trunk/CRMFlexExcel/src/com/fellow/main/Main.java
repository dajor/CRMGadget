package com.fellow.main;

public class Main {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		String arg = "";
		if (args.length > 0) {
			for(int i=0;i<args.length;i++){
				if(args[i].contains(".xml")){
					arg = args[i];
					break;
				}
			}
			
		}
		ExportExcel exp = new ExportExcel();
		exp.exportExcel(arg);
	}

}
