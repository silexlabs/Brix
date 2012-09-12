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

import org.slplayer.component.player.IPlayable;

import js.Dom;
import js.Lib;

/**
 * Any PlayerControl component should implement and be "using org.slplayer.component.player.PlayerControl" to be compliant with
 * Playable components.
 * 
 * The goal of the Playable/PlayerControl contracts is to allow having highly reusable micro components 
 * able to switch together in order to form a customized Player component. A Player control bar could thus be 
 * used for a galery (image player) as well as for a video player or any player-like component.
 * 
 * The PlayerControl contract is part of the contract that sends the player control commands. For example, in a 
 * case of a simple Gallery with a simple control bar (play/pause/previous/next), the Image part would be the 
 * Playable part while the control bar the PlayerControl part.
 * 
 * This contract is for the moment a draft as no Player components has been released yet in the slplayer distribution.
 * FIXME: Not compatible with android native browser because of custom events
 */
interface IPlayerControl
{
	/**
	 * Callback triggered when an associated Playable is playing its first item.
	 */
	public function onPlayableFirst():Void;
	/**
	 * Callback triggered when an associated Playable is playing its last item.
	 */
	public function onPlayableLast():Void;
	/**
	 * Callback triggered when an associated Playable changed its currently playing item.
	 */
	public function onPlayableChange():Void;
}

/**
 * Mixin methods for PlayerControl components.
 * 
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
	/**
	 * Starts sending PlayerControl events to and receiving PlayableEvent from the given target.
	 * @param	playerControl	the PlayerControl instance
	 * @param	target			usually the DOM element associated with the PlayerControl when it's a DisplayObject but it 
	 * could be any other object.
	 */
	static public function startPlayerControl(playerControl : IPlayerControl, target : Dynamic):Void
	{
		target.addEventListener(Playable.ON_LAST, function(e:Event) { playerControl.onPlayableLast();} , false);
		
		target.addEventListener(Playable.ON_FIRST, function(e:Event) { playerControl.onPlayableFirst();} , false);
		
		target.addEventListener(Playable.ON_CHANGE, function(e:Event) { playerControl.onPlayableChange();} , false);
		
		var newPlayerControlEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		newPlayerControlEvent.initCustomEvent(NEW_PLAYER_CONTROL, false, false, playerControl);
		
		target.dispatchEvent(newPlayerControlEvent);
	}
	/**
	 * Send a Next command to potentially associated Playable component.
	 * @param	playerControl
	 * @param	target
	 */
	static public function next(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var nextEvent = Lib.document.createEvent("Event");
		
		nextEvent.initEvent(NEXT, false, false);
		
		target.dispatchEvent(nextEvent);
	}
	/**
	 * Send a Previous command to potentially associated Playable component.
	 * @param	playerControl
	 * @param	target
	 */
	static public function previous(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var previousEvent = Lib.document.createEvent("Event");
		
		previousEvent.initEvent(PREVIOUS, false, false);
		
		target.dispatchEvent(previousEvent);
	}
	/**
	 * Send a First command to potentially associated Playable component.
	 * @param	playerControl
	 * @param	target
	 */
	static public function first(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var firstEvent = Lib.document.createEvent("Event");
		
		firstEvent.initEvent(FIRST, false, false);
		
		target.dispatchEvent(firstEvent);
	}
	/**
	 * Send a Last command to potentially associated Playable component.
	 * @param	playerControl
	 * @param	target
	 */
	static public function last(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var lastEvent = Lib.document.createEvent("Event");
		
		lastEvent.initEvent(LAST, false, false);
		
		target.dispatchEvent(lastEvent);
	}
}