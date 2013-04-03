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
 * load json data, parse it and dispatch an event for the consumers
 */
class JsonConnector extends ConnectorBase
{
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
		// parse string to json
		var objectData:Dynamic = null;
		try
		{
			// escape quotes because the json parser will turn "name":"value with \"quotes\"" into an object with name set to "value with "qotes""
			//data = StringTools.replace(data, "\\\"", "%5C%22");
			//data = StringTools.replace(data, "\\\"", "&quot;");
			//data = StringTools.replace(data, "\\\"", "\\\\\\\"");
			data = StringTools.replace(data, "\\\"", "'");
			objectData = haxe.Json.parse(data);
		}
		catch(e:Dynamic)
		{
			trace("Error parsing json string \""+data+"\". Error message: "+e);
		}

		// get data root
		if (objectData!=null)
		{
			var root = rootElement.getAttribute(ConnectorBase.ATTR_ROOT);
			if (root!=null)
			{
				try
				{
					var path = root.split(".");
					for (idx in 0...path.length)
					{
						var objName = path[idx];
						objectData = Reflect.field(objectData, objName);
					}
				}
				catch(e:Dynamic)
				{
					trace("Error while looking for the data root object \""+root+"\" in \""+data+"\". Error message: "+e);
				}
			}
			onDataReceived(objectData);
		}
		else
		{
			// todo: dispatch an error event
			trace("Warning: no data received.");
		}
	}
}