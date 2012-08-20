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
package org.slplayer.component.transition;

import js.Lib;
import js.Dom;

typedef TransitionTimingFunction = String;

/**
 * type of transition, i.e. show or hide the content
 */
enum TransitionType
{
	show;
	hide;
}
/** 
 * The transition event is a custom javascript event
 * It takes an object of this class as a data object
 * @example 	event.data.transitionProperty
 */
class TransitionData
{
	public static inline var EVENT_TYPE_REQUEST:String = "transitionEventTypeRequest";
	public static inline var EVENT_TYPE_STARTED:String = "transitionEventTypeStarted";
	public static inline var EVENT_TYPE_ENDED:String = "transitionEventTypeEnded";

	public static inline var LINEAR:String = "linear";
	public static inline var EASE:String = "ease";
	public static inline var EASE_IN:String = "ease-in";
	public static inline var EASE_OUT:String = "ease-out";
	public static inline var EASE_IN_OUT:String = "ease-in-out";

	public var duration:String;
	public var timingFunction:TransitionTimingFunction;
	public var delay:String;
	public var type:Null<TransitionType>;
	public var isReversed:Bool;

	/**
	 * constructor
	 * provides all required fields
	 */
	public function new(transitionType:Null<TransitionType>=null, 
						transitionDuration:String=".5s", 
						transitionTimingFunction:TransitionTimingFunction=TransitionData.LINEAR, 
						transitionDelay:String="0",
						transitionIsReversed:Bool=false	)
	{
		type = transitionType;
		duration = transitionDuration;
		timingFunction = transitionTimingFunction;
		delay = transitionDelay;
		isReversed = transitionIsReversed;
	}
}
/**
 * interface which must be implemented by all transitions
 */
//interface ITransition {
	/**
	 * Start the transition
	 * This is a virtual method which has to be implemented
	 * You are expected to call applyTransitionParams with your transition params
	 */
//	public function start(transitionData:TransitionData):Void;
//}
