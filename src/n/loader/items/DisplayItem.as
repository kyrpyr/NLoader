package n.loader.items {
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	/**
	 * ...
	 * @author N
	 */
	public class DisplayItem extends LoadingItem {
		
		private var loader:Loader;
		private var context:LoaderContext;
		
		public function DisplayItem(_request:URLRequest, _id:String) {
			super(_request, _id);
		}
		
		public function setContext(_context:LoaderContext):void {
			context = _context;
		}
		
		public override function load():void {
			super.load();
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request, context);
		}
		
		public override function cancel():void {
			super.cancel();
			
			try {
				loader.close()
			} catch (e:Error) { };
		}
		
		protected override function removeListeners():void {
			super.removeListeners();
			
			if (loader) {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		protected override function onLoadComplete(e:Event):void {
			content = loader.content;
			
			super.onLoadComplete(e);
		}
		
		protected override function onError(e:ErrorEvent):void {
			super.onError(e);
		}
		
		override public function get bytes_loaded():int {
			if (loader) {
				return loader.contentLoaderInfo.bytesLoaded
			}
			return super.bytes_loaded
		}
		
		override public function get bytes_total():int {
			if (loader) {
				return loader.contentLoaderInfo.bytesTotal
			}
			return super.bytes_total
		}
		
	}

}