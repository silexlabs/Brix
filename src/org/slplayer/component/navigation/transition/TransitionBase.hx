package org.slplayer.component.navigation.transition;

import js.Lib;
import js.Dom;

import org.slplayer.component.ui.DisplayObject;
import org.slplayer.component.transition.TransitionData;

/**
 * Does a transition between two states of an object
 * It starts when it receives a transitionEventTypeRequest event
 * When it starts and ends, it dispatches a transitionEventTypeStart / transitionEventTypeEnd 
 * These events make it possible for the Layer class to be notified that a transition is occuring or not
 */
@tagNameFilter("div")
class TransitionBase extends DisplayObject
{
	/**
	 * workaround bug removeEventListener 
	 */
	public var isListening:Bool;
	/**
	 * workaround bug removeEventListener 
	 */
	private var onEndCallback:Event->Void;

	/**
	 * constructor
	 * start listening for the transitionEventTypeRequest event
	 */
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);

		onEndCallback = onEnd;

		isListening = false;
		
		// listen to transitionEventTypeRequest
		rootElement.addEventListener(TransitionData.EVENT_TYPE_REQUEST, onTransitionEventTypeRequest, false);
	}

	/**
	 * Start the transition
	 * This method has to be overriden in order to do the transition
	 * You are expected to call applyTransitionParams with your transition params
	 */
	public function start(transitionData:TransitionData) { }

	/**
	 * Callback for the transitionEventTypeRequest event
	 * Dispatch a transitionEventTypeStarted to notify the transitioned object
	 * Starts the transition
	 */
	private function onTransitionEventTypeRequest(event:Event)
	{
		// add transition events for all browsers, to detect transition end
		addEvents();

		// retrieve the transition event data
		var transitionData:TransitionData = cast(event).detail;

		// start the transition
		start(transitionData);

		// dispatch the transition start event to notify the Layer class
		var event:Event = Lib.document.createEvent("Event");
		event.initEvent(TransitionData.EVENT_TYPE_STARTED, true, true);
		rootElement.dispatchEvent(cast(event));
	}

	/**
	 * apply transition params
	 */
	private function applyTransitionParams( transitionProperty:String, 
											newPropertyValue:String,
											transitionDuration:String, 
											transitionTimingFunction:TransitionTimingFunction, 
											transitionDelay:String )
	{
		// set the transition params before setting the value
		rootElement.style.transitionProperty = transitionProperty;
		rootElement.style.transitionDuration = transitionDuration;
		rootElement.style.transitionTimingFunction = transitionTimingFunction;
		rootElement.style.transitionDelay = transitionDelay;
		#if js
			// idem for Firefox
			untyped rootElement.style.MozTransitionProperty = transitionProperty;
			untyped rootElement.style.MozTransitionDuration = transitionDuration;
			untyped rootElement.style.MozTransitionTimingFunction = transitionTimingFunction;
			untyped rootElement.style.MozTransitionDelay = transitionDelay;
			// idem for Safari and Chrome
			untyped rootElement.style.webkitTransitionProperty = transitionProperty;
			untyped rootElement.style.webkitTransitionDuration = transitionDuration;
			untyped rootElement.style.webkitTransitionTimingFunction = transitionTimingFunction;
			untyped rootElement.style.webkitTransitionDelay = transitionDelay;
			// idem for Opera
			untyped rootElement.style.oTransitionProperty = transitionProperty;
			untyped rootElement.style.oTransitionDuration = transitionDuration;
			untyped rootElement.style.oTransitionTimingFunction = transitionTimingFunction;
			untyped rootElement.style.oTransitionDelay = transitionDelay;
			
			// workaround, in some cases the DOM is not updated right away, so we wait the nex frame
			haxe.Timer.delay(callback(doInNextFrame, transitionProperty, newPropertyValue), 10);
		#else
			// with cocktail, no need to wait the next frame
			doInNextFrame(transitionProperty, newPropertyValue);
		#end

	}
	/**
	 * workaround, in some cases the DOM is not updated right away, so we wait the nex frame
	 */
	private function doInNextFrame(transitionProperty:String, newPropertyValue:String)
	{

		// set the final value to start the transition
		Reflect.setField(rootElement.style, transitionProperty, newPropertyValue);
	}

	/**
	 * callback for the CSS transition
	 * dispatch the transition end event
	 */
	private function onEnd(e:Event)
	{
		if (isListening)
		{
			// dispatch the transition end event
			var event:Event = cast Lib.document.createEvent("Event");
			event.initEvent(TransitionData.EVENT_TYPE_ENDED, true, true);
			rootElement.dispatchEvent(cast(event));
		}
		// remove transition events for all browsers
		removeEvents();
	}

	/**
	 * add transition events for all browsers
	 */
	private function addEvents()
	{
		if (isListening==false)
		{
			isListening = true;
			rootElement.addEventListener("transitionend", onEndCallback, false);
			rootElement.addEventListener("transitionEnd", onEndCallback, false);
			rootElement.addEventListener("webkitTransitionEnd", onEndCallback, false);
			rootElement.addEventListener("oTransitionEnd", onEndCallback, false);
			rootElement.addEventListener("MSTransitionEnd", onEndCallback, false);
		}
	}

	/**
	 * Remove events for all browsers
	 */
	private function removeEvents()
	{
		if (isListening)
		{
			isListening = false;
			rootElement.removeEventListener("transitionend", onEndCallback, false);
			rootElement.removeEventListener("transitionEnd", onEndCallback, false);
			rootElement.removeEventListener("webkitTransitionEnd", onEndCallback, false);
			rootElement.removeEventListener("oTransitionEnd", onEndCallback, false);
			rootElement.removeEventListener("MSTransitionEnd", onEndCallback, false);
		}
	}
}