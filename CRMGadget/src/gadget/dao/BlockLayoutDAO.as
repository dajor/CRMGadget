package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.utils.Dictionary;
	
	import gadget.util.POOPS;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;

	public class BlockLayoutDAO extends SimpleTable
	{
		
		
		protected var stmtGetNameByEntity:SQLStatement;
		protected var stmtGetByField:SQLStatement;
		protected var stmtGetSubField:SQLStatement;
		protected var stmtGetallBlock:SQLStatement;
		
		private static const ADDRESS:String = 'address';
		private static const ADDRESS2:String = 'address2';
		private static const ADDRESS3:String = 'address3';
		private static const CITY:String='city';
		private static const COUNTY:String='county';
		private static const STATE:String = 'state';
		private static const ZIP:String = 'zip';
		private static const PROVINCE:String = 'province';
		
		private static const FIELDS:Object ={
			address:{'Address':'StreetAddress','Main':'PrimaryBillToStreetAddress','Shipping':'PrimaryShipToStreetAddress','Contact Address':'AlternateAddress1','Main Address':'PrimaryAddress'},
			address2:{'Address':'StreetAddress2','Main':'PrimaryBillToStreetAddress2','Shipping':'PrimaryShipToStreetAddress2','Contact Address':'AlternateAddress2','Main Address':'PrimaryStreetAddress2'},
			address3:{'Address':'StreetAddress3','Main':'PrimaryBillToStreetAddress3','Shipping':'PrimaryShipToStreetAddress3','Contact Address':'AlternateAddress3','Main Address':'PrimaryStreetAddress3'},
			city:{'Address':'City','Main':'PrimaryBillToCity','Shipping':'PrimaryShipToCity','Contact Address':'AlternateCity','Main Address':'PrimaryCity'},
			county:{'Address':'County','Main':'PrimaryBillToCounty','Shipping':'PrimaryShipToCounty','Contact Address':'AlternateCounty','Main Address':'PrimaryCounty'},
			state:{'Address':'StateProvince','Main':'PrimaryBillToState','Shipping':'PrimaryShipToState','Contact Address':'AlternateStateProvince','Main Address':'PrimaryStateProvince'},
			zip:{'Address':'ZipCode','Main':'PrimaryBillToPostalCode','Shipping':'PrimaryShipToPostalCode','Contact Address':'AlternateZipCode','Main Address':'PrimaryZipCode'},
			province:{'Address':'Province','Main':'PrimaryBillToProvince','Shipping':'PrimaryShipToProvince','Contact Address':'AlternateProvince','Main Address':'PrimaryProvince'}
		};
		
		public static const ADDRESS2REALFIELD:Object = {
			'address':'Address',
			'address2':'StreetAddress2',
			'address3':'StreetAddress3',
			'city':'City',
			'county':'County',
			'state':'StateProvince',
			'zip':'ZipCode',
			'province':'Province',
			'country':'Country'
		};
		
		private static const DYNAMIC_GROUP:Object ={
			DEFAULT:[ADDRESS,ADDRESS2,ZIP,CITY],
			Germany:[ADDRESS,ADDRESS2,ZIP,CITY],
			Netherlands:[ADDRESS,ADDRESS2,ZIP,CITY],
			Sweden:[ADDRESS,ADDRESS2,ZIP,CITY],
			Switzerland:[ADDRESS,ADDRESS2,ZIP,CITY],
			USA:[ADDRESS,ADDRESS2,ADDRESS3,CITY,COUNTY,STATE,ZIP],
			'United Kingdom':[ADDRESS,ADDRESS2,ADDRESS3,CITY,COUNTY,ZIP],
			'France':[ADDRESS,ADDRESS2,ZIP,CITY,COUNTY],
			China:[ADDRESS,ADDRESS2,ADDRESS3,PROVINCE,CITY,ZIP],
			'Spain':[ADDRESS,ADDRESS2,ADDRESS3,ZIP,CITY,PROVINCE],
			'Italy':[ADDRESS,ADDRESS2,ZIP,CITY,PROVINCE],
			'Japan':[ADDRESS,ADDRESS2,CITY,PROVINCE,ZIP],
			'Portugal':[ADDRESS,ADDRESS2,ADDRESS3,ZIP,CITY],
			'Russian Federation':[ZIP,CITY,COUNTY,ADDRESS,ADDRESS2],
			'Poland':[ADDRESS,ZIP,CITY],
			'Denmark':[ADDRESS,ADDRESS2,ZIP,CITY,COUNTY],
			'Belgium':[ADDRESS,ADDRESS2,ZIP,CITY,COUNTY],
			'New Zealand':[ADDRESS,ADDRESS2,ADDRESS3,CITY,ZIP],
			'Mexico':[ADDRESS,ADDRESS2,ADDRESS3,COUNTY,ZIP,CITY,PROVINCE],
			'Australia':[ADDRESS,ADDRESS2,CITY,PROVINCE,ZIP],
			'India':[ADDRESS,ADDRESS2,CITY,PROVINCE,ZIP],
			Brazil:[ADDRESS,ADDRESS2,ADDRESS3,ZIP,CITY,PROVINCE]
		};
		
		
		public function getIgnoreCustomLayout():Dictionary{
			var dic:Dictionary = new Dictionary();
			for(var addrf:String in FIELDS){
				var obj:Object = FIELDS[addrf];
				for(var f:String in obj){
					dic[obj[f]] = obj[f];
				}
			}
			//default country address
			dic['PrimaryBillToCountry'] = 'PrimaryBillToCountry';
			dic['PrimaryShipToCountry'] = 'PrimaryShipToCountry';
			dic['AlternateCountry'] = 'AlternateCountry';
			dic['PrimaryCountry'] = 'PrimaryCountry';
			dic['Country'] = 'Country'
			
			return dic;
		}
		
		
		private static const DEFAULT_BLOCK:Array = [
			{entity:'Account',parent_field:'PrimaryBillToCountry',Name:'Main'},			
			{entity:'Account',parent_field:'PrimaryShipToCountry',Name:'Shipping'},
			{entity:'Contact',parent_field:'AlternateCountry',Name:'Contact Address'},
			{entity:'Contact',parent_field:'PrimaryCountry',Name:'Main Address'},
			{entity:'Lead',parent_field:'Country',Name:'Address'}
			
		];
		
		public static const DEFAULT_COUNTRY_FROM_USER:Object={
			'Account':'PrimaryBillToCountry','Contact':'AlternateCountry','Lead':'Country'
		};
		
		
		protected function buildField(blockName:String,fields:Array):String{
			var strFields:String = '';
			var first:Boolean = true;
			for each(var f:String in fields){
				if(!first){
					strFields+=',';
				}
				var objF:Object = FIELDS[f];
				strFields+=objF[blockName];
				first = false;
			}
			return strFields;
		}
		
		public function checkAddressBlock():void{	
			for each(var block:Object in DEFAULT_BLOCK){
				if(!exist(block.entity,block.parent_field)){
					block.addressfield='country';
					insert(block);
					var lastRecord:Object = selectLastRecord();
					for(var val:String in DYNAMIC_GROUP){
						var dependFields:Array = DYNAMIC_GROUP[val] as Array;
						var objSave:Object = {'parent_field_value':val,'entity':lastRecord.entity,'isdefault':('DEFAULT'==val),'parent_id':lastRecord.gadget_id};
						objSave.fields = buildField(lastRecord.Name,dependFields);
						objSave.addressfields= dependFields.join(',');
						Database.blockDependField.insert(objSave);
					}
				}
			}		
			
		}
		
		public function BlockLayoutDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'block_layout',
				index: ["entity", "parent_field","Name"],
				unique : ["entity, parent_field,Name"],
				columns: {gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT", 'TEXT' : textColumns}
			});
			
			stmtGetNameByEntity = new SQLStatement();
			stmtGetNameByEntity.sqlConnection = sqlConnection;
			stmtGetNameByEntity.text = "Select * from block_layout where entity=:entity group by Name";
		}
		
		
		public function exist(entity:String,parent_field:String):Boolean{
			var result:Array = select("parent_field",null,{'parent_field':parent_field,'entity':entity},"1");
			return result!=null && result.length>0;
		}
		
		public function getAvailableName(entity:String):ArrayCollection{
			stmtGetNameByEntity.parameters[":entity"]=entity;
			exec(stmtGetNameByEntity);
			return new ArrayCollection(stmtGetNameByEntity.getResult().data);
		}
		
		public function getByGadgetId(gadget_id:String):Object{
			var result:Array = fetch({'gadget_id':gadget_id});
			if(result!=null && result.length>0){
				return result[0];
			}
			return null;
		}
		private var textColumns:Array = [
			"entity", 
			"Name",
			"parent_field",
			'addressfield'			
		];
		
	}
}