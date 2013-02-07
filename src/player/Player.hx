package player;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.HXP;
import enums.Gravity;

/**
 * ...
 * @author pistillphil
 */

class Player extends Entity
{
		private var speed:Float = 0.6;
		private var onGround:Bool=false;
		private var jumpPower:Float=20;
		private var hFriction:Float=0.9;
		private var vFriction:Float=0.95;
		private var xSpeed:Float=0;
		private var ySpeed:Float=0;
        private var gravity:Float = 0.5;
		private var keyDown:Bool = false;
		private var currentGravity:Gravity;

	public function new() 
	{
		super();
		currentGravity = Gravity.DOWN;
		
		this.graphic = new Image("gfx/player.png");
		this.setHitboxTo(this.graphic);
	}
	
	override public function update():Void 
	{
		keyDown = false;
		onGround = false;
		super.update();
		
		checkInput();
		checkGravityReverse();
		
		xSpeed*=hFriction;
		ySpeed*=vFriction;
		moveX();
		moveY();
		
	}
	
	private function checkInput():Void 
	{
		if (Input.check(Key.LEFT))
		{
			xSpeed -= speed;
			keyDown = true;
		}
		if (Input.check(Key.RIGHT))
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
		else 
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
	
	private function reverseGravity():Void 
	{
		gravity = -gravity;
		//jumpPower = -jumpPower;
		(this.currentGravity == Gravity.UP)?currentGravity = Gravity.DOWN:currentGravity = Gravity.UP;
	}
	
	public function getOnGround():Bool 
	{
		return onGround;
	}
	
}