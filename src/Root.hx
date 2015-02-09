import starling.display.Sprite;
import starling.utils.AssetManager;
import starling.core.Starling;
import starling.animation.Transitions;

class Root extends Sprite {
	
	public static var assets:AssetManager;
	
	public var map:GameMap;
	public var game:Game;
	
	
	public function new() {
		super();
		trace("1");
	}
	
	public function start(startup:Startup) {
		assets = new AssetManager();
		assets.enqueue("assets/Player.png");
		assets.enqueue("assets/Obstacle.png");
		assets.enqueue("assets/Finish.png");
		assets.enqueue("assets/star_background.png");
		assets.enqueue("assets/star_foreground.png");
		assets.loadQueue(function onProgress(ratio:Float) {
			if (ratio == 1) {
				Starling.juggler.tween(startup.loadingBitmap, 2.0, {
					transition:Transitions.EASE_OUT, delay:0, alpha: 0, onComplete: function(){
						startup.removeChild(startup.loadingBitmap);
						trace("2");
						game = new Game();
						trace("6");
						addChild(game);
					}
				});
			}
		});
	}
}