package com.rubenswieringa.interactivemindmap {
	
	import com.adobe.flex.extras.controls.springgraph.*;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Controller extends EventDispatcher {
		public var _model:XML;
		private var _graph:Graph = new Graph();
		private var _springGraph:SpringGraph;
		private var addedItems:Object;
		private var distinguishedItemSuccessor:String = "";
		
		public static var _instance:Controller;
		private static var booted:Boolean = false;
		
		private static const GRAPH_CHANGE:String = "graphChange";
		public static const BUILT:String = "controllerBuilt";
		
		private static const STRONG_LINK:Object =	{settings: {alpha: 0.4, color: 0x000000, thickness: 4}};
		private static const NORMAL_LINK:Object =	{settings: {alpha: 0.3, color: 0x000000, thickness: 2}};
		private static const EXTERNAL_LINK:Object =	{settings: {alpha: 0.3, color: 0x000000, thickness: 1}};
		
		private static const ILLEGAL_ATTRIBUTE_VALUES:RegExp = /[\s\!@#$%^_=+\[\]\\|:;'",.<>\/\?-]+/ig;
		
		/**
		 * Parses a given XML structure (makes sure every node has an id and value attribute value) and returns it.
		 */
		private function load (xml:XML):void {
			
			var nodes:XMLList;
			var node:XML;

			
			// make sure all words have values:
			nodes = xml..word.(hasOwnProperty("@id") && !hasOwnProperty("@value"));
			for each (node in nodes){
				node.@value = node.@id;
			}
			
			// make sure all words have IDs:
			nodes = xml..word.(!hasOwnProperty("@id") && hasOwnProperty("@value"));
			for each (node in nodes){
				node.@id = node.@value.toString().replace(ILLEGAL_ATTRIBUTE_VALUES, "").toLowerCase();
				if (node.@id.toString().indexOf("(") != -1 || node.@id.toString().indexOf(")") != -1){
					throw new Error("Parenthesis are not allowed in id-values (found in "+node.toXMLString()+")");
				}
			}
			
			_model = xml;
			
		}
		
		/**
		 * Constructor.
		 */
		public function Controller ():void {
			this._graph.addEventListener(Graph.CHANGE, this.onGraphChange);
		}
		
		/**
		 * Starts up the Controller class.
		 */
		public static function boot (springGraph:SpringGraph, xml:XML):void {

			Controller.booted = true;
			// prepare SpringGraph:
			if (Controller._instance._springGraph != null){
				Controller._instance._springGraph.removeEventListener(NodeRendererShell.ACTIVATE, Controller._instance.onNodeActivate);
			}
			Controller._instance._springGraph = springGraph;
			Controller._instance._springGraph.addEventListener(NodeRendererShell.ACTIVATE, Controller._instance.onNodeActivate);
			// load:
			Controller._instance.load(xml);
			Controller._instance.build();
		}
		

		
		/**
		 * Builds a structure of Item instances.
		 */
		public function build (id:String=""):void {
			// default:
			if (id == ""){
				id = _model.words.word[0].@id;
			}
			// stop if the SpringGraph is already displaying the requested data:
			if (this._graph.distinguishedItem != null && id == this._graph.distinguishedItem.id){
				return;
			}
			
			// @see Controller#emptyMemory():
			this.emptyMemory();
			// find nearest main-node in above levels (<word type="main" />):
			var xml:XML = Controller.getXML(id);
			var nearestMainTypedParent:XML = Controller.getNearestMainTypedParent(xml);
			// trigger structure-build:
			this.distinguishedItemSuccessor = xml.@id;
			var item:Item = this.addItem(nearestMainTypedParent, true, true, true);
			
			// let item-renderers know that a knew build has been performed:
			this.dispatchEvent(new Event(Controller.BUILT));
		}
		
		/**
		 * 
		 * 
		 * @see	Controller#addItemChildren()
		 * @see	Controller#addItemParents()
		 * @see	Controller#addItemLinks()
		 * @see	Controller#cleanUpRedundants()
		 * 
		 * ...
		 * @param	forceShowChildren	'word' nodes with their type-attribute set to 'main' automatically have their children hidden, this parameter overrides that functionality. Defaults to false.
		 */
		private function addItem   (xml:XML, 
									addChildren:Boolean=true, 
									addParents:Boolean=false, 
									forceShowChildren:Boolean=false):Item {
			
			if (xml.name() != "word"){
				throw new TypeError("XML should be a <word>");
			}
			
			var id:String = xml.@id;
			var item:Item;
			
			// add Item (or find if exists):
			if (this._graph.hasNode(id)){
				item = this._graph.find(id);
			}else{
				item = new Item(id);
				this._graph.add(item);
			}
			this.addedItems[item.id] = item;
			
			// set distinguishedItem:
			if (xml.@id == this.distinguishedItemSuccessor){
				this._graph.distinguishedItem = item;
			}
			
			// add children, parents, external links, and clean up redundant Items:
			if (addChildren && (forceShowChildren || xml.@type != "main")){
				this.addItemChildren(xml);
			}
			if (addParents){
				this.addItemParents(xml);
			}
			if (addChildren && (forceShowChildren || xml.@type != "main")){
				this.addItemLinks(item);
			}
			this.cleanUpRedundants();
			
			// return value:
			return item;
			
		}
		
		/**
		 * @see	Controller#addItem()
		 */
		private function addItemChildren (xml:XML):void {
			
			if (xml.name() != "word"){
				throw new TypeError("XML should be a <word>");
			}
			
			var newItem:Item;
			var children:XMLList = xml.children();
			var child:XML;
			var linkStyle:Object;
			
			for each (child in children){
				newItem = this.addItem(child);
				linkStyle = (xml.@type == "main" && child.@type == "main") ? Controller.STRONG_LINK : Controller.NORMAL_LINK;
				this._graph.link(this._graph.find(xml.@id), newItem, linkStyle);
				this.addedItems[newItem.id] = newItem;
			}
			
		}
		
		/**
		 * @see	Controller#addItem()
		 */
		private function addItemParents (xml:XML):void {
			
			if (xml.name() != "word"){
				throw new TypeError("XML should be a <word>");
			}
			
			var newItem:Item;
			var name:String = xml.name();
			var linkTo:XML = xml;
			var parent:XML = xml.parent();
			var linkStyle:Object;
			
			while (parent.name() == name){
				newItem = this.addItem(parent, false);
				linkStyle = (xml.@type == "main" && parent.@type == "main") ? Controller.STRONG_LINK : Controller.NORMAL_LINK;
				this._graph.link(this._graph.find(linkTo.@id), newItem, linkStyle);
				this.addedItems[newItem.id] = newItem;
				linkTo = linkTo.parent() as XML;
				parent = parent.parent() as XML;
			}
			
		}
		
		/**
		 * @see	Controller#addItem()
		 */
		private function addItemLinks (item:Item):void {
			
			var nearestMainTypedParent:XML = Controller.getNearestMainTypedParent(Controller.getXML(item.id));
			
			var newItem:Item;
			var links:XMLList = _model.links.link.(@a == item.id || @b == item.id);
			var link:XML;
			var linkID:String;
			var linkStyle:Object;
			var xml:XML;
			
			for each (link in links){
				linkID = (link.@b == item.id) ? link.@a : link.@b;
				xml = Controller.getXML(linkID);
				if (xml == null) continue; // skip if ID is non-existent
				newItem	= (this._graph.hasNode(linkID)) ? this._graph.find(linkID) : this.addItem(xml, false);
				linkStyle = (Controller.getNearestMainTypedParent(xml) == nearestMainTypedParent) ? Controller.NORMAL_LINK : Controller.EXTERNAL_LINK;
				if (!this._graph.linked(item, newItem)) this._graph.link(item, newItem, linkStyle);
				this.addedItems[newItem.id] = newItem;
			}
			
		}
		
		/**
		 * @see	Controller#addItem()
		 */
		private function cleanUpRedundants ():void {
			
			var items:Object = this._graph.nodes;
			var item:Item;
			var neighbours:Object;
			var neighbour:Item;
			var i:String;
			
			for each (item in items){
				if (this.addedItems[item.id] == null){
					neighbours = this._graph.neighbors(item.id);
					for (i in neighbours){
						neighbour = this._graph.find(i);
						this._graph.unlink(item, neighbour);
					}
					this._graph.remove(item);
				}
			}
			
		}
		
		/**
		 * While building an Item-structure the Controller class will remember all newly added Item instances, so 
		 * that it knows which Items to remove from the Graph later on. This method is typically called by the 
		 * build() method before executing the rest of itself.
		 * 
		 * @see	Controller#build()
		 */
		private function emptyMemory ():void {
			this.addedItems = {};
		}
		
		/**
		 * 
		 */
		private function onNodeActivate (event:Event):void {
			var renderer:NodeRendererShell = event.target as NodeRendererShell;
			this.build(renderer.data.id);
		}
		
	// GETTER/SETTER ACCESSORS-------------------------------------------------------------------------------------
		
		/**
		 * Singleton instance.
		 */
		public static function get instance ():Controller {
			if (Controller._instance == null){
				Controller._instance = new Controller();
			}
			return Controller._instance;
		}
		
		/**
		 * Corresponding Graph instance.
		 */
		[Bindable(event='graphChanged')]
		public function get graph ():Graph {
			return this._graph;
		}
		/**
		 * Change-eventlistener for graph getter binding.
		 */
		private function onGraphChange (event:Event):void {
			this.dispatchEvent(new Event(Controller.GRAPH_CHANGE));
		}
		
	// STATIC METHODS ---------------------------------------------------------------------------------------------
		
		/**
		 * 
		 */
		public static function getXML (id:String):XML {
			return Controller._instance._model.words..word.(@id == id)[0] as XML;
		}
		
		/**
		 * 
		 */
		public static function getNearestMainTypedParent (xml:XML):XML {
			var name:Object = xml.name();
			var parent:XML = xml as XML;
			var nearestMainXML:XML;
			while (parent.name() == name){
				if (parent.@type == "main"){
					nearestMainXML = parent;
					break;
				}
				parent = parent.parent() as XML;
			}
			if (nearestMainXML == null){
				nearestMainXML = xml;
			}
			return nearestMainXML;
		}
		
		/**
		 * 
		 */
		public static function getXMLDepthDifference (parent:XML, child:XML):int {
			var depth:int = 0;
			while (child != parent && child != null){
				child = child.parent();
				depth++;
			}
			if (child == null){
				depth = -1;
			}
			return depth;
		}
		
	}
	
}