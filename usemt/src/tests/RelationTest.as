package tests
{
	
	import gadget.util.Relation;
	
	import mx.collections.ArrayCollection;
	
	import org.flexunit.Assert;
	
	public class RelationTest
	{
	
		[Test(description="Account is linkable to 4 other entities")]
		public function testGetLinkable():void {
		    var linkable:ArrayCollection = Relation.getLinkable("Account");
		    Assert.assertEquals(4, linkable.length);
		}
		
		[Test(description="Test relation between contact and account")]
		public function testGetRelation():void {
			var relation:Object = Relation.getRelation("Contact", "Account");
			Assert.assertEquals("AccountId", relation.keySrc);
			Assert.assertEquals("AccountName", relation.labelSrc[0]);
		}
		
		[Test(description="Entities referenced by opportunity")]
		public function testGetReferenced():void {
			var referenced:ArrayCollection = Relation.getReferenced("Opportunity");
			Assert.assertEquals(1, referenced.length);
			Assert.assertEquals("Account", referenced[0].entityDest);
		}

		[Test(description="Entities referencing contact")]
		public function testGetReferencers():void {
			var referencers:ArrayCollection = Relation.getReferencers("Contact");
			Assert.assertEquals(1, referencers.length);
			Assert.assertEquals("Activity", referencers[0].entitySrc);
			Assert.assertEquals("PrimaryContactId", referencers[0].keySrc);
		}
		
		[Test(description="Activity's OpportunityName")]
		public function testGetFieldRelation():void {
			var relation:Object = Relation.getFieldRelation("Activity", "OpportunityName");
			Assert.assertEquals("Opportunity", relation.entityDest);
			Assert.assertEquals("OpportunityId", relation.keyDest);
		}

	}
}
