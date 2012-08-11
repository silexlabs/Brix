package org.slplayer.component.navigation;

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
	 * open the pages with linkname in their css style class name
	 * this will close other pages
	 */
	override private function linkToPage(page:Page, targetAttr:Null<String> = null)
	{
		// open the page
		page.close(transitionData);
	}
}