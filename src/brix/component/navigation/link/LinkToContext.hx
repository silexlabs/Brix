/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.navigation.link;

import js.Lib;
import js.Dom;

import brix.util.DomTools;

/**
 * Let you specify a context to display when the user clicks on the component's node
 * All the elements with the context in their class name will be displayed. Initially, you are expected to set ther css style "visibility" to "hidden".
 */
@tagNameFilter("a")
class LinkToContext extends LinkBase
{
	/**
	 * constant, name of attribute
	 * Optional, you can use href instead
	 */
	public static inline var CONFIG_TRANSITION_DURATION:String = "data-context";
	/**
	 * Stores the style node with the current context as visible 
	 */
	private static var styleSheet:HtmlDom;

	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		// retrieve the name of our link in data-context instead of href
		if (rootElement.getAttribute(CONFIG_TRANSITION_DURATION) != null)
		{
			linkName = rootElement.getAttribute(CONFIG_TRANSITION_DURATION);
		}
		trace("LinkToContext "+linkName);
	}

	/**
	 * user clicked the link
	 * do an action to the pages corresponding to our link
	 */
	override private function onClick(e:Event)
	{
		super.onClick(e);
		
		if (styleSheet != null)
		{
			Lib.document.getElementsByTagName("head")[0].removeChild(cast(styleSheet));	
		}

		var cssText = "."+linkName+" { display : inline; visibility : visible; }";

		styleSheet = DomTools.addCssRules(cssText);
	}
}
