package tests{
	import gadget.util.FieldUtils;
	
	import org.flexunit.Assert;
	
	public class FieldUtilsTest{
		
		[Test(description="getDefaultFields Account")]
		public function getDefaultFieldsAccount():void{
		    var accountField:Array = FieldUtils.getDefaultFields("Account");
		    Assert.assertEquals(19, accountField.length);
		    Assert.assertEquals(0, accountField[0].col);
		    Assert.assertEquals(0, accountField[0].row);
		    Assert.assertEquals("#0", accountField[0].column_name);
		    Assert.assertEquals("Key Information", accountField[0].custom);
		    
		    Assert.assertEquals(0, accountField[1].col);
		    Assert.assertEquals(1, accountField[1].row);
		    Assert.assertEquals("AccountName", accountField[1].column_name);
		    
		    Assert.assertEquals(0, accountField[2].col);
		    Assert.assertEquals(2, accountField[2].row);
		    Assert.assertEquals("MainPhone", accountField[2].column_name);
		    
		    Assert.assertEquals(0, accountField[3].col);
		    Assert.assertEquals(3, accountField[3].row);
		    Assert.assertEquals("MainFax", accountField[3].column_name);
		    
		    Assert.assertEquals(0, accountField[4].col);
		    Assert.assertEquals(4, accountField[4].row);
		    Assert.assertEquals("WebSite", accountField[4].column_name);
		    
		    Assert.assertEquals(0, accountField[5].col);
		    Assert.assertEquals(5, accountField[5].row);
		    Assert.assertEquals("OwnerFullName", accountField[5].column_name);
		    
		    
		    Assert.assertEquals(1, accountField[6].col);
		    Assert.assertEquals(0, accountField[6].row);
		    Assert.assertEquals("#1", accountField[6].column_name);
		    Assert.assertEquals("Sales Information", accountField[6].custom);
		    
		    Assert.assertEquals(1, accountField[7].col);
		    Assert.assertEquals(1, accountField[7].row);
		    Assert.assertEquals("AccountType", accountField[7].column_name);
		    
		    Assert.assertEquals(1, accountField[8].col);
		    Assert.assertEquals(2, accountField[8].row);
		    Assert.assertEquals("Priority", accountField[8].column_name);
		    
		    Assert.assertEquals(1, accountField[9].col);
		    Assert.assertEquals(3, accountField[9].row);
		    Assert.assertEquals("Industry", accountField[9].column_name);
		    
		    Assert.assertEquals(1, accountField[10].col);
		    Assert.assertEquals(4, accountField[10].row);
		    Assert.assertEquals("PublicCompany", accountField[10].column_name);
		    
		    Assert.assertEquals(1, accountField[11].col);
		    Assert.assertEquals(5, accountField[11].row);
		    Assert.assertEquals("AnnualRevenues", accountField[11].column_name);
		    
		    Assert.assertEquals(1, accountField[12].col);
		    Assert.assertEquals(6, accountField[12].row);
		    Assert.assertEquals("NumberEmployees", accountField[12].column_name);
		    
		    Assert.assertEquals(1, accountField[13].col);
		    Assert.assertEquals(7, accountField[13].row);
		    Assert.assertEquals("PrimaryContactFullName", accountField[13].column_name);
		    
		    Assert.assertEquals(0, accountField[14].col);
		    Assert.assertEquals(6, accountField[14].row);
		    Assert.assertEquals("#2", accountField[14].column_name);
		    Assert.assertEquals("Address Information", accountField[14].custom);
		    
		    Assert.assertEquals(0, accountField[15].col);
		    Assert.assertEquals(7, accountField[15].row);
		    Assert.assertEquals("PrimaryBillToStreetAddress", accountField[15].column_name);
		    
		    Assert.assertEquals(0, accountField[16].col);
		    Assert.assertEquals(8, accountField[16].row);
		    Assert.assertEquals("PrimaryBillToPostalCode", accountField[16].column_name);
		    
		    Assert.assertEquals(0, accountField[17].col);
		    Assert.assertEquals(9, accountField[17].row);
		    Assert.assertEquals("PrimaryBillToCity", accountField[17].column_name);
		    
		    Assert.assertEquals(0, accountField[18].col);
		    Assert.assertEquals(10, accountField[18].row);
		    Assert.assertEquals("PrimaryBillToCountry", accountField[18].column_name);
		}
		
		[Test(description="getDefaultFields Contact")]
		public function getDefaultFieldsContact():void{
		    var fields:Array = FieldUtils.getDefaultFields("Contact");
		    Assert.assertEquals(24, fields.length);
		    
		    Assert.assertEquals(0, fields[0].col);
		    Assert.assertEquals(0, fields[0].row);
		    Assert.assertEquals("#0", fields[0].column_name);
		    Assert.assertEquals("Key Information", fields[0].custom);
		    
		    Assert.assertEquals(0, fields[1].col);
		    Assert.assertEquals(1, fields[1].row);
		    Assert.assertEquals("ContactFirstName", fields[1].column_name);
		    
		    Assert.assertEquals(0, fields[2].col);
		    Assert.assertEquals(2, fields[2].row);
		    Assert.assertEquals("MiddleName", fields[2].column_name);
		    
		    Assert.assertEquals(0, fields[3].col);
		    Assert.assertEquals(3, fields[3].row);
		    Assert.assertEquals("ContactLastName", fields[3].column_name);
		    
		    Assert.assertEquals(0, fields[4].col);
		    Assert.assertEquals(4, fields[4].row);
		    Assert.assertEquals("AccountName", fields[4].column_name);
		    
		    Assert.assertEquals(0, fields[5].col);
		    Assert.assertEquals(5, fields[5].row);
		    Assert.assertEquals("JobTitle", fields[5].column_name);
		    
		    Assert.assertEquals(0, fields[6].col);
		    Assert.assertEquals(6, fields[6].row);
		    Assert.assertEquals("WorkPhone", fields[6].column_name);
		    
		    Assert.assertEquals(0, fields[7].col);
		    Assert.assertEquals(7, fields[7].row);
		    Assert.assertEquals("WorkFax", fields[7].column_name);
		    
		    Assert.assertEquals(0, fields[8].col);
		    Assert.assertEquals(8, fields[8].row);
		    Assert.assertEquals("ContactEmail", fields[8].column_name);
		    
		    Assert.assertEquals(0, fields[9].col);
		    Assert.assertEquals(9, fields[9].row);
		    Assert.assertEquals("OwnerFullName", fields[9].column_name);
		    
		    Assert.assertEquals(0, fields[10].col);
		    Assert.assertEquals(10, fields[10].row);
		    Assert.assertEquals("#1", fields[10].column_name);
		    Assert.assertEquals("Detail Information", fields[10].custom);
		    
		    Assert.assertEquals(0, fields[11].col);
		    Assert.assertEquals(11, fields[11].row);
		    Assert.assertEquals("ContactType", fields[11].column_name);
		    
		    Assert.assertEquals(0, fields[12].col);
		    Assert.assertEquals(12, fields[12].row);
		    Assert.assertEquals("Department", fields[12].column_name);
		    
		    Assert.assertEquals(0, fields[13].col);
		    Assert.assertEquals(13, fields[13].row);
		    Assert.assertEquals("Manager", fields[13].column_name);
		    
		    Assert.assertEquals(0, fields[14].col);
		    Assert.assertEquals(14, fields[14].row);
		    Assert.assertEquals("LeadSource", fields[14].column_name);
		    
		    Assert.assertEquals(0, fields[15].col);
		    Assert.assertEquals(15, fields[15].row);
		    Assert.assertEquals("CurrencyCode", fields[15].column_name);
		    
		    Assert.assertEquals(0, fields[16].col);
		    Assert.assertEquals(16, fields[16].row);
		    Assert.assertEquals("AssistantName", fields[16].column_name);
		    
		    Assert.assertEquals(1, fields[17].col);
		    Assert.assertEquals(0, fields[17].row);
		    Assert.assertEquals("#2", fields[17].column_name);
		    Assert.assertEquals("Photo", fields[17].custom);
		    
		    Assert.assertEquals(1, fields[18].col);
		    Assert.assertEquals(1, fields[18].row);
		    Assert.assertEquals("picture", fields[18].column_name);
		    
		    Assert.assertEquals(1, fields[19].col);
		    Assert.assertEquals(2, fields[19].row);
		    Assert.assertEquals("#3", fields[19].column_name);
		    Assert.assertEquals("Address Information", fields[19].custom);
		    
		    Assert.assertEquals(1, fields[20].col);
		    Assert.assertEquals(3, fields[20].row);
		    Assert.assertEquals("AlternateAddress1", fields[20].column_name);
		    
		    Assert.assertEquals(1, fields[21].col);
		    Assert.assertEquals(4, fields[21].row);
		    Assert.assertEquals("AlternateZipCode", fields[21].column_name);
		    
		    Assert.assertEquals(1, fields[22].col);
		    Assert.assertEquals(5, fields[22].row);
		    Assert.assertEquals("AlternateCity", fields[22].column_name);
		    
		    Assert.assertEquals(1, fields[23].col);
		    Assert.assertEquals(6, fields[23].row);
		    Assert.assertEquals("AlternateCountry", fields[23].column_name);
		}
		
		[Test(description="getDefaultFields Activity")]
		public function getDefaultFieldsActivity():void{
		    var fields:Array = FieldUtils.getDefaultFields("Activity");
		    Assert.assertEquals(7, fields.length);
		    
		    Assert.assertEquals(0, fields[0].col);
		    Assert.assertEquals(0, fields[0].row);
		    Assert.assertEquals("Subject", fields[0].column_name);
		    
		    Assert.assertEquals(0, fields[1].col);
		    Assert.assertEquals(1, fields[1].row);
		    Assert.assertEquals("Priority", fields[1].column_name);
		    
		    Assert.assertEquals(0, fields[2].col);
		    Assert.assertEquals(2, fields[2].row);
		    Assert.assertEquals("DueDate", fields[2].column_name);
		    
		    Assert.assertEquals(0, fields[3].col);
		    Assert.assertEquals(3, fields[3].row);
		    Assert.assertEquals("Type", fields[3].column_name);
		    
		    Assert.assertEquals(0, fields[4].col);
		    Assert.assertEquals(4, fields[4].row);
		    Assert.assertEquals("Status", fields[4].column_name);
		    
		    Assert.assertEquals(0, fields[5].col);
		    Assert.assertEquals(5, fields[5].row);
		    Assert.assertEquals("Private", fields[5].column_name);
		    
		    Assert.assertEquals(0, fields[6].col);
		    Assert.assertEquals(6, fields[6].row);
		    Assert.assertEquals("Description", fields[6].column_name);
		    
		}
		
		[Test(description="getDefaultFields Opportunity")]
		public function getDefaultFieldsOpportunity():void{
		    var fields:Array = FieldUtils.getDefaultFields("Opportunity");
		    Assert.assertEquals(17, fields.length);
		    
		    Assert.assertEquals(0, fields[0].col);
		    Assert.assertEquals(0, fields[0].row);
		    Assert.assertEquals("#0", fields[0].column_name);
		    Assert.assertEquals("Key Information", fields[0].custom);
		    
		    Assert.assertEquals(0, fields[1].col);
		    Assert.assertEquals(1, fields[1].row);
		    Assert.assertEquals("OpportunityName", fields[1].column_name);
		    
		    Assert.assertEquals(0, fields[2].col);
		    Assert.assertEquals(2, fields[2].row);
		    Assert.assertEquals("AccountName", fields[2].column_name);
		    
		    Assert.assertEquals(0, fields[3].col);
		    Assert.assertEquals(3, fields[3].row);
		    Assert.assertEquals("CloseDate", fields[3].column_name);
		    
		    Assert.assertEquals(0, fields[4].col);
		    Assert.assertEquals(4, fields[4].row);
		    Assert.assertEquals("Revenue", fields[4].column_name);
		    
		    Assert.assertEquals(0, fields[5].col);
		    Assert.assertEquals(5, fields[5].row);
		    Assert.assertEquals("SalesStage", fields[5].column_name);
		    
		    Assert.assertEquals(0, fields[6].col);
		    Assert.assertEquals(6, fields[6].row);
		    Assert.assertEquals("Forecast", fields[6].column_name);
		    
		    Assert.assertEquals(0, fields[7].col);
		    Assert.assertEquals(7, fields[7].row);
		    Assert.assertEquals("NextStep", fields[7].column_name);
		    
		    Assert.assertEquals(0, fields[8].col);
		    Assert.assertEquals(8, fields[8].row);
		    Assert.assertEquals("CurrencyCode", fields[8].column_name);
		    
		    Assert.assertEquals(0, fields[9].col);
		    Assert.assertEquals(9, fields[9].row);
		    Assert.assertEquals("OwnerFullName", fields[9].column_name);
		    
		    
		    Assert.assertEquals(1, fields[10].col);
		    Assert.assertEquals(0, fields[10].row);
		    Assert.assertEquals("#1", fields[10].column_name);
		    Assert.assertEquals("Sales information", fields[10].custom);
		    
		    Assert.assertEquals(1, fields[11].col);
		    Assert.assertEquals(1, fields[11].row);
		    Assert.assertEquals("Status", fields[11].column_name);
		    
		    Assert.assertEquals(1, fields[12].col);
		    Assert.assertEquals(2, fields[12].row);
		    Assert.assertEquals("Priority", fields[12].column_name);
		    
		    Assert.assertEquals(1, fields[13].col);
		    Assert.assertEquals(3, fields[13].row);
		    Assert.assertEquals("LeadSource", fields[13].column_name);
		    
		    Assert.assertEquals(1, fields[14].col);
		    Assert.assertEquals(4, fields[14].row);
		    Assert.assertEquals("Probability", fields[14].column_name);
		    
		    Assert.assertEquals(1, fields[15].col);
		    Assert.assertEquals(5, fields[15].row);
		    Assert.assertEquals("ReasonWonLost", fields[15].column_name);
		    
		    Assert.assertEquals(1, fields[16].col);
		    Assert.assertEquals(6, fields[16].row);
		    Assert.assertEquals("OpportunityType", fields[16].column_name);
		}
		
		[Test(description="getDefaultFields Product")]
		public function getDefaultFieldsProduct():void{
		    var fields:Array = FieldUtils.getDefaultFields("Product");
		    Assert.assertEquals(13, fields.length);
		    
		    Assert.assertEquals(0, fields[0].col);
		    Assert.assertEquals(0, fields[0].row);
		    Assert.assertEquals("#0", fields[0].column_name);
		    Assert.assertEquals("Key Information", fields[0].custom);
		    
		    Assert.assertEquals(0, fields[1].col);
		    Assert.assertEquals(1, fields[1].row);
		    Assert.assertEquals("Name", fields[1].column_name);
		    
		    Assert.assertEquals(0, fields[2].col);
		    Assert.assertEquals(2, fields[2].row);
		    Assert.assertEquals("ProductType", fields[2].column_name);
		    
		    Assert.assertEquals(0, fields[3].col);
		    Assert.assertEquals(3, fields[3].row);
		    Assert.assertEquals("ProductCategory", fields[3].column_name);
		    
		    Assert.assertEquals(0, fields[4].col);
		    Assert.assertEquals(4, fields[4].row);
		    Assert.assertEquals("ProductCurrency", fields[4].column_name);
		    
		    Assert.assertEquals(0, fields[5].col);
		    Assert.assertEquals(5, fields[5].row);
		    Assert.assertEquals("Status", fields[5].column_name);
		    
		    Assert.assertEquals(0, fields[6].col);
		    Assert.assertEquals(6, fields[6].row);
		    Assert.assertEquals("PartNumber", fields[6].column_name);
		    
		    Assert.assertEquals(1, fields[7].col);
		    Assert.assertEquals(0, fields[7].row);
		    Assert.assertEquals("#1", fields[7].column_name);
		    Assert.assertEquals("Sales information", fields[7].custom);
		    
		    Assert.assertEquals(1, fields[8].col);
		    Assert.assertEquals(1, fields[8].row);
		    Assert.assertEquals("PriceType", fields[8].column_name);
		    
		    Assert.assertEquals(1, fields[9].col);
		    Assert.assertEquals(2, fields[9].row);
		    Assert.assertEquals("Model", fields[9].column_name);
		    
		    Assert.assertEquals(1, fields[10].col);
		    Assert.assertEquals(3, fields[10].row);
		    Assert.assertEquals("Orderable", fields[10].column_name);
		    
		    Assert.assertEquals(1, fields[11].col);
		    Assert.assertEquals(4, fields[11].row);
		    Assert.assertEquals("Make", fields[11].column_name);
		    
		    Assert.assertEquals(1, fields[12].col);
		    Assert.assertEquals(5, fields[12].row);
		    Assert.assertEquals("Description", fields[12].column_name);
		}
		
		[Test(description="getDefaultFields Service Request")]
		public function getDefaultFieldsServiceRequest():void{
		    var fields:Array = FieldUtils.getDefaultFields("Service Request");
		    Assert.assertEquals(15, fields.length);
		    
		    Assert.assertEquals(0, fields[0].col);
		    Assert.assertEquals(0, fields[0].row);
		    Assert.assertEquals("#0", fields[0].column_name);
		    Assert.assertEquals("Contact Information", fields[0].custom);
		    
		    Assert.assertEquals(0, fields[1].col);
		    Assert.assertEquals(1, fields[1].row);
		    Assert.assertEquals("SRNumber", fields[1].column_name);
		    
		    Assert.assertEquals(0, fields[2].col);
		    Assert.assertEquals(2, fields[2].row);
		    Assert.assertEquals("AccountName", fields[2].column_name);
		    
		    Assert.assertEquals(0, fields[3].col);
		    Assert.assertEquals(3, fields[3].row);
		    Assert.assertEquals("WorkPhone", fields[3].column_name);
		    
		    Assert.assertEquals(0, fields[4].col);
		    Assert.assertEquals(4, fields[4].row);
		    Assert.assertEquals("#1", fields[4].column_name);
		    Assert.assertEquals("Service Detail Information:", fields[4].custom);
		    
		    Assert.assertEquals(0, fields[5].col);
		    Assert.assertEquals(5, fields[5].row);
		    Assert.assertEquals("Area", fields[5].column_name);
		    
		    Assert.assertEquals(0, fields[6].col);
		    Assert.assertEquals(6, fields[6].row);
		    Assert.assertEquals("Cause", fields[6].column_name);
		    
		    Assert.assertEquals(0, fields[7].col);
		    Assert.assertEquals(7, fields[7].row);
		    Assert.assertEquals("Type", fields[7].column_name);
		    
		    Assert.assertEquals(0, fields[8].col);
		    Assert.assertEquals(8, fields[8].row);
		    Assert.assertEquals("Source", fields[8].column_name);
		    
		    Assert.assertEquals(0, fields[9].col);
		    Assert.assertEquals(9, fields[9].row);
		    Assert.assertEquals("Priority", fields[9].column_name);
		    
		    Assert.assertEquals(0, fields[10].col);
		    Assert.assertEquals(10, fields[10].row);
		    Assert.assertEquals("Status", fields[10].column_name);
		    
		    Assert.assertEquals(0, fields[11].col);
		    Assert.assertEquals(11, fields[11].row);
		    Assert.assertEquals("OpenedTime", fields[11].column_name);
		    
		    Assert.assertEquals(1, fields[12].col);
		    Assert.assertEquals(0, fields[12].row);
		    Assert.assertEquals("#1", fields[12].column_name);
		    Assert.assertEquals("Additional Information", fields[12].custom);
		    
		    Assert.assertEquals(1, fields[13].col);
		    Assert.assertEquals(1, fields[13].row);
		    Assert.assertEquals("Subject", fields[13].column_name);
		    
		    Assert.assertEquals(1, fields[14].col);
		    Assert.assertEquals(2, fields[14].row);
		    Assert.assertEquals("Description", fields[14].column_name);
		}
		
		[Test(description="getDefaultFields Campaign")]
		public function getDefaultFieldsCampaign():void{
		    var fields:Array = FieldUtils.getDefaultFields("Campaign");
		    Assert.assertEquals(16, fields.length);
		    
		    Assert.assertEquals(0, fields[0].col);
		    Assert.assertEquals(0, fields[0].row);
		    Assert.assertEquals("#0", fields[0].column_name);
		    Assert.assertEquals("Key Information", fields[0].custom);
		    
		    Assert.assertEquals(0, fields[1].col);
		    Assert.assertEquals(1, fields[1].row);
		    Assert.assertEquals("SourceCode", fields[1].column_name);
		    
		    Assert.assertEquals(0, fields[2].col);
		    Assert.assertEquals(2, fields[2].row);
		    Assert.assertEquals("CampaignName", fields[2].column_name);
		    
		    Assert.assertEquals(0, fields[3].col);
		    Assert.assertEquals(3, fields[3].row);
		    Assert.assertEquals("CampaignType", fields[3].column_name);
		    
		    Assert.assertEquals(0, fields[4].col);
		    Assert.assertEquals(4, fields[4].row);
		    Assert.assertEquals("Objective", fields[4].column_name);
		    
		    Assert.assertEquals(0, fields[5].col);
		    Assert.assertEquals(5, fields[5].row);
		    Assert.assertEquals("Audience", fields[5].column_name);
		    
		    Assert.assertEquals(0, fields[6].col);
		    Assert.assertEquals(6, fields[6].row);
		    Assert.assertEquals("Offer", fields[6].column_name);
		    
		    Assert.assertEquals(0, fields[7].col);
		    Assert.assertEquals(7, fields[7].row);
		    Assert.assertEquals("Status", fields[7].column_name);
		    
		    Assert.assertEquals(0, fields[8].col);
		    Assert.assertEquals(8, fields[8].row);
		    Assert.assertEquals("StartDate", fields[8].column_name);
		    
		    Assert.assertEquals(0, fields[9].col);
		    Assert.assertEquals(9, fields[9].row);
		    Assert.assertEquals("EndDate", fields[9].column_name);
		    
		    Assert.assertEquals(1, fields[10].col);
		    Assert.assertEquals(0, fields[10].row);
		    Assert.assertEquals("#1", fields[10].column_name);
		    Assert.assertEquals("Campaign Plan Information", fields[10].custom);
		    
		    Assert.assertEquals(1, fields[11].col);
		    Assert.assertEquals(1, fields[11].row);
		    Assert.assertEquals("RevenueTarget", fields[11].column_name);
		    
		    Assert.assertEquals(1, fields[12].col);
		    Assert.assertEquals(2, fields[12].row);
		    Assert.assertEquals("BudgetedCost", fields[12].column_name);
		    
		    Assert.assertEquals(1, fields[13].col);
		    Assert.assertEquals(3, fields[13].row);
		    Assert.assertEquals("ActualCost", fields[13].column_name);
		    
		    Assert.assertEquals(2, fields[14].col);
		    Assert.assertEquals(0, fields[14].row);
		    Assert.assertEquals("#2", fields[14].column_name);
		    Assert.assertEquals("Additional Information", fields[14].custom);
		    
		    Assert.assertEquals(2, fields[15].col);
		    Assert.assertEquals(1, fields[15].row);
		    Assert.assertEquals("Description", fields[15].column_name);
		}
		[Test(description="getDefaultFields Custom Object 1")]
		public function getDefaultFieldsCustomObject1():void{
		    var fields:Array = FieldUtils.getDefaultFields("Custom Object 1");
		    Assert.assertEquals(3, fields.length);
		    
		    Assert.assertEquals(0, fields[0].col);
		    Assert.assertEquals(0, fields[0].row);
		    Assert.assertEquals("#0", fields[0].column_name);
		    Assert.assertEquals("Key Information", fields[0].custom);
		    
		    Assert.assertEquals(0, fields[1].col);
		    Assert.assertEquals(1, fields[1].row);
		    Assert.assertEquals("Name", fields[1].column_name);
		    
		    Assert.assertEquals(0, fields[2].col);
		    Assert.assertEquals(2, fields[2].row);
		    Assert.assertEquals("Description", fields[2].column_name);
		    
		}
		
	}
}