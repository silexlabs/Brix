package slplayer.ui.player;

import js.Dom;
import js.Lib;

/**
 * ...
 * @author Thomas Fétiveau
 */
class PlayerControl 
{
	/**
	 * This event is to notify the associated Playable(s) that the user triggered a "FIRST" command.
	 */
	static public var FIRST = "first";
	/**
	 * This event is to notify the associated Playable(s) that the user triggered a "LAST" command.
	 */
	static public var LAST = "last";
	/**
	 * This event is to notify the associated Playable(s) that the user triggered a "NEXT" command.
	 */
	static public var NEXT = "next";
	/**
	 * This event is to notify the associated Playable(s) that the user triggered a "PREVIOUS" command.
	 */
	static public var PREVIOUS = "previous";
	/**
	 * This event is to notify any Playable that a new PlayerControl just initialized for them.
	 */
	static public var NEW_PLAYER_CONTROL = "onNewPlayerControl";
	
	static public function startPlayerControl(playerControl : IPlayerControl, target : Dynamic):Void
	{
		untyped target.addEventListener(Playable.ON_LAST, function(e:Event) { playerControl.onPlayableLast();} , false);
		
		untyped target.addEventListener(Playable.ON_FIRST, function(e:Event) { playerControl.onPlayableFirst();} , false);
		
		untyped target.addEventListener(Playable.ON_CHANGE, function(e:Event) { playerControl.onPlayableChange();} , false);
		
		var newPlayerControlEvent = untyped Lib.document.createEvent("CustomEvent");
		
		untyped newPlayerControlEvent.initEvent(NEW_PLAYER_CONTROL, false, false, playerControl);
		
		untyped target.dispatchEvent(newPlayerControlEvent);
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
	private function onPlayableFirst():Void;
	
	private function onPlayableLast():Void;
	
	private function onPlayableChange():Void;
}