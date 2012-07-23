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
package org.slplayer.core;

/**
 * A class grouping together util functions to handle SLPlayer components.
 * @author Thomas Fétiveau
 */
class SLPlayerComponentTools 
{
	/**
	 * Checks if there is any missing required attribute on the associated HTML element of this component.
	 * @param	the class of the component to check.
	 * @param	the DOM element to check. By default the rootElement.
	 */
	static public function checkRequiredParameters( cmpClass : Class<Dynamic> , elt:js.Dom.HtmlDom ) : Void
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
	
	/**
	 * Determine a class tag value for a component that won't be conflicting with other components.
	 * 
	 * @param	displayObjectClassName
	 * @param 	an Iterator of Strings containing the classnames we check against.
	 * @return	a tag class value for the given component class name that will not conflict with other components classnames / class tags.
	 */
	static public function getUnconflictedClassTag(displayObjectClassName : String , registeredComponentsClassNames:Iterator<String>) : String
	{
		var classTag = displayObjectClassName;
		
		if (classTag.indexOf(".") != -1)
			classTag = classTag.substr(classTag.lastIndexOf(".") + 1);
		
		while (registeredComponentsClassNames.hasNext())
		{
			var registeredComponentClassName = registeredComponentsClassNames.next();
			
			if (registeredComponentClassName != displayObjectClassName && classTag == registeredComponentClassName.substr(classTag.lastIndexOf(".") + 1))
			{
				return displayObjectClassName;
			}
		}
		
		return classTag;
	}
}