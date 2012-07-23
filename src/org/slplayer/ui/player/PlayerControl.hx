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
package org.slplayer.ui.player;

import js.Dom;
import js.Lib;

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
	
	static public function startPlayerControl(playerControl : IPlayerControl, target : Dynamic):Void
	{
		target.addEventListener(Playable.ON_LAST, function(e:Event) { playerControl.onPlayableLast();} , false);
		
		target.addEventListener(Playable.ON_FIRST, function(e:Event) { playerControl.onPlayableFirst();} , false);
		
		target.addEventListener(Playable.ON_CHANGE, function(e:Event) { playerControl.onPlayableChange();} , false);
		
		var newPlayerControlEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		newPlayerControlEvent.initCustomEvent(NEW_PLAYER_CONTROL, false, false, playerControl);
		
		target.dispatchEvent(newPlayerControlEvent);
	}
	
	static public function next(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var nextEvent = Lib.document.createEvent("Event");
		
		nextEvent.initEvent(NEXT, false, false);
		
		target.dispatchEvent(nextEvent);
	}
	
	static public function previous(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var previousEvent = Lib.document.createEvent("Event");
		
		previousEvent.initEvent(PREVIOUS, false, false);
		
		target.dispatchEvent(previousEvent);
	}
	
	static public function first(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var firstEvent = Lib.document.createEvent("Event");
		
		firstEvent.initEvent(FIRST, false, false);
		
		target.dispatchEvent(firstEvent);
	}
	
	static public function last(playerControl : IPlayerControl, target : Dynamic):Void
	{
		var lastEvent = Lib.document.createEvent("Event");
		
		lastEvent.initEvent(LAST, false, false);
		
		target.dispatchEvent(lastEvent);
	}
}

/**
 * Any PlayerControl component should implement and be "using org.slplayer.ui.player.PlayerControl" to be compliant with
 * Playable components.
 */
interface IPlayerControl
{
	public function onPlayableFirst():Void;
	
	public function onPlayableLast():Void;
	
	public function onPlayableChange():Void;
}