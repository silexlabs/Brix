package slplayer.util;

import js.Lib;
import js.Dom;

/**
 * ...
 * @author Thomas Fétiveau
 */
class DomTools 
{
	/**
	 * Search for all children elements of the given element that have the given attribute with the given value.
	 * @param	elt the DOM element
	 * @param	attr the attr name to search for
	 * @param	value the attr value to search for, specifying '*' means "any value"
	 * @return an Array<HtmlDom>
	 */
	static public function getElementsByAttribute(elt : HtmlDom, attr:String, value:String):Array<HtmlDom>
	{
		var childElts = elt.getElementsByTagName('*');
		var filteredChildElts:Array<HtmlDom> = new Array();
		
		for (cCount in 0...childElts.length)
		{
			if ( childElts[cCount].getAttribute(attr)!=null && ( value == "*" || childElts[cCount].getAttribute(attr) == value) )
                filteredChildElts.push(childElts[cCount]);
		}
		return filteredChildElts;
	}
	
}