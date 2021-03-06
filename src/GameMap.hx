import haxe.io.Eof;
import starling.display.Sprite;
import starling.display.Image;
import starling.display.Quad;
import starling.events.*;
import starling.utils.AssetManager;
import flash.ui.Keyboard;
import starling.core.Starling;
import starling.text.TextField;
import flash.utils.Timer;
import flash.events.TimerEvent;
import starling.animation.Transitions;
import starling.animation.Tween;
import flash.media.*;
import starling.display.Button;

class GameMap extends Sprite {
	
	public inline static var SPRITE_WIDTH = 32;
	public inline static var SPRITE_HEIGHT = 32;

	//for player movement event
	public inline static var MOVE_DONE = "playerMoveFinished";

	//NOTE: The convention to access map coordinate from this array is mapArr[y][x], NOT mapArr[x][y]
	private var mapArr : Array<Array<Int>>;

	private var player : Player;

	private static var lives = 5;

	private var crew : Array<Image>;
	private var spaceship : Sprite;

	private var bg : Image;
	private var grid : Sprite;
	private var planet:String;

	public function new(s:String) {
		super();
		planet = s.charAt(0);
		setMap(LoadMap.load(s));
	}

	public static function reset()
	{
		//resets lives if starting at level 1
		lives = 5;
	}

	private function setMap(map : Array<Array<Int>>) {
		removeChildren();
		mapArr = map;

		var quad = new Quad(mapArr[0].length * SPRITE_WIDTH, mapArr.length * SPRITE_HEIGHT);
		x = Starling.current.stage.stageWidth / 2;
		y = Starling.current.stage.stageHeight / 2;

		//Center the background
		bg = getBG();
		bg.x = -bg.width / 2;
		bg.y = -bg.height / 2;
		bg.alpha = 0;
		bg.addEventListener(Event.ADDED, function()
		{
			Starling.juggler.tween(bg, 1.0, {
			transition:Transitions.EASE_OUT, delay:0, alpha: 1});
		});
		addChild(bg);

		//Add the spaceship behind the crew sprites
		spaceship = new Sprite();
		spaceship.addChild(new Image(Root.assets.getTexture("spaceship")));
		//Add the lives number of crew members
		for(i in 0...lives)
			spaceship.addChild(Root.game.getCrew(i));
		spaceship.x = Starling.current.stage.stageWidth;
		spaceship.y = -150;
		addChild(spaceship);

		grid = new Sprite();
		grid.scaleX = 1.3;
		grid.scaleY = 1.3;
		grid.x = -quad.width / 2 * grid.scaleX;
		grid.y = -quad.height / 2 * grid.scaleY;
		addChild(grid);
		
		Starling.juggler.tween(spaceship, 2, { transition: Transitions.EASE_OUT,
			x: -(quad.width / 2) * grid.scaleX + 60, //TO-DO
			y: -(quad.height / 2) * grid.scaleY - 100,
			onComplete: function() {
				//generate grid
				var h = 0; var w = 0;
				while(h <= mapArr.length * SPRITE_HEIGHT)//horizontal lines
				{
					var line = new Quad(quad.width, 2.5);
					line.y = h;
					h += SPRITE_HEIGHT;
					line.color = 0;
					grid.addChild(line);
				}
				while(w <= mapArr[0].length * SPRITE_WIDTH)//vertical lines
				{
					var line = new Quad(2.5, quad.height);
					line.x = w;
					w += SPRITE_WIDTH;
					line.color = 0;
					grid.addChild(line);
				}

				generateSprites();
				//make sure your level has a player!!!
				if(player == null){
					trace("This level doesn't have a player! Error will occur if you try to move the player");
				}
				addEventListener(KeyboardEvent.KEY_DOWN, checkInput);
				

				//Button Movements
				var down = new Button(Root.assets.getTexture("transButton"));
				down.scaleX = Starling.current.stage.stageWidth;
				down.scaleY = 8;
				down.x = (Starling.current.stage.stageWidth - down.width) / 2 - this.x;
				down.y = Starling.current.stage.stageHeight - down.height - this.y;
				down.addEventListener(Event.TRIGGERED, function()
				{
					if (player.movable)
					{
						playerMovementScan(0, 1);
						player.changeTexture(0);
					}
				});
				addChild(down);
				
				var up = new Button(Root.assets.getTexture("transButton"));
				up.scaleX = Starling.current.stage.stageWidth;
				up.scaleY = 8;
				up.x = (Starling.current.stage.stageWidth - up.width) / 2 - this.x;
				up.y = 0 - this.y;
				up.addEventListener(Event.TRIGGERED, function()
				{
					if (player.movable)
					{
						playerMovementScan(0, -1);
						player.changeTexture(2);
					}
				});
				addChild(up);
				
				var left = new Button(Root.assets.getTexture("transButton"));
				left.scaleX = 12;
				left.scaleY = Starling.current.stage.stageHeight;
				left.x = 0 - this.x;
				left.y = (Starling.current.stage.stageHeight - left.height) / 2 - this.y;
				left.addEventListener(Event.TRIGGERED, function()
				{
					if (player.movable)
					{
						playerMovementScan( -1, 0);
						player.changeTexture(3);
					}
				});
				addChild(left);
				
				var right = new Button(Root.assets.getTexture("transButton"));
				right.scaleX = 12;
				right.scaleY = Starling.current.stage.stageHeight;
				right.x = Starling.current.stage.stageWidth - right.width - this.x;
				right.y = (Starling.current.stage.stageHeight - right.height) / 2 - this.y;
				right.addEventListener(Event.TRIGGERED, function()
				{
					if (player.movable)
					{
						playerMovementScan(1, 0);
						player.changeTexture(1);
					}
				});
				addChild(right);
			}
		});
	}

	private function generateSprites() {
		if (mapArr.length > 0 && mapArr[0].length > 0) {
			for (y in 0...mapArr.length) {
				for (x in 0...mapArr[0].length) {
					switch mapArr[y][x] {
						case 1:
							createObstacle(x, y);
						case 2:
							createPlayer(x, y);
						case 3:
							createFinish(x, y);
					}
				}
			}
		} else {
			trace("Error: mapArr dimensions must be greater than 0");
		}
		grid.addChild(player); //Added at the end so it moves on top of everything else
	}

	private function createPlayer(x:Int, y:Int) {
		player = new Player(x, y);
		addEventListener(MOVE_DONE, onPlayerMoveFinished);
	}

	private function createObstacle(x:Int, y:Int) {
		grid.addChild(new Obstacle(x, y, planet));
	}

	private function createFinish(x:Int, y:Int) {
		grid.addChild(new Finish(x, y));
	}

	private function checkInput(e:KeyboardEvent) {
		//ignore event if the player is in the middle of moving
		if (!player.movable) return;
		switch (e.keyCode)
		{
			case Keyboard.LEFT:
				playerMovementScan( -1, 0);
				player.changeTexture(3);
			case Keyboard.RIGHT:
				playerMovementScan(1, 0);
				player.changeTexture(1);
			case Keyboard.UP:
				playerMovementScan(0, -1);
				player.changeTexture(2);
			case Keyboard.DOWN:
				playerMovementScan(0, 1);
				player.changeTexture(0);
			case Keyboard.R:
				//restarts, but costs a life
				if(lives > 1) loseLife();
			case Keyboard.ESCAPE:
				Root.game.reset();
		}
	}

	var flag:Bool = false;

	private function playerMovementScan(dirX:Int, dirY:Int) {
		var currentX:Int = player.mapX;
		var currentY:Int = player.mapY;
		var distance:Int = 0;
		Root.game.highscore -= 1;
		var check = false;
		
		// Makes sure we're within the map bounds and that the next space isn't an obstacle.
		while (currentX + dirX >= 0 && currentY + dirY >= 0 && mapArr[currentY + dirY][currentX + dirX] != 1)
		{
			currentX += dirX;
			currentY += dirY;
			++distance;

			//We've hit the goal!
			if (mapArr[currentY][currentX] == 3)
			{
				check = true;
				break;
			}

			//We've hit an edge!
			if (currentX + dirX < 0 || currentY + dirY < 0 || currentX + dirX == mapArr[currentY].length || currentY + dirY == mapArr.length)
			{
				flag = true;
				break;
			}
		}
		
		player.moveTo(currentX, currentY, distance, check);
		
	}

	private function onPlayerMoveFinished(e:Event) {
		if (mapArr[player.mapY][player.mapX] == 3)
		{
			Root.assets.playSound("Win").soundTransform = new SoundTransform(Root.game.getVol() * 2);
			Starling.juggler.tween(spaceship, 2, { transition: Transitions.EASE_IN,
				x: -spaceship.width * 5,	//a little buffer space
				y: -250,
				onComplete: function()
				{
					removeChildren(1);
					Starling.juggler.tween(bg, 1.0,
					{
						transition:Transitions.EASE_OUT,
						alpha : 0, delay : 0, onComplete : function()
						{
							Root.game.highscore = Root.game.highscore + 5 * lives + 100;
							Root.game.nextLevel();
						}
					});
				}
			});
		}
		if (flag) {
			loseLife();
			flag = false;
		}
	}

	private function loseLife(){
		player.restart();
		--lives;
		Root.assets.playSound("Lose").soundTransform = new SoundTransform(Root.game.getVol() * 2);
		if (lives == 0) {
			//Game Over
			removeChildren();
			removeEventListeners();
			var gameover:TextField = new TextField(350, 50, "Game Over", "8bitwonder_0", 35, 0xff0000);
			gameover.x = (Starling.current.stage.stageWidth - gameover.width) / 2;	// horizontal alignment
			gameover.y = (Starling.current.stage.stageHeight - gameover.height) / 2;	// vertical alignment
			Root.game.addChild(gameover);
			
			var score:TextField = new TextField(350, 50, "Score: " + Root.game.highscore, "8bitwonder_0", 35, 0xff0000);
			score.x = gameover.x;	// horizontal alignment
			score.y = gameover.y + gameover.height + 50;	// vertical alignment
			Root.game.addChild(score);
			Root.game.addToHighScores();
			
			var timer = new Timer(1000,3);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent)
			{
				GameMap.reset();
				Root.game.reset();
			});
		}
		else {
			if(lives == 1){
				var text = new TextField(400,50,"One member left","8bitwonder_0",20,0xff0000);
				text.x = -(Starling.current.stage.stageWidth / 2 - (mapArr[0].length * SPRITE_WIDTH / 2));
				text.y = -(Starling.current.stage.stageHeight / 2 - (mapArr.length * SPRITE_HEIGHT / 2));
				addChild(text);
			}
			//remove the last crew member
			spaceship.removeChild(Root.game.getCrew(lives));
		}
	}

	//Gets the background image depending on the current level
	private function getBG() {
		return switch (planet) {
			case 'm':
				new Image(Root.assets.getTexture("mars_new"));
			case 'j':
				new Image(Root.assets.getTexture("jupiter_new"));
			case 'n':
				new Image(Root.assets.getTexture("neptune_new"));
			case 's':
				new Image(Root.assets.getTexture("saturn_new"));
			case 'u':
				new Image(Root.assets.getTexture("uranus_new"));
			default:
				new Image(Root.assets.getTexture("mars_new"));
		}
	}
}