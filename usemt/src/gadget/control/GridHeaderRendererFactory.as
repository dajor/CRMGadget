package gadget.control
{
	import mx.core.IFactory;
	
	public class GridHeaderRendererFactory implements IFactory
	{
		private var _label:String;
		private var _entity:String;
		
		public function GridHeaderRendererFactory(label:String,enity:String)
		{
			_label = label;
			_entity = enity;
		}
		
		public function newInstance():*
		{
			var renderer:GridHeaderRenderer = new GridHeaderRenderer();
			renderer.textHeader = _label;
			renderer.entity = _entity;
			return renderer;
		}
	}
}