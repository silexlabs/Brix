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

import org.slplayer.util.DomTools;

/**
 * Let you specify a context to display when the user clicks on the component's node
 * All the elements with the context in their class name will be displayed. Initially, you are expected to set ther css style "visibility" to "hidden"
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
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);
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
