/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.navigation.transition;

import brix.util.DomTools;

import js.Lib;
import js.Dom;

/**
 * this class is passed to the layers when a page opens or closes
 * it keeps track of all layer transitions pending
 * it dispatches a start event when the first transition starts
 * it dispatches a end event when the last transition has stoped
 * @see 
 */
class TransitionObserver{
	private var hasStarted:Bool = false;
	private var hasStoped:Bool = false;
	private var pendingTransitions:Int = 0;

	private var page:Page;
	private var startEvent:String;
	private var stopEvent:String;
	/**
	 * store all the useful references
	 * @param 	page 		the Page which initiated the transitions
	 * @param 	startEvent	name of the event thrown when the first transition started
	 * @param 	stopEvent	name of the event thrown when the last transition ended
	 * @example 	new TransitionObserver(page, PAGE_OPEN_START, PAGE_OPEN_END);
	 */
	public function new(page:Page, startEvent:String, stopEvent:String){
		this.page = page;
		this.startEvent = startEvent;
		this.stopEvent = stopEvent;
	}
	/**
	 * call this when a layer transition has started
	 */
	public function addTransition(layer:Layer){
		// check if an event must be dispatched
		if (pendingTransitions == 0){
			if (hasStoped){
				trace("Error: the watcher has allready been used and all transitions have finished. Canot reuse watchers.");
				//throw("Error: the watcher has allready been used and all transitions have finished. Canot reuse watchers.");
				return;
			}
			hasStarted = true;
			dispatch(startEvent);
		}
		// keep track of the number of pending transitions
		pendingTransitions++;
	}
	/**
	 * call this when a layer transition has ended
	 */
	public function removeTransition(layer:Layer){
		DomTools.doLater(doRemoveTransition);
	}
	public function doRemoveTransition(){
		if (hasStoped){
			trace("Error: the watcher has allready been used and all transitions have finished. Canot reuse watchers.");
			//throw("Error: the watcher has allready been used and all transitions have finished. Canot reuse watchers.");
			return;
		}
		// keep track of the number of pending transitions
		pendingTransitions--;
		// check if an event must be dispatched
		if (pendingTransitions == 0){
			hasStoped = true;
			dispatch(stopEvent);
		}
	}
	/** 
	 * dispatch a custom event on the root element with event.detail is a reference to the page
	 */
	private function dispatch(eventName:String){
		trace("TransitionObserver dispatch "+eventName);
		// dispatch a custom event on the root element
		try
		{
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(eventName, true, true, page);
			page.rootElement.dispatchEvent(event);
		}
		catch (e:Dynamic)
		{
			// android browsers
			trace("Error: could not dispatch event "+e);
		}
	}
}