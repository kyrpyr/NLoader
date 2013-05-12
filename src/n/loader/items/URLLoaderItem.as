package n.loader.items {
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author N
	 */
	public class URLLoaderItem extends LoadingItem {
		
		public var data_format:String = URLLoaderDataFormat.TEXT;
		
		private var loader:URLLoader;
		
		public function URLLoaderItem(_request:URLRequest, _id:String) {
			super(_request, _id);
		}
		
		/**
		 * Before loading set data_format.
		 */
		public override function load():void {
			super.load();
			
			loader = new URLLoader(request);
			loader.dataFormat = data_format;
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}
		
		public override function cancel():void {
			super.cancel();
			
			try {
				loader.close();
			} catch (e:Error) { };
		}
		
		protected override function removeListeners():void {
			super.removeListeners();
			
			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}
		
		protected override function onLoadComplete(e:Event):void {
			content = loader.data;
			
			super.onLoadComplete(e);
		}
		
		protected override function onError(e:ErrorEvent):void {
			super.onError(e);
		}
		
		override public function get bytes_loaded():int {
			if (loader) {
				return loader.bytesLoaded
			}
			return super.bytes_loaded
		}
		
		override public function get bytes_total():int {
			if (loader) {
				return loader.bytesTotal
			}
			return super.bytes_total
		}
		
	}

}