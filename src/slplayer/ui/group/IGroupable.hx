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
package slplayer.ui.group;

import slplayer.core.Application;
import slplayer.ui.DisplayObject;

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
		var groupElements : Array<HtmlDom> = untyped groupable.getSLPlayer().htmlRootElement.getElementsByClassName(groupable.rootElement.getAttribute("data-group-id"));
		
		if ( groupElements.length < 1 )
		{
			return;
		}
		if ( groupElements.length > 1 )
		{
			throw "ERROR "+groupElements.length+" Group components are declared with the same group id "+groupable.rootElement.getAttribute("data-group-id");
		}
		
		groupable.groupElement = groupElements[0];
	}
}