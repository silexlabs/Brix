/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.list;

/**
 * load rss data, parse it and dispatch an event for the consumers
 * 
 * @author Raphael Harmel
 */

import js.Dom;
import js.Lib;

class RssConnector extends ConnectorBase
{
	/**
	 * Parse RSS String to object
	 * 
	 * @param	data
	 * @return
	 */
	override public function parseData2Object(data:String):Dynamic
	{
		return rss2object(Xml.parse(data));
	}
	
	/**
	 * Converts a rss to an Array of object
	 * 
	 * @param	rss
	 * @return
	 */
	public static function rss2object(rss:Xml):Dynamic
	{
		// init items Array
		var items:Array<Dynamic> = new Array<Dynamic>();

		// set channel node
		var channelNode:Xml = rss.firstElement().firstElement();
		
		// exit if no data
		if (channelNode == null)
			return items;
		
		// get the rss data
		for ( channelChild in channelNode.elements() )
		{
			if (channelChild.nodeName == "item")
			{
				var item:Dynamic = {};
				
				// for each node
				for (itemParam in channelChild.elements())
				{
					// Build the item object. Only add data for nodes having value. The try/catch is used for this.
					try {
						Reflect.setField(item, itemParam.nodeName, itemParam.firstChild().nodeValue);
					}
					catch(e:Dynamic) {
						//trace("No rss value for " + itemParam.nodeName + ". Error message: " + e);
					}
				}
				
				// add item to item array
				items.push(item);
			}
		}

		return items;
	}
	
}
