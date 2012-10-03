/*
 * This file is part of Brix http://www.silexlabs.org/groups/labs/slplayer/
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
package org.brix.component;

import org.brix.core.Application;

#if macro
import cocktail.Dom;
#else
import js.Dom;
#end

/**
 * The interface each SLPlayer component should implement to be able to standardly retreive their SLPlayer Application instance.
 * 
 * @author Thomas Fétiveau
 */
interface IBrixComponent
{
	/**
	 * the Brix Application instance id.
	 */
	public var brixInstanceId : String;
	
	/**
	 * a method to get transparently the associated Application instance.
	 */
	public function getBrix() : Application;
}

/**
 * The common code to all SLPlayer components.
 */
class BrixComponent 
{
	static public function initBrixComponent(component : IBrixComponent, brixInstanceId : String):Void
	{
		component.brixInstanceId = brixInstanceId;
	}
	
	static public function getBrix(component : IBrixComponent):Application
	{
		return Application.get(component.brixInstanceId);
	}
	
	/**
	 * Checks if there is any missing required attribute on the associated HTML element of this component.
	 * 
	 * @param	the class of the component to check.
	 * @param	the DOM element to check. By default the rootElement.
	 */
	static public function checkRequiredParameters( cmpClass : Class<Dynamic> , elt:HtmlDom ) : Void
	{
		var requires = haxe.rtti.Meta.getType(cmpClass).requires;
		
		if (requires == null)
			return;

		for (r in requires)
		{
			if ( elt.getAttribute( Std.string(r) ) == null || StringTools.trim( elt.getAttribute( Std.string(r) ) ) == "" )
			{
				throw Std.string(r) + " parameter is required for "+Type.getClassName(cmpClass);
			}
		}
	}
}
