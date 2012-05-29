package slplayer.prototype.player;

import js.Dom;
import js.Lib;

import slplayer.ui.DisplayObject;

import slplayer.ui.player.PlayerControl;
using slplayer.ui.player.PlayerControl;

import haxe.Timer;

/**
 * A simple AutoPlayer component for Playables.
 * @author Thomas Fétiveau
 */
class AutoPlayer  extends DisplayObject, implements IPlayerControl
{
	/**
	 * The AutoPlayer classname.
	 */
	static var className = "autoplayer";
	/**
	 * The custom attribute for setting the autoplay interval (in ms).
	 */
	static var AUTOPLAY_INTERVAL_TAG = "autoplay-interval";
	
	/**
	 * The Timer component.
	 */
	var timer : Timer;
	/**
	 * The autoplay intervak in ms. default is 2000 ms.
	 */
	var interval : Int;

	/**
	 * The AutoPlayer component initialization takes a ["data-"+AUTOPLAY_INTERVAL_TAG] argument.
	 * @param	?args
	 */
	override public function init(?args:Hash<String>):Void
	{
		var rowInterval = null;
		
		if (args != null)
			rowInterval = args.get("data-" + AUTOPLAY_INTERVAL_TAG);
		
		if (rowInterval == null)
			interval = 2000;
		else
			interval = Std.parseInt(rowInterval);
		
		startPlayerControl(rootElement);
		
		timer = new Timer(interval);
		
		var me = this;
		timer.run = callback(me.next, rootElement);
	}
	
	private function onPlayableFirst():Void
	{
		var me = this;
		timer.run = callback(me.next, rootElement);
	}
	
	private function onPlayableLast():Void
	{
		var me = this;
		timer.run = callback(me.first, rootElement);
	}
	
	private function onPlayableChange():Void { }
	
}