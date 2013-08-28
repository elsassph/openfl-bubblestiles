package openfl.display;

import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.Lib;
import flash.system.Capabilities;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

/**
 * Device-independent Stage setup
 * @author Philippe
 */
class DI 
{
	static public var TOUCH:String = MouseEvent.MOUSE_DOWN;
	static public var ROLL_OVER:String = MouseEvent.ROLL_OVER;
	static public var ROLL_OUT:String = MouseEvent.ROLL_OUT;
	
	static public var stageWidth(default, null):Int;
	static public var stageHeight(default, null):Int;
	static public var stageScale(default, null):Float;
	static public var referenceSize(default, null):Int;
	
	/**
	 * Scale the stage to match the desired dimension
	 * @param	referenceSize	Short side desired stage size
	 */
	static public function init(referenceSize:Int)
	{
		DI.referenceSize = referenceSize;
		Lib.current.stage.addEventListener(Event.RESIZE, resize);
		resize(null);
		
		if (Multitouch.supportsTouchEvents)
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			TOUCH = TouchEvent.TOUCH_BEGIN;
			ROLL_OVER = TouchEvent.TOUCH_BEGIN;
			ROLL_OUT = TouchEvent.TOUCH_END;
		}
	}
	
	static private function resize(e:Event)
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		var sw:Float = stage.stageWidth;
		var sh:Float = stage.stageHeight;
		if (sw == 0)
		{
			sw = Capabilities.screenResolutionX;
			sh = Capabilities.screenResolutionY;			
		}
		
		var currentSize = Math.min(sw, sh);
		stageScale = currentSize / referenceSize;
		if (sw < sh) {
			stageWidth = referenceSize;
			stageHeight = Math.ceil(referenceSize * sh / sw);
		}
		else {
			stageWidth = Math.ceil(referenceSize * sw / sh);
			stageHeight = referenceSize;
		}
		
		Lib.current.scaleX = Lib.current.scaleY = stageScale;
	}
	
}