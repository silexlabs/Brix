package slplayer.ui.player;

import js.Dom;
import js.Lib;

/**
 * ...
 * @author Thomas Fétiveau
 */
class Playable
{
	static public var START_PLAYABLE = "start_playable";
	
	static public var ON_LAST = "on_last";
	
	static public var ON_FIRST = "on_first";
	
	static public var ON_CHANGE = "on_change";
	
	/**
	 * 
	 * @param	playable
	 */
	static public function startPlayable(playable : IPlayable, target : Dynamic):Void
	{
		untyped target.addEventListener(PlayerControl.FIRST, function(e:Event) { playable.first();} , false);
		
		untyped target.addEventListener(PlayerControl.LAST, function(e:Event) { playable.last();} , false);
		
		untyped target.addEventListener(PlayerControl.NEXT, function(e:Event) { playable.next();} , false);
		
		untyped target.addEventListener(PlayerControl.PREVIOUS, function(e:Event) { playable.previous();} , false);
		
		untyped target.addEventListener(PlayerControl.NEW_PLAYER_CONTROL, function(e:Event) { playable.onNewPlayerControl();} , false);
		
		var onStartPlayableEvent = untyped Lib.document.createEvent("CustomEvent");
		
		untyped onStartPlayableEvent.initCustomEvent(START_PLAYABLE, false, false, playable);
		
		untyped target.dispatchEvent(onStartPlayableEvent);
	}
	
	static public function dispatchOnLast(playable : IPlayable, target : Dynamic)
	{
		var onLastEvent = untyped Lib.document.createEvent("CustomEvent");
		
		untyped onLastEvent.initCustomEvent(ON_LAST, false, false, playable);
		
		untyped target.dispatchEvent(onLastEvent);
	}
	
	static public function dispatchOnFirst(playable : IPlayable, target : Dynamic)
	{
		var onFirstEvent = untyped Lib.document.createEvent("CustomEvent");
		
		untyped onFirstEvent.initCustomEvent(ON_FIRST, false, false, playable);
		
		untyped target.dispatchEvent(onFirstEvent);
	}
	
	static public function dispatchOnChange(playable : IPlayable, target : Dynamic)
	{
		var onChangeEvent = untyped Lib.document.createEvent("CustomEvent");
		
		untyped onChangeEvent.initCustomEvent(ON_CHANGE, false, false, playable);
		
		untyped target.dispatchEvent(onChangeEvent);
	}
}

/**
 * 
 */
interface IPlayable 
{
	private function next():Void;
	
	private function previous():Void;
	
	private function first():Void;
	
	private function last():Void;
	
	private function onNewPlayerControl():Void;
	
}