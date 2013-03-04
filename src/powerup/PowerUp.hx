package powerup;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.Sfx;

/**
 * ...
 * @author pistillphil
 */

class PowerUp extends Entity
{
	
	private var image:Image;
	private var pickUpSound:Sfx;

	public function new(x:Int,y:Int) 
	{
		super();
		
		this.x = x;
		this.y = y;
	}
	
	public function setVisibility(visibility:Bool):Void 
	{
		image.visible = visibility;
	}
	
}