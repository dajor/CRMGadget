// This is a nested class for autocompletion sugar
//
// AIR sadly does not support nested classes within a class ;(
package gadget.util
{
	public class SodUtilsTAO {
		public var our_name:String;			// Our internal name
		public var sync_order:int;			// sequence of outgoing sync
		public var top_level:Boolean;		// Is a top level object (GetField supported)
		public var sod_name:String;			// Name of object in SoD
		public var dao:String;				// DAO to use: Database[dao]
		public var ws20att_id:String;		// ListOfAttachment Tag with RowId of parent

		public var ws20act:Boolean;			// ListOfActivity present in WSDL for WS2.0
		public var ws20att:Boolean;			// ListOfAttachment present in WSDL for WS2.0
		public var ws20prod:Boolean;		// Scoop ListOfProduct
//		public var ws20user:Boolean;		// Fetch ListOfUser - actually only true on Activity object

		// Internal name from SoD-Name
		public static var mkSod:Function = function (s:String):String {
			if (s!=null) return s;
			return this.our_name;
		};
		
		// DAO name from Internal name
		public static var mkDao:Function = function (s:String):String {
			if (s!=null) return s;
			return SodUtils.mkDaoName(this.our_name);
		};
		
		// ID from SoD name
		public static var mkId:Function = function (s:String):String {
			if (s!=null) return s;
			return this.sod_name.replace(/ /g,"")+"Id";
		};

		// THIS MUST COME LAST!
		// Initializers (first letter CAPS) for the above
		// Sadly, these cannot be accessed as static object,
		// as functionlets (like mkDao etc.) cannot use "this" then.
		public static const OurName:String	= "our_name";
		public static const Order:String	= "sync_order";
		public static const Top:String		= "top_level";
		public static const SodName:Object	= { sod_name:mkSod };
		public static const Dao:Object		= { dao:mkDao };
		public static const W2AttId:Object	= { ws20att_id:mkId };
		public static const W1:String		= "ws10";
		public static const W2Gen:String	= "ws20gen";
		public static const W2Act:String	= "ws20act";
		public static const W2Att:String	= "ws20att";
		public static const W2Prod:String	= "ws20prod";
//		public static const W2User:String	= "ws20user";
	}
}
