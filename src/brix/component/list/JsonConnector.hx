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
import brix.component.template.TemplateMacros;

/**
 * load json data, parse it and dispatch a 
 */
class JsonConnector extends DisplayObject
{
	////////////////////////////////////
	// constants
	////////////////////////////////////
	/**
	 * attribute to set on the root element to specify an url
	 */
	static inline var ATTR_URL = "data-connector-url";
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
	////////////////////////////////////
	// DisplayObject methods
	////////////////////////////////////
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{trace("new connector");
		super(rootElement, brixId);

		// listen to the Layer class event, in order to loadData when the page opens
		if (rootElement.getAttribute(ATTR_AUTO_LOAD) != "false")
		{trace("listen to layer open");
			var tmpHtmlDom = rootElement;
			while(tmpHtmlDom!=null && !DomTools.hasClass(tmpHtmlDom, "Layer"))
			{
				tmpHtmlDom = tmpHtmlDom.parentNode;
			}
			if (tmpHtmlDom!=null)
			{
				// tmpHtmlDom is the layer node
				mapListener(tmpHtmlDom, Layer.EVENT_TYPE_SHOW_STOP, onLayerShow, false);
			}
			var pollingFreqStr = rootElement.getAttribute(ATTR_POLL_FREQ);
			if (pollingFreqStr != null)
			{
				var pollingFreq = Std.parseInt(pollingFreqStr);
				if (pollingFreq!=null && pollingFreq>0)
				{
					startPolling(pollingFreq);
				}
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
	}
	/**
	 * load the json data
	 */ 
	public function loadData(?url:Null<String>=null)
	{trace("loadData");
		// default value
		if (url == null)
		{
			url = rootElement.getAttribute(ATTR_URL);
			if (url == null)
			{
				throw("Error: no url provided, aborting http request. I will not load data. Connector "+rootElement.className);
			}
		}
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
		var objectData = Json.parse(data);

		// dispatch a custom event
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(Repeater.SET_DATA_REQUEST, false, false, objectData);
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