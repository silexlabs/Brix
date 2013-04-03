/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.list;

import js.Dom;
import haxe.Http;
import haxe.Timer;

import brix.component.navigation.Layer;

/**
 * load xml data, parse it and dispatch an event for the consumers
 */
class XmlConnector extends ConnectorBase
{
	
	/**
	 * The rss root node
	 */
	private var dataRootNode:String = "";
	
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		init();
	}
	
	/**
	 * init
	 */ 
	override public function init():Void
	{
		if (rootElement.getAttribute(ConnectorBase.ATTR_ROOT) != null) {
			dataRootNode = rootElement.getAttribute(ConnectorBase.ATTR_ROOT);
		}
	}
	
	/**
	 * callback for the http request
	 */ 
	override public function onData(data:String)
	{
		if (isPolling && pollingFreq!=null && pollingFreq>0)
		{
			Timer.delay(callback(loadData, null), pollingFreq);
		}
		// small optim
		if (data == latestData)
		{
			//trace("no new data");
			return;
		}
		else
		{
			//trace("new data ");
			//trace(rootElement.className);
		}
		latestData = data;
		// parse string to xml
		var objectData = {};
		try
		{
			objectData = Xml2Dynamic(Xml.parse(data));
		}
		catch(e:Dynamic)
		{
			trace("Error parsing xml string \""+data+"\". Error message: "+e);
		}

		// get data root
		if (objectData!=null)
		{
			if (dataRootNode!=null)
			{
				try
				{
					var path = dataRootNode.split(".");
					for (idx in 0...path.length)
					{
						var objName = path[idx];
						objectData = Reflect.field(objectData, objName);
					}
				}
				catch(e:Dynamic)
				{
					trace("Error while looking for the data root object \""+dataRootNode+"\" in \""+data+"\". Error message: "+e);
				}
			}
			onDataReceived(objectData);
			trace(objectData);
		}
		else
		{
			// todo: dispatch an error event
			trace("Warning: no data received.");
		}
	}
	
	/**
	*  This method takes an XML, removes white spaces, indent & comments, and then return the XML.
	*  For now it just calling the equivalent recursive method.
	*  It is better to have two methods for recursive algorithms, one to initialise recursion, the other for recursion
	*/
	public static function cleanUp(xml:Xml) : Xml
	{
		// duplicate input xml to avoid changing input xml data
		var xmlCopy:Xml = Xml.parse(xml.toString()).firstElement();
		
		// return value
		// if xml is not null, call cleanUpRecursive
		if (xmlCopy != null)
		{
			return cleanUpRecursive(xmlCopy);
		}
		// else return input xml (returning null creates type conflicts
		else
		{
			return xml;
		}
	}
	
	/**
	*  This method takes an XML, removes white spaces, indent & comments, and then return the XML. To be called by cleanUp(xml) and not directly.
	*/
	private static function cleanUpRecursive(xml:Xml) : Xml
	{
		var whiteSpaceValues:Array<String> = ["\n","\r","\t"];
		var childData:Xml = null;
		var child:Xml = null;
		// create root element
		var cleanedXml:Xml = null;


		// depending on the xml root node type, create cleanedXml with the corresponding type 
		switch (xml.nodeType)
		{
			case Xml.Document:
				cleanedXml = Xml.createDocument();
			
			case Xml.Element:
				cleanedXml = Xml.createElement(xml.nodeName);
				for (attrib in xml.attributes())
				{
					cleanedXml.set(attrib, xml.get(attrib));
				}
		}

		// iterate on all children
		for ( child in xml ) {
			// case child node is element ie. a child node but not data
			switch (child.nodeType)
			{
				// case child node is element: recursive loop on elements
				case Xml.Element:
				childData = cleanUpRecursive(child);
				cleanedXml.addChild(childData);
					
				// case child node is Comment, do not add it to the cleanedXml
				//   => not working for PHP target, issue sent to Haxe mailing list, cf. workaround below
				case Xml.Comment:

				// case child node is CData or PCData
				default:
				// set noValue to child's nodeValue
				var nodeValue:String = child.nodeValue;

				//  if value is Comment, do not add it to the cleanedXml => workaround as issue with Haxe getting Xml.Comment type
				if ( (nodeValue.substr(0,4) == '<!--') && (nodeValue.substr(-3) == '-->') )
				{
					nodeValue = '';
				}		

				// removes ramaning white spaces, ie. text formatting (uneeded spaces)
				nodeValue = StringTools.ltrim(nodeValue);
				
				// value is cleaned in case it is not "real" value but indenting (\n and \t)
				// remove white spaces, ie. text formatting (indent and carrier return)
				for (whiteSpace in whiteSpaceValues)
				{
					nodeValue = StringTools.replace(nodeValue, whiteSpace, "");
				}

				// if cleaned value is not empty, add it to the cleanedXml
				if (nodeValue != "")
				{
					var duplicatedXml : Xml;
					duplicatedXml = null;
					switch(child.nodeType)
					{
						case Xml.PCData:
							duplicatedXml = Xml.createPCData(nodeValue);
						case Xml.CData:
							duplicatedXml = Xml.createCData(nodeValue);
					}

					cleanedXml.addChild(duplicatedXml);
				}
			}
		}

		return cleanedXml;
	}
	
	/**
	*  This method takes an XML object and returns the equivalent Dynamic.
	* 
	* input:	a Xml
	* output:	a dynamic
	* 
	*/
	public static function Xml2Dynamic(xml:Xml) : Dynamic
	{
		// set start node & remove white spaces
		var firstElement:Xml = cleanUp(xml);

		// call recursive loop
		var generatedXml:Dynamic = xml2DynamicRecursive(firstElement,firstElement.nodeName.toLowerCase() == 'rss');
		
		return generatedXml;
	}

	/**
	*  This method takes an XML object and returns the equivalent Dynamic.
	*  To be called by xml2StringIndent(xml) and not directly.
	* 
	* input:	a Xml
	* output:	a dynamic
	* 
	*/
	private static function xml2DynamicRecursive(xml:Xml, isRss:Bool) : Dynamic
	{
		// return value
		var xmlAsDynamic:Dynamic = {};
		var whiteSpaceValues:Array<String> = ["\n","\r","\t"];

		// value (ie. the first child, hopefully !)
		if (xml.firstChild() != null)
		{
			// if type is PCData, return value
			// in that case, no attributes values and children informations are returned
			if (xml.firstChild().nodeType == Xml.PCData || xml.firstChild().nodeType == Xml.CData)
			{
				var nodeStrValue:String = "";
				for(node in xml)
				{
						nodeStrValue = node.nodeValue;
				}
				
				// escape the string, useful for the rss description node which is often using html entities.
				// the &quot part is used as it is not correctly escaped in Haxe 2.10
				//return StringTools.htmlUnescape(nodeStrValue).split("&quot;").join('"');
				return nodeStrValue;
			}
		}
		
		// attributes
		// initialise attributes
		if(xml.attributes().hasNext() == true) {
			xmlAsDynamic.attributes = { };
		}
		for (attrib in xml.attributes())
		{
			// store attribute data
			Reflect.setField(xmlAsDynamic.attributes, attrib, xml.get(attrib));
		}
			
		// children
		// children information are added directly to xmlAsDynamic
		var childData:Dynamic = null;
		// nodeValues is an Array used to store the values of the children having the same nodeName.
		// assumption is that in this case, all the children have the same nodeName
		// TODO => assumption not correct as not working with RSS format => to be corrected
		var nodeValues:Array<Dynamic> = new Array<Dynamic>();
		var processedNodeNames:Array<Dynamic> = new Array<String>();
		var processed:Bool = false;
		var iteration:Int = 0;
		// iterate on all children
		for( child in xml ) {
			// case child node is element ie. a child node but not data
			if (child.nodeType == Xml.Element)
			{
				// checks if the child's nodeName has already been processed
				for (name in processedNodeNames)
				{
					if (child.nodeName == name)
					{
						processed = true;
						// exit for loop
						break;
					}
				}
				
				// if this child's nodeName has not already been processed
				if (!processed)
				{
					// adds the child's nodeName to processedNodeNames
					processedNodeNames.push(child.nodeName);
					
					// Check how many iterations are existing with the same child's nodeName
					iteration = 0;
					for ( currentChild in xml )
					{
						if (child.nodeName == currentChild.nodeName)
						{
							// recursive call. Resulting Dynamic is stored in childData
							childData = xml2DynamicRecursive(currentChild,isRss);

							// childData is pushed to nodeValues Array
							nodeValues.push(childData);

							iteration++;
						}
					}
					// if there are multiple child having the same node name, or if xml is a Rss and nodeName is item, add nodeValues array
					if ( (iteration != 1) || (isRss && (child.nodeName=='item')) )
					{
						// Xml2Dynamic's child.nodeName field is setted to nodeValues' array 
						Reflect.setField(xmlAsDynamic, child.nodeName, nodeValues);
					}
					// if there is only one child having the same node name, add childData (no array)
					else
					{
						// Xml2Dynamic's child.nodeName field is setted to childData value 
						Reflect.setField(xmlAsDynamic, child.nodeName, childData);
					}
					// reset nodeValues array
					nodeValues = new Array<String>();
				}
			}
		}
		
		return xmlAsDynamic;
	}
}