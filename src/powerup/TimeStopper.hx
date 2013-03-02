package powerup;
import com.haxepunk.graphics.Emitter;
import com.haxepunk.graphics.Image;
import nme.display.BitmapData;
import worlds.GameWorld;

/**
 * ...
 * @author pistillphil
 */

class TimeStopper extends PowerUp
{
	private var time:Int;
	private var emitter:Emitter;
	private var numParticles:Int = 16;

	//time: how many seconds should the timer be stopped? 
	public function new(x:Int,y:Int,time:Float) 
	{
		super(x, y);
		
		this.time = Math.round(time * Main.kFrameRate);
		
		
		this.emitter = new Emitter(new BitmapData(3, 3), 3, 3);
		this.emitter.relative = false;
		this.emitter.newType("sparkle", [0]);
		this.emitter.setColor("sparkle", 0xFFFF00);
		this.emitter.setAlpha("sparkle", 1 ,0.66);
		this.emitter.setMotion("sparkle", 0, 60, 1, 360, 20, 0.5);
		
		this.image = new Image("gfx/TimeStopper.png");
		this.setHitboxTo(this.image);
		addGraphic(this.image);
		addGraphic(this.emitter);
	}
	
	override public function update():Void 
	{
		super.update();
		
		
		if (collide("player", x, y) != null && image.visible)
		{
			sparkle();
			
			var world:GameWorld = cast(this.world, GameWorld);
			//world.removePowerUp(this);
			setVisibility(false);
			world.pauseTimerFor(time);
			
		}
	}
	
	private function sparkle():Void 
	{
		for (i in 0...numParticles)
		{
			emitter.emit("sparkle", x + image.width/2, y + image.width/2);
		}
	}
	
}