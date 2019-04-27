package com.crmgadget.eval
{
	public class Parser
	{
		public function Parser()
		{
		}

		//Function is checking comma(,) in format '#,###.00'
		public static function insideQuotes(s:String, pos:int):Boolean {
			var insideQuotes:Boolean = false;
			for (var i:int = 0; i < s.length; i++) {
				if (s.charAt(i) == "'") {
					insideQuotes = !insideQuotes;
				}
				if (i == pos) return insideQuotes;
			}
			return false;
		}
		
		
		public static function parse(formula:String):Node {
			var current:Node = new Node("root");
			var pos:int = 0;
			var read:String = "";
			var tmp:Node;
			var temp:Node;
			while (true) {
				if (formula.charAt(pos) == '(') {
					
						tmp = new Node(read);
						current.addChild(tmp);
						current = tmp;
						read = "";

					
				} else if (formula.charAt(pos) == ')') {
					if (read.length > 0) {
						tmp = new Node(read);
						current.addChild(tmp);
						
						read = "";
					}
					
						current = current.getParent();
					
				} else if (formula.charAt(pos) == ',' && insideQuotes(formula, pos) == false ) {
					if(read == " "){
						read = "";
					}else if (read.length > 0) {
						tmp = new Node(read);
						current.addChild(tmp);
						read = "";
					}
				} else {
					read += formula.charAt(pos);
				}
				pos ++;
				if (pos >= formula.length) break;
			}
			
			//If it is not the function
			if(current.getChildren().length<1){
				return new Node(formula);
			}
			
			return Node(current.getChildren().getItemAt(0));
		}
		
	}
}