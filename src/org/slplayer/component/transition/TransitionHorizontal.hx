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

import org.slplayer.component.transition.TransitionBase;
import org.slplayer.component.transition.TransitionData;

/**
 * Does a transition between two states of an object
 */
class TransitionHorizontal extends TransitionBase
{
	/**
	 * Value of position in the style attribute of the DOM element
	 * This is stored because it is changed during the transition
	 */
	private var styleAttrPosition:String;

	/**
	 * constructor
	 * init the property so that it can be tweened with css transitions
	 */
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);
		styleAttrPosition = rootElement.style.position;
		rootElement.style.left = "0px";
	}

	/**
	 * Start the transition
	 * This is a virtual method which has to be implemented
	 * You are expected to call applyTransitionParams with your transition params
	 */
	override public function start(transitionData:TransitionData)
	{
		super.start(transitionData);
		// position absolute
		rootElement.style.position="absolute";

		// show or hide
		var left:Int;
		if (transitionData.type == show)
			left = 0;
		else
			left = Lib.window.innerWidth;

		if (transitionData.isReversed)
			left = -left;

		// start transition
		applyTransitionParams( 	"left", 
								left+"px",
								transitionData.duration, 
								transitionData.timingFunction, 
								transitionData.delay );
	}

	/**
	 * reset style.position
	 */
	override private function onEnd(e:Event)
	{
		super.onEnd(e);
		rootElement.style.position=styleAttrPosition;
	}
}