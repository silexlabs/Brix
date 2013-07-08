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

typedef DomObject = {
	node:HtmlDom,
	children:Array<DomObject>,
}

/**
 * pass the Dom nodes to the lists or repaeter components
 */
class DomConnector extends ConnectorBase
{
	////////////////////////////////////
	// constants
	////////////////////////////////////
	/**
	 * event to request data change 
	 */
	public static inline var ON_DOM_CHANGED = "domChanged";
	/**
	 * attribute to set on the root element to specify a root node to be displayed
	 * @example		a value of a css class, e.g. "css-class-name-test" 
	 */
	public static inline var ATTR_CONNECTOR_ROOT = "data-connector-root";

	////////////////////////////////////
	// properties
	////////////////////////////////////
	private var latestData:String = "";
	/**
	 * 
	 */
	private var connectorRoot:HtmlDom;

	////////////////////////////////////
	// DisplayObject methods
	////////////////////////////////////
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
	}
	override public function init() 
	{
		// attributes from html
		var rootClassName = rootElement.getAttribute(ATTR_CONNECTOR_ROOT);

		// default value
		if (rootClassName == null || rootClassName == "")
		{
			trace("Warning: no connector root provided, take the body as root");
			connectorRoot = getBrixApplication().body;
		}
		else
		{
			connectorRoot = DomTools.getSingleElement(getBrixApplication().body, rootClassName, true);
		}
		trace("root="+connectorRoot);
		// listen to the Layer class event, in order to loadData when the page opens
		if (rootElement.getAttribute(ConnectorBase.ATTR_AUTO_LOAD) != "false")
		{		
			mapListener(rootElement, Layer.EVENT_TYPE_SHOW_AGAIN, onLayerShow, false);
			mapListener(rootElement, Layer.EVENT_TYPE_SHOW_STOP, onLayerShow, false);

			// start the process
			loadData();
		}
	}
	/**
	 * the layer is being showed
	 */ 
	public function onLayerShow(e:Event)
	{trace("onLayerShow");
		// refresh list data
		loadData();
		latestData = "";
	}
	/**
	 * load the json data
	 */ 
	public function loadData()
	{
		trace("loadData "+connectorRoot+" - "+connectorRoot.innerHTML);
		// small optim
		if (connectorRoot.innerHTML == latestData)
		{
			trace("no new data "+latestData);
			return;
		}
		// keep track of the new data
		latestData = connectorRoot.innerHTML;

		trace("new data "+latestData);

		onDataReceived(domToObj(connectorRoot).children);
	}
	private function domToObj(htmlDom:HtmlDom):DomObject
	{//trace("domToObj on "+htmlDom);
		var children:Array<DomObject> = [];
		for (i in 0...htmlDom.childNodes.length)
		{
			var child = htmlDom.childNodes[i];
			if (child.nodeType == NodeTypes.ELEMENT_NODE)
			{
				children.push(domToObj(child));
			}
		}
		return {node: htmlDom, children: children};
	}
	/**
	 * dispatch an event with the new data
	 */ 
	public function onDataReceived(data:Array<DomObject>)
	{
		trace("dispatch");
		// dispatch a custom event
		dispatch(ConnectorBase.ON_DATA_RECEIVED, data, rootElement, false, none);
	}
}