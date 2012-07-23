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
package org.slplayer.util;

import haxe.macro.Type;

import cocktail.Dom;

/**
 * Helper tools for macros.
 * 
 * @author Thomas Fétiveau
 */
class MacroTools 
{
	/**
	 * Tells if a given ClassType implements or extends or is <fullName>.
	 * 
	 * @param	classType, the classType to check.
	 * @param	fullName, the full name of the class or interface to compare to.
	 * @return	true if classType extends, implements or is fullname.
	 */
	static public function is( classType : haxe.macro.ClassType , fullName : String ) : Bool
	{
		if ( classType.pack.join(".") + "." + classType.name == fullName )
		{
			return true;
		}
		
		for ( i in classType.interfaces )
		{
			if ( i.t.get().pack.join(".")+"."+i.t.get().name == fullName )
			{
				return true;
			}
		}
		
		if ( classType.superClass != null )
		{
			return is(classType.superClass.t.get(), fullName);
		}
		
		return false;
	}
	
	/**
	 * Gets the line number of a given node in the HTML file in memory.
	 * 
	 * @return the line number of the node's position.
	 */
	static public function getLineNumber(elt:HtmlDom) : Int
	{
		if (elt.parentNode == null)
			return 0;
		
		var parent:HtmlDom = elt.parentNode;
		var count = 0;
		
		for ( i in 0...parent.childNodes.length )
		{
			var child = parent.childNodes[i];
			
			if ( elt == child )
				return count + getLineNumber(parent); 
			
			switch (child.nodeType)
			{
				//FIXME Use constants (add to Dom.hx ?)
				case 1: // Node.ELEMENT_NODE
					
					count += child.innerHTML.split('\n').length - 1;
					
				case 3: // Node.TEXT_NODE
					
					count += child.nodeValue.split('\n').length - 1;
			}
		}
		
		throw 'error parsing DOM tree';
	}
}