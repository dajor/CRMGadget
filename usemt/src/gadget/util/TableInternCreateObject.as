// Helper Object to allow better typechecking
package gadget.util
{
	import flash.data.SQLStatement;

	public class TableInternCreateObject
	{
		public var work:Function;		// Worker function
		public var stmt:SQLStatement;	// SQL info
		public var table:String;		// table name to use
		public var structure:Object;	// structure object
		public var special:Object;		// special object
		public var dn:String;			// DisplayName
		public var callcallback:Boolean;// call structure.create_cb?
		public var cols:Object;			// object {column:{type:"TEXT",...}
		public var colslc:Object;		// object with column names all lowercase
	}
}