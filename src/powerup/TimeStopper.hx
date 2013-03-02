package powerup;
import com.haxepunk.graphics.Image;
import worlds.GameWorld;

/**
 * ...
 * @author pistillphil
 */

class TimeStopper extends PowerUp
{
	private var image:Image;
	private var time:Int;

	//time: how many seconds should the timer be stopped? 
	public function new(x:Int,y:Int,time:Float) 
	{
		super(x, y);
		
		this.time = Math.round(time * Main.kFrameRate);
		
		this.image = new Image("gfx/TimeStopper.png");
		this.setHitboxTo(this.image);
		addGraphic(this.image);
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (collide("player", x, y) != null)
		{
			var world:GameWorld = cast(this.world, GameWorld);
			world.removePowerUp(this);
			world.pauseTimerFor(time);
		}
	}
	
}