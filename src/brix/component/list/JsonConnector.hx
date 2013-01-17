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
class JsonConnector extends DisplayObject
{
	////////////////////////////////////
	// constants
	////////////////////////////////////
	/**
	 * event to request data change 
	 */
	public static inline var ON_DATA_RECEIVED = "onDataReceived";
	/**
	 * attribute to set on the root element to specify an url
	 */
	static inline var ATTR_URL = "data-connector-url";
	/**
	 * path of the object to use as root for the data
	 * @example		a value of "resource.list" 
	 * 				will look for the obect list in the data received: {resource:{list:[{title:a},{title:b}]}}
	 */
	static inline var ATTR_ROOT = "data-connector-root";
	/**
	 * attribute to set the polling frequency, in ms
	 */
	static inline var ATTR_POLL_FREQ = "data-connector-poll-frequency";
	/**
	 * attribute to allow the component to load data automatically, e.g. when the layer is shown
	 * by default it is true, set it to false in the html to prevent auto data loading
	 */
	static inline var ATTR_AUTO_LOAD = "data-connector-auto-load";
	////////////////////////////////////
	// properties
	////////////////////////////////////
	private var timer:Timer;
	private var pollingFreq:Null<Int>;

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
		if (rootElement.getAttribute(ATTR_AUTO_LOAD) != "false")
		{
			var tmpHtmlDom = rootElement;
			while(tmpHtmlDom!=null && !DomTools.hasClass(tmpHtmlDom, "Layer"))
			{
				tmpHtmlDom = tmpHtmlDom.parentNode;
			}
			if (tmpHtmlDom!=null)
			{
				// tmpHtmlDom is the layer node
				mapListener(tmpHtmlDom, Layer.EVENT_TYPE_SHOW_STOP, onLayerShow, false);
				mapListener(tmpHtmlDom, Layer.EVENT_TYPE_HIDE_STOP, onLayerHide, false);
			}
			var pollingFreqStr = rootElement.getAttribute(ATTR_POLL_FREQ);
			if (pollingFreqStr != null)
			{
				pollingFreq = Std.parseInt(pollingFreqStr);
			}
		}
	}
	/**
	 * start/stop polling
	 */
	public function startPolling(pollingFreq:Int) 
	{
		if (timer!=null)
		{
			timer.run = null;
			timer = null;
		}
		timer = new Timer(pollingFreq);
		timer.run = callback(loadData, null);
	}
	/**
	 * start/stop polling
	 */
	public function stopPolling() 
	{
		if (timer!=null)
		{
			timer.run = null;
			timer = null;
		}
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
			if (url == null)
			{
				throw("Error: no url provided, aborting http request. I will not load data. Connector "+rootElement.className);
			}
		}
		trace("loadData "+url);
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
		var objectData:Dynamic = null;
		try
		{
			objectData = Json.parse(data);
		}
		catch(e:Dynamic)
		{
			trace("Error parsing json string \""+data+"\". Error message: "+e);
		}

		// get data root
		var root = rootElement.getAttribute(ATTR_ROOT);
		if (root!=null && objectData!=null)
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

		// dispatch a custom event
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(ON_DATA_RECEIVED, false, false, objectData);
		rootElement.dispatchEvent(event);
	}
	/**
	 * callback for the http request
	 */ 
	public function onError(message:String)
	{
		trace("onError "+message);
	}
}