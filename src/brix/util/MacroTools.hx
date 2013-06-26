/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.util;

import haxe.macro.Type;
import cocktail.html.HtmlElement;


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
	static public function getLineNumber(elt:HtmlElement) : Int
	{
		if (elt.parentNode == null)
			return 0;
		
		var parent:HtmlElement = elt.parentNode;
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