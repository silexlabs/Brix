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
import haxe.Http;
import haxe.Json;
import haxe.Timer;

import brix.component.interaction.Draggable;

import brix.util.DomTools;

import brix.component.navigation.Layer;
import brix.component.ui.DisplayObject;

/**
 * load json data, parse it and dispatch an event for the consumers
 */
class JsonConnector extends ConnectorBase
{
	////////////////////////////////////
	// constants
	////////////////////////////////////
	/**
	 * attribute to set on the root element to specify an url
	 */
	public static inline var ATTR_URL = "data-connector-url";
	/**
	 * path of the object to use as root for the data
	 * @example		a value of "resource.list" 
	 * 				will look for the obect list in the data received: {resource:{list:[{title:a},{title:b}]}}
	 */
	public static inline var ATTR_ROOT = "data-connector-root";
	/**
	 * attribute to set the polling frequency, in ms
	 */
	public static inline var ATTR_POLL_FREQ = "data-connector-poll-frequency";
	public static inline var ATTR_STARTUP_DELAY = "data-connector-startup-delay";
	////////////////////////////////////
	// properties
	////////////////////////////////////
	private var pollingFreq:Null<Int>;
	private var isPolling:Bool=false;
	private var latestData:String = "";

	////////////////////////////////////
	// DisplayObject methods
	////////////////////////////////////
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);

		// listen to the Layer class event, in order to loadData when the page opens
		if (rootElement.getAttribute(ConnectorBase.ATTR_AUTO_LOAD) != "false")
		{
			mapListener(rootElement, Layer.EVENT_TYPE_SHOW_AGAIN, onLayerShow, false);
			mapListener(rootElement, Layer.EVENT_TYPE_SHOW_STOP, onLayerShow, false);
			mapListener(rootElement, Layer.EVENT_TYPE_HIDE_STOP, onLayerHide, false);

			var pollingFreqStr = rootElement.getAttribute(ATTR_POLL_FREQ);
			if (pollingFreqStr != null)
			{
				pollingFreq = Std.parseInt(pollingFreqStr);
			}
			else
			{
				pollingFreq = 0;
			}
			var startupDelay = rootElement.getAttribute(ATTR_STARTUP_DELAY);
			if (startupDelay != null)
			{
				Timer.delay(callback(loadData, null), Std.parseInt(startupDelay));
			}
			else
			{
				loadData();
			}
		}
	}
	/**
	 * start/stop polling
	 */
	public function startPolling(pollingFreq:Int) 
	{
		isPolling = true;
	}
	/**
	 * start/stop polling
	 */
	public function stopPolling() 
	{
		isPolling = false;
	}
	/**
	 * the layer is being showed
	 */ 
	public function onLayerShow(e:Event)
	{
		// refresh list data
		loadData();
		// stat polling
		if (pollingFreq!=null && pollingFreq>0)
		{
			startPolling(pollingFreq);
		}
		latestData = "";
	}
	/**
	 * the layer is being hidden
	 */ 
	public function onLayerHide(e:Event)
	{
		// stop polling
		if (pollingFreq!=null && pollingFreq>0)
		{
			stopPolling();
		}
	}
	/**
	 * load the json data
	 */ 
	public function loadData(?url:Null<String>=null)
	{
		// default value
		if (url == null)
		{
			url = rootElement.getAttribute(ATTR_URL);
			if (url == null || url == "")
			{
				trace("Error: no url provided, aborting http request. I will not load data. Connector "+rootElement.className);
				return;
			}
		}
		//trace("loadData "+url);
		// call the service
		var http = new Http(url);
		http.onError = onError;
		http.onData  = onData;
		http.request(false);
	}
	/**
	 * callback for the http request
	 */ 
	public function onData(data:String)
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
			// escape quotes because the jeson parser will turn "name":"value with \"quotes\"" into anbject with name set to "value with "qotes""
			//data = StringTools.replace(data, "\\\"", "%5C%22");
			//data = StringTools.replace(data, "\\\"", "&quot;");
			//data = StringTools.replace(data, "\\\"", "\\\\\\\"");
			data = StringTools.replace(data, "\\\"", "'");
			objectData = Json.parse(data);
		}
		catch(e:Dynamic)
		{
			trace("Error parsing json string \""+data+"\". Error message: "+e);
		}

		// get data root
		if (objectData!=null)
		{
			var root = rootElement.getAttribute(ATTR_ROOT);
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
	/**
	 * callback for the http request
	 */ 
	public function onError(message:String)
	{
		trace("onError "+message);
	}
	/**
	 * dispatch an event with the new data
	 */ 
	public function onDataReceived(objectData:Dynamic)
	{
		// dispatch a custom event
		dispatch(ConnectorBase.ON_DATA_RECEIVED, objectData, rootElement, false, both);
	}
}