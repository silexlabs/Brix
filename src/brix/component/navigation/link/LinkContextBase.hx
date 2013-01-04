/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.navigation.link;

import brix.component.navigation.ContextManager;
import brix.core.Application;
import brix.util.DomTools;

import js.Lib;
import js.Dom;

/**
 * Let you specify the list of contexts to display when the user clicks on the component's node
 * @example <a href="#context1#context2" class="LinkReplaceContext">Reset to context 1+2</a>
 */
@tagNameFilter("a")
class LinkContextBase extends LinkBase
{
	/**
	 * links targeted by this link
	 * value of the href attribute, splitted with "#"
	 */
	public var links:ContextEventDetail;
	/**
	 * constant, name of attribute
	 * Optional, you can use href instead
	 */
	public static inline var CONFIG_ATTR_CONTEXT:String = "data-context";
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		// retrieve the name of our link in data-context instead of href
		if (rootElement.getAttribute(CONFIG_ATTR_CONTEXT) != null)
		{
			linkName = rootElement.getAttribute(CONFIG_ATTR_CONTEXT);
			links = linkName.split("#");
		}
		else
		{
			links = [];
		}
	}
	/**
	 * user clicked the link
	 * do an action to the layers corresponding to our link
	 * this method should be overriden in order to specialize the link
	 */
	override private function onClick(e:Event)
	{
		super.onClick(e);
	}
	/**
	 * to be implemented in sub classes
	 */
	public function dispatchContextEvent(type:String) 
	{
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(type, false, false, links);
		rootElement.dispatchEvent(event);
	}
}
