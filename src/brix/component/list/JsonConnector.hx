/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.list;

import haxe.Http;
import haxe.Timer;

import brix.component.navigation.Layer;

/**
 * load json data, parse it and dispatch an event for the consumers
 */
class JsonConnector extends ConnectorBase
{
	/**
	 * Parse JSON string to object
	 * 
	 * @param	data
	 * @return
	 */
	override public function parseData2Object(data:String):Dynamic
	{
		// escape quotes because the json parser will turn "name":"value with \"quotes\"" into an object with name set to "value with "qotes""
		data = StringTools.replace(data, "\\\"", "'");
		return haxe.Json.parse(data);
	}

}