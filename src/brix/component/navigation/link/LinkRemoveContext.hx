/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.navigation.link;


import js.html.HtmlElement;
import js.html.Event;

/**
 * Let you specify a context to hide when the user clicks on the component's node
 * @example <a href="#context1" class="LinkRemoveContext">- Context 1</a>
 */
@tagNameFilter("a")
class LinkRemoveContext extends LinkContextBase
{
	/**
	 * to be implemented in sub classes
	 */
	override public function onClick(e:Event) 
	{
		super.onClick(e);
		dispatchContextEvent(ContextManager.EVENT_REMOVE_CONTEXTS);
	}
}
