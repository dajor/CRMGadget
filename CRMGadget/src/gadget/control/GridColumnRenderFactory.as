package gadget.control
{
	import mx.core.IFactory;
	
	public class GridColumnRenderFactory implements IFactory
	{
		
		private var renderer:Class;
		public function GridColumnRenderFactory(rendererClass:Class)
		{
			this.renderer = rendererClass;
		}
		
		public function newInstance():*
			
		{
			//var render:CheckBoxColRender=new CheckBoxColRender();
			return new renderer();
		}
	}
}