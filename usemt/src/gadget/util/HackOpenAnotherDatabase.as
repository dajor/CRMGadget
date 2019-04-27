package gadget.util {
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;

	public function HackOpenAnotherDatabase(conn:SQLConnection):Array {
		try {
			var stmt:SQLStatement;
			
			stmt = new SQLStatement();
			stmt.sqlConnection = conn;
			stmt.text = "select key,value from prefs where key like 'DB_LIST:%'";
			stmt.execute();
			var res:SQLResult = stmt.getResult();
			if (res.data==null || res.data.length==0)
				return null;
			trace(res.data[0].value);
			return [];
		} catch (e:Error) {
			trace(e.message);
		}
		return null;
	}
}
