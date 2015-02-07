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
	}
	
	public function start(startup:Startup) {
		assets = new AssetManager();
		//assets.enqueue("assets/Player.png");
		assets.enqueue("assets/Obstacle.png");
		assets.enqueue("assets/Finish.png");
		
		assets.enqueue("assets/playerSprites.png");
		assets.enqueue("assets/playerSprites.xml");
		
		//Load the level assets
		for (i in 0...Levels.level.length) {
			assets.enqueue("assets/Levels/" + Levels.level[i] + ".txt");
		}
		
		assets.loadQueue(function onProgress(ratio:Float) {
			if (ratio == 1) {
				Starling.juggler.tween(startup.loadingBitmap, 2.0, {
					transition:Transitions.EASE_OUT, delay:0, alpha: 0, onComplete: function(){
						startup.removeChild(startup.loadingBitmap);
						
						game = new Game();
						addChild(game);
					}
				});
			}
		});
	}
}