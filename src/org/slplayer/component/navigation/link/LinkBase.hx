/*
 * This file is part of SLPlayer http://www.silexlabs.org/groups/labs/slplayer/
 * 
 * This project is © 2011-2012 Silex Labs and is released under the GPL License:
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms 
 * of the GNU General Public License (GPL) as published by the Free Software Foundation; 
 * either version 2 of the License, or (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU General Public License for more details.
 * 
 * To read the license please visit http://www.gnu.org/copyleft/gpl.html
 */
package org.slplayer.component.navigation.link;

import js.Lib;
import js.Dom;

import org.slplayer.core.Application;
import org.slplayer.component.ui.DisplayObject;
import org.slplayer.component.navigation.transition.TransitionData;
import org.slplayer.util.DomTools;

using StringTools;

/**
 * Base class for the links components
 * Retrieve the href attribute and make an action on the pages which node has the targetted class name
 * Virtual class, it is supposed to be overriden to implement a behavior on click (override the onClick method)
 */
@tagNameFilter("a")
class LinkBase extends DisplayObject
{
	/**
	 * constant, name of attribute href
	 */
	public static inline var CONFIG_PAGE_NAME_ATTR:String = "href";
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
	 * constant, name of attribute
	 * defines the param for the transition
	 */
	public static inline var CONFIG_TRANSITION_DURATION:String = "data-transition-duration";
	/**
	 * constant, name of attribute
	 * defines the param for the transition
	 */
	public static inline var CONFIG_TRANSITION_TIMING_FUNCTION:String = "data-transition-timing-function";
	/**
	 * constant, name of attribute
	 * defines the param for the transition
	 * @example	 &lt;a href=&quot;#page2&quot; class=&quot;Link next&quot; data-transition-delay = &quot;2s&quot; &gt;Test link&lt;/a&gt;
	 */
	public static inline var CONFIG_TRANSITION_DELAY:String = "data-transition-delay";
	/**
	 * constant, name of attribute
	 * defines the param for the transition
	 * @example 	true
	 * @example 	false
	 */
	public static inline var CONFIG_TRANSITION_IS_REVERSED:String = "data-transition-is-reversed";
	/**
	 * value of the href attribute without the #
	 */
	public var linkName:String;
	/**
	 * value of the target attribute 
	 */
	public var targetAttr:Null<String>;
	/**
	 * store the html attribute value
	 * determines which transition to apply 
	 */
	public var transitionData:TransitionData;

	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);

		/// init transition data
		transitionData = new TransitionData(
			null,
			"0"
		);

		// catch the click
		rootElement.addEventListener("click", onClick, false);

		// retrieve the name of our link 
		if (rootElement.getAttribute(CONFIG_PAGE_NAME_ATTR) != null){
			linkName = rootElement.getAttribute(CONFIG_PAGE_NAME_ATTR).trim();
			// removes the URL before the deep link
			linkName = linkName.substr(linkName.indexOf("#")+1);
		}
		else {
			trace("Warning: the link has no href atribute ("+rootElement+")");
		}
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
		// values for the transition
		transitionData = new TransitionData(
			null,
			rootElement.getAttribute(CONFIG_TRANSITION_DURATION),
			rootElement.getAttribute(CONFIG_TRANSITION_TIMING_FUNCTION),
			rootElement.getAttribute(CONFIG_TRANSITION_DELAY),
			rootElement.getAttribute(CONFIG_TRANSITION_IS_REVERSED) != null
		);
	}
}
