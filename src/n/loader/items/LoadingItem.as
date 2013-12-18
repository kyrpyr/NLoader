package n.loader.items {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author N
	 */
	[Event(name = "progress", type = "flash.events.ProgressEvent")]
	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "error", type = "flash.events.ErrorEvent")]
	[Event(name = "can_begin_playing", type = "n.loader.events.NLoaderEvent")]
	public class LoadingItem extends EventDispatcher {
		
		public var id:String;
		public var is_loaded:Boolean = false;
		public var is_can_playing:Boolean = false;	//only for VideoItem
		public var content:*;
		
		public var request:URLRequest;
		
		private var dummy_listener:Sprite = new Sprite();	//for progress
		
		public function LoadingItem(_request:URLRequest, _id:String) {
			id = _id;
			request = _request;
		}
		
		public function load():void {
			dummy_listener.addEventListener(Event.ENTER_FRAME, onLoadProgress);	//check progress
		}
		
		public function cancel():void {
			removeListeners();
		}
		
		/*public function dispose():void {
			cancel();
			
		}*/
		
		public function dispatchOnNextFrame(_event_to_dispatch:Event):void {
			setTimeout(function():void {
				dispatchEvent(_event_to_dispatch);
			}, 1)
		}
		
		public function get bytes_loaded():int {
			return 0
		}
		
		public function get bytes_total():int {
			return 0
		}
		
		protected function removeListeners():void {
			dummy_listener.removeEventListener(Event.ENTER_FRAME, onLoadProgress);
		}
		
		protected function onLoadProgress(e:Event):void {
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytes_loaded, bytes_total));
		}
		
		protected function onLoadComplete(e:Event):void {
			is_loaded = true;
			removeListeners();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function onError(e:ErrorEvent):void {
			removeListeners();
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.text));
		}
		
	}

}