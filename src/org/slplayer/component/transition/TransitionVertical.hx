package org.slplayer.component.transition;

import js.Lib;
import js.Dom;

import org.slplayer.component.transition.TransitionBase;
import org.slplayer.component.transition.TransitionData;


/**
 * Does a transition between two states of an object
 */
class TransitionVertical extends TransitionHorizontal
{
	/**
	 * Start the transition
	 * This is a virtual method which has to be implemented
	 * You are expected to call applyTransitionParams with your transition params
	 */
	override public function start(transitionData:TransitionData)
	{
		// prevent horizontal behavior
		//super.start(transitionData);

		// position absolute
		rootElement.style.position="absolute";

		// show or hide
		var top:Int;
		if (transitionData.type == show)
			top = 0;
		else
			top = Lib.window.innerHeight;

		if (transitionData.isReversed)
			top = -top;

		// start transition
		applyTransitionParams(	"top", 
								top+"px",
								transitionData.duration, 
								transitionData.timingFunction, 
								transitionData.delay );
	}
}