package slplayer.ui.player;

import js.Dom;
import js.Lib;

/**
 * ...
 * @author Thomas Fétiveau
 */
class PlayerControl 
{
	static public var FIRST = "first";
	
	static public var LAST = "last";
	
	static public var NEXT = "next";
	
	static public var PREVIOUS = "previous";
	
	static public function startPlayerControl(playerControl : IPlayerControl, target : Dynamic):Void
	{
		untyped target.addEventListener(Playable.ON_LAST, playerControl.onPlayableLast , false);
		
		untyped target.addEventListener(Playable.ON_FIRST, playerControl.onPlayableFirst , false);
		
		untyped target.addEventListener(Playable.ON_CHANGE, playerControl.onPlayableChange , false);
	}
	
	static public function next(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var nextEvent = untyped Lib.document.createEvent("Event");
		
		untyped nextEvent.initEvent(NEXT, false, false);
		
		untyped target.dispatchEvent(nextEvent);
	}
	
	static public function previous(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var previousEvent = untyped Lib.document.createEvent("Event");
		
		untyped previousEvent.initEvent(PREVIOUS, false, false);
		
		untyped target.dispatchEvent(previousEvent);
	}
	
	static public function first(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var firstEvent = untyped Lib.document.createEvent("Event");
		
		untyped firstEvent.initEvent(FIRST, false, false);
		
		untyped target.dispatchEvent(firstEvent);
	}
	
	static public function last(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var lastEvent = untyped Lib.document.createEvent("Event");
		
		untyped lastEvent.initEvent(LAST, false, false);
		
		untyped target.dispatchEvent(lastEvent);
	}
}

interface IPlayerControl
{
	private function onPlayableFirst(e:Event):Void;
	
	private function onPlayableLast(e:Event):Void;
	
	private function onPlayableChange(e:Event):Void;
}