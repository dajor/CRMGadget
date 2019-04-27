package gadget.dao {
	
	import flash.data.SQLConnection;
	
	public class BookmarkDAO extends SimpleTable {
		
		public function BookmarkDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"bookmark",
				unique: [ 'num' ],
				columns: {
					'num' : 'INTEGER PRIMARY KEY',
					'TEXT' : [ 'id' ]
				}
			});			
		}
		
		public function insert_bookmark(bookmark:Object):void {
			insert({id: bookmark.id, num: bookmark.num});
		}		
		
		public function read():Array {
			return fetch();
		}
		
		public function delete_bookmark(bookmark:Object):void {
			delete_({id: bookmark.id});
		}
		
		public function is_bookmarked(bookmark:Object):Boolean {			
			return fetch({id: bookmark.id}).length == 0 ? false : true;
		}
		
	}
	
}