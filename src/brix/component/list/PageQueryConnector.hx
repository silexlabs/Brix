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
 * load data from the page query string, and dispatch an event for the consumers
 */
class PageQueryConnector extends DisplayObject
{
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
		mapListener(rootElement, Layer.EVENT_TYPE_SHOW_START, onLayerShow, false);
		mapListener(rootElement, Layer.EVENT_TYPE_SHOW_AGAIN, onLayerShow, false);
	}
	/**
	 * the layer is being showed
	 */ 
	public function onLayerShow(e:Event)
	{
		// get the page query object
		var data:Dynamic = {};
		var layerEvent: LayerEventDetail = cast(e).detail;
		if (layerEvent.transitionObserver != null 
			&& layerEvent.transitionObserver.page != null 
			&& layerEvent.transitionObserver.page.query != null)
		{
			data = layerEvent.transitionObserver.page.query;
		}
		trace("onLayerShow "+data);
		// refresh list data
		DomTools.doLater(callback(onData, data));
	}
	/**
	 * callback for the http request
	 */ 
	public function onData(data:Dynamic)
	{
		// dispatch a custom event
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(ConnectorBase.ON_DATA_RECEIVED, false, false, data);
		rootElement.dispatchEvent(event);
	}
}