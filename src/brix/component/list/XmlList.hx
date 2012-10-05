/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.list;

import js.Lib;
import js.Dom;
import brix.component.list.List;
import brix.util.DomTools;

/**
 * list component with XML as an input
 * takes the XML in the attributes o the node
 * convert the XML into an object tree in the data provider
 */
class XmlList extends List<Xml>
{
	static inline var ATTR_ITEMS:String = "data-items";
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		var attr = rootElement.getAttribute(ATTR_ITEMS);
		var xmlData:Xml = Xml.parse(StringTools.htmlUnescape(attr));
		dataProvider = [];
		for (item in xmlData.elements())
		{
			dataProvider.push(xmlToObj(item));
		}
		trace("dataProvider = "+dataProvider);
	}
	/**
	 * init the component
	 * get elements by class names 
	 * you can now initialize the process of refreshing the list by calling redraw()
	 */
	override public function init() : Void
	{ 
		redraw();
		// init the parent class
		super.init();
	}
	private function xmlToObj(xml:Xml):Dynamic
	{
		var res:Dynamic = {};
		for (item in xml.iterator())
		{
			if ( item.nodeType == Xml.PCData 
				|| item.nodeType == Xml.CData
					|| item.nodeType == Xml.Prolog )
			{
				return item.nodeValue;
			}
			else
			{
				Reflect.setField(res, item.nodeName, xmlToObj(item));
			}
		}
		return res;
	}
}