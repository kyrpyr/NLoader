package n.examples {
	import flash.display.Sprite;
	import flash.events.Event;
	import n.loader.NLoader;
	
	/**
	 * Всякие нюансы.
	 * @author N
	 */
	public class AdvancedLoading extends Sprite {
		
		private var loader:NLoader;
		
		public function AdvancedLoading() {
			loader = new NLoader();
			
			loader.add("data/lopatin/ilyustratcii-0001.jpg", NLoader.TYPE_IMAGE, 'image').addEventListener(Event.COMPLETE, onImageComplete);
		}
		
		private function onImageComplete(e:Event):void {
			trace("onImageComplete");
			loader.get('image').removeEventListener(Event.COMPLETE, onImageComplete);
			
			//идентификация загружаемых элементов происходит исключительно по id
			//попробуем загрузить файл с предыдущим id
			loader.add("data/lopatin/ilyustratcii-0001.jpg", NLoader.TYPE_IMAGE, 'image').addEventListener(Event.COMPLETE, onImage2Complete);
			//в этом случае в консоль будет выведен трейс о том, что файл с таким id уже загружен
			//и на следующем фрейме будет продиспатчено событие COMPLETE для этого item
		}
		
		private function onImage2Complete(e:Event):void {
			trace("onImage2Complete");
		}
		
	}

}