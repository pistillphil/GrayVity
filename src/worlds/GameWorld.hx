package worlds;
import com.haxepunk.Entity;
import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.World;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.HXP;
import obstacle.Obstacle;
import obstacle.Spikes;
import powerup.PowerUp;
import player.Player;
import powerup.TimeAdder;
import powerup.TimeStopper;
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
	
	private var numLevels:Int = 10;
	
	private var map:TmxEntity;
	private var door:TmxEntity;
	private var gravityReversers:Array<Wall>;
	private var obstacles:Array<Obstacle>;
	private var powerups:Array<PowerUp>;
	private var collectedpowerups:Array<PowerUp>;
	private var player:Player;
	private var timer:Timer;
	private var lvlNumber:Int;
	private var levelComplete:Bool = false;
	
	private var gravityReverseInterval:Float = 0;
	private var gravityReverseTimer:Float = 0;
	
	public function new() 
	{
		
		super();
		
		this.player = new Player();
		this.timer = new Timer(32, 32);
		this.gravityReversers = new Array<Wall>();
		this.obstacles = new Array<Obstacle>();
		this.powerups = new Array<PowerUp>();
		this.collectedpowerups = new Array<PowerUp>();
		
		this.loadLevel();
		
	}
	
	public function loadLevel(lvlNumber:Int=0):Void 
	{
		if (lvlNumber > numLevels )
		{
			HXP.world = new GameWorld();
			return;
		}
		
		removeAll();
		gravityReverseInterval = 0;
		gravityReverseTimer = 0;
		gravityReversers = new Array<Wall>();
		obstacles = new Array<Obstacle>();
		this.powerups = new Array<PowerUp>();
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
		placePowerUps();
		
		add(timer);
		timer.resumeTimer();
		
		if (lvlNumber == numLevels)
		{
			timer.pauseTimer();
			var restart:Text = new Text("Restart?");
			restart.font = Main.font;
			restart.size = 40;
			restart.x = (Main.kScreenWidth / 2) - (restart.textWidth / 2);
			restart.y = 45;
			
			var useDoors:Text = new Text("Use the doors!");
			useDoors.font = Main.font;
			useDoors.size = 40;
			useDoors.x = (Main.kScreenWidth / 2) - (useDoors.textWidth / 2);
			useDoors.y = 85;
			
			addGraphic(restart);
			addGraphic(useDoors);
		}
		
	}
	
	public function loadNextLevel():Void 
	{
		loadLevel(++lvlNumber);
	}
	
	override public function update():Void
	{
		super.update();
		checkGravityReverse();
		checkAlive();
		checkLevelComplete();
	}
	
	private function checkAlive():Void 
	{
		if (!player.alive)
		{
			if (player.getCurrentGravity() != Gravity.DOWN)
				player.reverseGravity();
			gravityReverseTimer = 0;
			placePlayer();
			resetPowerUps();
			timer.resumeTimer();
			player.alive = true;
			for (i in powerups)
			{
				if (Std.is(i,TimeAdder))
				{
					cast(i, TimeAdder).resetPath();
				}
			}
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
	
	public function placePowerUps():Void 
	{
		if (map.map.objectGroups.exists("Objects"))
		{
			var group = map.map.getObjectGroup("Objects");			
			for (i in group.objects)
			{
				if (i.type == "PowerUp")
				{
					if (i.name == "TimeStopper")
					{
						var powerup = new TimeStopper(i.x, i.y, Std.parseFloat(i.custom.resolve("time")));
						powerups.push(powerup);
						add(powerup);
					}
					else if(i.name == "TimeAdder") 
					{
						var pointsString:String = i.custom.resolve("points");
						var pointsStrings:Array<String> = pointsString.split(",");
						var pointsFloat:Array<Float> = new Array<Float>();
						
						for ( i in 0...pointsStrings.length)
						{
							pointsFloat[i] = Std.parseFloat(pointsStrings[i]);
						}
						
						var powerup = new TimeAdder(i.x, i.y, Std.parseFloat(i.custom.resolve("time")), pointsFloat,Std.parseFloat(i.custom.resolve("duration")));
						powerups.push(powerup);
						add(powerup);
					}
				}
				else if(i.type == "PeriodicalGravityReverse")
				{
					gravityReverseInterval = Std.parseFloat(i.custom.resolve("interval"));
				}
			}
		}
	}
	
	public function pauseTimerFor(frames:Int):Void 
	{
		timer.pauseTimerFor(frames);
	}
	
	public function getLevelComplete():Bool
	{
		return levelComplete;
	}
	
	/*
	public function removePowerUp(pow:PowerUp):Void 
	{
		powerups.remove(pow);
		collectedpowerups.push(pow);
		remove(pow);
	}
	*/
	
	public function resetPowerUps():Void 
	{
		for (pow in powerups)
		{
			pow.setVisibility(true);
		}
		
		/*
		for (pow in collectedpowerups)
		{
			powerups.push(pow);
			add(pow);
			collectedpowerups.remove(pow);
		}
		*/
		
	}
	
	public function addTime(time:Float):Void 
	{
		timer.addTime(time);
	}
	
	private function checkGravityReverse()
	{
		if(gravityReverseInterval > 0)
		{
			gravityReverseTimer += HXP.elapsed;
			if (gravityReverseTimer > gravityReverseInterval)
			{
				player.reverseGravity();
				player.reverseSound.play();
				gravityReverseTimer = 0;
			}
		}
	}
	
}
