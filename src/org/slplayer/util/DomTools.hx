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

import js.Lib;
import js.Dom;

/**
 * Some additional DOM functions extending the standard ones.
 * 
 * @author Thomas Fétiveau
 */
class DomTools 
{
	/**
	 * Search for all children elements of the given element that have the given attribute with the given value. Note that you should
	 * avoid to use any non standard methods like this one to select elements as it's much less efficient than the standard ones 
	 * implemented right into the browsers for the js target (like getElementById or getElementsByClassname).
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
	
	/**
	 * Retrieve an element with the given css class in the dom
	 * The element is supposed to be the only one with this css class
	 * If the element is not found, returns null or throws an error, depending on the param "required"
	 */
	public static function getSingleElement(rootElement:HtmlDom, className:String, required:Bool = true):Null<HtmlDom>
	{
		var domElements = rootElement.getElementsByClassName(className);
		
		if (domElements != null && domElements.length == 1)
		{
			return domElements[0];
		}
		else
		{
			if (required)
				throw("Error: search for the element with class name \""+className+"\" gave "+domElements.length+" results");
			
			return null;
		}
	}
	
	/**
	 * for debug purpose
	 * trace the properties of an object
	 */
	public static function inspectTrace(obj:Dynamic):Void
	{
		for (prop in Reflect.fields(obj))
		{
			trace("- "+prop+" = "+Reflect.field(obj, prop));
		}
	}
	
	/**
	 * add a css class to a node if it is not already in the class name
	 */
	static public function toggleClass(element:HtmlDom, className:String) 
	{
		if(hasClass(element, className))
			removeClass(element, className);
		else
			addClass(element, className);
	}
	
	/**
	 * add a css class to a node if it is not already in the class name
	 */
	static public function addClass(element:HtmlDom, className:String)
	{
		if(!hasClass(element, className))
			element.className += " "+ className;
	}
	
	/**
	 * remove a css class from a node 
	 */
	static public function removeClass(element:HtmlDom, className:String)
	{
		if(hasClass(element, className))
			element.className = StringTools.replace(element.className, className, "");
	}
	
	/**
	 * check if the node has a given css class
	 */
	static public function hasClass(element:HtmlDom, className:String)
	{
		return element.className.indexOf(className) > -1;
	}
	/**
	 * Set the value of a given HTML head/meta tags
	 * @param	name 			the value of the name attribute of the desired meta tag
	 * @param	metaValue 			the value to apply to the meta tag
	 * @param	attributeName 	the name of the attribute, of which to return the value
	 * @example	DomTools.setMeta("description", "A 1st test of Silex publication"); // set the description of the HTML page found in the head tag, i.e. <META name="description" content="A 1st test of Silex publication"></META>
	 */
	static public function setMeta(metaName:String, metaValue:String, attributeName:String="content"):Hash<String>{
		var res:Hash<String> = new Hash();
		//trace("setConfig META TAG "+metaName+" = " +metaValue);

		// retrieve all config tags (the meta tags)
		var metaTags:HtmlCollection<HtmlDom> = Lib.document.getElementsByTagName("META");

		// flag to check if metaName exists
		var found = false;

		// for each config element, store the name/value pair
		for (idxNode in 0...metaTags.length){
			var node = metaTags[idxNode];
			var configName = node.getAttribute("name");
			var configValue = node.getAttribute(attributeName);
			if (configName!=null && configValue!=null){
				if(configName == metaName){
					configValue = metaValue;
					node.setAttribute(attributeName, metaValue);
					found = true;
				}
				res.set(configName, configValue);
			}
		}
		// add the meta if needed
		if (!found){
			var node = Lib.document.createElement("meta");
			node.setAttribute("name", metaName);
			node.setAttribute("content", metaValue);
			var head = Lib.document.getElementsByTagName("head")[0];
			head.appendChild(node);
			// update config
			res.set(metaName, metaValue);
		}

		return res;
	}
	/**
	 * Get the value of a given HTML head/meta tags
	 * @param	name 			the value of the name attribute of the desired meta tag
	 * @param	attributeName 	the name of the attribute, of which to return the value
	 * @example	DomTools.getMeta("description", "content"); // returns the description of the HTML page found in the head tag, e.g. <META name="description" content="A 1st test of Silex publication"></META>
	 */
	static public function getMeta(name:String, attributeName:String="content"):Null<String>{
		// retrieve all config tags (the meta tags)
		var metaTags:HtmlCollection<HtmlDom> = Lib.document.getElementsByTagName("meta");

		// for each config element, store the name/value pair
		for (idxNode in 0...metaTags.length){
			var node = metaTags[idxNode];
			var configName = node.getAttribute("name");
			var configValue = node.getAttribute(attributeName);
			if (configName==name)
				return configValue;
		}
		return null;
	}
	/**
	 * Add a css tag with the given CSS rules in it
	 * @param	css 			String containing the CSS rules
	 */
	static public function addCssRules(css:String):StyleSheet{
		var node = Lib.document.createElement('style');
		node.setAttribute('type', 'text/css');
		node.appendChild(Lib.document.createTextNode(css));

		Lib.document.getElementsByTagName("head")[0].appendChild(node);

		return cast(node);
	}
	/**
	 * Add a script tag with the given src param
	 * @param	src 			String containing the URL of the script to embed
	 */
	static public function embedScript(src:String):HtmlDom{
		var node = Lib.document.createElement("script");
		node.setAttribute("src", src);
		
		var head = Lib.document.getElementsByTagName("head")[0];
		head.appendChild(node);

		return cast(node);
	}
}