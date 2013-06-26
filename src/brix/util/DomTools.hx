/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.util;

using StringTools;
import js.html.HtmlElement;
import js.html.NodeList;
import js.Browser;
import haxe.ds.StringMap;

typedef BoundingBox = {
	x:Int,
	y:Int,
	w:Int,
	h:Int,
}
/**
 * As no constant is defined in haxe/js...
 */
class NodeTypes
{
    public static inline var ELEMENT_NODE:Int 					= 1;
	public static inline var ATTRIBUTE_NODE:Int 				= 2;
	public static inline var TEXT_NODE:Int 						= 3;
	public static inline var CDATA_SECTION_NODE:Int 			= 4;
	public static inline var ENTITY_REFERENCE_NODE:Int 			= 5;
	public static inline var ENTITY_NODE:Int 					= 6;
	public static inline var PROCESSING_INSTRUCTION_NODE:Int 	= 7;
	public static inline var COMMENT_NODE:Int 					= 8;
	public static inline var DOCUMENT_NODE:Int 					= 9;
	public static inline var DOCUMENT_TYPE_NODE:Int 			= 10;
	public static inline var DOCUMENT_FRAGMENT_NODE:Int 		= 11;
	public static inline var NOTATION_NODE:Int 					= 12;
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
	 * @param 	frames	Optional - number of frames to skip, default is 1
	 */
	static public function doLater(callbackFunction:Void->Void, ?frames:Int=1)
	{
		var frameInterval = 200;
#if (flash || nme || js)
		// interval between frames in ms
		haxe.Timer.delay(callbackFunction, frames*frameInterval);
#else // php for example
		callbackFunction();
#end
	}
	/**
	 * convert into relative url
	 */
	static public function abs2rel(url:String):String
	{
		// store the initial value of url
		var initialUrl = url;

		// value for base is the document or the base tag
		var base = getBaseUrl();

		// **
		// remove http
		var idx = base.indexOf("://");
		// check that we have absolute urls
		if (idx == -1)
		{
			trace("Warning, could not make URL relative because base URL is relative and should be absolute - could not find pattern \"://\" in "+base+". Now returns "+initialUrl);
			return initialUrl;
		}
		else
		{
			base = base.substr(idx+3);
		}
		var idx = url.indexOf("://");
		// check that we have absolute urls
		if (idx == -1)
		{
			//trace("Warning, could not make URL relative because it is relative already - could not find pattern \"://\". Now returns "+initialUrl);
			return initialUrl;
		}
		else
		{
			url = url.substr(idx+3);
		}


		// split base url
		var baseArray = base.split("/");
		// split url
		var urlArray = url.split("/");

		// check that there is a common domain name
		if (baseArray[0] != urlArray[0])
		{
			//trace("Warning, could not make URL relative because the url is absolute external url - "+urlArray[0]+" != "+baseArray[0]+". Now returns initial URL "+initialUrl);
			// the url is absolute external url
			return initialUrl;
		}

		// **
		// find the common parts in both base and url
		var diffIdx = 0;
		for (idx in 0...baseArray.length)
		{
			if (urlArray.length < idx || baseArray[idx] != urlArray[idx]){
				// at this point, URLs are different
				diffIdx = idx;
				break;
			}
		}
		// **
		// build the final result
		var resUrl = "";
		// add "../"
		if (baseArray.length>diffIdx+1)
		{
			for (idx in diffIdx...baseArray.length-1){
				resUrl += "../";
			}
		}
		else{
			// todo: decide if we should add a ./ when needed
			//resUrl = "./";
		}
		// add everything after the common part
		for (idx in diffIdx...urlArray.length){
			resUrl += urlArray[idx];
			// only if it is not the file name
			if (idx != urlArray.length-1)
			{
				resUrl += "/";
			}
		}
		return resUrl;
	}
	/**
	 * convert into absolute url
	 * duplicated from cocktail.core.history.History
	 * 
	 * handle the .. in relative urls, take the base tag into account
	 * todo: do it right like described here http://dev.w3.org/html5/spec/single-page.html#fallback-base-url
	 */
	static public function rel2abs(url:String, base:Null<String>=null):String
	{
		// default value for base is the document 
		// todo: do it right like described here (with case of iframe abd about:blank) http://dev.w3.org/html5/spec/single-page.html#fallback-base-url
		if (base == null)
		{
			base = getBaseUrl();
		}
		// replace all "\" by "/" in url
		url = StringTools.replace(url, "\\", "/");

		// add base to url if needed
		var idxBase = url.indexOf("://");
		if (idxBase == -1)
		{
			url = base+url;
		}

		// resolve the ".."
		var urlArray = url.split("/");
		var absoluteUrlArray = new Array();
		for (idx in 0...urlArray.length)
		{
			// check if this is a ".."
			if (urlArray[idx]==".."){
				// removes the last element of the final array
				absoluteUrlArray.pop();
			}
			else{
				// add the path element to the final array
				absoluteUrlArray.push(urlArray[idx]);
			}
		}
		url = absoluteUrlArray.join("/");

		// return the absolute url
		return url;
	}
	/**
	 * Search for all children elements of the given element that have the given attribute with the given value. Note that you should
	 * avoid to use any non standard methods like this one to select elements as it's much less efficient than the standard ones 
	 * implemented right into the browsers for the js target (like getElementById or getElementsByClassname).
	 * @param	elt the DOM element
	 * @param	attr the attr name to search for
	 * @param	value the attr value to search for, specifying '*' means "any value"
	 * @return an Array<HtmlElement>
	 */
	static public function getElementsByAttribute(elt : HtmlElement, attr:String, value:String):Array<HtmlElement>
	{
		var childElts = elt.getElementsByTagName('*');
		var filteredChildElts:Array<HtmlElement> = new Array();
		
		for (cCount in 0...childElts.length)
		{
			var child : HtmlElement = cast childElts[cCount];
			if ( child.getAttribute(attr)!=null && ( value == "*" || child.getAttribute(attr) == value) )
                filteredChildElts.push(child);
		}
		return filteredChildElts;
	}
	
	/**
	 * Retrieve an element with the given css class in the dom
	 * The element is supposed to be the only one with this css class
	 * If the element is not found, returns null or throws an error, depending on the param "required"
	 */
	public static function getSingleElement(rootElement:HtmlElement, className:String, required:Bool = true):Null<HtmlElement>
	{
		var domElements = rootElement.getElementsByClassName(className);
		
		if (domElements.length > 1)
		{
			throw("Error: search for the element with class name \""+className+"\" gave "+domElements.length+" results");
		}
		if (domElements != null && domElements.length == 1)
		{
			return cast domElements[0];
		}
		else
		{
			if (required)
				throw("Error: search for the element with class name \""+className+"\" gave "+domElements.length+" results");
			
			return null;
		}
	}
	/**
	 * Compute the HtmlElement element size and position, taking margins, paddings and borders into account, and also the parents ones
	 * @param	htmlElement 	HtmlElement element of which we want to know the size 
	 * @return 	the BoundingBox object
	 */
	static public function getElementBoundingBox(htmlElement:HtmlElement):BoundingBox{
		if (htmlElement.nodeType != 1)
			return null;

		// add the scroll offset of all container
		// and the position of all positioned ancecestors
		var offsetTop = 0;
		var offsetLeft = 0;
		var offsetWidth = 0.0;
		var offsetHeight = 0.0;
		var element = htmlElement;
		while (element != null
			//&& element.tagName.toLowerCase() != "body" 
			//&& element.style.position != "relative" && element.style.position != "absolute" && element.style.position != "fixed"
			){
			var borderH = (element.offsetWidth - element.clientWidth)/2;
			var borderV = (element.offsetHeight - element.clientHeight)/2;

			offsetWidth += borderH;
			offsetHeight += borderV;
			offsetWidth -= borderH;
			offsetHeight -= borderV;

			offsetTop -= Math.round(borderV/2.0);
			offsetLeft -= Math.round(borderH/2.0);

			offsetTop -= element.scrollTop;
			offsetLeft -= element.scrollLeft;

			offsetTop += element.offsetTop;
			offsetLeft += element.offsetLeft;

			element = cast element.offsetParent;
		}

		return {
			x:Math.round(offsetLeft),
			y:Math.round(offsetTop),
			w:Math.round(htmlElement.offsetWidth + offsetWidth),
			h:Math.round(htmlElement.offsetHeight + offsetHeight)
		};
	}
	/**
	 * retrieve the postion of a node in its parent's children
	 */
	public static function getElementIndex(childNode:HtmlElement):Int
	{
		var i = 0;
		var child = childNode;
		while((child = cast child.previousSibling) != null ) 
			i++;
		return i;
	}
	/**
	 * position the given element at the given position
	 * apply an offest instead of an absolut position, in order to handle the case of the container being position absolute or relative
	 * @param 	htmlElement 	the elment to move
	 * @param 	x 			the position in the window global coordinate system
	 * @param 	y 			the position in the window global coordinate system
	 */
	static public function moveTo(htmlElement: HtmlElement, x:Null<Int>, y:Null<Int>) 
	{
		// retrieve the bounding boxes
		var elementBox = DomTools.getElementBoundingBox(htmlElement);

		if (x != null){
			// apply the offset between the 2 positions
			var newPosX = htmlElement.offsetLeft + (x - elementBox.x);
			// move the element to the position
			htmlElement.style.left = Math.round(newPosX) + "px";
		}
		if (y != null){
			// apply the offset between the 2 positions
			var newPosY = htmlElement.offsetTop + (y - elementBox.y);
			// move the element to the position
			htmlElement.style.top = Math.round(newPosY) + "px";
		}
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
	static public function toggleClass(element:HtmlElement, className:String) 
	{
		if(hasClass(element, className))
			removeClass(element, className);
		else
			addClass(element, className);
	}

	/**
	 * Adds a css class to a node if it is not already in the class name.
	 * @param the DOM element to consider.
	 * @param the class name(s) to add.
	 */
	static public function addClass(element:HtmlElement, className:String):Void
	{
		if (element.className == null) element.className = "";

		Lambda.iter( className.split(" "), function(cn:String) { if (!Lambda.has(element.className.split(" "), cn)) { if (element.className != "") { element.className += " "; } element.className += cn; } } );
	}

	/**
	 * Removes a/several css class(es) from a DOM node.
	 * @param the DOM element to consider.
	 * @param the class name(s) to remove. Several class names can be passed, separated by a white space, ie: "myClass1 myClass2".
	 */
	static public function removeClass(element:HtmlElement, className:String):Void
	{
		if (element.className == null || element.className.trim() == "") return;

		var classNamesToKeep:Array<String> = new Array();
		var cns = className.split(" ");

		Lambda.iter( element.className.split(" "), function(ecn:String) { if (!Lambda.has(cns, ecn)) { classNamesToKeep.push(ecn); } } );

		element.className = classNamesToKeep.join(" ");
	}

	/**
	 * Checks if the node has a given css class. Use the orderedClassName param if you want to search for class names in a specific
	 * order.
	 * @param the DOM element to consider
	 * @param the class name to search for. It can be several class names seperated by spaces like: "myClass1 myClass2"
	 * @param in case several class names are passed, set this to true will tell the hasClass function to search for the class names
	 * in the order they've been passed to it. ie: <div class="class2 class1"></div> => hasClass(node, "class1 class2") => true
	 * 																				 => hasClass(node, "class1 class2", true) => false
	 * 																				 => hasClass(node, "class2 class1", true) => true
	 * @return true if className found, else false.
	 */
	static public function hasClass(element:HtmlElement, className:String, ?orderedClassName:Bool=false):Bool
	{
		if (element.className == null || element.className.trim() == "" || className == null || className.trim() == "") return false;

		if (orderedClassName)
		{
			var cns:Array<String> = className.split(" ");
			var ecns:Array<String> = element.className.split(" ");

			var result:List<Int> = Lambda.map( cns, function (cn:String) { return Lambda.indexOf(ecns, cn); } );
			var prevR:Int = 0;
			for (r in result)
			{
				if (r < prevR)
				{
					return false;
				}
				prevR = r;
			}
			return true;
		}
		else
		{
			for (cn in className.split(" "))
			{
				if (cn == null || cn.trim() == "")
				{
					continue;
				}
				var found:Bool = Lambda.has(element.className.split(" "), cn);

				if (!found)
				{
					return false;
				}
			}
			return true;
		}
	}

	/**
	 * Set the value of a given HTML head/meta tags
	 * @param	name 			the value of the name attribute of the desired meta tag
	 * @param	metaValue 			the value to apply to the meta tag
	 * @param	attributeName 	the name of the attribute, of which to return the value
	 * @example	DomTools.setMeta("description", "A 1st test of Silex publication"); // set the description of the HTML page found in the head tag, i.e. <META name="description" content="A 1st test of Silex publication"></META>
	 */
	static public function setMeta(metaName:String, metaValue:String, attributeName:String="content", head:HtmlElement=null):StringMap<String>{
		var res:StringMap<String> = new StringMap();

		// default value for document
		if (head == null) 
			head = cast Browser.document.documentElement.getElementsByTagName("head")[0]; 

		// retrieve all config tags (the meta tags)
		var metaTags:NodeList = head.getElementsByTagName("META");

		// flag to check if metaName exists
		var found = false;

		// for each config element, store the name/value pair
		for (idxNode in 0...metaTags.length){
			var node : HtmlElement = cast metaTags[idxNode];
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
			var node = Browser.document.createElement("meta");
			node.setAttribute("name", metaName);
			node.setAttribute("content", metaValue);
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
	static public function getMeta(name:String, attributeName:String="content", head:HtmlElement=null):Null<String>{
		// default value for document
		if (head == null) 
			head = cast Browser.document.documentElement.getElementsByTagName("head")[0]; 

		// retrieve all config tags (the meta tags)
		var metaTags:NodeList = head.getElementsByTagName("meta");

		// for each config element, store the name/value pair
		for (idxNode in 0...metaTags.length){
			var node : HtmlElement = cast metaTags[idxNode];
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
	 * @param	head 		An optional HtmlElement which is the <head> tag of the document. Default: use Browser.document.getElementsByTagName("head") to retrieve it
	 * @returns the created node for the css style tag
	 */
	static public function addCssRules(css:String, head:HtmlElement=null):HtmlElement{
		// default value for document
		if (head == null) 
			head = cast Browser.document.documentElement.getElementsByTagName("head")[0]; 
		
		var node = Browser.document.createElement('style');
		node.setAttribute('type', 'text/css');
		node.appendChild(Browser.document.createTextNode(css));

		head.appendChild(node);
		return cast(node);
	}
	/**
	 * Add a script tag with the given src param
	 * @param	src 			String containing the URL of the script to embed
	 */
	static public function embedScript(src:String):HtmlElement{
		var head = Browser.document.getElementsByTagName("head")[0];
		var scriptNodes = Browser.document.getElementsByTagName("script");
		for (idxNode in 0...scriptNodes.length){
			var node : HtmlElement = cast scriptNodes[idxNode];
			if(node.getAttribute("src") == src){
				return node;
			}
		}
		var node = Browser.document.createElement("script");
		node.setAttribute("src", src);
		head.appendChild(node);

		return cast(node);
	}
	/**
	 * Get the html page base tag
	 */
	public static function getBaseTag():Null<String>{
		var baseNodes = Browser.document.getElementsByTagName("base");
		if (baseNodes.length > 0){
			return cast(baseNodes[0]).getAttribute("href");
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
		var head = Browser.document.getElementsByTagName("head")[0];
		var baseNodes = Browser.document.getElementsByTagName("base");

		href = DomTools.rel2abs(href);
		if (baseNodes.length > 0){
			trace("Warning: base tag already set in the head section. Current value (\""+cast(baseNodes[0]).getAttribute("href")+"\") will be replaced by \""+href+"\"");
			cast(baseNodes[0]).setAttribute("href", href);
		}
		else{
			var node = Browser.document.createElement("base");
			node.setAttribute("href", href);
			if (head.childNodes.length>0)
				head.insertBefore(node, head.childNodes[0]);
			else
				head.appendChild(node);
		}
	}
	/**
	 * Remove the base tag
	 */
	public static function removeBaseTag(){
		// browse all tags in the head section and check if it a base tag is already set
		var baseNodes = Browser.document.getElementsByTagName("base");
		while (baseNodes.length > 0){
			baseNodes[0].parentNode.removeChild(baseNodes[0]);
		}
	}
	/**
	 * compute the base url of the document
	 * handle base tag if any, otherwise take the documentlocation
	 */
	public static function getBaseUrl():String
	{
		var base = getBaseTag();
// workaround window.location not yet implemented in cocktail
#if js
		// defaults to the document location
		if (base == null)
		{
			// check if there is a file name in the location, i.e. */*.* pattern 
			var idxSlash = Browser.window.location.href.lastIndexOf("/");
			var idxDot = Browser.window.location.href.lastIndexOf(".");
			if (idxSlash < idxDot) base = base = Browser.window.location.href.substr(0, idxSlash+1);
			else base = Browser.window.location.href;
		}
#end
		return base;
	}
	/**
	 * Test the undefined js value.
	 * @param	value
	 * @return Bool
	 */
	public static inline function isUndefined(value : Dynamic):Bool
	{
	#if js
		var ret:Bool = untyped __js__('"undefined" === typeof value'); // do not remove this variable, it would break the code
		return ret;
	#else
		return false;
	#end
	}

	/**
	 * Cross-browser innerHTML accessor for DOM nodes
	 * @param node HtmlElement
	 * @param optional, a value to set
	 * @return String
	 */
	static public function innerHTML(node:HtmlElement, ?content:String=null):String
	{
#if js
		if (content!=null && node.nodeName == "HTML" && Browser.window.navigator.userAgent.toLowerCase().indexOf("msie")>-1) //IE specific
		{
			content=StringTools.replace(content, "<HEAD>", "<BRIXHEAD>");
			content=StringTools.replace(content, "</HEAD>", "</BRIXHEAD>");
			content=StringTools.replace(content, "<BODY>", "<BRIXBODY>");
			content=StringTools.replace(content, "</BODY>", "</BRIXBODY>");
			var tempNode = Browser.document.createElement("DIV");
			tempNode.innerHTML = content;

			//clean existing DOM tree
			while (node.attributes.length>0)
			{
				node.removeAttribute(node.attributes[0].nodeName);
			}
			var head = node.getElementsByTagName("HEAD");
			if (head.length > 0)
			{
				while (head[0].hasChildNodes())
				{
					head[0].removeChild(head[0].firstChild);
				}
			}
			var bodies = node.getElementsByTagName("BODY");
			if (bodies.length > 0)
			{
				var body : HtmlElement = cast bodies[0];
				while (body.attributes.length>0)
				{
					body.removeAttribute(body.attributes[0].nodeName);
				}
				while (body.hasChildNodes())
				{
					body.removeChild(body.firstChild);
				}
			}

			//assemble new DOM tree
			while (tempNode.attributes.length>0)
			{
				node.setAttribute(tempNode.attributes[0].nodeName, tempNode.attributes[0].nodeValue);
				tempNode.removeAttribute(tempNode.attributes[0].nodeName);
			}
			var tempHead = tempNode.getElementsByTagName("BRIXHEAD");
			var head = node.getElementsByTagName("HEAD");
			if (tempHead.length > 0)
			{
				if (head.length == 0)
				{
					if (node.hasChildNodes())
					{
						node.insertBefore( Browser.document.createElement("HEAD"), node.firstChild );
					}
					else
					{
						node.appendChild( Browser.document.createElement("HEAD") );
					}
				}
				while (tempHead[0].hasChildNodes())
				{
					head[0].appendChild(tempHead[0].removeChild(tempHead[0].childNodes[0]));
				}
			}
			var tempBodies = tempNode.getElementsByTagName("BRIXBODY");
			var bodies = node.getElementsByTagName("BODY");
			if (tempBodies.length > 0)
			{
				if (bodies.length == 0)
				{
					node.appendChild( Browser.document.createElement("BODY") );
				}
				var tempBody : HtmlElement = cast tempBodies[0];
				var body : HtmlElement = cast bodies[0];
				while (tempBody.attributes.length>0)
				{
					body.setAttribute(tempBody.attributes[0].nodeName, tempBody.attributes[0].nodeValue);
					tempBody.removeAttribute(tempBody.attributes[0].nodeName);
				}
				while (tempBody.hasChildNodes())
				{
					body.appendChild(tempBody.removeChild(tempBody.childNodes[0]));
				}
			}
			return node.innerHTML;
		}
#end
		if (content != null)
		{
			node.innerHTML = content;
		}
		return node.innerHTML;
	}	
}