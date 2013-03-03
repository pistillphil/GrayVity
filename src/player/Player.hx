package player;
import worlds.GameWorld;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Emitter;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.utils.Ease;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.HXP;
import enums.Gravity;
import nme.display.BitmapData;

/**
 * ...
 * @author pistillphil
 */

class Player extends Entity
{
		public var playerImage:Image;
		private var speed:Float = 0.6;
		private var onGround:Bool=false;
		private var jumpPower:Float=16;
		private var hFriction:Float=0.9;
		private var vFriction:Float=0.95;
		private var xSpeed:Float=0;
		private var ySpeed:Float=0;
        private var gravity:Float = 0.5;
		private var keyDown:Bool = false;
		private var currentGravity:Gravity;
		private var explosionEmitter:Emitter;
		private var levelCompleteEmitter:Emitter;
		private var numParticles:Int = 45;

		private var sloMoSkip:Int = 2;	//every n-th frame will be skipped if slowMo
		private var sloMoSkipLeft:Int = 1;
		private var skip:Bool = false;
		
		public var alive:Bool = true;

	public function new() 
	{
		super();
		this.currentGravity = Gravity.DOWN;
		
		this.playerImage = new Image("gfx/player.png");
		this.setHitboxTo(this.playerImage);
		this.type = "player";
		
		this.explosionEmitter = new Emitter(new BitmapData(4, 4), 4, 4);
		this.explosionEmitter.relative = false;
		
		this.explosionEmitter.newType("explosion", [0]);
		this.explosionEmitter.setColor("explosion", 0x000000);
		this.explosionEmitter.setAlpha("explosion", 1, 0);
		this.explosionEmitter.setMotion("explosion", 0, 160, 3, 360, -130, -1, Ease.quadOut);
		this.explosionEmitter.setGravity("explosion", 2);
		
		this.explosionEmitter.newType("blood", [0]);
		this.explosionEmitter.setColor("blood", 0xFF0000, 0xFF0000);
		this.explosionEmitter.setAlpha("blood", 1, 0.5);
		this.explosionEmitter.setMotion("blood", 0, 160, 3, 360, -130, -1, Ease.quadOut);
		this.explosionEmitter.setGravity("blood", 1);
		
		this.levelCompleteEmitter = new Emitter(new BitmapData(1, 1), 1, 1);
		this.levelCompleteEmitter.relative = false;
		
		this.levelCompleteEmitter.newType("beam", [0]);
		this.levelCompleteEmitter.setColor("beam", 0x444444, 0xFFFFFF);
		this.levelCompleteEmitter.setAlpha("beam", 1, 0.75);
		this.levelCompleteEmitter.setMotion("beam", 45, 200, 3.5, 90, -130, -1);
		this.levelCompleteEmitter.setGravity("beam", -10);
		
		
		this.graphic = new Graphiclist([this.playerImage, explosionEmitter, levelCompleteEmitter]);
	}
	
	override public function update():Void 
	{
		keyDown = false;
		onGround = false;
		super.update();
		
		checkInput();
		checkGravityReverse();
			
		if (!skip)
		{
			xSpeed*=hFriction;
			ySpeed*=vFriction;
			moveX();
			moveY();
		}
		else 
		{
			skip = false;
		}
		
	}
	
	private function checkInput():Void 
	{
		if (Input.check(Key.X))
		{
			checkSkip();
		}
		
		if (Input.check(Key.LEFT) && !skip)
		{
			xSpeed -= speed;
			keyDown = true;
		}
		if (Input.check(Key.RIGHT) && !skip)
		{
			xSpeed += speed;
			keyDown = true;
		}
		if (collide("solid", x, y + 1) != null && currentGravity == Gravity.DOWN)
		{
			onGround = true;
			ySpeed = 0;
			if (Input.check(Key.C))
			{
				ySpeed = -jumpPower;
			}
		}
		else if (collide("solid", x, y - 1) != null && currentGravity == Gravity.UP)
		{
			onGround = true;
			ySpeed = 0;
			if (Input.check (Key.C))
			{
				ySpeed = jumpPower;
			}
		}
		else if(!skip)
		{
			ySpeed += gravity;
		}
		
		/*if (Math.abs(xSpeed) < 1 && !keyDown)
		{
			xSpeed=0;
		}*/
	}
		
		
	private function moveX():Void
	{
		for (i in 0...Math.floor(Math.abs(xSpeed)))
		{
			if (collide("solid", x + HXP.sign(xSpeed), y) == null)
			{
				x+=HXP.sign(xSpeed);
			}
			else 
			{
				xSpeed=0;
				break;
			}
		}
	}
		
	private function moveY():Void
	{
		for (i in 0...Math.floor(Math.abs(ySpeed)))
		{
			if (collide("solid", x, y + HXP.sign(ySpeed))==null)
			{
				y+=HXP.sign(ySpeed);
			}
			else 
			{
				ySpeed=0;
				break;
			}
		}
	}
	
	private function checkGravityReverse():Void 
	{
		switch (this.currentGravity) 
		{
			case Gravity.DOWN:
				if (collide("up", x, y + 1) != null)
				{
					reverseGravity();
				}
				
			case Gravity.UP:
				if (collide("down", x, y - 1) != null)
				{
					reverseGravity();
				}
				
			//default:
				
		}
		
	}
	
	public function reverseGravity():Void 
	{
		gravity = -gravity;
		(this.currentGravity == Gravity.UP)?currentGravity = Gravity.DOWN:currentGravity = Gravity.UP;
	}
	
	public function getOnGround():Bool 
	{
		return onGround;
	}
	
	public function getCurrentGravity():Gravity
	{
		return this.currentGravity;
	}
	
	public function die():Void 
	{
		if (!cast(this.world, GameWorld).getLevelComplete())
		{
			trace("oh my, I died!");
			
			for (i in 0...numParticles)
			{
				if(Math.random() <= 0.66)
					explosionEmitter.emit("explosion", x + playerImage.width / 2, y + playerImage.height / 2);
				else
					explosionEmitter.emit("blood", x + playerImage.width / 2, y + playerImage.height / 2);
			}
			
			xSpeed = 0;
			ySpeed = 0;
			alive = false;
		}
	}
	
	public function beam():Void
	{
		playerImage.visible = false;
		for (i in 0...numParticles*7)
		{
			levelCompleteEmitter.emit("beam", x + (Math.random()* playerImage.width), y + (Math.random()*playerImage.height));
		}
	}
	
	public function getRemainingParticles():Int 
	{
		return levelCompleteEmitter.particleCount;
	}
	
	private function checkSkip():Void 
	{
		if (sloMoSkipLeft >= sloMoSkip)
		{
			skip = true;
			sloMoSkipLeft = 1;
		}
		
		else 
		{
			skip = false;
			sloMoSkipLeft++;
		}
	}
}