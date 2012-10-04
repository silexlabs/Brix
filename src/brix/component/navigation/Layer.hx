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
import brix.component.sound.SoundOn;
import brix.util.DomTools;

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
	public function new(rootElement:HtmlDom, BrixId:String)
	{
		super(rootElement, BrixId);
		childrenArray = new Array();
		status = notInit;
		// Store the transition data for use in onEnd
		styleAttrDisplay = rootElement.style.display;
	}
	/** 
	 * Retrieve the given layer of this application or group
	 */
	static public function getLayerNodes(pageName:String, brixId:String, root:HtmlDom = null):HtmlCollection<HtmlDom>
	{
		// default is the hole document
		var document:Dynamic = root;
		if (root == null)
			document = Lib.document.documentElement;

		// get the desired layers, i.e. the elements with the page name as class name
		return document.getElementsByClassName(pageName);
	}
	//////////////////////////////////////////////////////
	// Transitions
	//////////////////////////////////////////////////////
/*
with priority to the css classes of the link over the one of the layer
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
/*
with sum of the css classes
*/	private function startTransition(type:TransitionType, transitionData:Null<TransitionData> = null, onComplete:Null<Event->Void>=null)
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
			// set the fla
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

/**/
	/**
	 * add transition events for all browsers
	 */
	private function addTransitionEvent(onEndCallback:Event->Void)
	{// trace("EVENTS SET");
		rootElement.addEventListener("transitionend", onEndCallback, false);
	#if js
		// only for pure js, not for cocktail compilation
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
	{// trace("EVENTS RESET");
		rootElement.removeEventListener("transitionend", onEndCallback, false);
	#if js
		// only for pure js, not for cocktail compilation
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
	public function show(transitionData:Null<TransitionData> = null, preventTransitions:Bool = false) : Void
	{
		if (status != hidden && status != notInit)
		{
			trace("Warning: can not show the layer, since it has the status '"+status+"'");
			return;
		}
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
		// update status 
		status = showTransition;

		// put the children back in place
		while (childrenArray.length > 0)
		{
			var element = childrenArray.shift();
			rootElement.appendChild(element);
		}
		// play the videos/sounds when entering the page
		var audioNodes = rootElement.getElementsByTagName("audio");
		setupAudioElements(cast(audioNodes));
		var videoNodes = rootElement.getElementsByTagName("video");
		setupVideoElements(cast(videoNodes));

		// dispatch a custom event on the root element
		try
		{
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_TYPE_SHOW, false, false, {
				transitionData : transitionData,
				target: rootElement,
				layer: this,
			});
			rootElement.dispatchEvent(event);
		}
		catch (e:Dynamic)
		{
			// android browsers
			trace("Error: could not dispatch event "+e);
		}

		// do the transition
		if (preventTransitions == false)
		{
			doShowCallback = callback(doShow, transitionData, preventTransitions);
			startTransition(TransitionType.show, transitionData, doShowCallback);
		}
		else
		{
			doShow(transitionData, preventTransitions, null);
		}
		// set or reset style.display
		rootElement.style.display=styleAttrDisplay;
	}
	/**
	 * transition is over
	 */
	public function doShow(transitionData:Null<TransitionData>, preventTransitions:Bool, e:Null<Event>) : Void
	{// trace("doShow");
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
	}

	//////////////////////////////////////////////////////
	// Hide
	//////////////////////////////////////////////////////
	/**
	 * start the transition and then hide
	 */
	public function hide(transitionData:Null<TransitionData> = null, preventTransitions:Bool) : Void
	{// trace("hide "+preventTransitions);
		if (status != visible && status != notInit){
			//trace("Warning, can not hide the layer, since it has the status '"+status+"'");
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
		if (preventTransitions == false)
		{
			doHideCallback = callback(doHide, transitionData, preventTransitions);
			startTransition(TransitionType.hide, transitionData, doHideCallback);
		}
		else
		{
			doHide(transitionData, preventTransitions, null);
		}
	}

	/**
	 * remove children from the DOM and store it in childrenArray
	 */
	public function doHide(transitionData:Null<TransitionData>, preventTransitions:Bool, e:Null<Event>) : Void
	{ // trace("doHide "+preventTransitions);

		if (e!=null && e.target != rootElement){
			trace("End transition event from another html element");
			return;
		}
		if (preventTransitions == false && doHideCallback == null){
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
		try{
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_TYPE_HIDE, false, false, {
				transitionData : transitionData,
				target: rootElement,
				layer: this,
			});
			rootElement.dispatchEvent(event);
		}
		catch(e:Dynamic){
			// android browsers
			trace("Error: could not dispatch event "+e);
		}
		// stop the videos/sounds when leaving the page
		var audioNodes = rootElement.getElementsByTagName("audio");
		cleanupAudioElements(cast(audioNodes));
		var videoNodes = rootElement.getElementsByTagName("video");
		cleanupVideoElements(cast(videoNodes));

		// remove children 
		while (rootElement.childNodes.length > 0)
		{
			var element:HtmlDom = rootElement.childNodes[0];
			rootElement.removeChild(element);
			childrenArray.push(element);
		}
		// set or reset style.display
		rootElement.style.display="none";
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
