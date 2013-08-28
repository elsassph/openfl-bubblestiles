package openfl.samples.bubbles;

import flash.display.Sprite;
import flash.events.Event;
import openfl.display.ComponentBase;
import openfl.display.DI;
import openfl.samples.bubbles.view.Bath;
import openfl.samples.bubbles.view.Logo;

/**
 * ...
 * @author Philippe
 */
class Bubbles
{
	var root:Sprite;
	var logo:Logo;
	var game:Bath;

	public function new(root:Sprite) 
	{
		this.root = root;
		
		logo = new Logo();
		logo.addEventListener(Event.CLOSE, startGame);
		root.addChild(logo);
		
		root.stage.addEventListener(Event.RESIZE, resize);
		resize(null);
	}
	
	private function startGame(e:Event):Void 
	{
		root.removeChild(logo);
		game = new Bath();
		root.addChild(game);
	}
	
	private function resize(e:Event):Void 
	{
		if (logo != null) {
			logo.x = DI.stageWidth >> 1;
			logo.y = DI.stageHeight >> 1;
			logo.resize();
		}
	}
	
}