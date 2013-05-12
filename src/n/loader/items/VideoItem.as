package n.loader.items {
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import n.loader.events.NLoaderEvent;
	/**
	 * ...
	 * @author N
	 */
	public class VideoItem extends LoadingItem {
		
		private var nc:NetConnection;
		private var stream:NetStream;
		public var metadata:Object;
		
		public function VideoItem(_request:URLRequest, _id:String) {
			super(_request, _id);
		}
		
		public override function load():void {
			super.load();
			
			nc = new NetConnection();
			nc.connect(null);
			
			stream = new NetStream(nc);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onError);
			stream.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
			stream.client = { onMetaData:onMetaData };
			stream.play(request.url);
		}
		
		private function onMetaData(o:Object):void {
			metadata = o;
			content = stream;
			stream.pause();
			dispatchEvent(new NLoaderEvent(NLoaderEvent.CAN_BEGIN_PLAYING));
		}
		
		private function onStatus(e:NetStatusEvent):void {
			switch (e.info.code) {
				case "NetStream.Play.StreamNotFound":
					onError(new ErrorEvent(ErrorEvent.ERROR, false, false, "NetStream not found at " + request.url));
					break;
			}
		}
		
		public override function cancel():void {
			super.cancel();
			
			try {
				stream.close();
			} catch (e:Error) { };
		}
		
		protected override function removeListeners():void {
			super.removeListeners();
			
			stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			stream.removeEventListener(NetStatusEvent.NET_STATUS, onStatus);
		}
		
		protected override function onLoadProgress(e:Event):void {
			if (bytes_loaded == bytes_total && bytes_total > 0) {	//load complete
				super.onLoadComplete(null);
				return
			}
			super.onLoadProgress(e);
		}
		
		protected override function onError(e:ErrorEvent):void {
			super.onError(e);
		}
		
		override public function get bytes_loaded():int {
			if (stream) {
				return stream.bytesLoaded
			}
			return super.bytes_loaded
		}
		
		override public function get bytes_total():int {
			if (stream) {
				return stream.bytesTotal
			}
			return super.bytes_total
		}
	}

}