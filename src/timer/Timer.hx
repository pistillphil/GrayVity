package timer;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;

/**
 * ...
 * @author pistillphil
 */

class Timer extends Entity
{
	
	private var time:Float;
	private var textFieldTime:Text;
	private var textFieldSeconds:Text;
	private var timerActive:Bool;
	
	private var pauseFrames:Int;
	private var timerPaused:Bool = false;

	public function new(x:Float,y:Float) 
	{
		super();
		
		this.x = x;
		this.y = y;
		
		this.time = 0;
		this.textFieldTime = new Text("0");
		this.textFieldTime.font = Main.font;
		this.textFieldTime.size = 22;
		this.textFieldSeconds = new Text("Seconds" , 64 , 0);
		this.textFieldSeconds.font = Main.font;
		this.textFieldSeconds.size = 22;
		this.timerActive = true;
		
		addGraphic(textFieldTime);
		addGraphic(textFieldSeconds);
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (timerActive)
		{
			time += HXP.elapsed;
			textFieldTime.text = (Math.round(time * 100)/100) + "";	//round the time to 2 digits after comma
		}
		
		if (timerPaused && !timerActive)
		{
			if (pauseFrames > 0)
			{
				pauseFrames--;
			}
			else
			{
				timerPaused = false;
				timerActive = true;
			}
		}
		
	}
	
	public function pauseTimerFor(frames:Int):Void 
	{
		timerPaused = true;
		timerActive = false;
		pauseFrames = frames;
	}
	
	
	public function pauseTimer():Void 
	{
		timerActive = false;
		timerPaused = false;
		pauseFrames = 0;
	}
	
	public function resumeTimer():Void 
	{
		timerActive = true;
		timerPaused = false;
		pauseFrames = 0;
	}
	
	
	
}