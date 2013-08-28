package openfl.display;

import flash.display.Sprite;
import flash.events.Event;

/**
 * Easy methods to override to handle ADDED/REMOVED FROM STAGE
 * @author Philippe
 */
class ComponentBase extends Sprite
{

	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStage);
	}
	
	private function addedToStage(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		init();
	}
	
	private function removedFromStage(e:Event):Void 
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		dispose();
	}
	
	private function dispose():Void 
	{
		
	}
	
	private function init():Void
	{
		
	}
}