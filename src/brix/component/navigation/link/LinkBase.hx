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

import brix.core.Application;
import brix.component.ui.DisplayObject;
import brix.component.navigation.transition.TransitionData;
import brix.component.navigation.transition.TransitionTools;
import brix.util.DomTools;

import brix.component.group.IGroupable;
using brix.component.group.IGroupable.Groupable;

using StringTools;

/**
 * Base class for the links components
 * Retrieve the href attribute and make an action on the pages which node has the targetted class name
 * Virtual class, it is supposed to be overriden to implement a behavior on click (override the onClick method)
 */
@tagNameFilter("a" ,"div")
class LinkBase extends DisplayObject, implements IGroupable
{
	/**
	 * constant, name of attribute href
	 */
	public static inline var CONFIG_PAGE_NAME_ATTR:String = "href";
	/**
	 * constant, name of attribute href
	 * in case the link is not on a "a" tag
	 */
	public static inline var CONFIG_PAGE_NAME_DATA_ATTR:String = "data-href";
	/**
	 * constant, name of attribute target
	 */
	public static inline var CONFIG_TARGET_ATTR:String = "target";
	/**
	 * constant, name of attribute
	 * if this the target attribute has this value, then it is a link to open a popup
	 */
	public static inline var CONFIG_TARGET_IS_POPUP:String = "_top";
	/**
	 * the group element set by the Group class
	 * implementation of IGroupable
	 */
	public var groupElement:HtmlDom;
	/**
	 * value of the href attribute without the #
	 */
	public var linkName:Null<String>;
	/**
	 * value of the target attribute 
	 */
	public var targetAttr:Null<String>;
	/**
	 * store the html attribute value
	 * determines which transition to apply 
	 */
	public var transitionDataShow:TransitionData;
	public var transitionDataHide:TransitionData;

	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);

		// implementation of IGroupable
		startGroupable();
		
		// catch the click
		//rootElement.addEventListener("click", onClick, false);
		mapListener(rootElement,"click", onClick, true); // true, otherwise click is dispatched 2 times
		// show that it is clickable
		rootElement.style.cursor = "pointer";

		// retrieve the name of our link 
		if (rootElement.getAttribute(CONFIG_PAGE_NAME_ATTR) != null)
		{
			linkName = rootElement.getAttribute(CONFIG_PAGE_NAME_ATTR).trim();
			// removes the URL before the deep link
			linkName = linkName.substr(linkName.indexOf("#")+1);
		}
		else
		{
			if (rootElement.getAttribute(CONFIG_PAGE_NAME_DATA_ATTR) != null)
			{
				linkName = rootElement.getAttribute(CONFIG_PAGE_NAME_DATA_ATTR).trim();
			}
			else
			{
				trace("Warning: the link has no href atribute ("+rootElement+")");
			}
		}
/*		var pageURL = linkName.split("?");
		if (pageURL[1] != null)
		{
			pageURL[1] = StringTools.urlEncode(StringTools.htmlUnescape(pageURL[1]));
			linkName = pageURL.join("?");
		}
*/
		// retrieve the target attr of our link 
		if (rootElement.getAttribute(CONFIG_TARGET_ATTR) != null && rootElement.getAttribute(CONFIG_TARGET_ATTR).trim() != "")
		{
			targetAttr = rootElement.getAttribute(CONFIG_TARGET_ATTR).trim();
		}
	}

	/**
	 * user clicked the link
	 * do an action to the pages corresponding to our link
	 * overide this method in order to open or close pages, or anything you want to do when the user clicks on the link
	 */
	private function onClick(e:Event)
	{
		// prevent the link from being followed or the hash tag to change the scroll position as an HTML anchor would
		e.preventDefault();

		// values for the transition
		transitionDataShow = TransitionTools.getTransitionData(rootElement, TransitionType.show);
		transitionDataHide = TransitionTools.getTransitionData(rootElement, TransitionType.hide);
	}
}
