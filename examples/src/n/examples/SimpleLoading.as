package n.examples {
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.media.SoundChannel;
	import flash.media.Video;
	import flash.net.NetStream;
	import n.loader.events.NLoaderEvent;
	import n.loader.NLoader;
	/**
	 * Пробуем загружать различные типы файлов
	 * @author N
	 */
	public class SimpleLoading extends Sprite {
		
		private var loader:NLoader;
		private var xml:XML;
		
		public function SimpleLoading() {
			loader = new NLoader();
			//грузим конфигурационный xml
			loader.add("data/data.xml", NLoader.TYPE_XML, 'data').addEventListener(Event.COMPLETE, onXMLComplete);
		}
		
		private function onXMLComplete(e:Event):void {
			trace("onXMLComplete");
			loader.get('data').removeEventListener(Event.COMPLETE, onXMLComplete);
			
			//конфиг загружен, теперь можно грузить картинки
			xml = loader.getXML('data');
			for each (var i:XML in xml.item) {
				//если не указывать id, он автоматически становится равен строке url
				loader.add(i, NLoader.TYPE_IMAGE);
			}
			//если нужно грузить несколько файлов, продуктивнее подписывать обработчики не на экземпляр LoadingItem, а на сам loader
			loader.addEventListener(Event.COMPLETE, onImagesComplete);
		}
		
		private function onImagesComplete(e:Event):void {
			trace("onImagesComplete");
			loader.removeEventListener(Event.COMPLETE, onImagesComplete);
			//все картинки загружены
			
			var count:uint = 0;
			var bitmap:Bitmap;
			for each (var i:XML in xml.item) {
				//не нужно приводить i к String, чтобы использовать его как id, все происходит автоматически
				bitmap = loader.getBitmap(i);
				bitmap.x = count * 80;
				bitmap.y = count * 40;
				addChild(bitmap);
				count++;
				
				trace(loader.getBitmapData(i));	//при желании можно легко взять и BitmapData
			}
			
			//пробуем грузить свфки
			//сначала грузим avm2
			loader.add("data/test_as3.swf", NLoader.TYPE_SWF, 'avm2').addEventListener(Event.COMPLETE, onAVM2Complete);
		}
		
		private function onAVM2Complete(e:Event):void {
			trace("onAVM2Complete");
			loader.get('avm2').removeEventListener(Event.COMPLETE, onAVM2Complete);
			
			var avm2:MovieClip = loader.getMovieClip('avm2');
			avm2.x = 650;
			addChild(avm2);
			
			//теперь avm1
			loader.add("data/circle_motion_as2.swf", NLoader.TYPE_SWF, 'avm1').addEventListener(Event.COMPLETE, onAVM1Complete);
		}
		
		private function onAVM1Complete(e:Event):void {
			trace("onAVM1Complete");
			loader.get('avm1').removeEventListener(Event.COMPLETE, onAVM1Complete);
			
			//avm1 нельзя просто добавить в список отображения, надо действовать так:
			var avm1:Loader = loader.getAVM1Movie('avm1').parent as Loader;
			avm1.x = 700;
			avm1.y = 200;
			addChild(avm1);
			
			//грузим звук
			loader.add("data/12 - You Suffer.mp3", NLoader.TYPE_SOUND, 'sound').addEventListener(Event.COMPLETE, onSoundComplete);
			//тут надо заметить, что экземпляр Sound доступен сразу после инициализации загрузки
			var sch:SoundChannel = loader.getSound('sound').play();
			//а событие COMPLETE выстреливает после полной загрузки файла
		}
		
		private function onSoundComplete(e:Event):void {
			trace("onSoundComplete");
			loader.get('sound').removeEventListener(Event.COMPLETE, onSoundComplete);
			
			//грузим видос, для него есть специальное событие NLoaderEvent.CAN_BEGIN_PLAYING
			loader.add("data/01.flv", NLoader.TYPE_VIDEO, 'video').addEventListener(NLoaderEvent.CAN_BEGIN_PLAYING, onMetadataLoaded);
		}
		
		private function onMetadataLoaded(e:NLoaderEvent):void {
			trace("onMetadataLoaded");
			loader.get('video').removeEventListener(NLoaderEvent.CAN_BEGIN_PLAYING, onMetadataLoaded);
			
			//загрузилась метадата, можно начинать проигрывание. сам видеофайл еще загружен не полностью
			//собственно метадата видео
			var metadata:Object = loader.getNetStreamMetaData('video');
			for (var i:String in metadata) {
				trace(i + " = " + metadata[i]);
			}
			
			var video:Video = new Video();
			video.y = 500;
			addChild(video);
			
			var ns:NetStream = loader.getNetStream('video');
			ns.resume();
			video.attachNetStream(ns);
			
			//можно отследить загрузку видеофайла до конца
			//тут конечно (как и целиком в примере) надо загружать файл из интернета, чтобы отследить прогресс. локально все происходит мгновенно
			//событие прогресса ProgressEvent.PROGRESS доступно только для LoadingItem, но не для loader
			loader.get('video').addEventListener(ProgressEvent.PROGRESS, onVideoLoadProgress);
			loader.get('video').addEventListener(Event.COMPLETE, onVideoLoadComplete);
		}
		
		private function onVideoLoadProgress(e:ProgressEvent):void {
			trace("onVideoLoadProgress " + e.bytesLoaded + " of " + e.bytesTotal);
		}
		
		private function onVideoLoadComplete(e:Event):void {
			loader.get('video').removeEventListener(ProgressEvent.PROGRESS, onVideoLoadProgress);
			loader.get('video').removeEventListener(Event.COMPLETE, onVideoLoadComplete);
			//файл загружен полностью
			trace("onVideoLoadComplete");
			
			//помимо этого можно грузить двоичные данные NLoader.TYPE_BINARY, получаем loader.getByteArray(id)
			//и текстовые данные NLoader.TYPE_TEXT, получаем loader.getString(id)
		}
		
	}

}