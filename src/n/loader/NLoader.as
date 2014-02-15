package n.loader {
	import flash.display.AVM1Movie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.net.NetStream;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import n.loader.events.NLoaderEvent;
	import n.loader.items.*;
	
	/**
	 * ...
	 * @author N
	 */
	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "error", type = "flash.events.ErrorEvent")]
	public class NLoader extends EventDispatcher {
		
        public static const TYPE_BINARY:String = "binary";
        public static const TYPE_IMAGE:String = "image";
        public static const TYPE_SWF:String = "swf";
        public static const TYPE_SOUND:String = "sound";
        public static const TYPE_TEXT:String = "text";
        public static const TYPE_XML:String = "xml";
        public static const TYPE_VIDEO:String = "video";
		
		public const VERSION:String = "v0.13";
		
		private static const type_classes:Object = { 
			image:DisplayItem, 
			swf:DisplayItem, 
			xml:URLLoaderItem, 
			text:URLLoaderItem, 
			binary:URLLoaderItem, 
			video:VideoItem, 
			sound:SoundItem
		}
		
		//loading & loaded items
		private var items:Vector.<LoadingItem>;
		//items id to be loaded
		private var queue:Vector.<String>;
		private var _current_item:LoadingItem;
		private var is_running:Boolean;
		private var is_paused:Boolean;	//not used
		
		public function NLoader() {
			items = new Vector.<LoadingItem>();
			queue = new Vector.<String>();
			is_running = false;
			is_paused = false;
		}
		
		/**
		 * Add new item to load.
		 * @param	_url	String, XML, XMLList, URLRequest
		 * @param	_type	one of available types
		 * @param	_id		by default == _url as String
		 * @param 	_props	properties { context:LoaderContext or SoundLoaderContext, headers:Array }
		 */
		
		public function add(_url:*, _type:String, _id:String = null, _props:Object = null):LoadingItem {
			var _request:URLRequest;
			if (_url is URLRequest) {
				_request = _url;
			} else {
				_request = new URLRequest(String(_url));
			}
			if (_props && _props['headers']) _request.requestHeaders = _props['headers'];
			if (!_id || _id == "") _id = _request.url;
			
			var _item:LoadingItem = get(_id);
			if (_item) {
				trace("[NLoader] Item with id == '" + _id + "' already exist");
				if (_item.is_loaded) {
					_item.dispatchOnNextFrame(new Event(Event.COMPLETE));
				}
				if (_item.is_can_playing) {
					_item.dispatchOnNextFrame(new NLoaderEvent(NLoaderEvent.CAN_BEGIN_PLAYING));
				}
				if (!queue.length) dispatchEvent(new Event(Event.COMPLETE));
				return _item
			}
			
			_item = new type_classes[_type](_request, _id) as LoadingItem;
			if (_type == TYPE_BINARY) {
				(_item as URLLoaderItem).data_format = URLLoaderDataFormat.BINARY;
			}
			if (_item is DisplayItem && _props && _props['context']) (_item as DisplayItem).setContext(_props['context']);
			if (_item is SoundItem && _props && _props['context']) (_item as SoundItem).setContext(_props['context']);
			
			_item.addEventListener(Event.COMPLETE, onItemComplete);
			_item.addEventListener(ErrorEvent.ERROR, onError);
			items.push(_item);
			queue.push(_id);
			if (!is_paused && !is_running) loadNext();
			return _item
		}

		/**
		 * Cancel item with <code>id == _id</code>. If <code>_id</code> unknown, cancel all not loaded items and clear queue.
		 * Before calling this method you must unsubscribe removed items from listeners.
		 * If item already loaded, nothing happened (use <code>dispose(_id)</code> to delete them).
		 * @param	_id
		 */
		public function cancel(_id:String = null):void {
			if (_id) {
				cancelItem(_id);
			} else {
				cancelAll();
			}
		}
		
		/**
		 * Delete item with <code>id == _id</code>. If <code>_id</code> not set, delete all items and get them ready for garbage collector.
		 * @param	_id
		 */
		public function dispose(_id:String = null):void {
			if (_id) {
				disposeItem(_id);
			} else {
				disposeAll();
			}
		}
		
		public function get current_item():LoadingItem {
			return _current_item
		}
		
		public function get queue_length():uint {
			return queue.length
		}
		
		public function get(_id:String):LoadingItem {
			for (var i:int = 0; i < items.length; i++) {
				if (items[i].id == _id) {
					return items[i]
				}
			}
			return null
		}
		
		public function getBitmap(_id:String):Bitmap {
			return Bitmap(getContentAsType(_id, Bitmap))
		}
		
		public function getBitmapData(_id:String):BitmapData {
			var _item:Bitmap = getBitmap(_id);
			if (_item) {
				return getBitmap(_id).bitmapData
			} else {
				return null
			}
		}
		
		public function getXML(_id:String):XML {
			return XML(getContentAsType(_id, String));
		}
		
		public function getString(_id:String):String {
			return String(getContentAsType(_id, String))
		}
		
		public function getMovieClip(_id:String):MovieClip {
			return MovieClip(getContentAsType(_id, MovieClip))
		}
		
		/**
		 * AVM1 movie cannot be added to display list by itself, use this construction <code>addChild(getAVM1Movie("id").parent)</code>
		 * @param	_id
		 * @return
		 */
		
		public function getAVM1Movie(_id:String):AVM1Movie {
			return AVM1Movie(getContentAsType(_id, AVM1Movie))
		}
		
		public function getNetStream(_id:String):NetStream {
			return NetStream(getContentAsType(_id, NetStream))
		}
		
		public function getNetStreamMetaData(_id:String):Object {
			return (get(_id) as VideoItem).metadata
		}
		
		public function getByteArray(_id:String):ByteArray {
			return ByteArray(getContentAsType(_id, ByteArray))
		}
		
		/**
		 * Sound instance available right after adding item to load.
		 * @param	_id
		 * @return
		 */
		public function getSound(_id:String):Sound {
			return Sound(getContentAsType(_id, Sound))
		}
		
		private function onItemComplete(e:Event):void {
			var _item:LoadingItem = e.target as LoadingItem;
			removeListeners(_item);
			
			loadNext();
		}
		
		private function onError(e:ErrorEvent):void {
			var _item:LoadingItem = e.target as LoadingItem;
			removeListeners(_item);
			if (hasEventListener(ErrorEvent.ERROR)) {
				dispatchEvent(new ErrorEvent(e.type, false, false, e.text));
			} else if (!_item.hasEventListener(ErrorEvent.ERROR)) {
				trace("[NLoader] Cannot load item with id == '" + _item.id + "' " + e.text);
			}
			loadNext();
		}
		
		private function loadNext():void {
			if (queue.length) {
				is_running = true;
				var _id:String = queue.splice(0, 1)[0];
				var _item:LoadingItem = get(_id);
				_current_item = _item;
				_item.load();
			} else {
				is_running = false;
				_current_item = null;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function getContentAsType(_id:String, _class:Class):Object {
			var _item:LoadingItem = get(_id);
			if (_item) {
				return _item.content as _class
			} else {
				return null
			}
		}
		
		private function removeListeners(_item:LoadingItem):void {
			_item.removeEventListener(Event.COMPLETE, onItemComplete);
			_item.removeEventListener(ErrorEvent.ERROR, onError);
		}
		
		private function cancelItem(_id:String):void {
			var _item:LoadingItem;
			for (var i:int = 0; i < items.length; i++) {
				_item = items[i];
				if (_item.id == _id) {
					if (!_item.is_loaded) {
						_item.cancel();
						removeListeners(_item);
						items.splice(i, 1);
						if (_item == _current_item) {
							loadNext();
						} else {
							queue.splice(queue.indexOf(_id), 1);
						}
					}
					return
				}
			}
		}
		
		private function cancelAll():void {
			if (_current_item) _current_item = null;
			queue = new Vector.<String>();
			is_running = false;
			
			var _item:LoadingItem;
			for (var i:int = 0; i < items.length; i++) {
				_item = items[i];
				if (!_item.is_loaded) {
					removeListeners(_item);
					_item.cancel();
					items.splice(i, 1);
				}
			}
		}
		
		private function disposeItem(_id:String):void {
			var _item:LoadingItem;
			for (var i:int = 0; i < items.length; i++) {
				_item = items[i];
				if (_item.id == _id) {
					if (_item.is_loaded) {
						_item.dispose();
						items.splice(i, 1);
					} else {
						cancelItem(_id);
					}
					return
				}
			}
		}
		
		private function disposeAll():void {
			cancelAll();
			for (var i:int = 0; i < items.length; i++) {
				items[i].dispose();
			}
			items = new Vector.<LoadingItem>();
		}
		
	}

}