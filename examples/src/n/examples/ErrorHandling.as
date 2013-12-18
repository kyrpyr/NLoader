package n.examples {
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import n.loader.NLoader;
	/**
	 * ...
	 * @author N
	 */
	public class ErrorHandling {
		
		private var loader:NLoader;
		
		public function ErrorHandling() {
			loader = new NLoader();
			
			//рекомендую подписывать на ошибки не каждый LoadingItem по отдельности, а сразу весь loader целиком
			//хотя как вам поступать дело ваше)
			loader.addEventListener(ErrorEvent.ERROR, onGlobalError);
			//событие COMPLETE для loader сигнализирует об окончании очереди загрузки (независимо от успеха или провала конкретной операции)
			loader.addEventListener(Event.COMPLETE, onGlobalComplete);
			
			//событие COMPLETE для LoadingItem сигнализирует об успешной загрузке данного item
			//попробуем загрузить файл, которого нет
			loader.add("none", NLoader.TYPE_IMAGE).addEventListener(Event.COMPLETE, onItemComplete);
			loader.get("none").addEventListener(ErrorEvent.ERROR, onItemError);
		}
		
		private function onGlobalComplete(e:Event):void {
			trace("onGlobalComplete");	//этот трейс сработает, т.к. очередь закончилась (пускай и с ошибками)
		}
		
		private function onGlobalError(e:ErrorEvent):void {
			trace("onGlobalError");		//этот трейс сработает на ошибку
		}
		
		private function onItemError(e:ErrorEvent):void {
			trace("onItemError");	//и этот трейс сработает на ошибку
		}
		
		private function onItemComplete(e:Event):void {
			trace("onItemComplete");	//а этот трейст не сработает
		}
		
	}

}