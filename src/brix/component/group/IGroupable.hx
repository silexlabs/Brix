/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.group;

import brix.core.Application;
import brix.component.ui.DisplayObject;

import js.Dom;
import js.Lib;

/**
 * Makes a component groupable (ie: gives it a common object - the Group node - to listen to and dispatch events with its group mates).
 * 
 * Note that you have to call Groupable.startGroupable(...) manually in your component implementation to make your component entering its
 * group and be able to use its groupElement attribute.
 * 
 * You'll also have to dispatch and listen to the events on groupElement manually in your component implementation.
 */
interface IGroupable implements IDisplayObject
{
	var groupElement : HtmlDom;
}

/**
 * The IGroupable components common methods.
 */
class Groupable
{
	/**
	 * Simply retrieves the group element by calling getElementsByClassName on the application root element.
	 */ 
	static public function startGroupable( groupable : IGroupable ) : Void
	{
		// retrieve the group ID in the node's attributes
		var groupId = groupable.rootElement.getAttribute("data-group-id");
		if (groupId == null)
			return ;

		// get the group elements corresponding to this ID
		var groupElements = groupable.getBrixApplication().htmlRootElement.getElementsByClassName(groupId);
		// check if we have one and only one group for this ID
		if ( groupElements.length < 1 )
		{
			trace("WARNING: could not find the group component "+groupId);
			return;
		}
		if ( groupElements.length > 1 )
		{
			throw "ERROR "+groupElements.length+" Group components are declared with the same group id "+groupId;
		}
		// set the reference to the group node on the element
		groupable.groupElement = groupElements[0];
	}
}