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
 * Let you specify a page to display when the user clicks on the component's node
 */
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
		Page.openPage(linkName, targetAttr==LinkBase.CONFIG_TARGET_IS_POPUP, transitionDataShow, transitionDataHide, brixInstanceId, groupElement);
	}
}
