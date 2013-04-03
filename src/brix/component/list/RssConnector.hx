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
 * load rss data, parse it and dispatch an event for the consumers
 */
class RssConnector extends XmlConnector
{

	/**
	 * The rss root node
	 */
	static inline private var ROOT_NODE:String = "channel.item";
	
	/**
	 * init
	 */ 
	override public function init():Void
	{
		trace("RssConnector loaded");
		dataRootNode = ROOT_NODE;
	}

}