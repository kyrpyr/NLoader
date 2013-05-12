package n.loader.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author N
	 */
	public class NLoaderEvent extends Event {
		
		public static const CAN_BEGIN_PLAYING:String = "can_begin_playing";
		
		public function NLoaderEvent(_type:String) {
			super(_type);
		}
		
	}

}