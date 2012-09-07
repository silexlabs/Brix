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
import org.slplayer.component.navigation.transition.TransitionTools;
import org.slplayer.component.sound.SoundOn;
import org.slplayer.util.DomTools;

enum LayerStatus
{
	showTransition;
	hideTransition;
	visible;
	hidden;
	notInit;
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
	 * constant for the show event, dispatched on the rootElement node when the layer is shown
	 * the event have this object in event.detail: {transitionData:transitionData,target:rootElement,layer: this,}	
	 */
	public static inline var EVENT_TYPE_SHOW:String = "onLayerShow";
	/**
	 * constant for the hide event, dispatched on the rootElement node when the layer is hided
	 * the event have this object in event.detail: {transitionData:transitionData,target:rootElement,layer: this,}	
	 */
	public static inline var EVENT_TYPE_HIDE:String = "onLayerHide";
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
	private var hasTransitionStarted:Bool = false;
	/**
	 * Value of display in the style attribute of the DOM element
	 * This is stored because it is changed during the transition
	 */
	private var styleAttrDisplay:String;
	/**
	 * Callback used to add/remove events
	 */
	private var doShowCallback:Event->Void;
	/**
	 * Callback used to add/remove events
	 */
	private var doHideCallback:Event->Void;

	/**
	 * constructor
	 * removes all children from the DOM
	 */
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);
		childrenArray = new Array();
		status = notInit;
		// Store the transition data for use in onEnd
		styleAttrDisplay = rootElement.style.display;
	}
	//////////////////////////////////////////////////////
	// Transitions
	//////////////////////////////////////////////////////
	/**
	 * set the property hasTransitionStarted 
	 * for the method detectTransition to be aware of this event
	 */
	private function startTransition(type:TransitionType, transitionData:Null<TransitionData> = null, onComplete:Null<Event->Void>=null)
	{
		if (transitionData == null)
			transitionData = TransitionTools.getTransitionData(rootElement, type);

		if (transitionData == null){
			if(onComplete != null)
				onComplete(null);
		}
		else{
			// set the flag
			hasTransitionStarted = true;
			// set the css style
			DomTools.addClass(rootElement, transitionData.startStyleName);
			// continue later
			DomTools.doLater(callback(doStartTransition, transitionData, onComplete));
		}
	}
	private function doStartTransition(transitionData:TransitionData, onComplete:Null<Event->Void>=null) 
	{
		// set the css style
		DomTools.removeClass(rootElement, transitionData.startStyleName);
		// listen for the transition end event
		if (onComplete != null){
			addTransitionEvent(onComplete);
		}
		DomTools.addClass(rootElement, transitionData.endStyleName);
	}

	/**
	 * add transition events for all browsers
	 */
	private function addTransitionEvent(onEndCallback:Event->Void)
	{trace("EVENTS SET");
		rootElement.addEventListener("transitionend", onEndCallback, false);
	#if js
		rootElement.addEventListener("transitionEnd", onEndCallback, false);
		rootElement.addEventListener("webkitTransitionEnd", onEndCallback, false);
		rootElement.addEventListener("oTransitionEnd", onEndCallback, false);
		rootElement.addEventListener("MSTransitionEnd", onEndCallback, false);
	#end
	}

	/**
	 * Remove events for all browsers
	 */
	private function removeTransitionEvent(onEndCallback:Event->Void)
	{trace("EVENTS RESET");
		rootElement.removeEventListener("transitionend", onEndCallback, false);
	#if js
		rootElement.removeEventListener("transitionEnd", onEndCallback, false);
		rootElement.removeEventListener("webkitTransitionEnd", onEndCallback, false);
		rootElement.removeEventListener("oTransitionEnd", onEndCallback, false);
		rootElement.removeEventListener("MSTransitionEnd", onEndCallback, false);
	#end
	}

	//////////////////////////////////////////////////////
	// Show
	//////////////////////////////////////////////////////
	/**
	 * Add all children from childrenArray back to the DOM
	 * This will empty childrenArray
	 * Start the transition and then show
	 */
	public function show(transitionData:Null<TransitionData> = null) : Void
	{
		if (status != hidden && status != notInit){
			trace("Warning: can not show the layer, since it is "+status);
			return;
		}
		// reset transition if it is pending
		if (status == hideTransition){
			trace("Warning: hide break previous transition hide");
			doHideCallback(null);
			removeTransitionEvent(doHideCallback);
		}
		// reset transition if it is pending
		else if (status == showTransition){
			trace("Warning: hide break previous transition show");
			doShowCallback(null);
			removeTransitionEvent(doShowCallback);
		}
		// update status 
		status = showTransition;

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
		// dispatch a custom event on the root element
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(EVENT_TYPE_SHOW, false, false, {
			transitionData : transitionData,
			target: rootElement,
			layer: this,
		});
		rootElement.dispatchEvent(event);

		// do the transition
		doShowCallback = callback(doShow, transitionData);
		startTransition(TransitionType.show, transitionData, doShowCallback);
	}
	/**
	 * transition is over
	 */
	public function doShow(transitionData:Null<TransitionData>, e:Null<Event>) : Void
	{trace("doShow");
		if (doShowCallback == null){
			trace("Warning: end transition callback already called");
			return;
		}
		if (e!=null && e.target != rootElement){
			trace("End transition event from another html element");
			return;
		}
		if (transitionData != null)
			DomTools.removeClass(rootElement, transitionData.endStyleName);
		removeTransitionEvent(doShowCallback);
		doShowCallback=null;
		// update status 
		status = visible;
	}

	//////////////////////////////////////////////////////
	// Hide
	//////////////////////////////////////////////////////
	/**
	 * start the transition and then hide
	 */
	public function hide(transitionData:Null<TransitionData> = null) : Void
	{
		if (status != visible && status != notInit){
			//trace("Warning, can not hide the layer, since it is "+status);
			return;
		}
		// reset transition if it is pending
		if (status == hideTransition){
			trace("Warning: hide break previous transition hide");
			doHideCallback(null);
			removeTransitionEvent(doHideCallback);
		}
		// reset transition if it is pending
		else if (status == showTransition){
			trace("Warning: hide break previous transition show");
			doShowCallback(null);
			removeTransitionEvent(doShowCallback);
		}
		// update status 
		status = hideTransition;

		// do the transition
		doHideCallback = callback(doHide, transitionData);
		startTransition(TransitionType.hide, transitionData, doHideCallback);
	}

	/**
	 * remove children from the DOM and store it in childrenArray
	 */
	public function doHide(transitionData:Null<TransitionData>, e:Null<Event>) : Void
	{trace("doHide");
		if (doHideCallback == null){
			trace("Warning: end transition callback already called");
			return;
		}
		if (e!=null && e.target != rootElement){
			trace("End transition event from another html element");
			return;
		}
		removeTransitionEvent(doHideCallback);
		doHideCallback = null;
		if (transitionData != null)
			DomTools.removeClass(rootElement, transitionData.endStyleName);
		// update status 
		status = hidden;

		// dispatch a custom event on the root element
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(EVENT_TYPE_HIDE, false, false, {
			transitionData : transitionData,
			target: rootElement,
			layer: this,
		});
		rootElement.dispatchEvent(event);

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
					// or when the video or audio format is not supported (e.g. mp3 in firefox)
					// it is the case when transition is immediate
					trace("Layer error: could not access audio or video element");
				}
			}
		}
		// set or reset style.display
		rootElement.style.display="none";
	}
}
