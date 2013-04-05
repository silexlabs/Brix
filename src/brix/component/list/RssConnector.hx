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
	//private var processVal:Bool = false;
	private static var getThumbImage:Bool = true;
	
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
					// Build the item object. Only add data for nodes having value.
					try {
						//if (itemParam.firstChild() != null)
						//{
							var key:String = itemParam.nodeName;
							var value:String = itemParam.firstChild().nodeValue;
							
							value = processValue(item, key, value);
							
							Reflect.setField(item, key, value);
						//}
					}
					catch(e:Dynamic)
					{
						
					}
				}
				trace(item);
				// add item to item array
				items.push(item);
			}
		}

		return items;
	}
	
	/**
	 * Process the value of a key. The process depends on the key.
	 * 
	 * @param	key
	 * @param	value
	 * @return
	 */
	private static function processValue(item:Dynamic, key:String, value:String):String
	{
		switch(key)
		{
			case "description":
				// unescape html
				value = StringTools.htmlUnescape(value);
				
				// get thumb
				if (getThumbImage)
				{
					//trace(value);
					//value = getThumb(StringTools.htmlUnescape(value));
					//trace(value);
					Reflect.setField(item, "image", getThumb(StringTools.htmlUnescape(value)));
				}
		}
		
		return value;
	}
	
	/**
	 * Gets the thumb image, i.e. the first image in the html string
	 * 
	 * @param	htmlString
	 */
	static private function getThumb(htmlString:String):String
	{
		// get thumbnail from description
		var imgNodeStartIndex:Int = htmlString.indexOf("<img ");
		var imgNode:String = "";
		var imgUrl:String = "";
		var imgUrlStartIndex:Int = 0;
		
		// if img node name has been found
		if ( imgNodeStartIndex != -1)
		{
			// get img node content
			htmlString = htmlString.substr(imgNodeStartIndex);
			var imgNodeEndIndex:Int = htmlString.indexOf(">") + 1;
			imgNode = htmlString.substr(0, imgNodeEndIndex);
			
			// get image url
			var srcKeyWord:String = 'src=';
			imgUrlStartIndex = imgNode.indexOf(srcKeyWord);
			
			// if srcKeyWord string has been found
			if (imgUrlStartIndex != -1)
			{
				// get the delimitor
				var imgUrlDelimitor:String = imgNode.substr(imgUrlStartIndex + srcKeyWord.length, 1);
				
				// get the image url
				imgUrl = imgNode.substr(imgUrlStartIndex + srcKeyWord.length + 1);
				var imgUrlEndIndex:Int = imgUrl.indexOf(imgUrlDelimitor);
				imgUrl = imgUrl.substr(0, imgUrlEndIndex);
				
				return imgUrl;
			}
		}
		// workaround for silicon sentier feed: if no img field, get the thumb from description only
		else
		{
			imgUrlStartIndex = htmlString.indexOf("<p>http://");
			if ( imgUrlStartIndex != -1)
			{
				// get image url
				var srcKeyWord:String = '<p>';
				imgUrl = htmlString.substr(imgUrlStartIndex + srcKeyWord.length);
				var imgUrlEndIndex:Int = imgUrl.indexOf("</p>");
				imgUrl = imgUrl.substr(0, imgUrlEndIndex);
				
				return imgUrl;
			}
		}
		
		return "";
		
	}
	
}
