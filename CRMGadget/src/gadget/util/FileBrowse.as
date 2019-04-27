package gadget.util
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	import gadget.i18n.i18n;

	public class FileBrowse
	{
		
		private var _fileReference:FileReference;
		private var _upload:Function;
		private var _fieldKey:String;
		private var _passImageType:Boolean;
		private var _fileFilter:FileFilter = new FileFilter("Images: (*.jpeg, *.jpg, *.gif, *.png)", "*.jpeg; *.jpg; *.gif; *.png");
		private var _showImageOnly:Boolean;
		public function FileBrowse(upload:Function, showImageOnly:Boolean = false,fieldKey:String=null, passImageType:Boolean=false)
		{
			_upload = upload;
			_showImageOnly = showImageOnly;
			_fieldKey = fieldKey;
			_passImageType = passImageType;
			_fileReference = new FileReference();
			_fileReference.addEventListener(Event.SELECT,onFileSelect);
			_fileReference.addEventListener(ProgressEvent.PROGRESS,onFileProgress);
			_fileReference.addEventListener(Event.COMPLETE,onFileComplete);
		}
		
		private function onFileSelect(event:Event):void
		{
			_fileReference.load();
		}

		private function onFileProgress(event:ProgressEvent):void
		{
			Utils.showLoadingProgressWindow(null, i18n._(StringUtils.LOADING_STR));
			trace("progressHandler: name=" + _fileReference.name + "bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}		
		
		private function onFileComplete(event:Event):void
		{
			
			if(_fieldKey){
				_upload(_fileReference.name, _fileReference.data,_fieldKey);
			}else if(_passImageType){
				_upload(_fileReference.name, _fileReference.data, _fileReference.extension);
			}else{
				_upload(_fileReference.name, _fileReference.data);
			}				

		}
		
		public function show():void 
		{
			_fileReference.browse( _showImageOnly ? [_fileFilter] : null );
		}
		
	}
}