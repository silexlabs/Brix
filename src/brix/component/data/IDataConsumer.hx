/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.data;

import js.Dom;
import js.Lib;

import brix.component.data.IDataProvider;

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