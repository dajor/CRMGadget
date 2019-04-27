package gadget.sync.incoming
{
	public class ColoplastIncomingWithoutMD extends IncomingObject
	{
		public function ColoplastIncomingWithoutMD(entity:String='CustomObject13')
		{
			super(entity);
			isUnboundedTask = true;
			linearTask=true;
		}
		
		override protected function generateSearchSpec(byModiDate:Boolean=true):String{
			//colopase want to read all data from odd for co13
			return super.generateSearchSpec(false);
		}
	}
}