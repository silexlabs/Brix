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

typedef BoundingBox = {
	x:Int,
	y:Int,
	w:Int,
	h:Int,
}

/**
 * Some additional DOM functions extending the standard ones.
 * 
 */
class DomTools 
{
	/**
	 * Call a calback later. This is useful sometimes when dealing with layout, because it needs time to be redrawn
	 * @param 	callbackFunction	The callback function to be called in the next frame
	 */
	static public function doLater(callbackFunction:Void->Void, nFrames:Float=1)
	{
#if php
		callbackFunction();
#else
		haxe.Timer.delay(callbackFunction, Math.round(200*nFrames));
#end
	}
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
		
		if (domElements.length > 1)
		{
			throw("Error: search for the element with class name \""+className+"\" gave "+domElements.length+" results");
		}
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
	 * Compute the htmlDom element size and position, taking margins, paddings and borders into account, and also the parents ones
	 * @param	htmlDom 	HtmlDom element of which we want to know the size 
	 * @return 	the BoundingBox object
	 */
	static public function getElementBoundingBox(htmlDom:HtmlDom):BoundingBox{
		if (htmlDom.nodeType != 1)
			return null;

		//trace("getElementBoundingBox "+htmlDom+" - "+htmlDom.offsetLeft+", "+htmlDom.offsetWidth);


		// add the scroll offset of all container
		// and the position of all positioned ancecestors
		var offsetTop = 0;
		var offsetLeft = 0;
		var offsetWidth = 0.0;
		var offsetHeight = 0.0;
		var element = htmlDom;
		while (element != null
			//&& element.tagName.toLowerCase() != "body" 
			//&& element.style.position != "relative" && element.style.position != "absolute" && element.style.position != "fixed"
			){
			var halfBorderH = (element.offsetWidth - element.clientWidth)/2.0;
			var halfBorderV = (element.offsetHeight - element.clientHeight)/2.0;
			//offsetWidth -= halfBorderH;
			//offsetHeight -= halfBorderV;

			//trace("parent "+element.scrollTop);
			offsetTop -= element.scrollTop;
			offsetLeft -= element.scrollLeft;

			offsetTop += element.offsetTop;
			offsetLeft += element.offsetLeft;

			element = element.offsetParent;
		}

		return {
			x:Math.round(offsetLeft),
			y:Math.round(offsetTop),
			w:Math.round(htmlDom.offsetWidth + offsetWidth),
			h:Math.round(htmlDom.offsetHeight + offsetHeight)
		};
	}

	/**
	 * for debug purpose
	 * trace the properties of an object
	 */
	public static function inspectTrace(obj:Dynamic, callingClass:String):Void
	{
		trace("-- "+callingClass+" inspecting element --");
		for (prop in Reflect.fields(obj))
		{
			trace("- "+prop+" = "+Reflect.field(obj, prop));
		}
		trace("-- --");
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
		if (element.className == null) element.className = "";
		if(!hasClass(element, className)){
			if (element.className != "") element.className += " ";
			element.className += className;
		}
	}
	
	/**
	 * remove a css class from a node 
	 */
	static public function removeClass(element:HtmlDom, className:String)
	{
		if (element.className == null) return;
		if(hasClass(element, className)){
			var arr = element.className.split(" ");
			for (idx in 0...arr.length)
				if (arr[idx] == className)
					arr[idx] = "";
			element.className = arr.join(" ");
		}
		//	element.className = StringTools.replace(element.className, className, "");
	}
	
	/**
	 * check if the node has a given css class
	 * TODO: this is not good since hasClass(element, "Page") would return true for element with className set to "LinkToPage", so split in array and use Lambda 
	 */
	static public function hasClass(element:HtmlDom, className:String)
	{
		if (element.className == null) return false;
		//return element.className.indexOf(className) > -1;
		return Lambda.has(element.className.split(" "), className);
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
	static public function getMeta(name:String, attributeName:String="content", head:HtmlDom=null):Null<String>{
		// default value for document
		if (head == null) 
			head = Lib.document.documentElement.getElementsByTagName("head")[0]; 

		// retrieve all config tags (the meta tags)
		var metaTags:HtmlCollection<HtmlDom> = head.getElementsByTagName("meta");

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
	 * @param	css 		String containing the CSS rules
	 * @param	head 		An optional HtmlDom which is the <head> tag of the document. Default: use Lib.document.getElementsByTagName("head") to retrieve it
	 * @returns the created node for the css style tag
	 */
	static public function addCssRules(css:String, head:HtmlDom=null):HtmlDom{
		// default value for document
		if (head == null) 
			head = Lib.document.documentElement.getElementsByTagName("head")[0]; 
		
		var node = Lib.document.createElement('style');
		node.setAttribute('type', 'text/css');
		node.appendChild(Lib.document.createTextNode(css));

		head.appendChild(node);
		return cast(node);
	}
	/**
	 * Add a script tag with the given src param
	 * @param	src 			String containing the URL of the script to embed
	 */
	static public function embedScript(src:String):HtmlDom{
		var head = Lib.document.getElementsByTagName("head")[0];
		var scriptNodes = Lib.document.getElementsByTagName("script");
		for (idxNode in 0...scriptNodes.length){
			var node = scriptNodes[idxNode];
			if(node.getAttribute("src") == src){
				return node;
			}
		}
		var node = Lib.document.createElement("script");
		node.setAttribute("src", src);
		head.appendChild(node);

		return cast(node);
	}
	/**
	 * Get the html page base tag
	 */
	public static function getBaseTag():Null<String>{
		var head = Lib.document.getElementsByTagName("head")[0];
		var baseNodes = Lib.document.getElementsByTagName("base");
		if (baseNodes.length > 0){
			return baseNodes[0].getAttribute("href");
		}
		else{
			return null;
		}
	}
	/**
	 * Add a base tag with the given href param
	 * @param	href 			String containing the URL of the base for the html page
	 */
	public static function setBaseTag(href:String){
		// browse all tags in the head section and check if it a base tag is already set
		var head = Lib.document.getElementsByTagName("head")[0];
		var baseNodes = Lib.document.getElementsByTagName("base");
		if (baseNodes.length > 0){
			trace("Warning: base tag already set in the head section. Current value (\""+baseNodes[0].getAttribute("href")+"\") will be replaced by \""+href+"\"");
			baseNodes[0].setAttribute("href", href);
		}
		else{
			var node = Lib.document.createElement("base");
			node.setAttribute("href", href);
			node.setAttribute("target", "_self");
			if (head.childNodes.length>0)
				head.insertBefore(node, head.childNodes[0]);
			else
				head.appendChild(node);
		}
	}

}