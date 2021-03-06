import starling.display.Sprite;
import starling.display.Image;

class Finish extends Sprite {
	private var obstacleImage:Image;

	public function new(mapX:Int, mapY:Int) {
		super();
		
		obstacleImage = new Image(Root.assets.getTexture("flag"));
		addChild(obstacleImage);
		
		x = mapX * GameMap.SPRITE_WIDTH;
		y = mapY * GameMap.SPRITE_HEIGHT;
	}
}