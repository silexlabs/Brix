package brix.prototype.player;

import js.Dom;
import js.Lib;

import brix.component.ui.DisplayObject;

import brix.component.player.IPlayerControl;
using brix.component.player.IPlayerControl.PlayerControl;

import brix.component.group.IGroupable;
using brix.component.group.IGroupable.Groupable;

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
	
	private override function new(rootElement : HtmlDom, BrixId:String)
	{
		super(rootElement,BrixId);
		
		startGroupable();
		
		if (groupElement == null)
			groupElement = rootElement;
	}
	
	/**
	 * The AutoPlayer component initialization takes a ["data-"+AUTOPLAY_INTERVAL_TAG] argument.
	 */
	override public function init():Void
	{
		var rowInterval = null;
		
		rowInterval = rootElement.getAttribute("data-" + AUTOPLAY_INTERVAL_TAG);
		
		if (rowInterval == null)
			interval = 2000;
		else
			interval = Std.parseInt(rowInterval);
		
		timer = new Timer(interval);
		
		startPlayerControl(groupElement);
		
		var me = this;
		timer.run = function () { me.next(groupElement); };
	}
	
	public function onPlayableFirst():Void
	{
		var me = this;
		timer.run = function () { me.next(groupElement); };
	}
	
	public function onPlayableLast():Void
	{
		var me = this;
		timer.run = function () { me.first(groupElement); };
	}
	
	public function onPlayableChange():Void { }
	
}