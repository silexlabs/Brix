/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.navigation;

import js.Lib;
import js.Dom;

import brix.component.ui.DisplayObject;
import brix.component.navigation.transition.TransitionData;
import brix.component.navigation.transition.TransitionTools;
import brix.component.navigation.transition.TransitionObserver;
import brix.component.sound.SoundOn;
import brix.util.DomTools;
import brix.core.Application;

enum LayerStatus
{
	showTransition;
	hideTransition;
	visible;
	hidden;
	notInit;
}
typedef LayerEventDetail =
{
	var transitionObserver : TransitionObserver;
	var transitionData : TransitionData;
	var target: HtmlDom;
	var layer: Layer;
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
	 * the event have this object in event.detail: {transitionObserver:transitionObserver, transitionData:transitionData,target:rootElement,layer: this,}	
	 */
	public static inline var EVENT_TYPE_SHOW_START:String = "onLayerShowStart";
	/**
	 * constant for the hide event, dispatched on the rootElement node when the layer is hided
	 * the event have this object in event.detail: {transitionObserver:transitionObserver, transitionData:transitionData,target:rootElement,layer: this,}	
	 */
	public static inline var EVENT_TYPE_HIDE_START:String = "onLayerHideStart";
	/**
	 * constant for the show event, dispatched on the rootElement node when the layer is shown
	 * the event have this object in event.detail: {transitionObserver:transitionObserver, transitionData:transitionData,target:rootElement,layer: this,}	
	 */
	public static inline var EVENT_TYPE_SHOW_STOP:String = "onLayerShowStop";
	/**
	 * constant for the hide event, dispatched on the rootElement node when the layer is hided
	 * the event have this object in event.detail: {transitionObserver:transitionObserver, transitionData:transitionData,target:rootElement,layer: this,}	
	 */
	public static inline var EVENT_TYPE_HIDE_STOP:String = "onLayerHideStop";
	/**
	 * constant for the show event, dispatched on the rootElement node when the layer is shown and it was allready visible
	 * it is useful for the TemplateRenderer component to redraw itself when a page is re-opened with different query data
	 * the event have this object in event.detail: {transitionObserver:transitionObserver, transitionData:transitionData,target:rootElement,layer: this,}	
	 */
	public static inline var EVENT_TYPE_SHOW_AGAIN:String = "onLayerShowAgain";
	/**
	 * constant for the hide event, dispatched on the rootElement node when the layer is hiden, and it was allready hidden
	 * the event have this object in event.detail: {transitionObserver:transitionObserver, transitionData:transitionData,target:rootElement,layer: this,}	
	 */
	public static inline var EVENT_TYPE_HIDE_AGAIN:String = "onLayerHideAgain";
	/**
	 * array used to store all the children while the layer is hided
	 */
	private var childrenArray:Array<HtmlDom>;
	/**
	 * true if the layer is hidden
	 */
	public var status(default, setStatus):LayerStatus;
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
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		childrenArray = new Array();
		status = notInit;
		// Store the transition data for use in onEnd
		styleAttrDisplay = rootElement.style.display;
	}
	/** 
	 * Retrieve the given layer of this application or group
	 */
	static public function getLayerNodes(pageName:String="", brixId:String, root:HtmlDom = null):HtmlCollection<HtmlDom>
	{
		// default is the hole body
		var body:Dynamic = root;
		if (root == null)
			body = Application.get(brixId).body;
		if (pageName != "")
			// get the desired layers, i.e. the elements with the page name as class name
			return body.getElementsByClassName(pageName);
		else
			return body.getElementsByClassName("Layer");
	}
	/**
	 * retrieve the layer in which this component is defined
	 */
	static public function getLayer(element:HtmlDom, brixId:String) : Null<Layer>
	{
		while(element!=null && !DomTools.hasClass(element, "Layer"))
		{
			element = element.parentNode;
		}
		if (element!=null)
		{
			return Application.get(brixId).getAssociatedComponents(element, Layer).first();
		}
		trace("WARNING: could not find layer "+element);
		return null;
	}
	//////////////////////////////////////////////////////
	// Transitions
	//////////////////////////////////////////////////////
	private static inline var MAX_DELAY_FOR_TRANSITION:Int = 2500;
	private function setStatus(newStatus:LayerStatus):LayerStatus
	{
		status = newStatus;
		#if (!php)
		if(status == showTransition || status == hideTransition){
			haxe.Timer.delay(checkForNeverEndingTransition, MAX_DELAY_FOR_TRANSITION);
		}
		#end
		return status;
	}
	#if (!php)
	private function checkForNeverEndingTransition() 
	{
		if(status == showTransition || status == hideTransition){
			trace("Warning, transition is not over. This may be a layer with data-show-start but with a style which does not has CSS transition. Root node with css class: "+rootElement.className);	
			haxe.Timer.delay(checkForNeverEndingTransition, MAX_DELAY_FOR_TRANSITION);
		}
	}
	#end
	/**
	 * concat the css classes used for transition (in data-*)
	 * if there is a transition, this will init the transition with the data-*-start style
	 * and call doStartTransition after a "frame"
	 */
 	private function startTransition(type:TransitionType, transitionData:Null<TransitionData> = null, onComplete:Null<Event->Void>=null)
	{
		// retrieve transition data from the root node
		var transitionData2 = TransitionTools.getTransitionData(rootElement, type);

		// add the transition data from the link
		var sumOfTransitions:Array<TransitionData> = new Array();
		if (transitionData != null)
		{
			sumOfTransitions.push(transitionData);
		}
		if (transitionData2 != null)
		{
			sumOfTransitions.push(transitionData2);
		}
		// apply the initial transition params
		if (sumOfTransitions.length == 0)
		{
			// no transition
			if(onComplete != null)
				onComplete(null);
		}
		else
		{
			// set the flag
			hasTransitionStarted = true;
			// prevent anim at this stage
			TransitionTools.setTransitionProperty(rootElement, "transitionDuration", "0");
			// set the css style
			for (transition in sumOfTransitions)
				DomTools.addClass(rootElement, transition.startStyleName);//
			// continue later
			DomTools.doLater(callback(doStartTransition, sumOfTransitions, onComplete));
		}
	}
	/**
	 * after init the transition with data-*-start
	 * this will apply the data-*-end style
	 */
	private function doStartTransition(sumOfTransitions:Array<TransitionData>, onComplete:Null<Event->Void>=null) 
	{
		// reset the css style
		for (transition in sumOfTransitions)
			DomTools.removeClass(rootElement, transition.startStyleName);
		// listen for the transition end event
		if (onComplete != null)
		{
			addTransitionEvent(onComplete);
		}
		// allow anim at this stage
		TransitionTools.setTransitionProperty(rootElement, "transitionDuration", null);
		// set the css style again
		for (transition in sumOfTransitions)
			DomTools.addClass(rootElement, transition.endStyleName);
	}
	/**
	 * callback for the css transition end
	 */
	private function endTransition(type:TransitionType, transitionData:Null<TransitionData> = null, onComplete:Null<Event->Void>=null)
	{
		removeTransitionEvent(onComplete);
		if (transitionData != null)
		{
			DomTools.removeClass(rootElement, transitionData.endStyleName);
		}
		var transitionData2 = TransitionTools.getTransitionData(rootElement, type);
		if (transitionData2 != null)
		{
			DomTools.removeClass(rootElement, transitionData2.endStyleName);
		}
	}
	/**
	 * add transition events for all browsers
	 */
	private function addTransitionEvent(onEndCallback:Event->Void)
	{
		//rootElement.addEventListener("transitionend", onEndCallback, false);
		mapListener(rootElement, "transitionend", onEndCallback, false);
	#if js
		// only for pure js, not for cocktail compilation
		//rootElement.addEventListener("transitionEnd", onEndCallback, false);
		mapListener(rootElement, "transitionEnd", onEndCallback, false);
		//rootElement.addEventListener("webkitTransitionEnd", onEndCallback, false);
		mapListener(rootElement, "webkitTransitionEnd", onEndCallback, false);
		//rootElement.addEventListener("oTransitionEnd", onEndCallback, false);
		mapListener(rootElement, "oTransitionEnd", onEndCallback, false);
		//rootElement.addEventListener("MSTransitionEnd", onEndCallback, false);
		mapListener(rootElement, "MSTransitionEnd", onEndCallback, false);
	#end
	}

	/**
	 * Remove events for all browsers
	 */
	private function removeTransitionEvent(onEndCallback:Event->Void)
	{
		//rootElement.removeEventListener("transitionend", onEndCallback, false);
		unmapListener(rootElement,"transitionend", onEndCallback, false);
	#if js
		// only for pure js, not for cocktail compilation
		//rootElement.removeEventListener("transitionEnd", onEndCallback, false);
		unmapListener(rootElement,"transitionEnd", onEndCallback, false);
		//rootElement.removeEventListener("webkitTransitionEnd", onEndCallback, false);
		unmapListener(rootElement,"webkitTransitionEnd", onEndCallback, false);
		//rootElement.removeEventListener("oTransitionEnd", onEndCallback, false);
		unmapListener(rootElement,"oTransitionEnd", onEndCallback, false);
		//rootElement.removeEventListener("MSTransitionEnd", onEndCallback, false);
		unmapListener(rootElement,"MSTransitionEnd", onEndCallback, false);
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
	public function show(transitionData:Null<TransitionData> = null, transitionObserver:TransitionObserver=null, preventTransitions:Bool = false) : Void
	{
		// reset transition if it is pending
		if (status == hideTransition)
		{
			trace("Warning: show break previous transition hide");
			doHideCallback(null);
			removeTransitionEvent(doHideCallback);
		}
		// reset transition if it is pending
		else if (status == showTransition)
		{
			trace("Warning: show break previous transition show");
			doShowCallback(null);
			removeTransitionEvent(doShowCallback);
		}
		if (status != hidden && status != notInit)
		{
			//trace("Warning: can not show the layer, since it has the status '"+status+"'");
			dispatch(EVENT_TYPE_SHOW_AGAIN, {
				transitionObserver : transitionObserver,
				transitionData : transitionData,
				target: rootElement,
				layer: this,
			}, rootElement, true, down);

			// notify the transition observer
			if (transitionObserver!=null){
				transitionObserver.alreadyOpen(this);
			}

			return;
		}
		// update status 
		status = showTransition;

		// put the children back in place
		while (childrenArray.length > 0)
		{
			var element = childrenArray.shift();
			rootElement.appendChild(element);
			getBrixApplication().initNode(element);
		}

		// notify the transition observer
		if (transitionObserver!=null)
			transitionObserver.addTransition(this);

		// dispatch a custom event on the root element
		try
		{
			dispatch(EVENT_TYPE_SHOW_START, {
				transitionObserver : transitionObserver,
				transitionData : transitionData,
				target: rootElement,
				layer: this,
			}, rootElement, true, down);
		}
		catch (e:Dynamic)
		{
			// android browsers
			trace("Error: could not dispatch event "+e);
		}

		// do the transition
		if (preventTransitions == false)
		{
			doShowCallback = callback(doShow, transitionData, transitionObserver, preventTransitions);
			startTransition(TransitionType.show, transitionData, doShowCallback);
		}
		else
		{
			// no transition
			doShow(transitionData, transitionObserver, preventTransitions, null);
		}
		// set or reset style.display
		rootElement.style.display=styleAttrDisplay;
	}
	/**
	 * transition is over
	 */
	public function doShow(transitionData:Null<TransitionData>, transitionObserver:TransitionObserver, preventTransitions:Bool, e:Null<Event>) : Void
	{
		if (e!=null && e.target != rootElement){
			trace("End transition event from another html element");
			return;
		}
		if (preventTransitions == false && doShowCallback == null){
			trace("Warning: end transition callback already called");
			return;
		}
		if (preventTransitions == false)
		{
			endTransition(TransitionType.show,transitionData, doShowCallback);
		}
		doShowCallback=null;
		// update status 
		status = visible;
		// play the videos/sounds after transition
		var audioNodes = rootElement.getElementsByTagName("audio");
		setupAudioElements(cast(audioNodes));
		var videoNodes = rootElement.getElementsByTagName("video");
		setupVideoElements(cast(videoNodes));

		// dispatch a custom event on the root element
		try
		{
			dispatch(EVENT_TYPE_SHOW_STOP, {
				transitionObserver : transitionObserver,
				transitionData : transitionData,
				target: rootElement,
				layer: this,
			}, rootElement, true, down);
		}
		catch (e:Dynamic)
		{
			// android browsers
			trace("Error: could not dispatch event "+e);
		}
		// notify the transition observer
		if (transitionObserver!=null)
			transitionObserver.removeTransition(this);
	}

	//////////////////////////////////////////////////////
	// Hide
	//////////////////////////////////////////////////////
	/**
	 * start the transition and then hide
	 */
	public function hide(transitionData:Null<TransitionData> = null, transitionObserver:TransitionObserver=null, preventTransitions:Bool=false) : Void
	{
		// reset transition if it is pending
		if (status == hideTransition)
		{
			trace("Warning: hide break previous transition hide");
			doHideCallback(null);
			removeTransitionEvent(doHideCallback);
		}
		// reset transition if it is pending
		else if (status == showTransition)
		{
			trace("Warning: hide break previous transition show");
			doShowCallback(null);
			removeTransitionEvent(doShowCallback);
		}
		if (status != visible && status != notInit){
			// trace("Warning, can not hide the layer, since it has the status '"+status+"'");
			dispatch(EVENT_TYPE_HIDE_AGAIN, {
				transitionObserver : transitionObserver,
				transitionData : transitionData,
				target: rootElement,
				layer: this,
			}, rootElement, true, down);
			return;
		}
		// update status 
		status = hideTransition;

		// notify the transition observer
		if (transitionObserver!=null)
			transitionObserver.addTransition(this);

		// dispatch a custom event on the root element
		try
		{
			dispatch(EVENT_TYPE_HIDE_START, {
				transitionObserver : transitionObserver,
				transitionData : transitionData,
				target: rootElement,
				layer: this,
			}, rootElement, true, down);
		}
		catch (e:Dynamic)
		{
			// android browsers
			trace("Error: could not dispatch event "+e);
		}
		// stop the videos/sounds during transition
		var audioNodes = rootElement.getElementsByTagName("audio");
		cleanupAudioElements(cast(audioNodes));
		var videoNodes = rootElement.getElementsByTagName("video");
		cleanupVideoElements(cast(videoNodes));

		// do the transition
		if (preventTransitions == false)
		{
			doHideCallback = callback(doHide, transitionData, transitionObserver, preventTransitions);
			startTransition(TransitionType.hide, transitionData, doHideCallback);
		}
		else
		{
			// no transition
			doHide(transitionData, transitionObserver, preventTransitions, null);
		}
	}

	/**
	 * remove children from the DOM and store it in childrenArray
	 */
	public function doHide(transitionData:Null<TransitionData>, transitionObserver:TransitionObserver, preventTransitions:Bool, e:Null<Event>) : Void
	{
		if (e != null && e.target != rootElement)
		{
			trace("End transition event from another html element");
			return;
		}
		if (preventTransitions == false && doHideCallback == null)
		{
			trace("Warning: end transition callback already called");
			return;
		}
		if (preventTransitions == false)
		{
			endTransition(TransitionType.hide, transitionData, doHideCallback);
			doHideCallback = null;
		}
		// update status 
		status = hidden;

		// dispatch a custom event on the root element
		try
		{
			dispatch(EVENT_TYPE_HIDE_STOP, {
				transitionObserver : transitionObserver,
				transitionData : transitionData,
				target: rootElement,
				layer: this,
			}, rootElement, true, down);
		}
		catch (e:Dynamic)
		{
			// android browsers
			trace("Error: could not dispatch event "+e);
		}
		// notify the transition observer
		if (transitionObserver!=null)
			transitionObserver.removeTransition(this);


		// remove children 
/*
		while (rootElement.childNodes.length > 0)
		{
			var element:HtmlDom = rootElement.childNodes[0];
			getBrixApplication().cleanNode(element);
			rootElement.removeChild(element);
			childrenArray.push(element);
		}
*/
		// set or reset style.display
		rootElement.style.display = "none";
	}
	//////////////////////////////////////////////////////
	// Media
	//////////////////////////////////////////////////////
	/**
	 * play the videos/sounds when entering the page
	 */ 
	private function setupAudioElements(nodeList:HtmlCollection<Audio>) 
	{
		for (idx in 0...nodeList.length)
		{
			try
			{				
				var element = nodeList[idx];
				if (element.autoplay == true)
				{
					element.currentTime = 0;
					element.play();
				}
				element.muted = SoundOn.isMuted;
			}
			catch (e:Dynamic)
			{
				// this happens when the element was removed from the dom for example
				// it is the case when transition is immediate
				trace("Layer error: could not access audio or video element");
			}
		}
	}
	/**
	 * play the videos/sounds when entering the page
	 */ 
	private function setupVideoElements(nodeList:HtmlCollection<Video>) 
	{
		for (idx in 0...nodeList.length)
		{
			try
			{				
				var element = nodeList[idx];
				if (element.autoplay == true)
				{
					element.currentTime = 0;
					element.play();
				}
				element.muted = SoundOn.isMuted;
			}
			catch (e:Dynamic)
			{
				// this happens when the element was removed from the dom for example
				// it is the case when transition is immediate
				trace("Layer error: could not access audio or video element");
			}
		}
	}
	/**
	 * stop the videos/sounds when leaving the page
	 */ 
	private function cleanupAudioElements(nodeList:HtmlCollection<Audio>) 
	{
		for (idx in 0...nodeList.length)
		{
			try
			{				
				var element = nodeList[idx];
				element.pause();
				element.currentTime = 0;
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
	/**
	 * stop the videos/sounds when leaving the page
	 */ 
	private function cleanupVideoElements(nodeList:HtmlCollection<Video>) 
	{
		for (idx in 0...nodeList.length)
		{
			try
			{
				var element = nodeList[idx];
				element.pause();
				element.currentTime = 0;
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

}
