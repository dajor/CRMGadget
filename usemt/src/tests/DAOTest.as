package tests
{
	import flash.data.SQLConnection;
	import flash.filesystem.File;
	
	import gadget.dao.AccountDAO;
	
	import mx.collections.ArrayCollection;
	
	import org.flexunit.Assert;
	
	public class DAOTest
	{

		private static var tmpFile:File;
		private static var sqlConnection:SQLConnection;

//		[BeforeClass]
//		public static function initDB():void {
//			var file:File = File.applicationDirectory.resolvePath("tests.db");
//			sqlConnection = new SQLConnection();
//			sqlConnection.open(file);
//		}
		
		[BeforeClass]
		public static function initDB():void {
			var sourceFile:File = File.applicationDirectory.resolvePath("tests.db");
			tmpFile = File.createTempFile();	
			sourceFile.copyTo(tmpFile, true);
			sqlConnection = new SQLConnection();
			sqlConnection.open(tmpFile);
		}		
		
		
		[AfterClass]
		public static function cleanUp():void {
			sqlConnection.close();
			tmpFile.deleteFile();			
		}		
		
		
		[Test(description="DAO findAll test")]
		public function findAll1():void {
			var accountDAO:AccountDAO = new AccountDAO(sqlConnection, null);
			var accounts:ArrayCollection = accountDAO.findAll(
				new ArrayCollection([{element_name:"AccountName"}]));
			// my local length = 14
			Assert.assertEquals(10, accounts.length);
		}
		
		[Test(description="DAO findAll filter test")]
		public function findAll2():void {
			var accountDAO:AccountDAO = new AccountDAO(sqlConnection, null);
			var accounts:ArrayCollection = accountDAO.findAll(
				new ArrayCollection([{element_name:"AccountName"}, {element_name:"Location"}]), 
				"Location='Augsburg'");
			Assert.assertEquals(1, accounts.length);
			Assert.assertEquals("Augsburg", accounts[0].Location);
		}
		
		[Test(description="DAO findByGadgetId with id=AAPA-2CN78B return one Object")]
		public function findByGadgetId1():void {
			var accountDAO:AccountDAO = new AccountDAO(sqlConnection, null);
			var account:Object = accountDAO.findByOracleId("AAPA-2CN78B");
			Assert.assertEquals("AAPA-2CN78B", account.AccountId);
			Assert.assertEquals("Siebel", account.AccountName);
		}
		
		[Test(description="DAO findByGadgetId with id=OOOO-231F3W1 return null")]
		public function findByGadgetId2():void {
			var accountDAO:AccountDAO = new AccountDAO(sqlConnection, null);
			var account:Object = accountDAO.findByOracleId("OOOO-231F3W1");
			Assert.assertNull(account);
		}
		
		[Test(description="DAO findCreated with offset 5 and limit 2")]
		public function findCreatedOrUpdated():void {
			var accountDAO:AccountDAO = new AccountDAO(sqlConnection, null);
			var accounts:ArrayCollection = accountDAO.findCreated(5, 2);
			Assert.assertEquals(0, accounts.length);
		}
		
		// Fixed if open this code, should be change length at the findAll method
		
//		[Test(description="DAO insertAccount")]
//		public function insertAccount():void {
//			var accountDAO:AccountDAO = new AccountDAO(sqlConnection);
//			var obj:Object = new Object();
//			obj.AccountName = "Testing JUnit";
//			obj.deleted = false;
//			obj.Priority = "Low";
//			obj.AccountType = "Customer";
//			obj.Country = "Germany";
//			obj.industry = "Energy";
//			Assert.assertWith(accountDAO.insert, obj);
//		}
		
		[Test(description="DAO updateAccount")]
		public function updateAccount():void {
			var accountDAO:AccountDAO = new AccountDAO(sqlConnection, null);
			var obj:Object = new Object();
			obj.AccountName = "Testing JUnit";
			obj.Country = "Germany";
			obj.deleted = false;
			obj.local_update = new Date().getTime();
			obj.gadget_id = 10;
			Assert.assertWith(accountDAO.update, obj);
		}

	}
}