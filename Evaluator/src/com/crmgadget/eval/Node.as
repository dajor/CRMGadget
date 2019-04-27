package com.crmgadget.eval
{
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;

	public class Node
	{
		
		
		private var name:String ;
		private var children:ArrayCollection;
		private var parent:Node;
		
		public function Node( pName:String) {
			name = StringUtil.trim(pName).replace(/'/gi,"");
			children = new ArrayCollection();
		}
		
		public function addChild(child:Node):void {
			children.addItem(child);
			child.parent = this;
		}
		
		public function getName():String {
			return name;
		}
		
		public function getParent():Node {
			return parent;
		}
		
		public function getChildren():ArrayCollection {
			return children;
		}
		
		public function getChildAt(idx:int):Node{
			if(children!=null){
				if(idx>=0 && idx<children.length){
					return children[idx] as Node;	
				}
			}
			return null;
		}
	}
}