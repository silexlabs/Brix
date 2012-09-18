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
package org.slplayer.component.list;

import js.Lib;
import js.Dom;
import org.slplayer.component.list.List;
import org.slplayer.util.DomTools;

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
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);
		var attr = rootElement.getAttribute(ATTR_ITEMS);
		var xmlData:Xml = Xml.parse(StringTools.htmlUnescape(attr));
		dataProvider = [];
		for (item in xmlData.elements())
		{
			dataProvider.push(xmlToObj(item));
		}
	}
	/**
	 * init the component
	 * get elements by class names 
	 * you can now initialize the process of refreshing the list by calling redraw()
	 */
	override public function init() : Void
	{ 
		// init the parent class
		super.init();
		redraw();
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