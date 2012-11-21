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

import brix.component.data.IDataConsumer;

/**
 * The DataObject structure common with DataConsumers.
 */
typedef DataObject = 
{
	src : String,
	srcTitle : Null<String>,
	data : Array<Dynamic>
}

/**
 * A data provider component should implement this interface to be compliant with data consumer components.
 * 
 * note : this is a draft and may be abandonned / revised again in a near future.
 * 
 * @author Thomas Fétiveau
 */
interface IDataProvider
{
	/**
	 * Common callback to all data provider to retreive data.
	 */
	public function getData():Void;
	/**
	 * Callback invoked when a new data consumer is showing up.
	 */
	public function onNewDataConsumer( dataConsumer : IDataConsumer ):Void;
}

/**
 * Mixin methods for DataProvider components.
 * FIXME: Not compatible with android native browser because of custom events
 */
class DataProvider 
{
	static public var ON_DATA_PROVIDER_EVENT_TYPE = "newDataProvider";
	
	static public function startProviding(provider : IDataProvider, target : Dynamic)
	{
		target.addEventListener(DataConsumer.ON_DATA_CONSUMER_EVENT_TYPE, function(e:CustomEvent) { provider.onNewDataConsumer( e.detail ); }, false);
	}
	
	static public function dispatchData(target : HtmlDom, data : DataObject)
	{
		var onDataEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onDataEvent.initCustomEvent(DataConsumer.ON_DATA_EVENT_TYPE, false, false, data);
		
		target.dispatchEvent(onDataEvent);
	}
}