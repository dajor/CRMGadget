package com.crmgadget.eval
{
	import mx.utils.StringUtil;

	public class Functionalizer
	{
		private  static var KEYS:Array = ["AND","OR","LIKE","IS NOT NULL","IS NULL","NOT",  "<>","<=", ">=","<",">","=", "*", "+","/","-"];
		
		private static var KEYS_ALIAS:Object={			
			"<=":"LTE",
			"<":"LT",
			">":"GT",
			">=":"GTE",
			"*":"MULT",
			"+":"ADD",
			"-":"SUB",
			"/":"DIV",
			"<>":"OPOSIT",
			"=":"EQ",
			"IS NULL":"ISNULL",
			"IS NOT NULL":"NOBLANK"
		};
		
		
		public static function functionalize(formula:String):String {
			for each (var key:String in KEYS) {
				//Bug fixing 214 CRO 07.02.2011
				formula = formula.replace(/\"/gi, '\'').replace(/\[\</gi,'[').replace(/\>\]/gi,']');
				var index:int =0;
				while (true) {	
					var tmp:String ;
					tmp = functionalizeOnce(key, formula,index);
					if (tmp==formula) {
						index =0;
						break;
					}
					formula = tmp;
					if(KEYS_ALIAS.hasOwnProperty(key)){
						//no need to increase because we have change the name of the operation
						index=0;
					}else{
						//keep the name of operation as before
						index++;
					}
					
				}
				
			}
			return formula;
		}
		
		private static function getOperationPos(index:int,work:String,key:String):int{
			var pos:int = -1;
			for(var i:int=0;i<=index;i++){
				var startIndex:int = 0;
				if(pos!=-1){
					startIndex = pos+key.length;
				}
				pos = work.indexOf(key,startIndex);
			}
			return pos;
			
		}
		
		private static function functionalizeOnce(key:String, formula:String,index:int):String {
			
			var work:String = hideString(formula).toUpperCase();
			var operatorPos:int = getOperationPos(index,work,key);
			if (operatorPos != -1) {
				var leftOpPos:int = getOperator(-1, work, operatorPos);
				var leftOp:String = (formula.substring(leftOpPos, operatorPos));
				var rightOpPos:int = getOperator(1, work, operatorPos + key.length) + 1;
				var rightOp:String = (formula.substring(operatorPos + key.length, rightOpPos));
				var funcKey:String = StringUtil.trim(key);
				var alias:String=KEYS_ALIAS[funcKey]  ;
				if(alias!=null){
					funcKey=alias;
				}
//				if (funcKey==">") funcKey = "GT";
//				if (funcKey=="<") funcKey = "LT";
//				if (funcKey==">=") funcKey = "GTE";
//				if (funcKey=="<=") funcKey = "LTE";
//				if (funcKey=="=") funcKey = "EQ";
				var comma:String = "";
				if(!StringUtils.isEmpty(leftOp) && !StringUtils.isEmpty(rightOp)){
					comma = ",";
				}
				
				
				return formula.substring(0, leftOpPos) + funcKey + "(" + leftOp + comma + rightOp + ")" + formula.substring(rightOpPos); 
			}
			return formula;
		}
		
		
		private static function getOperator(step:int, work:String, startPos:int):int {
			var i:int = startPos;
			var lvl:int = 0;
			while (true) {
				if (work.charAt(i) == ',' && lvl == 0) {
					break;
				}
				if (work.charAt(i) == '(') {
					lvl += step;
				}
				if (work.charAt(i) == ')') {
					lvl -= step;
				}
				if (lvl == -1) {
					break;
				}
				i += step;
				if (i < 0 || i >= work.length) {
					break;
				}
			}
			return i - step;
		}
		
		
		private static function hideString(s:String):String {
			var inString:Boolean = false;
			var ret:String = "";
			for (var i:int = 0; i < s.length; i++) {
				if (s.charAt(i) == '\'' ||s.charAt(i) == '['||s.charAt(i) == ']') {
					inString = !inString;
				}
				if(inString && (s.charAt(i) != '\'' && s.charAt(i) != '[' && s.charAt(i) != ']')){
					ret +=" ";
				}else{
					ret +=s.charAt(i);
				}
				//ret += inString && s.charAt(i) != '\'' ? " " : s.charAt(i);
			}
			return ret;
		}
	}
}