/*
 * This file is part of SLPlayer http://www.silexlabs.org/groups/labs/slplayer/
 * 
 * This project is © 2011-2012 Silex Labs and is released under the GPL License:
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms 
 * of the GNU General Public License (GPL) as published by the Free Software Foundation; 
 * either version 2 of the License, or (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU General Public License for more details.
 * 
 * To read the license please visit http://www.gnu.org/copyleft/gpl.html
 */
package org.slplayer.component.player;

import org.slplayer.component.player.IPlayerControl;

import js.Dom;
import js.Lib;

/**
 * Any playable component should implement this interface and be "using org.slplayer.component.player.Playable" 
 * to be compliant with PlayerControls.
 * 
 * The goal of the Playable/PlayerControl contracts is to allow having highly reusable micro components 
 * able to switch together in order to form a customized Player component. A Player control bar could thus be 
 * used for a galery (image player) as well as for a video player or any player-like component.
 * 
 * The Playable contract is part of the contract that receives the player control commands. For example, in a 
 * case of a simple Gallery with a simple control bar (play/pause/previous/next), the Image part would be the 
 * Playable part while the control bar the PlayerControl part.
 * 
 * This contract is for the moment a draft as no Player components has been released yet in the slplayer distribution.
 */
interface IPlayable 
{
	/**
	 * Next command callback.
	 */
	public function next():Void;
	
	/**
	 * Previous command callback.
	 */
	public function previous():Void;
	
	/**
	 * First command callback (comes back to the first played item).
	 */
	public function first():Void;
	
	/**
	 * Last command callback (comes back to the last played item).
	 */
	public function last():Void;
	
	/**
	 * Callback called when a new PlayerControl is ready to run.
	 * @param the new player control.
	 */
	public function onNewPlayerControl( newPlayerControl:IPlayerControl ):Void;
}

/**
 * Mixin methods for Playable components.
 * FIXME: Not compatible with android native browser because of custom events
 * 
 * @author Thomas Fétiveau
 */
class Playable
{
	/**
	 * The event type thrown when a playable component is started (ready to receive player control commands).
	 */
	static public var START_PLAYABLE = "start_playable";
	/**
	 * The event type thrown by the playable when playing the last item.
	 */
	static public var ON_LAST = "on_last";
	/**
	 * The event type thrown by the playable when playing the first item.
	 */
	static public var ON_FIRST = "on_first";
	/**
	 * The event type thrown by the playable when changing the currently played item.
	 */
	static public var ON_CHANGE = "on_change";
	
	/**
	 * Helper method to start Playing on a given DOM element.
	 * @param the playable to start.
	 * @param the DOM element (or any other object) to send Playable events to and to receive PlayerControl events from.
	 */
	static public function startPlayable(playable : IPlayable, target : Dynamic):Void
	{
		target.addEventListener(PlayerControl.FIRST, function(e:Event) { playable.first();} , false);
		
		target.addEventListener(PlayerControl.LAST, function(e:Event) { playable.last();} , false);
		
		target.addEventListener(PlayerControl.NEXT, function(e:Event) { playable.next();} , false);
		
		target.addEventListener(PlayerControl.PREVIOUS, function(e:Event) { playable.previous();} , false);
		
		target.addEventListener(PlayerControl.NEW_PLAYER_CONTROL, function(e:CustomEvent) { playable.onNewPlayerControl(e.detail);} , false);
		
		var onStartPlayableEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onStartPlayableEvent.initCustomEvent(START_PLAYABLE, false, false, playable);
		
		target.dispatchEvent(onStartPlayableEvent);
	}
	
	/**
	 * Dispatch an ON_LAST event on the given target (usually the associated DOM element for a DisplayObject).
	 * @param	playable
	 * @param	target
	 */
	static public function dispatchOnLast(playable : IPlayable, target : Dynamic)
	{
		var onLastEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onLastEvent.initCustomEvent(ON_LAST, false, false, playable);
		
		target.dispatchEvent(onLastEvent);
	}
	
	/**
	 * Dispatch an ON_FIRST event on the given target (usually the associated DOM element for a DisplayObject).
	 * @param	playable
	 * @param	target
	 */
	static public function dispatchOnFirst(playable : IPlayable, target : Dynamic)
	{
		var onFirstEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onFirstEvent.initCustomEvent(ON_FIRST, false, false, playable);
		
		target.dispatchEvent(onFirstEvent);
	}
	
	/**
	 * Dispatch an ON_CHANGE event on the given target (usually the associated DOM element for a DisplayObject).
	 * @param	playable
	 * @param	target
	 */
	static public function dispatchOnChange(playable : IPlayable, target : Dynamic)
	{
		var onChangeEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onChangeEvent.initCustomEvent(ON_CHANGE, false, false, playable);
		
		target.dispatchEvent(onChangeEvent);
	}
}