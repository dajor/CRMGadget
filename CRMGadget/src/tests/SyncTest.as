package tests
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import gadget.dao.BaseDAO;
	import gadget.dao.Database;
	import gadget.util.DateUtils;
	
	import mx.collections.ArrayCollection;


	public class SyncTest
	{
		
		[Test(description="test synchronize")]
		public function testSync():void{
			var syncTest:SyncProcessTest=new SyncProcessTest("D:\\software\\test23032011.xml",logResult);
			syncTest.dostart();
		}
		private function logResult():void{
			var logfile:File=File.userDirectory.resolvePath("loggadget.txt");;
			
			
			var stream:FileStream = new FileStream();
			stream.open(logfile, FileMode.WRITE);
			var fileData:String = "Result of synchronize on "+ DateUtils.format(new Date(),"MM/DD/YYYY JJ:NN:SS");//stream.readUTFBytes(stream.bytesAvailable);		
			var objTrans:ArrayCollection=Database.transactionDao.listEnabledTransaction();			
			
			for each(var t:Object in objTrans){
				if(fileData.length>0){
					fileData=fileData+"\n";
				}
				var dao:BaseDAO=Database.getDao(t.entity);	
				var results:ArrayCollection=dao.findAll(new ArrayCollection([{element_name:'gadget_id'}]),null,null,0);
				fileData=fileData+dao.entity + " = "+ results.length;
			}
			var byteArr:ByteArray = new ByteArray();
			byteArr.writeUTFBytes(fileData);
			stream.writeBytes(byteArr);
			stream.close();
			
			
		}
	}
}