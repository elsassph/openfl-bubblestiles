package openfl.samples.bubbles;

import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.Event;
import flash.Lib;
import openfl.display.DI;
import openfl.display.FPS;
import openfl.samples.bubbles.Bubbles;

/**
 * The entry point
 * @author Philippe
 */
class Main 
{
	static public var root:Sprite;
	static private var app:Bubbles;
	
	static public function main() 
	{
		// device-independent scaling (iPhone retina size as reference) and interactivity
		DI.init(640);
		
		// create out app
		root = Lib.current;
		app = new Bubbles(root);
		
		// be nice
		var fps = new FPS();
		root.stage.addChild(fps);
		root.addEventListener(Event.DEACTIVATE, deactivate);
		root.addEventListener(Event.ACTIVATE, activate);
	}
	
	
	/* PLAY NICE WITH OTHER PROCESSES */
	
	static private function activate(e:Event):Void 
	{
		root.stage.frameRate = 60;
	}
	
	static private function deactivate(e:Event):Void 
	{
		// pause everything in the app, or exit
		root.stage.frameRate = 1;
	}
	
}