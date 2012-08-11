package org.slplayer.component.navigation;

import js.Lib;
import js.Dom;

/**
 * Let you specify a page to display when the user clicks on the component's node
 */
@tagNameFilter("a")
class LinkToPage extends LinkBase
{
	/**
	 * constant, name of attribute
	 * if this the target attribute has this value, then it is a link to open a popup
	 */
	public static inline var CONFIG_TARGET_IS_POPUP:String = "_top";

	/**
	 * open the pages with linkname in their css style class name
	 * this will close other pages
	 */
	override private function linkToPage(page:Page, targetAttr:Null<String> = null)
	{
		// open the page
		page.open(transitionData, targetAttr != CONFIG_TARGET_IS_POPUP);
	}
}
