package powerup;
import com.haxepunk.graphics.Image;
import com.haxepunk.Sfx;
import com.haxepunk.graphics.Emitter;
import nme.display.BitmapData;
import worlds.GameWorld;
import com.haxepunk.tweens.motion.LinearPath;

/**
 * ...
 * @author pistillphil
 */

class TimeAdder extends PowerUp
{

	private var time:Float;
	private var pathPoints:Array<Float>;
	private var duration:Float;
	private var path:LinearPath;
	private var emitter:Emitter;
	private var numParticles:Int = 16;
	
	private var firstX:Float;
	private var firstY:Float;
	
	//time: how many seconds should the timer be stopped? 
	//path: Array containing points. even indices are x values, odd ones y values
	public function new(x:Int,y:Int,time:Float,path:Array<Float>,duration:Float) 
	{
		super(x, y);
		firstX = x;
		firstY = y;
		
		this.image = new Image("gfx/TimeAdder.png");
		
		this.time = time;
		this.pathPoints = path;
		this.duration = duration;
		this.setPath(path,duration);

		this.emitter = new Emitter(new BitmapData(3, 3), 3, 3);
		this.emitter.relative = false;
		this.emitter.newType("sparkle", [0]);
		this.emitter.setColor("sparkle", 0x0000FF);
		this.emitter.setAlpha("sparkle", 1);
		this.emitter.setMotion("sparkle", 0, 420, 1, 360, 160, 0.5);
		
		addGraphic(this.image);
		setHitboxTo(this.image);
		addGraphic(this.emitter);
		
		pickUpSound = new Sfx("sfx/powerdown.wav");
	}
	
	override public function update():Void 
	{
		super.update();
		
		
		if (collide("player", x, y) != null && image.visible)
		{
			sparkle();
			pickUpSound.play();
			
			var world:GameWorld = cast(this.world, GameWorld);
			//world.removePowerUp(this);
			setVisibility(false);
			world.addTime(time);
			
		}
		
		move();
	}
	
	
	private function sparkle():Void 
	{
		for (i in 0...numParticles)
		{
			emitter.emit("sparkle", x + image.width/2, y + image.width/2);
		}
	}
	
	private function move():Void 
	{
		this.x = path.x;
		this.y = path.y;
	}
	
	private function setPath(pathPoints:Array<Float>,duration:Float):Void 
	{
		var skip:Bool = false;
		this.path = new LinearPath(restart);
		
		for (i in 0...pathPoints.length)
		{
			if (skip)
			{
				skip = false;
			}
			else if (!skip)
			{
				skip = true;
				this.path.addPoint(pathPoints[i] + this.x, pathPoints[i + 1] + this.y);
			}
		}
		this.path.addPoint(pathPoints[0] + this.x, pathPoints[1] + this.y);	//will end at the start
		
		addTween(this.path);
		path.setMotion(duration);
		path.start();
	}
	
	private function restart(_):Void 
	{
		path.start();
	}
	
	public function resetPath():Void 
	{
		removeTween(path);
		x = firstX;
		y = firstY;
		this.setPath(pathPoints,duration);
	}
	
}