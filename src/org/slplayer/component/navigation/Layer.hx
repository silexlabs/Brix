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
package org.slplayer.component.navigation;

import js.Lib;
import js.Dom;

import org.slplayer.component.ui.DisplayObject;
import org.slplayer.component.navigation.transition.TransitionData;

import org.slplayer.component.sound.SoundOn;

enum LayerStatus
{
	visible;
	hidden;
	notInitialized;
}

/**
 * This component is linked to a DOM element, wich is the view of a layer. 
 * A layer belongs to one or more pages, and has these pages name in its css class name.
 * The DOM element is first made empty by removing all its children from the DOM.
 * When a page is to be displayed, the content of the corresponding layers are attached back to the DOM.
 */
class Layer extends DisplayObject
{
	/**
	 * workaround bug removeEventListener 
	 */
	public var isListeningHide:Bool;
	public var isListeningShow:Bool;
	/**
	 * array used to store all the children while the layer is hided
	 */
	private var childrenArray:Array<HtmlDom>;
	/**
	 * true if the layer is hidden
	 */
	private var status:LayerStatus;
	/**
	 * Flag used to detect if a transition has started
	 */
	private var hasTransitionStarted:Bool;
	/**
	 * Value of display in the style attribute of the DOM element
	 * This is stored because it is changed during the transition
	 */
	private var styleAttrDisplay:String;

	/**
	 * constructor
	 * removes all children from the DOM
	 */
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);
		isListeningHide = false;
		isListeningShow = false;
		status = notInitialized;
		childrenArray = new Array();
		// Store the transition data for use in onEnd
		styleAttrDisplay = rootElement.style.display;
	}

	/**
	 * dispatch a transition request event, 
	 * and listen to the transition start event to detect that a transition is taking place
	 * 
	 * TODO find a better way than using events in a synchrone way here
	 * 
	 * @return true if there is a transition
	 */
	public function detectTransition(transitionData:TransitionData) : Bool
	{
		//listen to the transition start event to detect that a transition is taking place
		rootElement.addEventListener(TransitionData.EVENT_TYPE_STARTED, onTransitionStarted, false);

		// unset the flag
		hasTransitionStarted = false;

		// dispatch the transition request event to check if a transition component is listening
		var event:CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(TransitionData.EVENT_TYPE_REQUEST, true, true, transitionData);
		rootElement.dispatchEvent(event);

		// remove the listener
		rootElement.removeEventListener(TransitionData.EVENT_TYPE_STARTED, onTransitionStarted, false);

		// returns true if the flag has changed 
		return hasTransitionStarted;
	}

	/**
	 * set the property hasTransitionStarted 
	 * for the method detectTransition to be aware of this event
	 */
	private function onTransitionStarted(event:Event)
	{
		// set the flag
		hasTransitionStarted = true;
	}

	/**
	 * start the transition and then hide
	 */
	public function hide(transitionData:TransitionData) : Void
	{
		if (status != hidden)
		{
			// update status 
			status = hidden;

			isListeningHide = true;
			if (detectTransition(transitionData))
			{
				// listen for the transition end event
				rootElement.addEventListener(TransitionData.EVENT_TYPE_ENDED, doHide, false);
			}
			else
			{
				// no transition
				doHide(null);
			}
		}
		else
		{
			//trace("Layer - Already hidden "+rootElement.className);
		}
	}

	/**
	 * remove children from the DOM and store it in childrenArray
	 */
	public function doHide(nullIfCalledDirectly:Dynamic = null) : Void
	{
		if (isListeningHide == false) return;
		isListeningHide = false;

		// remove listener
		if (nullIfCalledDirectly != null)
		{
			rootElement.removeEventListener(TransitionData.EVENT_TYPE_ENDED, doHide, false);
		}

		// remove children 
		while (rootElement.childNodes.length > 0)
		{
			var element:HtmlDom = rootElement.childNodes[0];
			rootElement.removeChild(element);
			childrenArray.push(element);
			// stop the videos/sounds when leaving the page
			if(element.tagName!= null && (element.tagName.toLowerCase() == "audio" || element.tagName.toLowerCase() == "video"))
			{
				try
				{				
					cast(element).pause();
					cast(element).currentTime = 0;
				}
				catch (e:Dynamic)
				{
					// this happens when the element was removed from the dom for example
					// it is the case when transition is immediate
					trace("Layer error: could not access audio or video element");
				}
			}
		}
		// set or reset style.display
		rootElement.style.display="none";
	}

	/**
	 * Add all children from childrenArray back to the DOM
	 * This will empty childrenArray
	 * Start the transition and then show
	 */
	public function show(transitionData:TransitionData) : Void
	{
		if (status != visible)
		{
			// update status 
			status = visible;

			// set or reset style.display
			rootElement.style.display=styleAttrDisplay;

			// put the children back in place
			while (childrenArray.length > 0)
			{
				var element = childrenArray.shift();
				rootElement.appendChild(element);
				// play the videos/sounds when entering the page
				if (element.tagName != null && (element.tagName.toLowerCase() == "audio" || element.tagName.toLowerCase() == "video"))
				{
					try
					{				
						if (cast(element).autoplay == true)
						{
							cast(element).currentTime = 0;
							cast(element).play();
						}
						cast(element).muted = SoundOn.isMuted;
					}
					catch (e:Dynamic)
					{
						// this happens when the element was removed from the dom for example
						// it is the case when transition is immediate
						trace("Layer error: could not access audio or video element");
					}
				}
			}
			isListeningShow = true;
			// start transition
			if (detectTransition(transitionData))
			{
				// listen for the transition end event
				rootElement.addEventListener(TransitionData.EVENT_TYPE_ENDED, doShow, false);
			}
			else
			{
				// no transition
				doShow(null);
			}
		}
		else
		{
			//trace("Layer - Already visible "+rootElement.className);
		}
	}
	/**
	 * transition is over
	 */
	public function doShow(nullIfCalledDirectly:Dynamic = null) : Void
	{
		if (isListeningShow == false) return;
		isListeningShow = false;

		// remove listener
		if (nullIfCalledDirectly != null)
			rootElement.removeEventListener(TransitionData.EVENT_TYPE_ENDED, doShow, false);
	}
}
