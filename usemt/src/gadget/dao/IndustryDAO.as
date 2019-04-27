package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import mx.collections.ArrayCollection;
	
	public class IndustryDAO extends SimpleTable {
		
		public function IndustryDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"industry",
				unique: [ 'enable, display_name, sic_code, language_code' ],
				index: [ 'enable, display_name, sic_code, language_code' ]
			});
		}

		public function getIndustrylists(langCode:String='ENU'):ArrayCollection{
			var pick:ArrayCollection = new ArrayCollection();
			var got:Array = fetch({
				language_code: langCode,
				enable:     "true"
			});
			pick.addItemAt({ data:'', enable:'', label:'', sic_code:'', language_code:'' }, 0);
			for each (var r:Object in got) {
				pick.addItem({ data:r.display_name, enable:r.enable, label:r.display_name, sic_code:r.sic_code, language_code:r.language_code });
			}
			return pick;
		}
		
		public function getDifferenceLanguage():ArrayCollection {
			var langCode:Array = columns("distinct language_code", null, null);
			return new ArrayCollection(langCode);
		}

		override public function getColumns():Array {
			return [
				'enable',
				'display_name',
				'sic_code',
				'language_code'
			];
		}
	}
}