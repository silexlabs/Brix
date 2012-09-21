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
package org.slplayer.component.data;

import js.Dom;
import js.Lib;

import org.slplayer.component.data.IDataProvider;

/**
 * A data consumer should implement to be compliant with data provider components.
 * 
 * note : this is a draft and may be abandonned / revised again in a near future.
 * FIXME: Not compatible with android native browser because of custom events
 * 
 * @author Thomas Fétiveau
 */
interface IDataConsumer
{
	/**
	 * Common callback to all data consumers to receive data.
	 * 
	 * @param	a DataObject instance.
	 */
	function onData(dataObj : DataObject):Void;
	/**
	 * Callback invoked when a new data provider is showing up.
	 */
	public function onNewDataProvider( dataProvider : IDataProvider ):Void;
}

/**
 * Mixin methods for DataConsumer components.
 */
class DataConsumer 
{
	static public var ON_DATA_EVENT_TYPE = "data";
	
	static public var ON_DATA_CONSUMER_EVENT_TYPE = "newDataConsumer";
	
	static public function startConsuming(consumer : IDataConsumer, from : Dynamic)
	{
		from.addEventListener(ON_DATA_EVENT_TYPE, function(e:CustomEvent) { consumer.onData( e.detail ); } , false);
		
		from.addEventListener(DataProvider.ON_DATA_PROVIDER_EVENT_TYPE, function(e:CustomEvent) { consumer.onNewDataProvider( e.detail ); } , false);
		
		var onNewConsumerEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onNewConsumerEvent.initCustomEvent(ON_DATA_CONSUMER_EVENT_TYPE, false, false, consumer);
		
		from.dispatchEvent(onNewConsumerEvent);
	}
}