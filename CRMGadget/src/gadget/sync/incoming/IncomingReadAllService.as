package gadget.sync.incoming {
	import flash.events.IOErrorEvent;
	
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.dao.SimpleTable;
	import gadget.i18n.i18n;
	import gadget.sync.task.SyncTask;
	import gadget.util.ObjectUtils;
	import gadget.util.SodUtils;

//	import gadget.util.FieldUtils;
	
	public class IncomingReadAllService extends SyncTask {

		private var name:String;
		private var ns1:Namespace;
		private var ns2:Namespace;
		private var urn:String;
		private var input:String;
		private var output:String;
		private var service:String;	// can be NULL for default

		private var def:Object;

		public function IncomingReadAllService(info:Object) {
			name = info.name;
			ns1 = new Namespace(info.ns1);	//urn:crmondemand/ws/odesabs/accessprofile/
			ns2 = new Namespace(info.ns2);	//urn:/crmondemand/xml/AccessProfile/Data
			urn = info.urn;					//document/urn:crmondemand/ws/odesabs/accessprofile/:AccessProfileReadAll
			input = info.input;				//AccessProfileReadAll_Input
			output = info.output;			//AccessProfileReadAll_Output
			service = info.service;			//Services/cte/AccessProfileService
			
			// subrecs is a parameterobject, defined as:
			// { name:"daoname", copy:{"to":"from"}, def:{"to":"from"}, dao:{parameterobject}, tag:{tagobject} }
			// tagobject is defined as:  { "tag1":{parameterobject},... }
			// copy and def are cumulative, detected on the availablility of the named columns in the DAOs.
			def = info.def;
		}

		override protected function doRequest():void {

			if (getLastSync() != NO_LAST_SYNC_DATE) {
				successHandler(null);
				return;
			} 
			
			sendRequest('\"'+urn+'\"',
				<{input} xmlns={ns1}/>,
				"admin",
				this.service
			);

		}
		
		private function getDataStr(field:XML, col:String):String {
			var tmp:XMLList = field.child(new QName(ns2.uri,col.replace(/_$/,"")));
			return tmp.length()==0 ? "" : tmp[0].toString();
		}
		
		private function copyCols(ob:Object, field:XML, cols:Array):Object {
			for each (var col:String in cols) {
				ob[col] = getDataStr(field,col);
			}
			return ob;
		}

		private function populate(field:XML, cols:Array):Object {
			return copyCols({}, field, cols);
		}

		private function parameterobject(xml:XML, tag:Object, rec:Object=null, copy:Object=null, me:String=null):int {
			var cnt:int = 0;

			if ("copy" in tag) {
				copy = ObjectUtils.merge(ObjectUtils.shallow_copy(copy), tag.copy);
			}
			if ("def" in tag) {
				for (var put:String in tag.def) {
					rec[put] = tag.def[put];
				}
			}
			if ("cols" in tag) {
				copyCols(rec, xml, tag.cols);
			}
			if ("self" in tag && tag.self) {
				rec[me] = xml.toString();
			}
			//tag.name already processed about
			if ("tag" in tag) {
				for (var field:String in tag.tag) {
					for each (var chi:XML in xml.child(new QName(ns2, field))) {
						cnt += parameterobject(chi, tag.tag[field], rec, copy, field);
					}
				}
			}
			if ("dao" in tag) {
				var dao:SimpleTable = Database[SodUtils.mkDaoName(tag.dao.name)];
				if (dao==null)
					throw new Error("unknown DAO: "+SodUtils.mkDaoName(tag.dao.name));
				var sub:Object = populate(xml, dao.getColumns());
				for (var s:String in copy) {
					sub[s] = rec[copy[s]];
				}
				cnt += parameterobject(xml, tag.dao, sub, copy, me);
				dao.insert(sub);
				cnt++;
			}
			return cnt;
		}

		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}

			var cnt:int = 0;

			Database.begin();
			
			var maindao:SimpleTable = Database[SodUtils.mkDaoName(name)]; 
			maindao.delete_all();
			
			cnt = parameterobject(result, def);

			Database.commit();
			
			nextPage(true);
			return cnt;
		}

		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, xml_list:XMLList):Boolean {
			if (xml_list!=null && xml_list.length()>0 && xml_list[0].faultstring.length()==1) {
				var str:String = xml_list[0].faultstring[0].toString();
				if (str!=""){//str=="Access Denied." || str=="Accès refusé.") {
					optWarn(i18n._("{1} not supported: {2}", name, str));
					nextPage(true);
					return true;
				}
			}
			if (mess!=null) {
				var lc:String = mess.toLowerCase();
				for each (var err:String in [ '404 not found' ]) {
					if (lc.indexOf(err)>0) {
						optWarn(i18n._("{1} not supported: {2}", name, err));
						nextPage(true);
						return true;
					}
				}
			}
			return false;
		}
		
		override public function getName():String {
			return i18n._("Getting {1}...", name); 
		}
		
		override public function getEntityName():String {
			return name; 
		}
	}
}
