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
class ConnectorBase extends DisplayObject
{
	////////////////////////////////////
	// constants
	////////////////////////////////////
	/**
	 * event to request data change 
	 */
	public static inline var ON_DATA_RECEIVED = "onDataReceived";
	/**
	 * attribute to allow the component to load data automatically, e.g. when the layer is shown
	 * by default it is true, set it to false in the html to prevent auto data loading
	 */
	public static inline var ATTR_AUTO_LOAD = "data-connector-auto-load";
}