package n.loader.items {
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author N
	 */
	public class SoundItem extends LoadingItem {
		
		private var sound:Sound;
		
		public function SoundItem(_request:URLRequest, _id:String) {
			super(_request, _id);
		}
		
		public override function load():void {
			super.load();
			
			sound = new Sound(request, new SoundLoaderContext(1000));
			sound.addEventListener(Event.COMPLETE, onLoadComplete);
			sound.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			content = sound;
		}
		
		public override function cancel():void {
			super.cancel();
			
			try {
				sound.close();
			} catch (e:Error) { };
		}
		
		protected override function removeListeners():void {
			super.removeListeners();
			
			sound.removeEventListener(Event.COMPLETE, onLoadComplete);
			sound.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		}
		
		protected override function onError(e:ErrorEvent):void {
			super.onError(e);
		}
		
		override public function get bytes_loaded():int {
			if (sound) {
				return sound.bytesLoaded
			}
			return super.bytes_loaded
		}
		
		override public function get bytes_total():int {
			if (sound) {
				return sound.bytesTotal
			}
			return super.bytes_total
		}
	}

}