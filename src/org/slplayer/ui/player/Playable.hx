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
 * Mixin methods for Playable components.
 * 
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
	 * 
	 * @param	playable
	 */
	static public function startPlayable(playable : IPlayable, target : Dynamic):Void
	{
		target.addEventListener(PlayerControl.FIRST, function(e:Event) { playable.first();} , false);
		
		target.addEventListener(PlayerControl.LAST, function(e:Event) { playable.last();} , false);
		
		target.addEventListener(PlayerControl.NEXT, function(e:Event) { playable.next();} , false);
		
		target.addEventListener(PlayerControl.PREVIOUS, function(e:Event) { playable.previous();} , false);
		
		target.addEventListener(PlayerControl.NEW_PLAYER_CONTROL, function(e:Event) { playable.onNewPlayerControl();} , false);
		
		var onStartPlayableEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onStartPlayableEvent.initCustomEvent(START_PLAYABLE, false, false, playable);
		
		target.dispatchEvent(onStartPlayableEvent);
	}
	
	static public function dispatchOnLast(playable : IPlayable, target : Dynamic)
	{
		var onLastEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onLastEvent.initCustomEvent(ON_LAST, false, false, playable);
		
		target.dispatchEvent(onLastEvent);
	}
	
	static public function dispatchOnFirst(playable : IPlayable, target : Dynamic)
	{
		var onFirstEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onFirstEvent.initCustomEvent(ON_FIRST, false, false, playable);
		
		target.dispatchEvent(onFirstEvent);
	}
	
	static public function dispatchOnChange(playable : IPlayable, target : Dynamic)
	{
		var onChangeEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onChangeEvent.initCustomEvent(ON_CHANGE, false, false, playable);
		
		target.dispatchEvent(onChangeEvent);
	}
}

/**
 * Any playable component should implement this interface and be "using org.slplayer.ui.player.Playable" to be compliant with
 * PlayerControls.
 */
interface IPlayable 
{
	public function next():Void;
	
	public function previous():Void;
	
	public function first():Void;
	
	public function last():Void;
	
	public function onNewPlayerControl():Void;
	
}