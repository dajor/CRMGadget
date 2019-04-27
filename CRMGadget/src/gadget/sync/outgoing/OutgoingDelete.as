
package gadget.sync.outgoing {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.i18n.i18n;
	import gadget.sync.task.SyncTask;
	import gadget.util.ObjectUtils;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;

	public class OutgoingDelete extends SyncTask {

		private var objects : ArrayCollection;


		// Following are precalculated from initialization
		protected var entityIDns:String;	// CustomObject1, ...
		protected var entityID:String;	// Account, Contact, Custom Object 1, ...
		protected var sodID:String;		// account, contact, ...
		protected var listID:String;	// ListOfAccount, ...
		protected var idField:String;	// AccountId, ...
		protected var wsIDcheck:String;		// AccountWS_AccountQueryPage_Input,  ...
		protected var wsIDdelete:String;		// AccountWS_AccountDelete_Input,  ...
		protected var urnCheck:String;	// document/urn:crmondemand/ws/account/:AccountQueryPage, ...
		protected var urnDelete:String;	// document/urn:crmondemand/ws/account/:AccountDelete, ...
		
		protected var ns1:Namespace;	// for request (delete)
		protected var ns2:Namespace;	// for data
		protected var dao:BaseDAO;

		// Likely to be changed after initialization
		protected var checkXML:XML;
		protected var deleteXML:XML;
		protected var appendTemplateCheck:XML, appendTemplateDelete:XML;
		
//		private var isChecked:Boolean;

		public function OutgoingDelete(ID:String):void {

			entityIDns	= ID.replace(/ /g,"");
			entityID	= ID;
			sodID		= entityIDns.toLowerCase();
			listID		= "ListOf"+entityIDns;
			idField		= DAOUtils.getOracleId(ID); //EntityIDns+"Id";

			var prop:SodUtilsTAO = SodUtils.transactionProperty(ID);

			ns1			= new Namespace("urn:crmondemand/ws/ecbs/"+sodID+"/");
			ns2			= new Namespace("urn:/crmondemand/xml/"+entityIDns+"/Data");
				
			wsIDcheck	= entityIDns+"QueryPage_Input";
			wsIDdelete	= entityIDns+"Delete_Input";
			urnCheck	= "document/urn:crmondemand/ws/ecbs/"+sodID+"/:"+entityIDns+"QueryPage";
			urnDelete	= "document/urn:crmondemand/ws/ecbs/"+sodID+"/:"+entityIDns+"Delete";

			var daoName:String = prop.dao;
			dao		= Database[daoName];
			if (!dao)
				notImpl(i18n._("DAO {1} for {2}", daoName, entityID));

			tweak_vars();

			if (checkXML==null) {
				checkXML = moreGenericXML(
					<{wsIDcheck} xmlns='{ns1.uri}'>
						<{listID}>
						</{listID}>
					</{wsIDcheck}>
					);
			}

			if (deleteXML==null) {
				deleteXML = moreGenericXML(
					<{wsIDdelete} xmlns='{ns1.uri}'>
						<{listID}>
						</{listID}>
					</{wsIDdelete}>
					);
			}

			if (appendTemplateCheck==null) {
				appendTemplateCheck	= moreGenericXML(
					<{entityIDns} xmlns='{ns1.uri}'>
						<Id/>
					</{entityIDns}>
					);
			}
			if (appendTemplateDelete==null) {
				appendTemplateDelete	= appendTemplateCheck;
			}

//			isChecked	= false;
			}

		protected function tweak_vars():void { }

		protected function moreGenericXML(xml:XML):XML {
			//VAHI Poor man's workaround because XML templates are not generic enough
			// perhaps do this in doRequest, too?
			return new XML(
				xml.toXMLString()
				.replace(/{EntityID}/g,entityID)
				.replace(/{EntityIDns}/g,entityIDns)
				.replace(/{ListID}/g,listID)
				.replace(/{SodID}/g,sodID)
				.replace(/{IdField}/g,idField)
				.replace(/{WsIDcheck}/g,wsIDcheck)
				.replace(/{WsIDdelete}/g,wsIDdelete)
				.replace(/{ns1.uri}/g,ns1.uri)
			);
		}
		
		override protected function doRequest():void {
			// VAHI Don't ask.  It took me (more than) 4hrs to find QName .. Bullshit documentation
			var qlist:QName=new QName(ns1.uri,listID), qent:QName=new QName(ns1.uri,entityIDns), qId:QName=new QName(ns1.uri, "Id");

			objects = dao.findDeleted(0, 1);
//			objects = dao.findDeleted(isChecked ? 0 : page, 1);
			if (objects.length == 0) {
//				if (isChecked) {
					updateLastSync();
					return;
//				}
//				isChecked	= true;
//				resetPage();
//				return;
			}

			//var request:XML = new XML(isChecked ? deleteXML.toXMLString() : checkXML.toXMLString());
			var request:XML = new XML(deleteXML.toXMLString());
			for (var i:int = 0; i < objects.length; i++) {
				//request.child(qlist)[0].appendChild(isChecked ? appendTemplateDelete : appendTemplateCheck);
				//request.child(qlist)[0].child(qent)[i].child(qId)[0] = (isChecked ? objects[i][idField] : "= '"+objects[i][idField]+"'");
				//delete always
				request.child(qlist)[0].appendChild( appendTemplateDelete);
				request.child(qlist)[0].child(qent)[i].child(qId)[0] =  objects[i][idField];
			}
			trace("::::::: DELETE ::::::::",getEntityName(),page, request);
//			sendRequest('"'+(isChecked ? urnDelete : urnCheck)+'"', request);
			sendRequest('"'+urnDelete+'"', request);
		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			var list:XMLList;
			var deleted:Boolean;

			trace(result.toXMLString());
//			dao.delete_(objects[0]);
			deleteFromDatabase(objects[0]);
			notifyDelete(true, ObjectUtils.joinFields(objects[0], DAOUtils.getNameColumns(entityID)));
//			list = result.child(new QName(ns2.uri,listID));
//			if (list.length()>0 && list[0].child(new QName(ns2.uri,entityID)).length()>0) {
//				// object was found on the other side.
//				// If we are deleting (isChecked is true) the object was deleted on SoD right now
//				deleted = isChecked;
//			} else {
//				// nothing was found on the other side
//				// If we are checking (isChecked is false) this means the object is gone on SoD
//				// so delete it here, too.
//				deleted	= !isChecked;
//			}
//			if (deleted) {
//				// The object has vanished on the other side (we got no result), so delete it locally
//				dao.delete_(objects[0]);
//				notifyDelete(true, objects[0].name);
//			}
            nextPage(false);
			return deleted ? 1 : 0;
 		}

		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			if (faultString.indexOf("(SBL-EAI-04421)")>=0||
				faultString.indexOf("(SBL-ODS-00336)")>=0) {	// Cannot perform DeleteRecord on the business component 'Action'(SBL-EAI-04421)
				dao.undeleteTemporary(objects[0]);
				var colsName:Array  = DAOUtils.getNameColumns(entityID);
				var name:String = ObjectUtils.joinFields(objects[0], colsName);
				notifyX(false, name, "Undeleted");
				warn(i18n._("undeleted {1} (cannot be deleted): {2}", entityID,  name));
				nextPage(false);
				return true;
			}else if(faultString.indexOf("(SBL-EAI-04378)")>=0){//No rows retrieved corresponding to the business component 'Action'(SBL-EAI-04378)
				//dao.delete_(objects[0]);
				deleteFromDatabase(objects[0]);
				nextPage(false);
				return true;
			}
			return false;
		}
		
		protected function deleteFromDatabase(obj:Object):void{			
			dao.delete_(obj);
			//Bug #1504 CRO						
			Database.attachmentDao.deleteByGadgetId(obj.gadget_id);
			// delete tree value
			Database.customPicklistValueDAO.deleteByGadgetId(obj);
			
			//delete child
			Utils.deleteChild(obj,entityID);
			//remove relation
			Utils.removeRelation(obj,entityID);
		}
		override protected function getCurrentRecordError():Object{
			if(objects!=null && objects.length>0){
				var obj:Object = objects[0];
				obj.gadget_type = entityID;
				return obj;
			}
			
			return null;
		}
		
		override public function getEntityName():String {
			return entityID;
		}
		
		override public function getName():String {
			return i18n._("Sending {1} deletions to server...", entityID); 
		}		

	}
}
