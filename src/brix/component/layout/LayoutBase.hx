/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.layout;

import js.Lib;
import js.Dom;
import Xml;

import brix.util.DomTools;
import brix.component.navigation.Page;
import brix.component.navigation.ContextManager;
import brix.component.navigation.StateManager;
import brix.component.ui.DisplayObject;

/**
 * LayoutBase class
 * This is a base class for components which takes html nodes and applyes a layout to them
 * It listens for and dispatches redraw events
 */
class LayoutBase extends DisplayObject
{
	/**
	 * event thrown when a layout redraws
	 * the event is dispatch with the properties 
	 * - detail.component, i.e. this
	 * - detail.target, i.e. rootElement
	 */
	public static inline var EVENT_LAYOUT_REDRAW = "layoutRedraw";
	/**
	 * flag used to avoid redraw loops
	 */
	public var preventRedraw:Bool = false;
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, BrixId:String){
		super(rootElement, BrixId);

		//Lib.window.addEventListener('resize', redrawCallback, false);
		mapListener(Lib.window,'resize', redrawCallback, false);

		// do not work: Lib.document.addEventListener("resize", redraw, false);
		// do not compile: Lib.window.addEventListener("resize", redraw, false);
		// yes but only 1 instance can listen: Lib.window.onresize = redraw;

		mapListener(Lib.document.body, Page.EVENT_TYPE_OPEN_STOP, navigationCallback, true);
		mapListener(Lib.document.body, Page.EVENT_TYPE_CLOSE_STOP, navigationCallback, true);
		mapListener(Lib.document.body, ContextManager.EVENT_CONTEXT_CHANGE, navigationCallback, true);
		mapListener(Lib.document.body, StateManager.EVENT_STATE_CHANGE, navigationCallback, true);

		// other layouts event
		mapListener(Lib.document.body, EVENT_LAYOUT_REDRAW, redrawCallback, true);
	}
	/**
	 * init the component
	 */
	override public function init() : Void { 
		super.init();

		// redraw
		//DomTools.doLater(redraw);
	}
	/**
	 * call redraw when an event occures
	 */
	public function navigationCallback(e:Event){
		DomTools.doLater(redraw);
	}
	/**
	 * call redraw when an event occures
	 */
	public function redrawCallback(e:Event){
		redraw();
	}

	/**
	 * throw a redraw event for the other layouts
	 * to be overriden in the derived classes
	 */
	public function redraw(){
		if (preventRedraw){
			return;
		}
		preventRedraw = true;
		// dispatch a custom event
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(EVENT_LAYOUT_REDRAW, true, true, {
			target: rootElement,
			component: this,
		});
		rootElement.dispatchEvent(event);
		preventRedraw = false;
	}
}
