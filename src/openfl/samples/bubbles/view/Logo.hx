package openfl.samples.bubbles.view;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Multitouch;
import motion.Actuate;
import motion.easing.Bounce;
import motion.easing.Cubic;
import openfl.Assets;
import openfl.display.ComponentBase;
import openfl.display.DI;

/**
 * The startup screen
 * @author Philippe
 */
class Logo extends ComponentBase
{
	var _scale:Float = 1.0;

	override private function init():Void 
	{
		var img = new Bitmap(Assets.getBitmapData("assets/img/logo.png", false));
		img.x = -img.width / 2;
		img.y = -img.height / 2;
		img.smoothing = true;
		addChild(img);
		resize();
		
		addEventListener(DI.ROLL_OVER, rollOver);
		addEventListener(DI.ROLL_OUT, rollOut);
		addEventListener(DI.TOUCH, touch);
		mouseChildren = false;
	}
	
	private function touch(e:Event):Void 
	{
		addEventListener(MouseEvent.MOUSE_UP, clicked);
	}
	
	private function clicked(e:MouseEvent):Void 
	{
		mouseEnabled = false;
		Actuate.tween(this, 0.3, { scale:0.1, alpha:0 } ).ease(Cubic.easeOut).onComplete(function() {
			visible = false;
			dispatchEvent(new Event(Event.CLOSE));
		});
	}
	
	private function rollOut(e:Event):Void 
	{
		if (mouseEnabled)
			Actuate.tween(this, 0.8, { scale:1.0 } ).ease(Bounce.easeOut);
	}
	
	private function rollOver(e:Event):Void 
	{
		if (mouseEnabled)
			Actuate.tween(this, 0.2, { scale:0.9 } ).ease(Cubic.easeOut);
	}
	
	public function resize() 
	{
		
	}
	
	
	function get_scale():Float { return _scale; }
	
	function set_scale(value:Float):Float 
	{
		return scaleX = scaleY = _scale = value;
	}
	
	public var scale(get_scale, set_scale):Float;
	
}