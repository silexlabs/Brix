package slplayer.prototype.player;

import js.Dom;
import js.Lib;

import slplayer.ui.DisplayObject;

import slplayer.ui.player.PlayerControl;
using slplayer.ui.player.PlayerControl;

import slplayer.ui.group.IGroupable;
using slplayer.ui.group.IGroupable.Groupable;

import haxe.Timer;

/**
 * A simple AutoPlayer component for Playables.
 * @author Thomas Fétiveau
 */
class AutoPlayer  extends DisplayObject, implements IPlayerControl, implements IGroupable
{
	/**
	 * The custom attribute for setting the autoplay interval (in ms). Default is 2000 ms.
	 */
	static inline var AUTOPLAY_INTERVAL_TAG = "autoplay-interval";
	
	/**
	 * The Timer component.
	 */
	var timer : Timer;
	/**
	 * The autoplay intervak in ms. default is 2000 ms.
	 */
	var interval : Int;
	
	public var groupElement:HtmlDom;
	
	private override function new(rootElement : HtmlDom, SLPId:String)
	{
		super(rootElement,SLPId);
		
		startGroupable();
	}
	
	/**
	 * The AutoPlayer component initialization takes a ["data-"+AUTOPLAY_INTERVAL_TAG] argument.
	 * @param	?args
	 */
	override public function init():Void
	{
		var rowInterval = null;
		
		rowInterval = rootElement.getAttribute("data-" + AUTOPLAY_INTERVAL_TAG);
		
		if (rowInterval == null)
			interval = 2000;
		else
			interval = Std.parseInt(rowInterval);
		
		if (groupElement == null)
			groupElement = rootElement;
		
		startPlayerControl(groupElement);
		
		timer = new Timer(interval);
		
		var me = this;
		timer.run = function () { me.next(groupElement); };
	}
	
	private function onPlayableFirst():Void
	{
		var me = this;
		timer.run = function () { me.next(groupElement); };
	}
	
	private function onPlayableLast():Void
	{
		var me = this;
		timer.run = function () { me.first(groupElement); };
	}
	
	private function onPlayableChange():Void { }
	
}