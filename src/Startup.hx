import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import starling.core.Starling;

@:bitmap("assets/loading.png")
class LoadingBitmapData extends flash.display.BitmapData { }

@:bitmap("assets/crew.png")
class CrewBitmapData extends flash.display.BitmapData { }

class Startup extends Sprite {
	public var loadingBitmap:Bitmap;
	public var crewBitmap:Bitmap;
	public var startup:Sprite;

	function new() {
		super();
		startup = this;
		
		Starling.handleLostContext = true;

		loadingBitmap = new Bitmap(new LoadingBitmapData(0, 0));
		loadingBitmap.x = 0;
		loadingBitmap.y = 0;
		loadingBitmap.width = Lib.current.stage.stageWidth;
		loadingBitmap.height = Lib.current.stage.stageHeight;
		loadingBitmap.smoothing = true;
		addChild(loadingBitmap);	//To display on scene

		crewBitmap = new Bitmap(new CrewBitmapData(500, 187));
		crewBitmap.x = (Lib.current.stage.stageWidth/2) - crewBitmap.width/2;
		crewBitmap.y = (Lib.current.stage.stageHeight/2) - crewBitmap.height/2 + 100;
		addChild(crewBitmap);

		Lib.current.stage.addEventListener(Event.RESIZE, function(e:Event) {
			Starling.current.viewPort = new Rectangle(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
			if (loadingBitmap != null) {
				loadingBitmap.width = Lib.current.stage.stageWidth;
				loadingBitmap.height = Lib.current.stage.stageHeight;
			}
		});

		var mStarling = new Starling(Root, Lib.current.stage);
		mStarling.antiAliasing = 0;

		function onRootCreated(event:Dynamic, root:Root) {
			mStarling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
			root.start(this);
			mStarling.start();
		}

		mStarling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
	}

	static function main() {
		var stage = Lib.current.stage;
		stage.addChild(new Startup());
	}
}