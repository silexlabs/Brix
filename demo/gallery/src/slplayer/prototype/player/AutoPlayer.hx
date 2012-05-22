package slplayer.prototype.player;

import js.Dom;
import js.Lib;

import slplayer.ui.DisplayObject;

import slplayer.ui.player.PlayerControl;
using slplayer.ui.player.PlayerControl;

import haxe.Timer;

/**
 * ...
 * @author Thomas Fétiveau
 */

class AutoPlayer  extends DisplayObject, implements IPlayerControl
{
	static var className = "autoplayer";
	
	static var AUTOPLAY_INTERVAL_TAG = "autoplay-interval";
	
	var timer : Timer;
	
	var interval : Int;

	override public function init(e:Event):Void
	{
		interval = Std.parseInt(rootElement.getAttribute("data-" + AUTOPLAY_INTERVAL_TAG));
		
		startPlayerControl(rootElement);
		
		timer = new Timer(interval);
		
		var me = this;
		timer.run = callback(me.next, rootElement);
	}
	
	private function onPlayableFirst(e:Event):Void
	{
		var me = this;
		timer.run = callback(me.next, rootElement);
	}
	
	private function onPlayableLast(e:Event):Void
	{
		var me = this;
		timer.run = callback(me.first, rootElement);
	}
	
	private function onPlayableChange(e:Event):Void { }
	
}