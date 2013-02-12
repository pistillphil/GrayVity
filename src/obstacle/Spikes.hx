package obstacle;
import com.haxepunk.Entity;
import enums.Position;
import player.Player;

/**
 * ...
 * @author pistillphil
 */

class Spikes extends Obstacle
{

	public function new(x:Int,y:Int,pos:Position) 
	{
		super(x, y);
		this.type = "spikes";
		if(pos == Position.BOTTOM)
			this.setHitbox(cast(Main.kTileSize, Int) , cast(Main.kTileSize / 2, Int), 0, -cast(Main.kTileSize / 2, Int));
		else if (pos == Position.TOP)
			this.setHitbox(cast(Main.kTileSize, Int) , cast(Main.kTileSize / 2, Int), 0, 0);
		
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