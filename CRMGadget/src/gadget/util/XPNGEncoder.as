package gadget.util {
	
	import __AS3__.vec.Vector;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.events.PropertyChangeEvent;
	
	[Event(name="pngComplete", type="utils.XPNGCompleteEvent")]
	
	/**
	 * Encode data from ImagSnapshot's captureBitmapData(...) and encode it to a 24-bit RGB PNG
	 **/
	public class XPNGEncoder extends Object implements IEventDispatcher
	{
		
		private var _totalPixels:Number; /// Total number of pixels in image
		private var _currentPixelCount:Number = 0; /// Current pixel being processed
		private var crcTable:Vector.<int>; /// PNG CRC Table
		private var bindingEventDispatcher:EventDispatcher; /// Event dispatcher for XPNGEncoder
		
		public var pixelsPerIteration:Number = 40; // Number of pixels to crunch per iteration, default=40 to avoid app lock-up
		
		/*
		* Constructor
		*/
		public function XPNGEncoder()
		{
			bindingEventDispatcher = new EventDispatcher( IEventDispatcher( this ) );
			
			initializeCRCTable();
		}
		
		/*
		* Retrieve total pixels in image
		*      @returns Total pixels in image
		*/
		public function get totalPixels():Number
		{
			return _totalPixels;
		}
		
		/*
		* Set current pixel count
		*      @value: Value to set pixel count at
		*/
		public function set currentPixelCount( value:Number ):void
		{
			if ( currentPixelCount !== value )
			{
				_currentPixelCount = value;
				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "currentPixelCount", currentPixelCount, value ) );
			}
		}
		
		/*
		* Retrieve current pixel count
		*      @returns Current pixel count
		*/
		public function get currentPixelCount():Number
		{
			return _currentPixelCount;
		}
		
		/*
		* Encode bitmap data into PNG
		*      @data: Bitmap data to encode
		*/
		public function encodePNG( data:BitmapData ):void
		{
			encodeBitmapData( data );
		}
		
		/*^
		* Write chunks of data for image
		*      @png: PNG header data
		*      @type: PNG type
		*      @data: PNG data
		*/
		private function writeChunk( png:ByteArray, type:uint, data:ByteArray ):void
		{
			var len:uint = 0;
			if ( data )     len = data.length;
			
			png.writeUnsignedInt( len );
			var typePos:uint = png.position;
			png.writeUnsignedInt( type );
			if ( data ) png.writeBytes( data );
			
			var crcPos:uint = png.position;
			png.position = typePos;
			var crc:uint = 4294967295;
			var en:uint = typePos;
			while ( en < crcPos )
			{
				crc = uint( crcTable[( crc ^ png.readUnsignedByte() ) & uint( 255 )] ^ uint( crc >>> 8 ) );
				en = en + 1;
			}
			crc = uint( crc ^ uint( 4294967295 ) );
			png.position = crcPos;
			png.writeUnsignedInt( crc );
		}
		
		/*
		* Encode BitmapData into ByteArray
		*      @data: BitmapData to encode
		*      @returns BitmapData as ByteArray
		*/
		private function encodeBitmapData( data:BitmapData ):void
		{
			var a:uint = 0;
			var b:int = 0;
			var pngH:ByteArray = new ByteArray();
			var height:Number = data.height;
			var width:Number = data.width;
			_totalPixels = width * height;
			pngH.writeUnsignedInt( 2303741511 );
			pngH.writeUnsignedInt( 218765834 );
			var pdata:ByteArray = new ByteArray();
			pdata.writeInt( width );
			pdata.writeInt( height );
			pdata.writeUnsignedInt( 134348800 );
			pdata.writeByte( 0 );
			writeChunk( pngH, 1229472850, pdata );
			var _pdata:ByteArray = new ByteArray();
			var c:Number = 0;
			var d:int = 0;
			
			setTimeout( asyncLoop, 10 );
			
			function asyncLoop():void
			{
				for ( var x:int = 0; pixelsPerIteration > x; x++ )
				{
					if ( d < height )
					{
						_pdata.writeByte( 0 );
						b = 0;
						
						///FIX
						while ( b < width )
						{
							a = data.getPixel( b, d );
							_pdata.writeByte( a >> 16 & 255 );
							_pdata.writeByte( a >> 8 & 255 );
							_pdata.writeByte( a & 255 );
							b++;
						}
						///FIX
						d++;
					}
					else
					{
						_pdata.compress();
						writeChunk( pngH, 1229209940, _pdata );
						writeChunk( pngH, 1229278788, null );
						dispatchEvent( new XPNGCompleteEvent( XPNGCompleteEvent.PNG_COMPLETE, pngH ) );
						return;
					}
				}
				setTimeout( asyncLoop, 10 );
			}
		}
		
		/*^
		* Initiate PNG CRC table
		*/
		private function initializeCRCTable():void
		{
			var a:uint = 0;
			var c:uint = 0;
			var b:uint = 0;
			
			crcTable = new Vector.<int>;
			
			while ( b < 256 )
			{                               
				a = b;
				c = 0;
				while ( c < 8 )
				{
					if ( a & 1 ) a = uint( uint( 3988292384 ) ^ uint( a >>> 1 ) );
					else a = uint( a >>> 1 );
					c = c + 1;
				}
				crcTable[b] = a;
				b = b + 1;
			}
		}
		
		/*
		* Add event listener
		*/
		public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void
		{
			bindingEventDispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}
		
		/*
		* Remove event listener
		*/
		public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void
		{
			bindingEventDispatcher.removeEventListener( type, listener, useCapture );
		}
		
		/*
		* Dispatch event
		*/
		public function dispatchEvent( event:Event ):Boolean
		{
			return bindingEventDispatcher.dispatchEvent( event );
		}
		
		/*
		* Check if XPNGEncoder has event listener of @type
		*/
		public function hasEventListener( type:String ):Boolean
		{
			return bindingEventDispatcher.hasEventListener( type );
		}
		
		/*
		* XPNGEncoder will trigget @type of event
		*/
		public function willTrigger( type:String ):Boolean
		{
			return bindingEventDispatcher.willTrigger( type );
		}
		
	}
}
