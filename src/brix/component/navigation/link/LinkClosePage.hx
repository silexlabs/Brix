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

/**
 * Close the nodes which have a targetted class name, when the user clicks on the component's node
 * Closing a node is done by calling close() on the Page class(es) associated with the node
 */
@tagNameFilter("a")
class LinkClosePage extends LinkBase
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
		// close the page with this name
		Page.closePage(linkName, transitionDataHide, brixInstanceId);
	}
}