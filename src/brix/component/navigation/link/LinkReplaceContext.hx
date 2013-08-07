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
 * Let you specify the list of contexts to display when the user clicks on the component's node
 * @example <a href="#context1#context2" class="LinkReplaceContext">Reset to context 1+2</a>
 */
@tagNameFilter("a")
class LinkReplaceContext extends LinkContextBase
{
	/**
	 * to be implemented in sub classes
	 */
	override public function onClick(e:Event) 
	{
		super.onClick(e);
		dispatchContextEvent(ContextManager.EVENT_REPLACE_CONTEXTS);
	}
}
