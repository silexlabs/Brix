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

/**
 * Let you specify a page to display when the user clicks on the component's node
 */
@tagNameFilter("a")
class LinkToPage extends LinkBase
{
	/**
	 * user clicked the link
	 * do an action to the pages corresponding to our link
	 *
	 * open the pages with linkname in their css style class name
	 * this will close other pages
	 */
	override private function onClick(e:Event)
	{
		super.onClick(e);
		// show the page with this name
		Page.openPage(linkName, targetAttr==LinkBase.CONFIG_TARGET_IS_POPUP, transitionDataShow, transitionDataHide, SLPlayerInstanceId, groupElement);
	}
}
