package gadget.sync.tasklists
{
	import gadget.sync.incoming.IncomingObject;
	import gadget.sync.incoming.IncomingObjectPerId;
	import gadget.sync.incoming.IncomingRelationObject;

	public class IncomingStructureByIds extends IncomingStructure
	{
		public function IncomingStructureByIds()
		{
			super(false);
		}
		
		
		override protected function createProcess(entity:String,parentTask:IncomingObject,pFields:Object,dependOn:Boolean=true):IncomingRelationObject{
			return new IncomingObjectPerId(entity,parentTask,pFields)
		}
		
		override protected function createParentProcess(entity:String):IncomingObject{
			return new IncomingObjectPerId(entity);
		}
	}
}