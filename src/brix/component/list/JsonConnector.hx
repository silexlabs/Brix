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
	/**
	 * attribute to set on the root element to specify an url
	 */
	static inline var ATTR_URL = "data-connector-url";
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		trace("new JsonConnector");
		super(rootElement, brixId);

		// listen to the Layer class event, in order to loadData when the page opens
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
	{
		// default value
		if (url == null)
		{
			url = rootElement.getAttribute(ATTR_URL);
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
		trace("onData "+data);

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