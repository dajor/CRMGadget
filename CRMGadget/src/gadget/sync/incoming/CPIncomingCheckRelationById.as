package gadget.sync.incoming
{
	import gadget.sync.outgoing.CPOutgoingUpdateRelation;

	public class CPIncomingCheckRelationById extends JDIncomingProduct
	{
		protected var countRetry:int=0;
		public function CPIncomingCheckRelationById(entity:String,id:String,retry:int)
		{
			super("[Id]=\'"+id+"\'",entity);
			this.countRetry = retry;
		}
		
		protected override function createCPOutgoingUpdateRelation(rec:Object):CPOutgoingUpdateRelation{
			return new CPOutgoingUpdateRelation(entityIDour,rec,countRetry+1);
		}
	}
}