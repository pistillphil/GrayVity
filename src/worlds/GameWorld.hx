package worlds;
import com.haxepunk.Entity;
import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.World;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.HXP;
import obstacle.Obstacle;
import obstacle.Spikes;
import player.Player;
import timer.Timer;
import wall.Wall;
import enums.Gravity;
import enums.Position;

/**
 * ...
 * @author pistillphil
 */

class GameWorld extends World
{
	
	private var numLevels:Int = 6;
	
	private var map:TmxEntity;
	private var door:TmxEntity;
	private var gravityReversers:Array<Wall>;
	private var obstacles:Array<Obstacle>;
	private var player:Player;
	private var timer:Timer;
	private var lvlNumber:Int;
	private var levelComplete:Bool = false;
	
	public function new() 
	{
		
		super();
		
		this.player = new Player();
		this.timer = new Timer(32, 32);
		this.gravityReversers = new Array<Wall>();
		this.obstacles = new Array<Obstacle>();
		
		this.loadLevel();
		
	}
	
	public function loadLevel(lvlNumber:Int = 0):Void 
	{
		if (lvlNumber > numLevels )
		{
			HXP.engine.paused = true;
			return;
		}
		
		removeAll();
		gravityReversers = new Array<Wall>();
		obstacles = new Array<Obstacle>();
		levelComplete = false;
		
		
		this.lvlNumber = lvlNumber;
		var lvlName:String = "map/level_" + lvlNumber + ".tmx";
		
		map = new TmxEntity(lvlName);
		map.loadGraphic("gfx/tiles.png", ["Wall","Door"]);
		map.loadMask("Solid", "solid");
		
		add(map);
		
		door = new TmxEntity(lvlName);
		door.loadMask("Door", "door");
		add(door);
		
		placePlayer();
		if (player.getCurrentGravity() != Gravity.DOWN)
			player.reverseGravity();
		player.playerImage.visible = true;
		add(player);
		
		placeGravityReversers("Wall");
		
		add(timer);
		timer.resumeTimer();
		
	}
	
	public function loadNextLevel():Void 
	{
		loadLevel(++lvlNumber);
	}
	
	override public function update():Dynamic 
	{
		super.update();
		checkAlive();
		checkLevelComplete();
	}
	
	private function checkAlive():Void 
	{
		if (!player.alive)
		{
			if (player.getCurrentGravity() != Gravity.DOWN)
				player.reverseGravity();
			placePlayer();
			player.alive = true;
		}
	}
	
	private function checkLevelComplete():Void 
	{
		if (Input.check(Key.UP) && !levelComplete)
		{
			if (player.collide("door", player.x, player.y) != null && player.getOnGround())
			{
				player.beam();
				levelComplete = true;
				timer.pauseTimer();
			}
		}
		else if (levelComplete)
		{
			if (player.getRemainingParticles() <= 0)
			{
				loadNextLevel();
			}
		}
		
	}
	
	private function placePlayer():Void 
	{
		if (map.map.objectGroups.exists("Objects"))
		{
			var group = map.map.getObjectGroup("Objects");
			for (i in group.objects)
			{
				if (i.type == "Start")
				{
					if (i.name == "PlayerStart")
					{
						player.x = i.x;
						player.y = i.y;
					}
				}
			}
		}
		else 
		{
			player.x = 32 * 2;
			player.y = Main.kScreenHeight - 32 * 2;
		}
	}
	
	private function placeGravityReversers(layerName:String):Void 
	{
		
		if (!map.map.layers.exists(layerName))
			return;

		var layer = map.map.getLayer(layerName);
		for (i in 0...layer.height)
		{
			for (j in 0...layer.width)
			{
				var gid = layer.tileGIDs[i][j];
				var tileset = map.map.getGidOwner(gid);
				if (tileset != null && (tileset.getPropertiesByGid(gid).resolve("Gravity")=="up" || tileset.getPropertiesByGid(gid).resolve("Gravity") == "down"))
				{
					var temp:Wall = new Wall(j * Main.kTileSize, i * Main.kTileSize, tileset.getPropertiesByGid(gid).resolve("Gravity"));
					gravityReversers.push(temp);
					add(temp);
				}
				else if (tileset != null && tileset.getPropertiesByGid(gid).resolve("Obstacle") == "spikes")
				{
					var temp:Spikes = null;
					if (tileset.getPropertiesByGid(gid).resolve("Position") == "top")
					{
						temp = new Spikes(j * Main.kTileSize, i * Main.kTileSize, Position.TOP);
					}
					else if (tileset.getPropertiesByGid(gid).resolve("Position") == "bottom")
					{
						temp = new Spikes(j * Main.kTileSize, i * Main.kTileSize, Position.BOTTOM);
					}
					obstacles.push(temp);
					add(temp);
				
				}
			}
		}
	}
	
	public function getLevelComplete():Bool
	{
		return levelComplete;
	}
	
}