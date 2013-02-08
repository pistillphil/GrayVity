package wall;
import com.haxepunk.Entity;

/**
 * ...
 * @author pistillphil
 */

class Wall extends Entity
{

	public function new(x:Int,y:Int,typeName:String) 
	{
		super();
		this.x = x;
		this.y = y;
		this.type = typeName;
		this.setHitbox(Main.kTileSize, Main.kTileSize);
		
	}
	
}