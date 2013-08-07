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

import js.html.HtmlElement;


class RssConnector extends ConnectorBase
{
	// process values switch
	private var processVal:Bool = false;
	
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
	public function rss2object(rss:Xml):Dynamic
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
				
				// for each item parameter
				for (itemParam in channelChild.elements())
				{
					// Build the item object. Only add data for nodes having value.
					try {
						if (itemParam.firstChild() != null)
						{
							var key:String = itemParam.nodeName;
							var value:String = itemParam.firstChild().nodeValue;
							
							if (processVal)
							{
								value = processValue(item, key, value);
							}
							
							Reflect.setField(item, key, value);
						}
					}
					catch(e:Dynamic)
					{
						
					}
				}
				//trace(item);
				// add item to item array
				items.push(item);
			}
		}
		//trace(items);
		return items;
	}
	
	/**
	 * Process the value of a key. The process depends on the key.
	 * to be overriden in children classes
	 * 
	 * @param	item
	 * @param	key
	 * @param	value
	 * @return
	 */
	private function processValue(item:Dynamic, key:String, value:String):String
	{
		return value;
	}
	
}
