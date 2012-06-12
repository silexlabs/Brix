/*
 * This file is part of SLPlayer http://www.silexlabs.org/groups/labs/slplayer/
 * 
 * This project is © 2011-2012 Silex Labs and is released under the GPL License:
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms 
 * of the GNU General Public License (GPL) as published by the Free Software Foundation; 
 * either version 2 of the License, or (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU General Public License for more details.
 * 
 * To read the license please visit http://www.gnu.org/copyleft/gpl.html
 */
package slplayer.data;

import js.Dom;
import js.Lib;

import slplayer.ui.DisplayObject;

import slplayer.data.Common;

/**
 * To be a standard data consumer, a component must implement IDataConsumer. Also, It should use DataConsumer (using slplayer.data.DataConsumer).
 * @author Thomas Fétiveau
 */
class DataConsumer 
{
	static public function startConsuming(consumer : IDataConsumer, from : Dynamic)
	{
		untyped from.addEventListener(Common.ON_DATA_EVENT_TYPE, function(e:Event) {
																						#if flash9
																							var evt:cocktail.core.event.CustomEvent = cast(e);
																						#else
																							var evt = e;
																						#end
																						consumer.onData(e.detail); 
																					} , false);
		
		var onNewConsumerEvent = untyped Lib.document.createEvent("CustomEvent");
		
		untyped onNewConsumerEvent.initCustomEvent(Common.ON_DATA_CONSUMER_EVENT_TYPE, false, false, consumer);
		
		untyped from.dispatchEvent(onNewConsumerEvent);
	}
}

interface IDataConsumer
{
	/**
	 * Common callback to all data consumers to receive data.
	 * @param	e
	 */
	private function onData(dataObj : DataObject):Void;
}