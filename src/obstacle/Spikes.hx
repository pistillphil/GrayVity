package obstacle;
import com.haxepunk.Entity;
import player.Player;

/**
 * ...
 * @author pistillphil
 */

class Spikes extends Obstacle
{

	public function new(x:Int,y:Int) 
	{
		super(x, y);
		this.type = "spikes";
		this.setHitbox(cast(Main.kTileSize,Int) ,cast(Main.kTileSize / 2,Int),0, -cast(Main.kTileSize / 2,Int));
		
	}
	
	override public function update():Void 
	{
		super.update();

		var tempPlayer:Entity;
		if ((tempPlayer = collide("player", x, y)) != null)
		{
			cast(tempPlayer,Player).die();
		}
	}
	
}