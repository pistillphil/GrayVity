package worlds;
import com.haxepunk.Entity;
import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.World;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import player.Player;

/**
 * ...
 * @author pistillphil
 */

class GameWorld extends World
{
	
	private var map:TmxEntity;
	private var up:TmxEntity;
	private var down:TmxEntity;
	private var door:TmxEntity;
	private var player:Player;
	
	private var lvlNumber:Int;
	
	public function new() 
	{
		
		super();
		
		player = new Player();
		
		loadLevel();
		
	}
	
	public function loadLevel(lvlNumber:Int = 0):Void 
	{
		this.lvlNumber = lvlNumber;
		var lvlName:String = "map/level_" + lvlNumber + ".tmx";
		
		map = new TmxEntity(lvlName);
		
		map.loadGraphic("gfx/tiles.png", ["Wall","Up","Down","Door"]);
		map.loadMask("Solid", "solid");
		
		add(map);
		
		up = new TmxEntity(lvlName);
		down = new TmxEntity(lvlName);
		door = new TmxEntity(lvlName);
		
		up.loadMask("Up", "up");
		down.loadMask("Down", "down");
		door.loadMask("Door", "door");
		
		add(up);
		add(down);
		add(door);
		
		player.x = 32*2;
		player.y = Main.kScreenHeight - 32 * 4;
		add(player);
		
	}
	
	public function loadNextLevel():Void 
	{
		removeAll();
		
		loadLevel(++lvlNumber);
		
	}
	
	override public function update():Dynamic 
	{
		super.update();
		
		checkLevelComplete();
	}
	
	private function checkLevelComplete():Void 
	{
		if (Input.check(Key.UP))
		{
			if (player.collide("door", player.x, player.y) != null && player.getOnGround())
			{
				loadNextLevel();
			}
		}
		
	}
	
}