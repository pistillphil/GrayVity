package worlds;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.Tween;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.World;
import com.haxepunk.utils.Ease;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

/**
 * ...
 * @author pistillphil
 */

class IntroWorld extends World
{

	private var image:Image;
	private var introTween:VarTween;
	private var continueTween:VarTween;
	private var goTween:VarTween;
	private var startButton:Text;
	private var goText:Text;
	private var startButtonY:Float = 64;
	private var input:Bool = false;
	
	public function new() 
	{
		super();
		
		this.image = new Image("gfx/intro_1.png");
		this.image.alpha = 0;
		this.addGraphic(image);
		
		this.introTween = new VarTween(onIntroComplete);
		this.introTween.tween(image, "alpha", 1, 1.5);
		this.addTween(introTween);
		
	}
	
	private function onIntroComplete(_):Void 
	{
		startButton = new Text("Press \"C\" to start the game...");
		startButton.font = Main.font;
		startButton.size = 32;
		startButton.alpha = 0;
		startButton.x = HXP.width / 2 - startButton.width / 2;
		startButton.y = HXP.height - startButtonY;
		addGraphic(startButton);
		
		continueTween = new VarTween(activateInput);
		continueTween.tween(startButton, "alpha", 1, 1, Ease.quadInOut);
		addTween(continueTween);
		
	}
	
	private function onGameStart():Void 
	{
		goText = new Text("GO!");
		goText.font = Main.font;
		goText.alpha = 0;
		goText.size = 128;
		goText.x = HXP.width / 2 - goText.width / 2;
		goText.y = HXP.height / 2 - goText.height / 2;
		addGraphic(goText);
		goTween = new VarTween();
		
		removeTween(continueTween);
		removeTween(introTween);
		introTween = new VarTween(startGame);
		introTween.tween(image, "alpha", 0, 3.5, Ease.expoOut);
		continueTween.tween(startButton, "alpha", 0, 4, Ease.expoOut);
		goTween.tween(goText, "alpha", 1, 2.5, Ease.quadIn);
		addTween(introTween);
		addTween(continueTween);
		addTween(goTween);
		
	}
	
	private function startGame(_):Void 
	{
		HXP.world = new GameWorld();
	}
	
	override public function update():Dynamic 
	{
		super.update();
		
		if (input && Input.check(Key.C))
		{
			onGameStart();
			input = false;
		}
	}
	
	
	private function activateInput(_):Void 
	{
		input = true;
	}
	
	
}