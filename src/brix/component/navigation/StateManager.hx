/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.navigation;

import brix.component.navigation.Page;
import brix.component.navigation.ContextManager;
import brix.component.ui.DisplayObject;
import brix.util.DomTools;
import brix.core.Application;

import js.Dom;
import js.Lib;

/**
 * The StateManager component is a component that is in charge to show/hide HTML elements in function of the currrent opened page or the contexts
 * It takes the parameters data-[page/context name]="css-class-name" to associate a page/context with a css class
 * When the corresponding page/context is opened, the css class is added to rootElement.className
 * @example <div class="StateManager" data-page1="left-style" data-page2="right-style" />
 * @example <div class="StateManager" data-context1="left-style" data-context2="right-style" />
 */
class StateManager extends DisplayObject
{
	/**
	 * prefix of the parameter used to get the page / css style associaiton
	 */
	public static inline var PARAM_DATA_PREFIX = "data-";
	/**
	 * name of the event dispatched when the state changes
	 */
	public static inline var EVENT_STATE_CHANGE = "changeStateEvent";
	/**
	 * css classes added to rootElement.className
	 */
	public var currentCssClassNamesContexts:Array<String>;
	/**
	 * css classes added to rootElement.className
	 */
	public var currentCssClassNamesPages:Array<String>;

	///////////////////////////////////////////////////////////////
	// main methods
	///////////////////////////////////////////////////////////////
	/**
	 * Builds the Context with arguments passed in the html node attributes
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		currentCssClassNamesContexts = new Array();
		currentCssClassNamesPages = new Array();
	}
	override public function init()
	{
		// listen to other components events
		mapListener(getBrixApplication().body, Page.EVENT_TYPE_OPEN_STOP, cast(onPageOpened), true);
		mapListener(getBrixApplication().body, ContextManager.EVENT_CONTEXT_CHANGE, cast(onContextChanged), true);

		dispatch(ContextManager.EVENT_REQUEST_CONTEXTS);
	}
	/** 
	 * callback for page events
	 */
	private function onContextChanged(e:CustomEvent)
	{// trace("onContextChanged");
		// retrieve the context manager
		var contextManager:ContextManager = e.detail;
		// update the state
		update(contextManager.currentContexts, currentCssClassNamesContexts);
	}
	/** 
	 * callback for page events
	 */
	private function onPageOpened(e:CustomEvent)
	{// trace("onPageOpened");
		// retrieve the opened page
		var page:Page = e.detail;

		// update the state
		update([page.name], currentCssClassNamesPages);
	}
	/**
	 * apply the css style corresponding to a state
	 */
	private function update(states:Array<String>, currentCssClassNames:Array<String>) 
	{// trace("update "+states);
		var isDirty = false;

		// remove the previously added css class
		for (cssClass in currentCssClassNames)
		{
			DomTools.removeClass(rootElement, cssClass);
			isDirty = true;
		}

		// get the desired css class corresponding to the new state
		for (state in states)
		{
			var attrName = PARAM_DATA_PREFIX + state;
			var attrVal = rootElement.getAttribute(attrName);

			// apply the corresponding css class
			if (attrVal != null)
			{
				DomTools.addClass(rootElement, attrVal);
				currentCssClassNames.push(attrVal);
				isDirty = true;
			}
		}
		// dispatch a change event if needed
		if (isDirty)
		{
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_STATE_CHANGE, false, false, this);
			rootElement.dispatchEvent(event);
		}
	}
}