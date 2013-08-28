package openfl.samples.bubbles.view;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import openfl.Assets;
import openfl.display.DI;
import openfl.display.Tilesheet;
import openfl.display.ComponentBase;

/**
 * A bunch of bubbles bouncing and popping, leveraging Tilesheet.drawTiles
 * @author Philippe
 */
class Bath extends ComponentBase
{
	static public inline var STEPS:Int = 4;
	static public inline var TILE_FIELDS = 4; // x+y+index+scale !rotation !alpha
	
	private var items:Array<Bubble>;
	private var count:Int;
	private var drawList:Array<Float>;
	private var tilesheet:Tilesheet;
	private var dragging:Bubble;
	private var dragPos:Point;
	private var dragSpeed:Point;
	private var t0:Int;
	private var tClick:Int;

	override private function init():Void
	{
		// spritesheet (manual) configuration
		var sheet = Assets.getBitmapData("assets/img/bubbles.png");
		drawList = new Array<Float>();
		tilesheet = new Tilesheet(sheet);
		tilesheet.addTileRect(new Rectangle(0, 0, 128, 128), new Point(64, 64));
		tilesheet.addTileRect(new Rectangle(128, 0, 128, 128), new Point(64, 64));
		tilesheet.addTileRect(new Rectangle(256, 0, 128, 128), new Point(64, 64));
		tilesheet.addTileRect(new Rectangle(384, 0, 128, 128), new Point(64, 64));		
		
		// creating random bubbles
		count = 80;
		items = [];
		var w = DI.stageWidth;
		var h = DI.stageHeight;
		for (i in 0...count) 
		{
			items.push(new Bubble(w, h));
		}
		
		// interactivity
		dragPos = new Point();
		dragSpeed = new Point();
		t0 = Lib.getTimer();
		tClick = 0;
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
		
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	override private function dispose():Void 
	{
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
		removeEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	
	/* POPPING BUBBLES */
	
	private function doubleClick():Void 
	{
		var rem:Array<Int> = [ ];
		findGroup(dragging, rem);
		if (rem.length < 3) 
		{
			for (i in rem) items[i].selected = false;
			return;
		}
		stage_mouseUp(null);
		
		for (i in rem) 
			items[i] = null;
		
		var newItems:Array<Bubble> = [];
		for (b in items)
			if (b != null) 
				newItems.push(b);
		
		// adjust buffer size to account for the removed items
		var diff:Int = count - newItems.length;
		drawList.splice(drawList.length - diff * TILE_FIELDS, diff * TILE_FIELDS);
		items = newItems;
		count = items.length;
		enterFrame(null);
	}
	
	private function findGroup(b1:Bubble, rem:Array<Int>)
	{
		var index = b1.index;
		var dx, dy, dmin, d;
		for (i in 0...count)
		{
			var b2 = items[i];
			if (b2.index != index || b2.selected) continue;
			if (b1 == b2)
			{
				if (!b1.selected) 
				{
					rem.push(i);
					b1.selected = true;
				}
				continue;
			}
			
			dmin = b1.size + b2.size + 10;
			dx = b1.x - b2.x;
			dy = b1.y - b2.y;
			d = Math.sqrt(dx * dx + dy * dy);
			if (d < dmin) 
			{
				b2.selected = true;
				rem.push(i);
				findGroup(b2, rem);
			}
		}
	}
	
	
	/* DRAGGING BUBBLES */
	
	private function stage_mouseDown(e:MouseEvent):Void 
	{
		if (dragging != null) stage_mouseUp(null);
		var lx:Float = e.localX;
		var ly:Float = e.localY;
		var dx:Float, dy:Float, d:Float;
		for (b in items)
		{
			dx = b.x - lx;
			dy = b.y - ly;
			d = Math.sqrt(dx * dx + dy * dy);
			if (d < b.size) 
			{
				dragging = b;
				dragPos.x = dx;
				dragPos.y = dy;
				dragSpeed.x = dragSpeed.y = 0;
				stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
				break;
			}
		}
		
		// double-click?
		var t = Lib.getTimer();
		if (dragging != null && t - tClick < 400)
			doubleClick();
		tClick = t;
	}
	
	private function stage_mouseUp(e:MouseEvent):Void 
	{
		if (dragging != null)
		{
			dragging.vx = dragSpeed.x / (5 * STEPS);
			dragging.vy = dragSpeed.y / (5 * STEPS);
		}
		dragging = null;
		stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
	}
	
	
	/* RENDER LOOP */
	
	private function enterFrame(e:Event):Void 
	{
		// some pseudo-physics
		var t = Lib.getTimer();
		var dt:Float = Math.min(34, t - t0);
		t0 = t;
		var dk:Float = dt / 17;
		
		var dx:Float, dy:Float;
		if (dragging != null)
		{
			dx = mouseX + dragPos.x - dragging.x;
			dy = mouseY + dragPos.y - dragging.y;
			dragging.x += dx;
			dragging.y += dy;
			dragging.vx = dragging.vy = 0;
			dragSpeed.x = dragSpeed.x * 0.7 + dx;
			dragSpeed.y = dragSpeed.y * 0.7 + dy;
		}
		
		var steps:Int = Math.round(STEPS * dk);
		var ymax:Int = DI.stageHeight;
		var xmax:Int = DI.stageWidth;
		var b1:Bubble, b2:Bubble;
		var s:Float, dmin:Float, d:Float, a:Float, pk:Float, px:Float, py:Float;
		var kv:Float = 1 / cast(STEPS, Float);
		var spring:Float = kv * 1.5;
		var acc:Float = kv / 10;
		for (r in 0...steps)
			for (i in 0...count)
			{
				b1 = items[i];
				b1.vy += acc;
				s = b1.size;
				for (j in i...count)
				{
					b2 = items[j];
					dmin = s + b2.size;
					dx = b1.x - b2.x;
					if (dx > dmin) continue;
					dy = b1.y - b2.y;
					if (dy > dmin) continue;
					d = Math.sqrt(dx * dx + dy * dy);
					if (d < dmin) 
					{
						a = Math.atan2(dy, dx);
						pk = (dmin - d) * spring;
						px = Math.cos(a) * pk;
						py = Math.sin(a) * pk;
						b1.x += px;
						b1.y += py;
						b2.x -= px;
						b2.y -= py;
						b1.vy += py * kv;
						b1.vx += px * kv;
						b2.vy -= py * kv;
						b2.vx -= px * kv;
					}
				}
				b1.y += b1.vy;
				b1.x += b1.vx;
				if (b1.y > ymax - s) 
				{
					b1.y = ymax - s;
					b1.vy = 0;
				}
				if (b1.x < s)
				{
					b1.x = s;
					b1.vx = 0;
				}
				if (b1.x > xmax - s)
				{
					b1.x = xmax - s;
					b1.vx = 0;
				}
			}
		
		// rendering
		graphics.clear ();
		var index:Int = 0;
		
		for (b in items) 
		{
			drawList[index] = b.x;
			drawList[index + 1] = b.y;
			drawList[index + 2] = b.index;
			drawList[index + 3] = b.scale;
			index += TILE_FIELDS;
		}
		
		tilesheet.drawTiles(graphics, drawList, true, Tilesheet.TILE_SCALE);
	}
}


/* MODEL */

@:publicFields
class Bubble
{
	var index:Int;
	var selected:Bool;
	var x:Float;
	var y:Float;
	var vx:Float;
	var vy:Float;
	var scale:Float;
	var size:Float;
	
	function new(w:Int, h:Int)
	{
		x = Math.random() * w;
		y = -Math.random() * h * 4;
		index = Std.int(Math.random() * 4);
		vx = vy = 0;
		scale = (Math.random() * 0.5 + 0.7) * 0.9;
		size = 128 * scale / 2;
	}
}