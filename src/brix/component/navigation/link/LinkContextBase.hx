/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.navigation.link;

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
	 * constant, name of attribute
	 * Optional, you can use href instead
	 */
	public static inline var CONFIG_ATTR_CONTEXT:String = "data-context";
	/** 
	 * context manager instance
	 */
	private var contextManager : ContextManager;
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
		}
		// find the context manager 
		var node = rootElement;
		while (node != null && !DomTools.hasClass(node, "ContextManager"))
		{
			node = node.parentNode;
		}
		if (node != null)
		{
			contextManager = Application.get(brixId).getAssociatedComponents(node, ContextManager).first();
		}
		else
		{
			throw("Error: Could not find the ContextManager node in the parent nodes. The ContextManager is needed for the context links.");
		}
	}
	/**
	 * user clicked the link
	 * do an action to the layers corresponding to our link
	 */
	override private function onClick(e:Event)
	{
		super.onClick(e);
		doContextAction(contextManager);
	}
	/**
	 * to be implemented in sub classes
	 */
	public function doContextAction(contextManager : ContextManager) 
	{
		throw("not implemented");
	}
}
